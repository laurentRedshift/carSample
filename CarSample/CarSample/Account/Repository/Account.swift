import Foundation
import UIKit

class Account: Codable, Equatable {
    
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
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.name == rhs.name && lhs.firstName == rhs.firstName && lhs.birthDate == rhs.birthDate && lhs.address == rhs.address
    }
}
