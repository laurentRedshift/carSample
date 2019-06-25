import Foundation

protocol EditAccountPresenter {
    func viewDidLoad()
    func viewDidTapSave()
}

protocol EditAccountInterface: class {
    var editAccountViewModel: EditAccountViewModel? { get }
    func display(editAccountViewModel: EditAccountViewModel)
    func displayEmptyAccount()
    func displaySaveError()
    func close()
}

class EditAccountPresenterImpl: EditAccountPresenter {
    
    private var repository: AccountRepository
    weak var interface: EditAccountInterface?
    
    init(repository: AccountRepository) {
        self.repository = repository
    }
    
    func viewDidLoad() {
        repository.getAccountInfos { [weak self] result in
            guard let self = self else { return }
            do {
                let account = try result.get()
                self.interface?.display(editAccountViewModel: EditAccountViewModel(firstName: account.firstName, lastName: account.name, address: account.address, birthDate: account.birthDate))
            } catch {
                self.interface?.displayEmptyAccount()
            }
        }
    }
    
    func viewDidTapSave() {
        guard let editAccountViewModel = interface?.editAccountViewModel else { return }
        repository.saveAccountInfos(account: Account(name: editAccountViewModel.lastName, firstName: editAccountViewModel.firstName, birthDate: editAccountViewModel.birthDate, address: editAccountViewModel.address)) { [weak self] result in
            guard let self = self else { return }
            if case .success = result {
                self.interface?.close()
            } else {
                self.interface?.displaySaveError()
            }
        }
    }
}
