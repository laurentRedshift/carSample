import Foundation
import UIKit

protocol AccountPresenter {
    func refresh()
    func imageSelected(image: UIImage)
}

protocol AccountInterface: class {
    func display(accountViewModel: AccountViewModel)
    func displayNoAccount()
    func displaySaveImageError()
    func display(accountImage: UIImage)
}

extension Date {
    func age() -> Int? {
        let components = Calendar.current.dateComponents([.year], from: self, to: Date())
        return components.year
    }
}

class AccountPresenterImpl: AccountPresenter {
    private var accountRepository: AccountRepository
    private var accountImageRepository: AccountImageRepository
    weak var interface: AccountInterface?
    
    init(repository: AccountRepository, accountImageRepository: AccountImageRepository) {
        self.accountRepository = repository
        self.accountImageRepository = accountImageRepository
    }
    
    func refresh() {
        retrieveAccountInfos()
        retrieveAccountImage()
    }
    
    private func retrieveAccountInfos() {
        accountRepository.getAccountInfos { [weak self] result in
            guard let self = self else { return }
            do {
                let account = try result.get()
                self.interface?.display(accountViewModel: AccountViewModel(name: "\(account.firstName) \(account.name)", adress: account.address, age: "\(account.birthDate.age() ?? 18)"))
            } catch {
                self.interface?.displayNoAccount()
            }
        }
    }
    
    private func retrieveAccountImage() {
        do {
            let image = try self.accountImageRepository.get()
            self.interface?.display(accountImage: image)
        } catch {}
    }

    func imageSelected(image: UIImage) {
        do {
            try accountImageRepository.store(image: image)
        } catch {
            interface?.displaySaveImageError()
        }
    }

}
