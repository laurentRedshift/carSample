import Foundation

class Car: Codable {
    let make: String
    let model: String
    let year: Int
    let picture: String
    let equipments: [String]?
    
    init(make: String, model: String, year: Int, picture: String, equipments: [String]?) {
        self.make = make
        self.model = model
        self.year = year
        self.picture = picture
        self.equipments = equipments
    }
}
