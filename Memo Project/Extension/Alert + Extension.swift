import UIKit

extension UIViewController {
    
    func showConfirmToDeleteAlert() {
        let alert = UIAlertController(title: "메모가 삭제됩니다.", message: "이 동작은 취소할 수 없습니다.", preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "메모 삭제", style: .destructive) { _ in
            // 데이터 삭제 구문 추가 필요
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}


