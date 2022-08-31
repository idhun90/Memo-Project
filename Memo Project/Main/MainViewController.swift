import UIKit

final class MainViewController: BaseViewController {
    
    private let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarUI()
    }
    
    override func configureUI() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.searchBar.searchResultsUpdater = self
        
    }
    
    func setNavigationBarUI() {
        navigationItem.title = "0개의 메모"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = mainView.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: - extension

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("입력된 단어: \(searchController.searchBar.text!)")
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        }
        
        delete.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
