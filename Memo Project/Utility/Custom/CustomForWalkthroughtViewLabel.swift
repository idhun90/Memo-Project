import UIKit

class CustomForWalkthroughtViewLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.font = .systemFont(ofSize: 22, weight: .bold)
        self.numberOfLines = 2
        self.textAlignment = .center
    }
}
