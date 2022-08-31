import UIKit

extension UIViewController {
    
    enum TransitionStyle {
        case present
        case push
    }
    
    enum UnwindStyle {
        case dismiss
        case pop
    }
    
    func transition<T: UIViewController>(viewController: T, transitionStyle: TransitionStyle) {
        switch transitionStyle {
        case .present:
            self.present(viewController, animated: true)
        case .push:
            let nav = UINavigationController(rootViewController: viewController)
            self.navigationController?.pushViewController(nav, animated: true)
        }
    }
    
    func unwind<T: UIViewController>(viewController: T, unwindStyle: UnwindStyle) {
        switch unwindStyle {
        case .dismiss:
            self.dismiss(animated: true)
        case .pop:
            self.navigationController?.popViewController(animated: true)
        }
    }
}
