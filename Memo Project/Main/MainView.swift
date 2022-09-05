import UIKit

import SnapKit

final class MainView: BaseView {
    
    let searchController: UISearchController = {
       let view = UISearchController(searchResultsController: nil)
        view.searchBar.placeholder = "검색"
        view.searchBar.setValue("취소", forKey: "cancelButtonText")
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(MainPinTableViewCell.self, forCellReuseIdentifier: MainPinTableViewCell.reusableIdentifier)
        view.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.reusableIdentifier)
        view.register(MainSearchTableViewCell.self, forCellReuseIdentifier: MainSearchTableViewCell.reusableIdentifier)
        view.backgroundColor = .CustomBackgroundColorForView
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure() {
        self.addSubview(tableView)
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
