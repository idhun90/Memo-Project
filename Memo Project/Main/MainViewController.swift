import UIKit

import RealmSwift

enum Section: Int, CaseIterable {
    case pinMemos
    case memos
    
    var sectionTitle: String {
        switch self {
        case .pinMemos:
            return "고정된 메모"
        case .memos:
            return "메모"
        }
    }
}

final class MainViewController: BaseViewController {
    
    private let mainView = MainView()
    let repository = RealmMemoRepository()
    
    //모든 메모
    var allMemos: Results<RealmMemo>! {
        didSet {
            print("allMemos 변화 발생")
            print("========================")
        }
    }
//    // 메모
//    var memos: Results<RealmMemo>! {
//        didSet {
//            print("memos 변화 발생")
//            print("========================")
//        }
//    }
//    // 고정된 메모
//    var pinMemos: Results<RealmMemo>! {
//        didSet {
//            print("pinMemos 변화 발생")
//            print("========================")
//        }
//    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: MainViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        print(repository.fetchRealmPath()) // RealmDefaults 경로
        
        showOnceWalkthroughView() // Walkthrough 화면 호출
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(String(describing: MainViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        
        allMemos = repository.fetchRealm()
        mainView.tableView.reloadData()
        setNavigationBarTitle()
    }
    
    //MARK: - UI 셋업
    override func configureUI() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.searchBar.searchResultsUpdater = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false
        navigationController?.navigationBar.tintColor = .ButtonTintColor
        
        navigationItem.searchController = mainView.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        setToolBarUI()
    }
    
    func setNavigationBarTitle() {
        navigationItem.title = countMemosToTitle() + "개의 메모"
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
    
    // 메인 화면 -> 작성 화면
    @objc func writeButtonClicked() {
        let vc = WriteEditViewController()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "메모"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 메소드
    func showOnceWalkthroughView() {
        if !UserDefaults.standard.bool(forKey: WalkthroughtViewToggle.once) {
            let vc = WalkthroughViewController()
            transition(viewController: vc, transitionStyle: .presentOverFullScreen)
        }
    }
    
    func countMemosToTitle() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let allMemos = allMemos else { return "0" }
        let total = numberFormatter.string(for: allMemos.count)!
        
        return total
    }
    
    func calculate(){
        // 오늘 작성한 메모
        
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
        switch section {
        case Section.pinMemos.rawValue:
            return Section.pinMemos.sectionTitle // 핀 데이터 조건에 따른 분기 처리 필요.
        case Section.memos.rawValue:
            return Section.memos.sectionTitle
        default:
            return nil
        }
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

        return section == 0 ? 0 : allMemos.count // 핀데이터 조건에 따른 분기 처리 필요
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 고정 Cell
        if indexPath.section == Section.pinMemos.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainPinTableViewCell.reusableIdentifier, for: indexPath) as? MainPinTableViewCell else { return UITableViewCell() }
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reusableIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            
            cell.setData(data: allMemos[indexPath.row]) //
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WriteEditViewController()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "메모"
        transition(viewController: vc, transitionStyle: .push)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            print(#function)
            completionHandler(true)
            // 데이터 처리
        }
        
        // 조건문 추가 작성 필요, 고정된 상태 또는 일반 상태일 때 아이콘 표시
        pin.backgroundColor = .systemOrange
        pin.image = UIImage(systemName: "pin.fill") // 고정된 상태라면 다른 아이콘 대체
        
        return UISwipeActionsConfiguration(actions: [pin])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: title) { action, view, completionHandler in
            print(#function)
            completionHandler(true)
            
            let alert = UIAlertController(title: nil , message: "메모가 삭제됩니다. 이 동작은 취소할 수 없습니다.", preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "메모 삭제", style: .destructive) { _ in
                self.repository.fetchRealmDeleteItem(item: self.allMemos[indexPath.row])
                self.mainView.tableView.reloadData()
                self.setNavigationBarTitle()
    
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
