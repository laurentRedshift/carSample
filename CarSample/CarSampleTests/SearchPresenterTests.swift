@testable import CarSample
import XCTest

enum RepositoryError: Error {
    case canGetCars
}

class MockInterface: SearchInterface {
    
    var displayedCarViewModels: [CarListViewModel]?
    var displayedNoCars = false
    var hasRefreshedCars = false

    func display(carsViewModels: [CarListViewModel]) {
        displayedCarViewModels = carsViewModels
    }
    
    func displayNoCars() {
        displayedNoCars = true
    }
    
    func refreshedCars() {
        hasRefreshedCars = true
    }
}

class MockCarRepository: CarRepository {
    
    private let mockResult: Result<Cars, Error>
    private let mockResultRefreshed: Result<Cars, Error>?

    init(result: Result<Cars, Error>, resultRefreshed: Result<Cars, Error>? = nil) {
        self.mockResult = result
        self.mockResultRefreshed = resultRefreshed
    }
    
    func getCars(completion: @escaping (Result<Cars, Error>) -> Void, refreshed: ((Result<Cars, Error>) -> Void)?) {
        completion(mockResult)
        if let mockResultRefreshed = mockResultRefreshed {
            refreshed?(mockResultRefreshed)
        }
    }
}

class SearchPresenterTests: XCTestCase {

    private func getCars() -> Cars? {
        guard let data = try? JsonHelper.json(filename: "tc-test-ios", bundle: Bundle(for: CarRepositoryTests.self)) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Cars.self, from: data)
    }
    
    func test_viewDidLoad_shouldDisplayCarsViewModelsOnly_whenGetCarsIsWorkingAndButRefreshedCarsNot() {
        let cars = getCars()!
        let repository = MockCarRepository(result: .success(cars), resultRefreshed: .failure(RepositoryError.canGetCars))
        let searchPresenter = SearchPresenterImpl(repository: repository)
        let interface = MockInterface()
        searchPresenter.interface = interface
        searchPresenter.viewDidLoad()
        XCTAssertEqual(cars.count, interface.displayedCarViewModels?.count)
        XCTAssertFalse(interface.hasRefreshedCars)
        XCTAssertFalse(interface.displayedNoCars)
    }
    
    func test_viewDidLoad_shouldDisplayRefreshedCarsViewModels_IfGetAndRefreshIsWorkingGood() {
        let cars = getCars()!
        var refreshedCars = cars
        refreshedCars.append(Car(make: "matra", model: "530", year: 1973, picture: "picture", equipments: nil))
        let repository = MockCarRepository(result: .success(cars), resultRefreshed: .success(refreshedCars))
        let searchPresenter = SearchPresenterImpl(repository: repository)
        let interface = MockInterface()
        searchPresenter.interface = interface
        searchPresenter.viewDidLoad()
        XCTAssertEqual(refreshedCars.count, interface.displayedCarViewModels?.count)
        XCTAssertTrue(interface.hasRefreshedCars)
        XCTAssertFalse(interface.displayedNoCars)
    }
    
    func test_viewDidLoad_shouldDisplayNoCars_whenGetCarsAndRefreshedFailed() {
        let repository = MockCarRepository(result: .failure(RepositoryError.canGetCars), resultRefreshed: .failure(RepositoryError.canGetCars))
        let searchPresenter = SearchPresenterImpl(repository: repository)
        let interface = MockInterface()
        searchPresenter.interface = interface
        searchPresenter.viewDidLoad()
        XCTAssertNil(interface.displayedCarViewModels)
        XCTAssertTrue(interface.displayedNoCars)
        XCTAssertFalse(interface.hasRefreshedCars)
    }
    
    func test_viewDidLoad_shouldDisplayRefreshedCarsAfterDisplayNoCars_whenGetCarsFailsAndRefreshedHasSuccess() {
        let cars = getCars()!
        let repository = MockCarRepository(result: .failure(RepositoryError.canGetCars), resultRefreshed: .success(cars))
        let searchPresenter = SearchPresenterImpl(repository: repository)
        let interface = MockInterface()
        searchPresenter.interface = interface
        searchPresenter.viewDidLoad()
        XCTAssertEqual(cars.count, interface.displayedCarViewModels?.count)
        XCTAssertTrue(interface.hasRefreshedCars)
        XCTAssertTrue(interface.displayedNoCars)
    }
}
