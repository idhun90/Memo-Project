import UIKit

import SnapKit

class WriteEditView: BaseView {
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        self.addSubview(textView)
    }
    
    override func setConstraints() {
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

