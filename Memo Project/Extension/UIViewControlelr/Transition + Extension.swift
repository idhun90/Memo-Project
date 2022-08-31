import UIKit

extension UIViewController {
    
    enum TransitionStyle {
        case present
        case presentOverFullScreen
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
        case .presentOverFullScreen:
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: false)
        case .push:
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func unwind(unwindStyle: UnwindStyle) {
        switch unwindStyle {
        case .dismiss:
            self.dismiss(animated: true)
        case .pop:
            self.navigationController?.popViewController(animated: true)
        }
    }
}
