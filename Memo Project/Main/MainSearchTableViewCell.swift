import UIKit

import SnapKit

final class MainSearchTableViewCell: BaseTableViewCell {
    
    let searchTitleLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configure(FontSize: 17, weight: .bold, color: .CustomTitleLabelColor)
        return view
    }()
    
    let searchDateLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configure(FontSize: 15, weight: .regular, color: .CustomContentDateLabelColor)
        return view
    }()
    
    let searchContentLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configure(FontSize: 15, weight: .regular, color: .CustomContentDateLabelColor)
        return view
    }()
    
    lazy var searchStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [searchDateLabel, searchContentLabel])
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
        searchTitleLabel.text = data.realmTitle
        searchDateLabel.text = calculateDateFormat(date: data.realmDate)
        searchContentLabel.text = data.realmContent
    }
    
    override func configure() {
        [searchTitleLabel, searchStackView].forEach {
            self.contentView.addSubview($0)
            self.backgroundColor = .CustomBackgroundColorForSubView
        }
    }
    
    override func setConstraints() {
        let spacing = 20
        
        searchTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top).offset(5)
            $0.leading.equalTo(self.contentView).inset(spacing)
            $0.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-spacing)
            $0.height.equalTo(30)
        }
        
        searchStackView.snp.makeConstraints {
            $0.top.equalTo(searchTitleLabel.snp.bottom)
            $0.leading.equalTo(self.contentView.snp.leading).offset(spacing)
            $0.trailing.lessThanOrEqualTo(self.contentView.snp.trailing).offset(-spacing)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-5)
            $0.height.equalTo(25)
        }
        
        self.searchDateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.searchContentLabel.textColor = .CustomContentDateLabelColor
        self.searchTitleLabel.textColor = .CustomTitleLabelColor
    }
}

