import UIKit

import Realm

class WriteEditViewController: BaseViewController {
    
    let mainView = WriteEditView()
    
    let repository = RealmMemoRepository()
    var receiveMemo: RealmMemo?
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemoData()
        autoShowKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                print("빈 메모는 저장되지 않습니다.")
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
                    print("수정된 메모로 저장됩니다.")
                } else if !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let title = originalText
                    self.repository.fetchRealmUpdate(objectId: receiveMemo!.objectId, originalText: originalText, title: title, content: nil, editedDate: Date())
                    print("수정된 메모로 저장됩니다.")
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
        showRightBarButtonItems()
        showHideShareButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        showHideShareButton()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
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
