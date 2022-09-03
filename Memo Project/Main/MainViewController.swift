import UIKit

import RealmSwift
import Toast

/*
 요구 사항
 - 최초 앱을 실행할 경우 팝업 화면을 띄워줍니다. 최초 1회만 뜹니다. (구현)
 - 총 작성된 메모 갯수가 네비게이션 타이틀에 보여지며, 1000개가 넘을 경우, 3자리마다 콤마 표기 (구현)
 - 최신 순으로 정렬 (구현)
 - 메모 최대 5개 최신순으로 정렬 고정, 5개가 초과일 경우 토스트로 공지 (구현)
 - 고정된 메모는 별도 섹션 관리 및 고정된 메모가 없다면 세션을 표기하지 않음. (구현) (세션 타이틀은 남아있음..)
 - Leading Swipe 고정 또는 해제 (구현)
 - Trailing Swipe 메모 삭제 구현 및 삭제 전 삭제 여부 확인 (구현)
 - 날짜 포멧 형태 (구현)
 : 오늘 작성한 메모는 오전 08:19 형태 표기 (구현)
 : 이번 주 작성한 메모는 일요일, 화요일 형태 표기 (구현)
 : 그 외 기간 작성된 메모는 2021.10.12 오후 02:22 형태 표기 (구현)
 - 섹션 헤더 (구현, 큰 섹션은 아직..)
 
 검색 기능
 - UISearchController 통해 제목 및 내용 실시간 검색 구현 (구현)
 : 입력하는 텍스트가 변경될 때 마다 검색이 이루어진다. (구현)
 : 검색 결과를 스크롤하거나 키보드의 검색 버튼을 누르면 키보드가 내려간다. (구현)
 : 검색 결과 갯수를 섹션에 보여준다.(구현, 큰 섹션은 아직..)
 - 검색한 키워드의 해당 단어 텍스트 컬러 변경 (구현)
 - 메모 고정, 삭제 기능도 검색 화면에서 구현 (구현)
 - 셀을 클릭하면 메모 수정 화면으로 전환 -> 그리고 수정 화면에서 백버튼 클릭 시 검색화면으로 다시 돌아옴.
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
    
    var searchedMemos: Results<RealmMemo>!
    
    var searchControllerIsActive: Bool {
        
        // return self.mainView.searchController.isActive && !self.mainView.searchController.searchBar.text!.isEmpty // 기존 Cell이 다 보임. 검색어 입력 전까지 false 상태이기 때문에 (기록용)
        return self.mainView.searchController.isActive // 검색 화면 눌렀을 때 Cell이 하나도 안 보여주게 구현하고 싶음.
        
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(String(describing: MainViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        print(repository.fetchRealmPath()) // RealmDefaults 경로
        
        showOnceWalkthroughView()
        
        allMemos = repository.fetchRealm()
        pinMemos = repository.fetchRealmPin()
        memos = repository.fetchRealmNoPin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(String(describing: MainViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        
        //        allMemos = repository.fetchRealm()
        //        pinMemos = repository.fetchRealmPin()
        //        memos = repository.fetchRealmNoPin()
        
        mainView.tableView.reloadData()
        setNavigationBarTitle()
        
        print("allMemos 갯수:", allMemos.count)
        print("pinMemos 갯수:", pinMemos.count)
        print("memos 갯수:", memos.count)
        print(self.mainView.searchController.isActive)
        print("================================================")
        
        
        // 작성 화면에서 제스처 또는 백버튼으로 화면 전환 과정에서 viewWillAppear 선 호출 -> textViewDidEndEditing이 호출된다.
        // 따라서 이 곳에서 데이터 또는 tableView 리로딩은 반영이 안 되는 문제가 있었다.
        // 1. 화면 전환이 완전히 종료된 시점 viewDidAppear에서 데이터를 반영하는 것을 선택함. -> 반응이 느리다.
        // 2. 작성 화면 viewWillDisAppear에 데이터를 Realm 저장 및 키보드 내리기 기능 추가 -> 여전히 화면 전환 왔다갔다할 때 계속 메모가 추가되는 것을 확인
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(String(describing: MainViewController.self), "->", #function, "-> 호출됨")
        print("================================================")
        // 리로딩 여기서 테스트하기. 제스처 유지한채로 왔다갔다하면 중복 현상 발생
    }
    
    //MARK: - UI 셋업
    override func configureUI() {
        print(#function)
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
    
    // 메인 화면 -> 작성 화면
    @objc func writeButtonClicked() {
        let vc = WriteEditViewController()
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "메모"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 메소드
    // 최초 1회 Walkthrough 화면 표시
    func showOnceWalkthroughView() {
        if !UserDefaults.standard.bool(forKey: WalkthroughtViewToggle.once) {
            let vc = WalkthroughViewController()
            transition(viewController: vc, transitionStyle: .presentOverFullScreen)
        }
    }
    // 메인&검색 타이틀에 들어갈 메모 갯수
    func countMemosToTitle(memos: Results<RealmMemo>!) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let memos = memos else { return "0" }
        let total = numberFormatter.string(for: memos.count)!
        
        return total
    }
    
    // 핀 고정, 해제 메소드
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
    
    // 테이블뷰 셀 삭제 메소드
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
    
}
//MARK: - extension UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {

        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            //self.mainView.searchController.becomeFirstResponder()
            print("편집 시작")
            self.navigationController?.isToolbarHidden = true
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            searchBar.resignFirstResponder()
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case Section.firstSection.rawValue:
            return self.searchControllerIsActive ? "\(self.countMemosToTitle(memos: searchedMemos))개 찾음" : Section.firstSection.sectionTitle
        case Section.secondSection.rawValue:
            return Section.secondSection.sectionTitle
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchControllerIsActive {
            return searchedMemos.count
            
        } else {
            switch section {
            case Section.firstSection.rawValue:
                return pinMemos.count
                //return self.mainView.searchController.becomeFirstResponder() ? 2 : pinMemos.count
            case Section.secondSection.rawValue:
                return memos.count
            default:
                return 0
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 하나의 cell 파일로 작업했을 때 재사용 문제가 발생했었다.(예:배경색이 달랐을 때)
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
        print(#function)
        
        if indexPath.section == Section.firstSection.rawValue {
            let pin = searchControllerIsActive ? togglePin(section: 0, item: searchedMemos[indexPath.row]) : togglePin(section: 0, item: pinMemos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [pin])
            
        } else if indexPath.section == Section.secondSection.rawValue {
            if pinMemos.count <= 4 {
                let pin = togglePin(section: 1, item: memos[indexPath.row])
                return UISwipeActionsConfiguration(actions: [pin])
                
            } else {
                let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                    completionHandler(true)
                }
                
                pin.backgroundColor = .CustomTintColor
                pin.image = UIImage(systemName: "pin.fill")
                
                var style = ToastStyle()
                style.backgroundColor = .CustomTintColor
                self.mainView.makeToast("최대 5개의 메모를 고정할 수 있습니다.", duration: 1.0, position: .center, style: style)
                
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
