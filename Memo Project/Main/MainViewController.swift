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
}
