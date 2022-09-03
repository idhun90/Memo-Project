import UIKit

extension UILabel {
    
    func changeSearchedTextColor<T: UILabel>(label: T, search: String, color: UIColor) {
        
        guard let text = label.text else { return }

        let attributeString = NSMutableAttributedString(string: text)
        
        attributeString.addAttribute(.foregroundColor, value: color, range: NSString(string: text).range(of: search.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive))

        self.attributedText = attributeString
    }
}
