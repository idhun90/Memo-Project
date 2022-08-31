import UIKit

import SnapKit

final class MainView: BaseView {
    
    let searchBar: UISearchController = {
       let view = UISearchController(searchResultsController: nil)
        view.searchBar.placeholder = "검색"
        view.searchBar.setValue("취소", forKey: "cancelButtonText")
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.reusableIdentifier)
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureUI() {
        self.addSubview(tableView)
        self.backgroundColor = .red
        
    }
    
    override func setConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
