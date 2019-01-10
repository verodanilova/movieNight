import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movies = MoviesTableViewController()
        movies.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(named: "movies"), tag: 0)
        
        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let wishlist = UINavigationController(rootViewController: WishlistTableViewController())
        wishlist.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), tag: 2)
        
        viewControllers = [movies, search, wishlist]
    }

}
