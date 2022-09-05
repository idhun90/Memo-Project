import UIKit

import SnapKit

final class MainTableViewHeaderView: BaseTableViewHeaderView {
    
    let sectionTitle: CustomForCellLabel = {
        let view = CustomForCellLabel()
        view.configure(FontSize: 22, weight: .bold, color: .CustomTitleLabelColor)
        return view
    }()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func configure() {
        self.backgroundColor = .clear
        self.contentView.addSubview(sectionTitle)
        
    }
    override func setConstraints() {
        sectionTitle.snp.makeConstraints {
            $0.edges.equalTo(self.contentView)
        }
        
    }
}
