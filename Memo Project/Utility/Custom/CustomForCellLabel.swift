import UIKit

final class CustomForCellLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(FontSize: CGFloat, weight: UIFont.Weight, color: UIColor) {
        self.font = .systemFont(ofSize: FontSize, weight: weight)
        self.textColor = color
        self.numberOfLines = 1
    }
}
