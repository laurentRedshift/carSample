import UIKit

public enum Notification {
    static let refreshNotificationId = "refreshNotificationId"
}

struct RefreshNotification: UserNotification {
    let id = Notification.refreshNotificationId
    let title = "Mise à jour"
    let body = "Les Voitures ont été mises à jour"
}

enum CarSearcher {
    static let minCharactersAcceptable = 3
    static func search(searchText: String, attribute: String) -> Bool {
        if searchText.count >= minCharactersAcceptable {
            return attribute.contains(searchText.prefix(minCharactersAcceptable))
            
        } else {
            return attribute.contains(searchText)
        }
    }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var noCarsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    lazy var searchPresenter: SearchPresenter = {
        let presenter = SearchPresenterImpl(repository: CarRepositoryImpl())
        presenter.interface = self
        return presenter
    }()
    
    let searchController = UISearchController(searchResultsController: nil)

    var carsListViewModels = [CarListViewModel]()
    var filteredCarsListModels: [CarListViewModel]?
    var searchedText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationManager.shared.register(identifier: Notification.refreshNotificationId)
        setupUI()
        searchPresenter.viewDidLoad()
    }
    
    private func setupUI() {
        noCarsLabel.isHidden = true
        tableView.alpha = 0
        navigationItem.title = "Search"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search cars models or marks"
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let viewController = segue.destination as? CarDetailViewController,
            let selectedIndexPath = tableView.indexPathForSelectedRow,
            let selectedCarViewModel = filteredCarsListModels?[safe: selectedIndexPath.row] {
            let carDetailPresenter = CarDetailPresenterImpl(model: selectedCarViewModel.model, repository: CarRepositoryImpl())
            carDetailPresenter.interface = viewController
            viewController.carDetailPresenter = carDetailPresenter
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let carsViewModels = filteredCarsListModels else {
            return 0
        }
        return carsViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CarListCell.self), for: indexPath) as? CarListCell else {
            fatalError("CarListCell does not exist")
        }
        if let carsViewModels = filteredCarsListModels, let carViewModel = carsViewModels[safe: indexPath.row] {
            cell.configure(carListViewModel: carViewModel, searchValue: searchedText)
        }
        
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension SearchViewController: SearchInterface {
    
    func refreshedCars() {
        NotificationHelper().presentNotification(RefreshNotification(), timeInterval: 1)
    }
    
    func display(carsViewModels: [CarListViewModel]) {
        loadingIndicator.stopAnimating()
        carsListViewModels = carsViewModels
        filteredCarsListModels = carsListViewModels
        tableView.reloadData()
        showTableViewIfNeed()
    }
    
    func displayNoCars() {
        loadingIndicator.stopAnimating()
        noCarsLabel.isHidden = false
    }
    
    private func showTableViewIfNeed() {
        if tableView.alpha == 0 {
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedText = nil
        tableView.reloadData()
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchedText = searchText
            filteredCarsListModels = carsListViewModels.filter { car in
                return CarSearcher.search(searchText: searchText.lowercased(), attribute: car.model.lowercased()) || CarSearcher.search(searchText: searchText.lowercased(), attribute: car.make.lowercased())
            }
            
        } else {
            searchedText = nil
            filteredCarsListModels = carsListViewModels
        }
        tableView.reloadData()
    }
}
