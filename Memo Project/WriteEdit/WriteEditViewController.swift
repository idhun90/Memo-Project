import Foundation
import UIKit

class WriteEditViewController: BaseViewController {
    
    let mainView = WriteEditView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        
    }
    
    override func setNavigationBarUI() {
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonClicked))
        
        let okButton = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(okButtonClicked))
        
        navigationItem.rightBarButtonItems = [okButton,shareButton]
    }
    
    @objc func shareButtonClicked() {
        
    }
    
    @objc func okButtonClicked() {
        
        // 데이터 값 저장
        // 기본 메모앱은 현재 화면 그대로이다.
        
    }
}
