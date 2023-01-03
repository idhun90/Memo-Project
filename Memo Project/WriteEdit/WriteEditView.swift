import UIKit

import SnapKit

class WriteEditView: BaseView {
    
    let textView: UITextView = {
        let view = UITextView()
        let spacing: CGFloat = 20
        view.backgroundColor = .CustomBackgroundColorForView
        view.font = .systemFont(ofSize: 17)
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: 0, right: spacing)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        self.addSubview(textView)
        backgroundColor = .CustomBackgroundColorForView
    }
    
    override func setConstraints() {
        textView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
}

