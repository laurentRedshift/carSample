@testable import CarSample
import XCTest

enum MockNetworkApiError: Error {
    case apiError
}

class MockNetworkApi: NetworkApi {
    private let mockResult: Result<Data, Error>
    init(mockResult: Result<Data, Error>) {
        self.mockResult = mockResult
    }
    func requestResult(resource: Resource, completion: @escaping (Result<Data, Error>) -> Void) {
        completion(mockResult)
    }
}

class CarRepositoryTests: XCTestCase {

    let cache = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        deleteStoredCars()
    }
    
    override func tearDown() {
        super.tearDown()
        cache.removeObject(forKey: "lastCarsDate")
        deleteStoredCars()
    }
    
    private func deleteStoredCars() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        do {
            try CoreDataManager.shared.deleteRecordsForEntity("CarEntity", inManagedObjectContext: context)
        } catch {
            print(error)
        }
    }

    func test_getCars_shouldReturnEmbededCars_whenNoCarsWasStored() {
        
        let networkApi = MockNetworkApi(mockResult: .failure(MockNetworkApiError.apiError))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        
        let carExpectation = expectation(description: "car expectation")
        var cars: Cars?
        carRepository.getCars(completion: { result in
            cars = try? result.get()
            carExpectation.fulfill()
        }) { _ in }
        XCTAssertNotNil(cars)
        XCTAssertEqual(6, cars?.count)
        waitForExpectations(timeout: 0.1)
    }
    
    func test_getCars_shouldReturnSavedCars_whenCarsWasAlreadyStored() {
        
        carsWasAlreadyStored()
        
        cache.set(Date().addingTimeInterval(-300), forKey: "lastCarsDate")
        let networkApi = MockNetworkApi(mockResult: .failure(MockNetworkApiError.apiError))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        let carExpectation = expectation(description: "car expectation")
        var cars: Cars?
        carRepository.getCars(completion: { result in
            cars = try? result.get()
            carExpectation.fulfill()
        }) { _ in }
        
        XCTAssertNotNil(cars)
        XCTAssertEqual(1, cars?.count) // verify cars was not embeded car but cars saved
        waitForExpectations(timeout: 0.01)
    }
    
    private func carsWasAlreadyStored() {
        cache.set(Date().addingTimeInterval(-300), forKey: "lastCarsDate")
        let networkApi = MockNetworkApi(mockResult: .success(getData()!))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        carRepository.getCars(completion: { _ in
        }) { _ in
        }
    }
    
    func test_getCars_shouldRefreshCars_whenNoDataWasStored() {
        
        let networkApi = MockNetworkApi(mockResult: .success(getData()!))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        
        let carExpectation = expectation(description: "car expectation")
        var cars: Cars?
        carRepository.getCars(completion: { _ in
        }) { result in
            cars = try? result.get()
            carExpectation.fulfill()
        }
        XCTAssertNotNil(cars)
        XCTAssertEqual(1, cars?.count)
        waitForExpectations(timeout: 0.01)
    }
    
    func test_getCars_shouldRefreshCars_whenNeedRefresh() {
        
        cache.set(Date().addingTimeInterval(-300), forKey: "lastCarsDate")
        let networkApi = MockNetworkApi(mockResult: .success(getData()!))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        
        let carExpectation = expectation(description: "car expectation")
        var cars: Cars?
        carRepository.getCars(completion: { _ in
        }) { result in
            cars = try? result.get()
            carExpectation.fulfill()
        }
        XCTAssertNotNil(cars)
        XCTAssertEqual(1, cars?.count)
        waitForExpectations(timeout: 0.01)
    }
    
    func test_getCars_shouldNotRefreshCars_whenNotNeedRefresh() {
        
        cache.set(Date().addingTimeInterval(-30), forKey: "lastCarsDate")
        let networkApi = MockNetworkApi(mockResult: .success(getData()!))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        
        var cars: Cars?
        carRepository.getCars(completion: { _ in
        }) { result in
            cars = try? result.get()
        }
        
        XCTAssertNil(cars)
    }
    
    func test_getCars_shouldNotRefreshCarsAndReturnApiError_whenNeedRefresh() {
        
        cache.set(Date().addingTimeInterval(-300), forKey: "lastCarsDate")
        let networkApi = MockNetworkApi(mockResult: .failure(MockNetworkApiError.apiError))
        let carRepository = CarRepositoryImpl(cache: cache, networkApi: networkApi)
        
        let carExpectation = expectation(description: "car expectation")
        var cars: Cars?
        var resultError: MockNetworkApiError?
        
        carRepository.getCars(completion: { _ in
        }) { result in
            do {
                cars = try result.get()
            } catch {
                resultError = error as? MockNetworkApiError
            }
            carExpectation.fulfill()
        }
        XCTAssertNil(cars)
        XCTAssertEqual(MockNetworkApiError.apiError, resultError)
        waitForExpectations(timeout: 0.01)
    }
    
    private func getData() -> Data? {
        return try? JsonHelper.json(filename: "tc-test-ios", bundle: Bundle(for: CarRepositoryTests.self))
    }
}
