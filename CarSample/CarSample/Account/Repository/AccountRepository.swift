import Foundation
import UIKit

protocol AccountRepository {
    func getAccountInfos(completion: @escaping (Result<Account, Error>) -> Void)
    func saveAccountInfos(account: Account, completion: @escaping (Result<Void, Error>) -> Void)
    func getAccountImage(completion: @escaping (Result<UIImage, Error>) -> Void)
}

enum AccountRepositoryError: Error {
    case accountDecodingError
    case canNotFindAnyAccount
    case saveAccountError
}

class AccountRepositoryImpl: AccountRepository {
    
    private let accountKey = "account"
    private let localCache = UserDefaults.standard
    
    func getAccountInfos(completion: @escaping (Result<Account, Error>) -> Void) {
        if let accountSaved = localCache.object(forKey: accountKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedAccount = try? decoder.decode(Account.self, from: accountSaved) {
               completion(.success(loadedAccount))
            } else {
                completion(.failure(AccountRepositoryError.accountDecodingError))
            }
        } else {
            completion(.failure(AccountRepositoryError.canNotFindAnyAccount))
        }
    }
    
    func saveAccountInfos(account: Account, completion: @escaping (Result<Void, Error>) -> Void) {
        let encoder = JSONEncoder()
        if let encodedAccount = try? encoder.encode(account) {
            localCache.set(encodedAccount, forKey: accountKey)
        } else {
            
        }
    }
    
    func getAccountImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        
    }
}
