import UIKit

import RealmSwift
import Toast

/*
 해결 못한 문제점
 - 텍스트가 많아지면 키보드에 가려지는 문제 (라이브러리 고려했으나 안 예뻐서..)
 - Leading, Trailing Swipe 코드 간소화 필요 (특히 LeadingSwipe)
 - 작성/수정 화면 빈 텍스트 계산 로직 개선 필요
 - 작성/수정 화면에서 값 저장 시점 고민 필요
    : 작성/수정 화면이 viewWillDisappear 시점에 값을 저장하도록 구현했다.
    : 완료 버튼을 누른 상태에서 사용자가 이전 화면으로 돌아가지 않고 앱을 종료하고 다시 실행한다면? 작성된 메모는 저장되지 않을 것 -> 완료 버튼에도 값 저장을 구현하면 중복 저장 되는 문제 발생
    : 데이터 저장 시점 개선 필요
 - 작성/수정 화면에서 제스처로 이전 화면으로 돌아가는 척하면서 다시 돌아오고를 반복한다면 메모가 계속 생성되는 문제
 - 날짜 표기
    : 같은 년도, 같은 월, 오늘 날짜가 아닐 때 '이번 주'요구 형식에 맞게 구현했으나, 주의 시작이 일요일이어서 일요일부터 '그 외 기간'형식으로 나타나짐
    : 주의 시작일을 월요일로 변경 가능 여부 또는 다른 방법으로 구현 필요 체크
 */

enum Section: Int, CaseIterable {
    case firstSection
    case secondSection
    
    var sectionTitle: String {
        switch self {
        case .firstSection:
            return "고정된 메모"
        case .secondSection:
            return "메모"
        }
    }
}

final class MainViewController: BaseViewController {
    
    private let mainView = MainView()
    let repository = RealmMemoRepository()
    
    var allMemos: Results<RealmMemo>! {
        didSet {
            print("allMemos 변화 발생")
        }
    }
    
    var memos: Results<RealmMemo>! {
        didSet {
            print("memos 변화 발생")
        }
    }
    
    var pinMemos: Results<RealmMemo>! {
        didSet {
            print("pinMemos 변화 발생")
        }
    }
    
    var searchedMemos: Results<RealmMemo>!
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showOnceWalkthroughView()
        
        allMemos = repository.fetchRealm()
        pinMemos = repository.fetchRealmPin()
        memos = repository.fetchRealmNoPin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainView.tableView.reloadData()
        setNavigationBarTitle()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: - UI 셋업
    override func configure() {
        self.mainView.tableView.delegate = self
        self.mainView.tableView.dataSource = self
        self.mainView.searchController.searchResultsUpdater = self
        self.mainView.searchController.searchBar.delegate = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.navigationBar.tintColor = .CustomTintColor
        
        self.navigationItem.searchController = mainView.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        setToolBarUI()
    }
    
    func setNavigationBarTitle() {
        self.navigationItem.title = countMemosToTitle(memos: allMemos) + "개의 메모"
    }
    
    func setToolBarUI() {
        var barButtonItems: [UIBarButtonItem] = []
        let writeButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(writeButtonClicked))
        writeButton.tintColor = .CustomTintColor
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        [space, writeButton].forEach {
            barButtonItems.append($0)
        }
        
        self.toolbarItems = barButtonItems
    }
    
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
    
    func countMemosToTitle(memos: Results<RealmMemo>!) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let memos = memos else { return "0" }
        let total = numberFormatter.string(for: memos.count)!
        
        return total
    }
    
    var searchControllerIsActive: Bool {
        return self.mainView.searchController.isActive
    }
    
    func togglePin(section: Int, item: RealmMemo) -> UIContextualAction {
        
        let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            completionHandler(true)
            
            self.repository.fetchRealmChangePin(item: item)
            self.mainView.tableView.reloadData()
            
        }
        
        pin.backgroundColor = .CustomTintColor
        
        if searchControllerIsActive {
            pin.image = item.realmPin ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
        } else {
            pin.image = section == 0 ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
        }
        
        return pin
    }
    
    func deleteCell(section: Int, item: RealmMemo) -> UIContextualAction {
        
        let delete = UIContextualAction(style: .destructive, title: title) { action, view, completionHandler in
            completionHandler(true)
            
            let alert = UIAlertController(title: nil , message: "메모가 삭제됩니다. 이 동작은 취소할 수 없습니다.", preferredStyle: .actionSheet)
            
            let ok = UIAlertAction(title: "메모 삭제", style: .destructive) { _ in
                self.repository.fetchRealmDeleteItem(item: item)
                self.mainView.tableView.reloadData()
                self.setNavigationBarTitle()
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
            
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        
        return delete
    }
    
    func showToast(message: String?, duration: TimeInterval, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = .CustomTintColor
        self.mainView.makeToast(message, duration: duration, position: position, style: style)
    }
    
}
//MARK: - extension UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("편집 시작")
        self.navigationController?.isToolbarHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("취소 버튼 클릭")
        self.navigationController?.isToolbarHidden = false
    }
    
}

//MARK: - extension UISearchResultsUpdating

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchedText = searchController.searchBar.text else { return }
        let searchedItems = repository.fetchRealmFilterSearchByText(text: searchedText.trimmingCharacters(in: .whitespacesAndNewlines))
        searchedMemos = searchedItems
        
        print("searchedMemos 갯수:", searchedMemos.count)
        print(searchControllerIsActive)
        
        mainView.tableView.reloadData()
    }
}

//MARK: - extension UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchControllerIsActive ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MainTableViewHeaderView.reusableIdentifier) as? MainTableViewHeaderView else { return UIView() }
        
        switch section {
        case Section.firstSection.rawValue:
            header.sectionTitle.text = self.searchControllerIsActive ? "\(self.countMemosToTitle(memos: searchedMemos))개 찾음" : Section.firstSection.sectionTitle
        case Section.secondSection.rawValue:
            header.sectionTitle.text = Section.secondSection.sectionTitle
        default:
            return nil
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchControllerIsActive {
            return searchedMemos.count
        } else {
            switch section {
            case Section.firstSection.rawValue:
                return pinMemos.count
            case Section.secondSection.rawValue:
                return memos.count
            default:
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.searchControllerIsActive {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainSearchTableViewCell.reusableIdentifier, for: indexPath) as? MainSearchTableViewCell else { return UITableViewCell() }
            
            cell.setData(data: searchedMemos[indexPath.row])
            
            cell.searchTitleLabel.changeSearchedTextColor(label: cell.searchTitleLabel, search: self.mainView.searchController.searchBar.text!, color: .CustomTintColor)
            cell.searchContentLabel.changeSearchedTextColor(label: cell.searchContentLabel, search: self.mainView.searchController.searchBar.text!, color: .CustomTintColor)
            
            return cell
            
        } else {
            if indexPath.section == Section.firstSection.rawValue {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MainPinTableViewCell.reusableIdentifier, for: indexPath) as? MainPinTableViewCell else { return UITableViewCell() }
                
                cell.setData(data: pinMemos[indexPath.row])
                
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.reusableIdentifier, for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
                
                cell.setData(data: memos[indexPath.row])
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = WriteEditViewController()
        
        if searchControllerIsActive {
            vc.receiveMemo = searchedMemos[indexPath.row]
        } else if indexPath.section == Section.firstSection.rawValue {
            vc.receiveMemo = pinMemos[indexPath.row]
        } else {
            vc.receiveMemo = memos[indexPath.row]
        }
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "메모"
        transition(viewController: vc, transitionStyle: .push)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.section == Section.firstSection.rawValue {
            if searchControllerIsActive { // 검색화면
                if pinMemos.count <= 4 { // 5개 미만 일 때
                    let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                        completionHandler(true)
                        self.repository.fetchRealmChangePin(item: self.searchedMemos[indexPath.row])
                        self.mainView.tableView.reloadData()
                    }
                    
                    pin.backgroundColor = .CustomTintColor
                    pin.image = searchedMemos[indexPath.row].realmPin ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
                    
                    return UISwipeActionsConfiguration(actions: [pin])
                    
                } else if pinMemos.count >= 5 && !searchedMemos[indexPath.row].realmPin { // 고정되지 않은 핀
                    let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                        completionHandler(true)
                        self.showToast(message: "최대 5개의 메모를 고정할 수 있습니다.", duration: 1.0, position: .center)
                    }
                    
                    pin.backgroundColor = .CustomTintColor
                    pin.image = UIImage(systemName: "pin.fill")
                    
                    return UISwipeActionsConfiguration(actions: [pin])
                    
                } else {
                    let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                        completionHandler(true)
                        self.repository.fetchRealmChangePin(item: self.searchedMemos[indexPath.row])
                        self.mainView.tableView.reloadData()
                    }
                    
                    pin.backgroundColor = .CustomTintColor
                    pin.image = UIImage(systemName: "pin.slash.fill")
                    
                    return UISwipeActionsConfiguration(actions: [pin])
                    
                }
            } else { // 메인화면 (고정된 메모)
                let pin = togglePin(section: 0, item: pinMemos[indexPath.row])
                return UISwipeActionsConfiguration(actions: [pin])
            }
        } else if indexPath.section == Section.secondSection.rawValue {
            if pinMemos.count <= 4 {
                let pin = togglePin(section: 1, item: memos[indexPath.row])
                return UISwipeActionsConfiguration(actions: [pin])
            } else {
                let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                    completionHandler(true)
                    self.showToast(message: "최대 5개의 메모를 고정할 수 있습니다.", duration: 1.0, position: .center)
                }
                
                pin.backgroundColor = .CustomTintColor
                pin.image = UIImage(systemName: "pin.fill")
                
                return UISwipeActionsConfiguration(actions: [pin])
            }
        } else {
            print("핀 스와이프 동작에 문제가 발생했습니다.")
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == Section.firstSection.rawValue {
            let delete = searchControllerIsActive ? deleteCell(section: 0, item: searchedMemos[indexPath.row]) : deleteCell(section: 0, item: pinMemos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [delete])
            
        } else if indexPath.section == Section.secondSection.rawValue {
            let delete = deleteCell(section: 1, item: memos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [delete])
            
        } else {
            print("삭제 과정에서 문제가 발생했습니다.")
            return nil
        }
    }
}
