import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let cameraVC = CameraViewController()
        cameraVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera.fill"), tag: 0)
        
        let historyVC = HistoryViewController()
        historyVC.tabBarItem = UITabBarItem(title: "History", image: UIImage(systemName: "calendar"), tag: 1)
        
        let navigationControllers = [
            UINavigationController(rootViewController: cameraVC),
            UINavigationController(rootViewController: historyVC)
        ]
        
        setViewControllers(navigationControllers, animated: false)
    }
} 