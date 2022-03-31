import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        let assemblyBuilder: AssemblyModuleBuilderProtocol = AssemblyModuleBuilder()
        window.makeKeyAndVisible()
        window.rootViewController = assemblyBuilder.createCocktailsModule()
        
        self.window = window
        
        return true
    }
}
