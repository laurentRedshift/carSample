import Foundation
import UIKit

class Account: Codable {
    let name: String
    let firstName: String
    let birthDate: Date
    let address: String
    
    init(name: String, firstName: String, birthDate: Date, address: String) {
        self.name = name
        self.firstName = firstName
        self.birthDate = birthDate
        self.address = address
    }
}
