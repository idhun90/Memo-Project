import UIKit

import Realm

/*
 
 요구사항
 작성 화면
 - 진입 시 자동으롤 키보드 띄워줌 (becomeFirstResponder) (구현)
 - 키보드 내려가지 않음 (구현)
 
 수정 화면
 - 사용자가 텍스트뷰 클릭 시 키보드 띄워줌 (구현)
 - 편집 상태 시작 시 공유, 완료 버튼 나타남 (구현)
 
 공통 사항
 - 완료 버튼 누르거나, 편집 상태가 끝나거나, 백버튼 액션, 제스처를 통해 이전 화면 이동 시 메모가 저장 됨 (구현)
 - 어떤 텍스트도 입력되지 않다면 통보 없이 메모 삭제 (구현)
 - 리턴키를 입력하기 전까지 내용을 제목으로, 나머지 내용은 내용으로 분류 (두 컬럼으로 나눠 저장) (구현)
 - 우측 상단 공유 버튼 클릭 시 메모 텍스트가 UIActivityViewController를 통해 공유됨 (구현)
 
 */

class WriteEditViewController: BaseViewController {
    
    let mainView = WriteEditView()
    
    let repository = RealmMemoRepository()
    var receiveMemo: RealmMemo?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: WriteEditViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        loadMemoData()
        autoShowKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(String(describing: WriteEditViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(String(describing: WriteEditViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        mainView.textView.resignFirstResponder()
        saveOrUpdateMemo(text: self.mainView.textView.text)
    }
    
    func loadMemoData() {
        guard let receiveMemo = receiveMemo else {
            print("데이터가 존재하지 않습니다.")
            return
        }
        self.mainView.textView.text = receiveMemo.realmOriginalText
    }
    
    // 작성 화면 진입 시 키보드 자동 띄움 및 공유, 완료 버튼 보이기
    func autoShowKeyboard() {
        if receiveMemo == nil {
            mainView.textView.becomeFirstResponder()
        }
    }
    
    func showRightBarButtonItems() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        let finishButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(finishButtonClicked))
        self.navigationItem.rightBarButtonItems = [finishButton,shareButton]
    }
    
    func showHideShareButton() {
        navigationItem.rightBarButtonItems![1].isEnabled = self.mainView.textView.text.isEmpty ? false : true
    }
    
    override func configure() {
        self.mainView.textView.delegate = self
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func shareButtonClicked() {
        createTextFileToDocumentDirectory(text: self.mainView.textView.text)
        showActivityViewController()
    }
    
    @objc func finishButtonClicked() {
        // 완료 버튼 누를 시 데이터 저장 및 키보드 내림 (saveTextToRelam을 이곳에 작성하면, DidEndEditing과 중복 호출로 두 번 저장됨)
        // 완료 버튼을 누르고 만약 앱을 완전히 종료되면 작성된 메모는 저장되어야 하는가
        self.mainView.textView.resignFirstResponder()
    }
    
    func separateTitle(originalText: String) -> String {
        return originalText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0]
    }
    
    func separateContent(originalText: String, title: String) -> String {
        let substring = originalText.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(title.count).trimmingCharacters(in: .whitespacesAndNewlines)
        let content = String(substring)
        return content
    }
    
    func saveOrUpdateMemo(text: String?) {
        guard let originalText = text else { return }
        // 작성화면 일 때
        if self.receiveMemo == nil {
            
            if originalText.contains("\n") && !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let title = separateTitle(originalText: originalText)
                let content = separateContent(originalText: originalText, title: title)
                let memo = RealmMemo(realmOriginalText: originalText, realmTitle: title, realmContent: content, realmDate: Date())
                repository.fetchRealmAddItem(item: memo)
            } else if !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let title = originalText
                let memo = RealmMemo(realmOriginalText: originalText, realmTitle: title, realmContent: nil, realmDate: Date())
                repository.fetchRealmAddItem(item: memo)
            } else {
                print("빈 텍스트는 저장되지 않습니다.")
            }
            
        } else { // 수정 화면일 때
            if self.receiveMemo?.realmOriginalText == text {
                // 데이터가 같으면 -> 미 저장
                print("같은 메모는 저장 또는 수정되지 않습니다.")
            } else {
                // 데이터가 다르다면 -> 수정
                if originalText.contains("\n") && !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let title = separateTitle(originalText: originalText)
                    let content = separateContent(originalText: originalText, title: title)
                    self.repository.fetchRealmUpdate(objectId: receiveMemo!.objectId, originalText: originalText, title: title, content: content, editedDate: Date())
                    print("수정된 데이터로 저장됩니다.")
                } else if !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let title = originalText
                    self.repository.fetchRealmUpdate(objectId: receiveMemo!.objectId, originalText: originalText, title: title, content: nil, editedDate: Date())
                    print("수정된 데이터로 저장됩니다.")
                } else {
                    self.repository.fetchRealmDeleteItem(item: receiveMemo!)
                    print("수정된 메모가 빈 텍스트여서 삭제됩니다.")
                }
            }
        }
    }
}

extension WriteEditViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print(#function)
        showRightBarButtonItems()
        showHideShareButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        showHideShareButton()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(#function)
    }
}

// 문자열 테스트
// 줄바꿈 기준 문자열 분리
//print(textView.text.split(separator: "\n"))
//print(textView.text.components(separatedBy: "\n")) // 여러 엔터 값을 가지면 split 보다는 comonents로 " " 표기해주는 것이 좋지 않을까

// 분리된 문자열 타이틀, 내용 분리
//let titleText = textView.text.components(separatedBy: "\n")[0] \n 기준 분리 시 첫 번째 요소
//print("제목:", titleText)
//let subtitleText = textView.text.components(separatedBy: "\n").last \n 기준 분리 시 마지막 요소, 내용 중에 줄 바꿈이 발생하면 놓치는 부분 발생 적합하지 않음
//print("제목을 뺀 나머지:", subtitleText)
//let subTextByDrop = textView.text.dropFirst(titleText.count) 분리된 첫 번째 요소를 제거하고 나머지 요소 보여줌
//print("내용:", subTextByDrop)
//let subTextByremove = textView.text.removeFirst() // 텍스트뷰에서 하나 하나 입력할 때마다 확인을 하려고 했는데 원본을 계속 수정에서 패스
//print(subTextByremove)
