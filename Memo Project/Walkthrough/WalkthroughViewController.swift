import UIKit

final class WalkthroughViewController: BaseViewController {
    
    let mainView = WalkthroughtView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.noticeButton.addTarget(self, action: #selector(dismissWalkthroughViewController), for: .touchUpInside)
    }
    
    @objc func dismissWalkthroughViewController() {
        UserDefaults.standard.set(true, forKey: WalkthroughtViewToggle.once)
        self.unwind(unwindStyle: .dismiss)
    }
}
