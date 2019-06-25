protocol CarDetailPresenter {
    var model: String { get }
    func viewDidLoad()
}

protocol CarInterface: class {
    func display(carViewModel: CarViewModel)
}

class CarDetailPresenterImpl: CarDetailPresenter {
    
    var model: String
    private var repository: CarRepository
    weak var interface: CarInterface?

    init(model: String, repository: CarRepository) {
        self.model = model
        self.repository = repository
    }
    
    func viewDidLoad() {
        repository.getCars(completion: {  [weak self] result in
            self?.receivedCars(result: result)
        }, refreshed: { [weak self] result in
            self?.receivedCars(result: result)
        })
    }
    
    private func receivedCars(result: Result<Cars, Error>) {
        do {
            let cars = try result.get().filter({ $0.model == self.model }).map({
                CarViewModel(carImage: $0.picture, make: $0.make, model: $0.model, year: $0.year, equipments: $0.equipments)
            })
            if let carViewModel = cars.first {
                self.interface?.display(carViewModel: carViewModel)
            }
        } catch {
            print("Error when get cars \(error.localizedDescription)")
        }
    }
}
