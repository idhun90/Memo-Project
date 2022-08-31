import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setNavigationBarUI()
        setConstraints()
    }
    
    func configureUI() { }
    func setNavigationBarUI() { }
    func setConstraints() { }
}
