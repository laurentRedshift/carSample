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
    
    init(repository: CarRepository) {
        self.repository = repository
    }
    
    func viewDidLoad() {
        repository.getCars(completion: { [weak self] result in
                self?.receivedCars(result: result)
            }, refreshed: { [weak self] result in
                self?.receivedCars(result: result)
                self?.interface?.refreshedCars()
            })
    }
    
    private func receivedCars(result: Result<Cars, Error>) {
        do {
            let carsViewModels = try result.get().map({
                CarListViewModel(carImage: $0.picture, make: $0.make, model: $0.model)
            })
            print("received \(carsViewModels.count) cars")
            interface?.display(carsViewModels: carsViewModels)
        } catch {
            interface?.displayNoCars()
            print("Error when get cars \(error.localizedDescription)")
        }
    }
}
