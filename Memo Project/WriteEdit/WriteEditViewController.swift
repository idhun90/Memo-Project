import UIKit

import Realm

/*
 
 요구사항
 작성 화면
 - 진입 시 자동으롤 키보드 띄워줌 (becomeFirstResponder) (구현)
 - 키보드 내려가지 않음
 
 수정 화면
 - 사용자가 텍스트뷰 클릭 시 키보드 띄워줌
 - 편집 상태 시작 시 공유, 완료 버튼 나타남 (구현)
 
 공통 사항
 - 완료 버튼 누르거나, 편집 상태가 끝나거나, 백버튼 액션, 제스처를 통해 이전 화면 이동 시 메모가 저장 됨
 - 어떤 텍스트도 입력되지 않다면 통보 없이 메모 삭제
 - 리턴키를 입력하기 전까지 내용을 제목으로, 나머지 내용은 내용으로 분류 (두 컬럼으로 나눠 저장) (구현)
 - 우측 상단 공유 버튼 클릭 시 메모 텍스트가 UIActivityViewController를 통해 공유됨
 
 */

class WriteEditViewController: BaseViewController {
    
    let mainView = WriteEditView()
    
    let repository = RealmMemoRepository()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: WriteEditViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
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
        saveTextToRealm(text: mainView.textView.text)
        
    }
    
    // 작성 화면 진입 시 키보드 자동 띄움 및 공유, 완료 버튼 보이기
    func autoShowKeyboard() {
        if mainView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mainView.textView.becomeFirstResponder()
            showRightBarButtonItems()
        }
    }
    
    func showRightBarButtonItems() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        
        let finishButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(finishButtonClicked))
        
        navigationItem.rightBarButtonItems = [finishButton,shareButton]
    }
    
    override func configureUI() {
        mainView.textView.delegate = self
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func shareButtonClicked() {
        
    }
    
    @objc func finishButtonClicked() {
        // 데이터 값 저장
        // 완료 버튼 누를 시 데이터 저장 및 키보드 내림 (saveTextToRelam을 이곳에 작성하면, DidEndEditing과 중복 호출로 두 번 저장됨)
        mainView.textView.resignFirstResponder()
    }
    
    func saveTextToRealm(text: String!) {
        
        // 저장 전 줄바꿈 여부 체크
        guard let originalText = text else { return }
        
        if originalText.contains("\n") && !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            // 제목 앞에 여러 공백 줄바꿈이 있다면 해당 줄바꿈 제거 후 첫 번째 문자열 요소를 타이틀로 선정
            // 애플 메모앱은 공백으로 줄바꿈을 주고 텍스트 준 상태에서도 테이블뷰 제목 항목은 공백이 제거된 타이틀이 보이면서, 수정 화면에서는 공백 줄바꿈이 여전히 함께 보여진다. 어떻게 처리한걸까
            
            let title = originalText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0]
            let contentSubstring = originalText.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(title.count).trimmingCharacters(in: .whitespacesAndNewlines)
            let content = String(contentSubstring)
            let memo = RealmMemo(realmTitle: title, realmContent: content, realmCreatedDate: Date(), realmEditedDate: nil)
            repository.fetchRealmAddItem(item: memo)
            
        } else if !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            let title = originalText
            let memo = RealmMemo(realmTitle: title, realmContent: nil, realmCreatedDate: Date(), realmEditedDate: nil)
            repository.fetchRealmAddItem(item: memo)
            
        } else {
            print("저장할 텍스트 내용이 없습니다.")
        }
        
    }
}

extension WriteEditViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print(#function)
        showRightBarButtonItems()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        print("공백 체크: ", textView.text.isEmpty)
        print("=================================")
        print("스페이스, 줄바꿈 조건 제거 공백 체크:", textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) //스페이스, 공백 제거
        print("=================================")
        print("줄바꿈 체크:", textView.text.contains("\n"))
        print("=================================")
        let title = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0]
        let content = String(textView.text.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(title.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        print("제목:", title)
        print("내용:", content)
        
        // 테이블쎌에 보여줄 제목은 공백이 제거된 제목 -> resultTitle
        // 하지만 메모장에 보여줄 때는 공백까지 함께 보여줘야 함. 공백이 포함된 제목
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(#function)
        // 백버튼 또는 제스처로 이전 화면 복귀 시 해당 메소드 호출 확인
        // 이 곳에서 데이터 저장 또는 값 전달이 이뤄져야 한다. (공백이 아닐 경우에만)
        
        //        textView.resignFirstResponder()
        //        saveTextToRealm(text: textView.text)
        
    }
}

// 문자열 테스트
// 줄바꿈 기준 문자열 분리
//print(textView.text.split(separator: "\n"))
//print(textView.text.components(separatedBy: "\n")) // 여러 엔터 값을 가지면 split 보다는 comonents로 " " 표기해주는 것이 좋지 않을까

// 분리된 문자열 타이틀, 내용 분리
//let titleText = textView.text.components(separatedBy: "\n")[0] \n 기준 분리 시 첫 번째 요소
//print("제목:", titleText)
//let subtitleText = textView.text.components(separatedBy: "\n").last \n 기준 분리 시 마지막 요소, 내용 중에 줄 바꿈이 발생하면 적합하지 않음
//print("제목을 뺀 나머지:", subtitleText)
//let subTextByDrop = textView.text.dropFirst(titleText.count) 분리된 첫 번째 요소를 제거하고 나머지 요소 보여줌
//print("내용:", subTextByDrop)
//let subTextByremove = textView.text.removeFirst() // 텍스트뷰에서 하나 하나 입력할 때마다 확인을 하려고 했는데 원본을 계속 수정에서 일단 패스
//print(subTextByremove)
