import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 10.0, *) {
            window?.rootViewController = ViewController()
        } else {
            // Fallback on earlier versions
        }
        window?.makeKeyAndVisible()
        return true
    }

}
