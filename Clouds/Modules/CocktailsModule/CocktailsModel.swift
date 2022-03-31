import Foundation

struct CocktailsModel: Codable {
    let drinks: [Drinks]
}

struct Drinks: Codable {
    let cocktailName: String
    
    enum CodingKeys: String, CodingKey {
        case cocktailName = "strDrink"
    }
}
