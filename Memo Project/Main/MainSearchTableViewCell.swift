import UIKit

import SnapKit

final class MainSearchTableViewCell: BaseTableViewCell {
    
    let searchTitleLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 17, weight: .bold, color: .black)
        return view
    }()
    
    let searchDateLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .systemGray)
        return view
    }()
    
    let searchContentLabel: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configureUI(FontSize: 15, weight: .regular, color: .systemGray)
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
    
    override func configureUI() {
        [searchTitleLabel, searchStackView].forEach {
            self.contentView.addSubview($0)
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
        super.prepareForReuse() // 깜빡하고 작성 안 했더니 검색 화면에서 핀 고정/해제 할 때마다 들쑥날쑥..
        self.searchContentLabel.textColor = .black
        self.searchTitleLabel.textColor = .black
    }
}

