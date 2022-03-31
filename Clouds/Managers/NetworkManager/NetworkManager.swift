import Alamofire

enum Result<T: Codable> {
    case success(T)
    case failure(AFError)
}

protocol NetworkManagerProtocol {
    func getCocktails(service: CocktailsProvider, completion: @escaping(Result<CocktailsModel>) -> Void)
}

final class NetworkManager: NetworkManagerProtocol {
    func getCocktails(service: CocktailsProvider, completion: @escaping(Result<CocktailsModel>) -> Void) {
        guard let urlRequest = service.urlRequest else { return }
        AF.request(urlRequest).responseDecodable(of: CocktailsModel.self) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
