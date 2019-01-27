import UIKit
import CoreData

class WishlistTableViewController: UITableViewController {
    
    var navigator: ProjectNavigator?
    var fetchedResultController: NSFetchedResultsController<Movie>!
    
    lazy var sectionSegmentedControl: UISegmentedControl = {
       
        let items = ["Movies", "TV Shows"]
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(sectionSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    struct Predicates {
        static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
        static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTableView()
        fetchData(predicate: Predicates.moviePredicate)
    }
    
    private func configureNavigationBar() {
        navigationItem.titleView = sectionSegmentedControl
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func configureTableView() {
        tableView.bounces = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistCell")
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            fetchData(predicate: Predicates.tvPredicate)
        } else {
            fetchData(predicate: Predicates.moviePredicate)
        }
        tableView.reloadData()
    }
    
    private func fetchData(predicate: NSPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.shared.fetchDataWithController(for: Movie.self, predicate: predicate)
        fetchedResultController.delegate = self
        fetchedObjectsCheck(predicate: predicate)
    }
    
    func fetchedObjectsCheck(predicate: NSPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
        if objects.count == 0 {
            let backgroundView = getNoResultsView()
            tableView.backgroundView = backgroundView
            NotificationService.shared.removeReminderNotification()
        } else {
            tableView.backgroundView = nil
            NotificationService.shared.planReminderNotification()
        }
    }
    
    private func getNoResultsView() -> UIView {
        
        let backgroundView = UIView()
        backgroundView.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height)
        backgroundView.backgroundColor = UIColor.white
        let label = UILabel()
        backgroundView.addSubview(label)
        label.text = "No movies in wishlist yet"
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -0.15 * backgroundView.frame.height).isActive = true
        label.widthAnchor.constraint(equalToConstant: backgroundView.frame.width - 32).isActive = true
        
        return backgroundView
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath)
        
        if let cell = cell as? WishlistTableViewCell {
            
            let item = fetchedResultController.object(at: indexPath)
            cell.configure(with: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WishlistTableViewCell
        if let type = cell.mediaType {
            navigator?.navigate(to: .movie(id: cell.id, type: type))
        } else { return }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeFromWishlist = UITableViewRowAction(style: .destructive, title: "Remove from wishlist") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.shared.delete(object: item)
        }
        
        return [removeFromWishlist]
    }

}
