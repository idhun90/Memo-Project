import UIKit

import SnapKit

final class WalkthroughtView: BaseView {
    
    let noticeView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .CustomBackgroundColorForSubView
        view.layer.cornerRadius = 15
        return view
    }()
    
    let noticeTopLabel: CustomForWalkthroughtViewLabel = {
        let view = CustomForWalkthroughtViewLabel()
        view.text = "환영합니다."
        return view
    }()
    
    let noticeCenterLabel: CustomForWalkthroughtViewLabel = {
        let view = CustomForWalkthroughtViewLabel()
        view.text = "당신만의 메모를 만들어보세요!"
        return view
    }()
    
    let noticeButton: UIButton = {
        let view = UIButton(type: .system)
        view.tintColor = .white
        view.backgroundColor = .CustomTintColor
        view.layer.cornerRadius = 15
        view.titleLabel?.textAlignment = .center
        view.setTitle("시작하기", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [noticeTopLabel, noticeCenterLabel])
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fillEqually
        view.backgroundColor = .clear
        view.spacing = 0
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        self.backgroundColor = .black.withAlphaComponent(0.7)
        [noticeView].forEach {
            self.addSubview($0)
        }
        noticeView.addSubview(stackView)
        [stackView, noticeButton].forEach {
            noticeView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        let spacing = 20
        
        noticeView.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.3)
            $0.width.equalTo(noticeView.snp.height)
            $0.center.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.top.equalTo(noticeView).offset(spacing)
            $0.trailing.equalTo(noticeView.snp.trailing).offset(-spacing)
            $0.bottom.equalTo(noticeButton.snp.top).offset(-spacing-5)
        }
        
        noticeButton.snp.makeConstraints {
            $0.height.equalTo(noticeView.snp.height).multipliedBy(0.18)
            $0.leading.equalTo(noticeView.snp.leading).offset(spacing)
            $0.trailing.equalTo(noticeView.snp.trailing).offset(-spacing)
            $0.bottom.equalTo(noticeView.snp.bottom).offset(-spacing)
        }
    }
}
