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
 - 날짜 포멧 형태
   : 오늘 작성한 메모는 오전 08:19 형태 표기
   : 이번 주 작성한 메모는 일요일, 화요일 형태 표기
   : 그 외 기간 작성된 메모는 2021.10.12 오후 02:22 형태 표기
 */

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
        
        mainView.tableView.reloadData()
        setNavigationBarTitle()
        
        print("allMemos 갯수:", allMemos.count)
        print("pinMemos 갯수:", pinMemos.count)
        print("memos 갯수:", memos.count)
                print("================================================")
                print(allMemos!)
                print("================================================")
                print(pinMemos!)
                print("================================================")
                print(memos!)
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
            completionHandler(true)
            
            self.repository.fetchRealmChangePin(item: item)
            self.mainView.tableView.reloadData()
        }
        
        pin.backgroundColor = .systemOrange
        pin.image = section == 0 ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
        
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MainPinTableViewCell.reusableIdentifier, for: indexPath) as? MainPinTableViewCell else { return UITableViewCell() }
            
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
        print(#function)
        
        if indexPath.section == Section.pinMemos.rawValue {
            
            let pin = changePin(section: 0, item: pinMemos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [pin])
            
        } else if indexPath.section == Section.memos.rawValue {
            
            if pinMemos.count <= 4 {
                
                let pin = changePin(section: 1, item: memos[indexPath.row])
                return UISwipeActionsConfiguration(actions: [pin])
                
            } else {
                
                let pin = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
                    completionHandler(true)
                }
                
                pin.backgroundColor = .systemOrange
                pin.image = UIImage(systemName: "pin.fill")
                
                var style = ToastStyle()
                style.backgroundColor = .ButtonTintColor
                self.mainView.makeToast("최대 5개의 메모를 고정할 수 있습니다.", duration: 1.0, position: .center, style: style)
                
                return UISwipeActionsConfiguration(actions: [pin])
            }
            
        } else {
            print("핀 스와이프 동작에 문제가 발생했습니다.")
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == Section.pinMemos.rawValue {
            let delete = deleteCell(section: 0, item: pinMemos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [delete])
        } else if indexPath.section == Section.memos.rawValue {
            let delete = deleteCell(section: 1, item: memos[indexPath.row])
            return UISwipeActionsConfiguration(actions: [delete])
        } else {
            print("삭제 과정에서 문제가 발생했습니다.")
            return nil
        }
    }
}
