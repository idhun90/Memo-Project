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
    // 메모
    var memos: Results<RealmMemo>! {
        didSet {
            print("memos 변화 발생")
            print("========================")
        }
    }
    // 고정된 메모
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
        pinMemos = repository.fetchRealmPin()
        memos = repository.fetchRealmNoPin()
        
        print(allMemos)
        print(pinMemos)
        print(memos)
        
        
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
    // 네비게이션 타이틀 갱신
    func countMemosToTitle() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let allMemos = allMemos else { return "0" }
        let total = numberFormatter.string(for: allMemos.count)!
        
        return total
    }
    
    // 핀 고정, 해제 메소드
    func changePin(section: Int, item: RealmMemo) -> UIContextualAction {
        
        let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            print(#function)
            completionHandler(true)
            
            self.repository.fetchRealmChangePin(item: item)
            self.mainView.tableView.reloadData()
        }
        
        pin.backgroundColor = .systemOrange
        pin.image = section == 0 ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
        
        return pin
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case Section.pinMemos.rawValue:
            return pinMemos.count
        case Section.memos.rawValue:
            return memos.count
        default:
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 고정 Cell
        if indexPath.section == Section.pinMemos.rawValue {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainPinTableViewCell.reusableIdentifier, for: indexPath) as? MainPinTableViewCell else { return UITableViewCell() }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reusableIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            
            cell.setData(data: pinMemos[indexPath.row])
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reusableIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            
            cell.setData(data: memos[indexPath.row])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = WriteEditViewController()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "메모"
        transition(viewController: vc, transitionStyle: .push)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == Section.pinMemos.rawValue {
            let pin = changePin(section: 0, item: pinMemos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [pin])
        } else if indexPath.section == Section.memos.rawValue {
            let pin = changePin(section: 1, item: memos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [pin])
        } else {
            print("핀 스와이프 동작에 문제가 발생했습니다.")
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        print(indexPath)
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
