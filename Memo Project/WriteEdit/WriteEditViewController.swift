import UIKit

import Realm

/*
 
 작성/수정 화면
 작성 화면
 - 진입 시 자동으롤 키보드 띄워줌 (becomeFirstResponder) (구현)
 - 키보드 내려가지 않음
 
 수정 화면
 - 사용자가 텍스트뷰 클릭 시 키보드 띄워줌
 - 편집 상태 시작 시 공유, 완료 버튼 나타남 (구현)
 
 공통 사항
 - 완료 버튼 누르거나, 편집 상태가 끝나거나, 백버튼 액션, 제스처를 통해 이전 화면 이동 시 메모가 저장 됨
 - 어떤 텍스트도 입력되지 않다면 통보 없이 메모 삭제
 - 리턴키를 입력하기 전까지 내용을 제목으로, 나머지 내용은 내용으로 분류 (두 컬럼으로 나눠 저장)
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
    // 작성 화면 진입 시 키보드 띄움 및 공유, 완료 버튼 보이기
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
    }
    
    override func setNavigationBarUI() {
        print(String(describing: WriteEditViewController.self), "->", #function, "-> 호출됨")
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func shareButtonClicked() {
        
    }
    
    @objc func finishButtonClicked() {
        // 데이터 값 저장
        // 완료 버튼 누를 시 '완료'버튼 히든 처리, 및 키보드 내림

        // 저장 전 줄바꿈 여부 체크
        guard let originalText = mainView.textView.text else { return }
        
        if originalText.contains("\n") && !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            // 제목 앞에 여러 줄바꿈이 있다면 해당 줄바꿈 제거 후 첫 번째 요소 타이틀로 선정
            // 애플 메모앱은 테이블뷰 제목 항목에 공백 없는 타이틀이 보이지만, 화면 내용이나 수정 화면으로 보이면 공백도 함께 보여진다. 어떻게 처리한걸까
            let title = originalText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0]
            // 공백을 제거한 상태에서 타이틀을 제외한 substring 타입의 나머지 요소
            let contentSubstring = originalText.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(title.count)
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
    
    // 공유, 완료 버튼
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        print("공백 체크: ", textView.text.isEmpty)
        print("=================================")
        print("스페이스, 줄바꿈 조건 제거 공백 체크:", textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) //스페이스, 공백 제거
        print("=================================")
        print("줄바꿈 체크:", textView.text.contains("\n"))
        print("=================================")
        let titleText = textView.text.components(separatedBy: "\n")[0]
        print("제목: ", titleText)
        let subTextByDrop = textView.text.dropFirst(titleText.count)
        print("내용:", subTextByDrop)
        
        print("첫 줄 공백", textView.text.components(separatedBy: "\n")[0].isEmpty) // -> 내용이 제목이 되야함.
        print("공백, 스페이스 제거:", textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0])
        
        let resulttitle = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")[0]
        print("공백, 스페이스 제거 내용:", textView.text.trimmingCharacters(in: .whitespacesAndNewlines).dropFirst(resulttitle.count))
        
        // 테이블쎌에 보여줄 제목은 공백이 제거된 제목 -> resultTitle
        // 하지만 메모장에 보여줄 때는 공백까지 함께 보여줘야 함. 공백이 포함된 제목
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(#function)
        // 백버튼 또는 제스처로 이전 화면 복귀 시 해당 메소드 호출 확인
        // 이 곳에서 데이터 저장 또는 값 전달이 이뤄져야 한다. (공백이 아닐 경우에만)
        
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // 값 전달을 해야 합니다.
            if textView.text.contains("\n") {
                
            } else {
                
            }
        }
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
