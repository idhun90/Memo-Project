import UIKit

import SnapKit

final class MainTableViewCell: BaseTableViewCell {
    
    let titleLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 17, weight: .bold, color: .black)
        view.text = "테스트sdsafdasfdsfasdf"
        return view
    }()
    
    let dateLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .systemGray)
        view.text = "8888.88.88 오전 88:88"
        return view
    }()
    
    let contentLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .systemGray)
        view.text = "가나다라마바사아자차카타파하sfadsfadsfadsfdsa"
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dateLabel, contentLabel])
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 10
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        [titleLabel, stackView].forEach {
            self.contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        let spacing = 20
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.leading.equalTo(self.contentView).inset(spacing)
            $0.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-spacing)
            $0.height.equalTo(30)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(self.contentView.snp.leading).offset(spacing)
            $0.trailing.equalTo(self.contentView.snp.trailing).offset(-spacing)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            $0.height.equalTo(25)
        }
        
        self.dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
