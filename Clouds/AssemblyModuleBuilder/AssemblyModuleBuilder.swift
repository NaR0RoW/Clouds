import UIKit

protocol AssemblyModuleBuilderProtocol {
    func createCocktailsModule() -> UIViewController
}

final class AssemblyModuleBuilder: AssemblyModuleBuilderProtocol {
    func createCocktailsModule() -> UIViewController {
        let view = CocktailsViewController()
        let networkManager = NetworkManager()
        let presenter = CocktailsPresenter(view: view, networkManager: networkManager)
        view.cocktailsPresenter = presenter
        
        return view
    }
}
