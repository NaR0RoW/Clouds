import Foundation

protocol CocktailsViewProtocol: AnyObject {
    func success()
    func failure()
}

protocol CocktailsPresenterProtocol: AnyObject {
    init(view: CocktailsViewProtocol, networkManager: NetworkManagerProtocol)
    var cocktails: [Drinks]? { get }
    
    func numberOfItemsInSection() -> Int
    func cocktailForItemAt(indexPath: IndexPath) -> Drinks?
    
    func filterCocktails(
        searchTerm: String,
        range: NSRange,
        string: String,
        completion: (CocktailsPresenter.CollectionViewAction) -> Void
    )
}

final class CocktailsPresenter: CocktailsPresenterProtocol {
    weak var view: CocktailsViewProtocol?
    let networkManager: NetworkManagerProtocol?
    var cocktails: [Drinks]?

    required init(view: CocktailsViewProtocol, networkManager: NetworkManagerProtocol) {
        self.view = view
        self.networkManager = networkManager
        
        getCocktails()
    }
    
    func getCocktails() {
        networkManager?.getCocktails(service: .getCocktails) { [weak self] result in
            switch result {
            case .success(let cocktails):
                self?.cocktails = cocktails.drinks
                DispatchQueue.main.async {
                    self?.view?.success()
                }
            case .failure(let error):
                print("Network manager error: ", String(describing: error))
                self?.view?.failure()
            }
        }
    }
    
    func numberOfItemsInSection() -> Int {
        return cocktails?.count ?? 0
    }
    
    func cocktailForItemAt(indexPath: IndexPath) -> Drinks? {
        cocktails?[indexPath.row]
    }
    
    func filterCocktails(
        searchTerm: String,
        range: NSRange,
        string: String,
        completion: (CollectionViewAction) -> Void
    ) {
        guard let cocktails: [Drinks] = cocktails, let range: Range = Range(range, in: searchTerm) else { return }
        
        let trimmedText: String = searchTerm.replacingCharacters(in: range, with: string).lowercased().trimmingCharacters(in: .whitespaces)
        
        for (index, cocktail) in cocktails.enumerated() {
            let cocktailName: String = cocktail.cocktailName.lowercased()
            let indexPath: IndexPath = IndexPath(row: index, section: 0)
            
            if cocktailName.contains(trimmedText) {
                completion(.selectItem(indexPath))
            } else {
                completion(.deselectItem(indexPath))
            }
        }
    }
    
    enum CollectionViewAction {
        case selectItem(IndexPath)
        case deselectItem(IndexPath)
    }
}
