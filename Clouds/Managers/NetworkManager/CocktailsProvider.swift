import Alamofire

enum CocktailsProvider: URLRequestBuilder {
    case getCocktails
    
    var path: String {
        switch self {
        case .getCocktails:
            return "json/v1/1/filter.php"
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        default:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getCocktails:
            return ["a": "Non_Alcoholic"]
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCocktails:
            return .get
        }
    }
}
