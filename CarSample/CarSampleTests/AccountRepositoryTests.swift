@testable import CarSample
import XCTest

class AccountRepositoryTests: XCTestCase {

    private let cache = UserDefaults.standard
    private var accountRepository: AccountRepositoryImpl!
    private let account = Account(name: "name", firstName: "firstName", birthDate: Date(), address: "address")
    
    override func setUp() {
        accountRepository = AccountRepositoryImpl(cache: cache)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    private func storeAccount() {
        let encoder = JSONEncoder()
        if let encodedAccount = try? encoder.encode(account) {
            cache.set(encodedAccount, forKey: "account")
        }
    }
    
    private func getAccount() -> Account? {
        if let accountData = cache.object(forKey: "account") as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(Account.self, from: accountData)
        } else {
            return nil
        }
    }
    
    func test_getAccountInfos_shouldReturnAccountStored() {
        
        storeAccount()
        var resultedAccount: Account?
        let accountExpectation = expectation(description: "account expectation")
        accountRepository.getAccountInfos { result in
            accountExpectation.fulfill()
            resultedAccount = try? result.get()
        }
        
        XCTAssertEqual(account, resultedAccount)
        waitForExpectations(timeout: 0.01)
    }
    
    func test_saveAccountInfos_shouldSaveAccount() {
        
        let accountExpectation = expectation(description: "account expectation")
        accountRepository.saveAccountInfos(account: account) { _ in
            accountExpectation.fulfill()
        }
        
        XCTAssertEqual(account, getAccount())
        waitForExpectations(timeout: 0.01)
    }
}
