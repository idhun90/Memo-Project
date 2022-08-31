import UIKit

import RealmSwift

final class MainViewController: BaseViewController {
    
    private let mainView = MainView()
    
    let repository = RealmMemoRepository()
    
    var allMemos: Results<RealmMemo>! {
        didSet {
            print("allMemos 변화 발생")
            print("========================")
        }
    }
    
    var memos: Results<RealmMemo>! {
        didSet {
            print("memos 변화 발생")
            print("========================")
        }
    }
    
    var pinMemos: Results<RealmMemo>! {
        didSet {
            print("pinMemos 변화 발생")
            print("========================")
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, "호출됨")
        print("========================")
        
        showOnceWalkthroughView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function, "호출됨")
        print("========================")
    }
    
    override func configureUI() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.searchBar.searchResultsUpdater = self
        
        setToolBarUI()
    }
    
    override func setNavigationBarUI() {
        navigationItem.title = "개의 메모"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.tintColor = .ButtonTintColor
        
        navigationItem.searchController = mainView.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setToolBarUI() {
        
        var barButtonItems: [UIBarButtonItem] = []
        
        let writeButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(writeButtonClicked))
        writeButton.tintColor = .ButtonTintColor
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        [space, writeButton].forEach {
            barButtonItems.append($0)
        }
        
        self.toolbarItems = barButtonItems
    }
    
    @objc func writeButtonClicked() {
        let vc = WriteEditViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showOnceWalkthroughView() {
        if !UserDefaults.standard.bool(forKey: WalkthroughtViewToggle.once) {
            let vc = WalkthroughViewController()
            transition(viewController: vc, transitionStyle: .presentOverFullScreen)
        }
    }
}

//MARK: - extension UISearchResultsUpdating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("입력된 단어: \(searchController.searchBar.text!)")
    }
}

//MARK: - extension UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "고정" : "메모"
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //        let headerView: UIView = {
    //           let view = UIView()
    //            view.backgroundColor = .red
    //            return view
    //        }()
    //
    //        let headerTitle: UILabel = {
    //            let view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
    //            view.text = "테스트"
    //            view.textColor = .black
    //            view.font = .systemFont(ofSize: 18, weight: .bold)
    //            return view
    //        }()
    //        headerView.addSubview(headerTitle)
    //
    //        return headerView
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 50
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reusableIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            print(#function)
            completionHandler(true)
            // 데이터 처리
        }
        
        pin.backgroundColor = .systemOrange
        pin.image = UIImage(systemName: "pin.fill") // 고정된 상태라면 다른 아이콘 대체
        
        return UISwipeActionsConfiguration(actions: [pin])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: title) { action, view, completionHandler in
            print(#function)
            completionHandler(true)
            self.showConfirmToDeleteAlert()
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
