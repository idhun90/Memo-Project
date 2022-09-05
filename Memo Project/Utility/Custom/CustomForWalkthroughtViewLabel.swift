import UIKit

final class CustomForWalkthroughtViewLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        self.font = .systemFont(ofSize: 22, weight: .bold)
        self.numberOfLines = 2
        self.textAlignment = .center
    }
}
