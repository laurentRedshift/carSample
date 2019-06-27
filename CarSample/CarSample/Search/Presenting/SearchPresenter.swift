import Foundation

protocol SearchPresenter {
    func viewDidLoad()
}

protocol SearchInterface: class {
    func display(carsViewModels: [CarListViewModel])
    func displayNoCars()
    func refreshedCars()
}

class SearchPresenterImpl: SearchPresenter {
    
    private let repository: CarRepository
    weak var interface: SearchInterface?
    private var displayedCars = false
    
    init(repository: CarRepository) {
        self.repository = repository
    }
    
    func viewDidLoad() {
        repository.getCars(completion: { [weak self] result in
                self?.receivedCars(result: result, displayNoCars: true)
            }, refreshed: { [weak self] result in
                guard let self = self else { return }
                if self.receivedCars(result: result, displayNoCars: self.displayedCars == false) {
                    self.interface?.refreshedCars()
                }
            })
    }
    
    @discardableResult
    private func receivedCars(result: Result<Cars, Error>, displayNoCars: Bool) -> Bool {
        do {
            let carsViewModels = try result.get().map({
                CarListViewModel(carImage: $0.picture, make: $0.make, model: $0.model)
            })
            print("received \(carsViewModels.count) cars")
            interface?.display(carsViewModels: carsViewModels)
            displayedCars = true
            return true
        } catch {
            if displayNoCars {
                interface?.displayNoCars()
            }
            print("Error when get cars \(error.localizedDescription)")
            return false
        }
    }
}
