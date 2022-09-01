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
    // 작성 화면 진입 시 키보드 자동 띄움
    func autoShowKeyboard() {
        if self.mainView.textView.text.isEmpty {
            mainView.textView.becomeFirstResponder()
        }
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
        
        guard let title = mainView.textView.text else {
            print("텍스트뷰에 작성된 내용이 없습니다.")
            return
        }
        // 엔터키를 치지 않았다면
        let memo = RealmMemo(realmTitle: title, realmContent: nil, realmCreatedDate: Date(), realmEditedDate: nil)
        repository.fetchRealmAddItem(item: memo)
        
        
    }
}

extension WriteEditViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print(#function)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(#function)
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        
        let finishButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(finishButtonClicked))
        
        if textView.text.isEmpty {
            navigationItem.rightBarButtonItems = nil
        } else {
            navigationItem.rightBarButtonItems = [finishButton,shareButton]
        }
    }
}
