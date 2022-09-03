import UIKit

extension UIViewController {
    
    func showAlert(title: String, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title , message: nil , preferredStyle: preferredStyle)
        let ok = UIAlertAction(title: "확인", style: .default)
        
        alert.addAction(ok)
        
        self.present(alert, animated: true)
    }
}


