import UIKit

import SnapKit

final class MainPinTableViewCell: BaseTableViewCell {
    
    let pinTitleLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 17, weight: .bold, color: .CustomTitleLabelColor)
        return view
    }()
    
    let pinDateLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .CustomContentDateLabelColor)
        return view
    }()
    
    let pinContentLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .CustomContentDateLabelColor)
        return view
    }()
    
    lazy var pinStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [pinDateLabel, pinContentLabel])
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
    
    func setData(data: RealmMemo) {
        pinTitleLabel.text = data.realmTitle
        pinDateLabel.text = calculateDateFormat(date: data.realmDate)
        pinContentLabel.text = data.realmContent
    }
    
    override func configureUI() {
        [pinTitleLabel, pinStackView].forEach {
            self.contentView.addSubview($0)
            self.backgroundColor = .CustomBackgroundColorForCell
        }
    }
    
    override func setConstraints() {
        let spacing = 20
        
        pinTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.leading.equalTo(self.contentView).inset(spacing)
            $0.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-spacing)
            $0.height.equalTo(30)
        }
        
        pinStackView.snp.makeConstraints {
            $0.top.equalTo(pinTitleLabel.snp.bottom)
            $0.leading.equalTo(self.contentView.snp.leading).offset(spacing)
            $0.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-spacing)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            $0.height.equalTo(25)
        }
        
        self.pinDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
