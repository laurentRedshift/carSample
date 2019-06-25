import Foundation

typealias Cars = [Car]

protocol CarRepository {
    func getCars(completion: @escaping (Result<Cars, Error>) -> Void, refreshed: ((Result<Cars, Error>) -> Void)?)
}

enum CarsRepositoryError: Error {
    case badCarsUrl
    case badAccessToLocalData
    case badDistantData
    case emptyStoredData
}

enum CarEntityKey {
    static let model = "model"
    static let make = "make"
    static let equipments = "equipments"
    static let year = "year"
    static let image = "image"
}

class CarRepositoryImpl: CarRepository {
    
    enum CacheValidity {
        public static let threeMins = 180
    }

    enum Entity {
        static let car = "CarEntity"
    }
    
    private let lastCarsStoredDateKey = "lastCarsDate"
    private let localCache = UserDefaults.standard
    private var carsEntities: [CarEntity]?
    
    private var lastCarsStoredDate: Date? {
        get {
            return localCache.object(forKey: lastCarsStoredDateKey) as? Date
        }
        
        set {
            localCache.set(newValue, forKey: lastCarsStoredDateKey)
        }
    }
    
    private func needToRefreshCars() -> Bool {
        guard let lastCarsStoredDate = lastCarsStoredDate else { return true }
        return Int((-lastCarsStoredDate.timeIntervalSinceNow)) > CacheValidity.threeMins
    }
    
    private func getLocalData() throws -> Data {
        do {
            guard let data = try JsonHelper.json(filename: "tc-test-ios", bundle: Bundle.main) else {
                throw CarsRepositoryError.badAccessToLocalData
            }
            return data
        } catch {
            throw CarsRepositoryError.badAccessToLocalData
        }
    }
    
    private func parseData(data: Data) throws -> Cars {
        let decoder = JSONDecoder()
        let carsData = try decoder.decode(Cars.self, from: data)
        return carsData
    }
    
    private func getLocalCars() throws -> Cars {
       return try parseData(data: getLocalData())
    }
    
    private func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://gist.githubusercontent.com/ncltg/6a74a0143a8202a5597ef3451bde0d5a/raw/8fa93591ad4c3415c9e666f888e549fb8f945eb7/tc-test-ios.json") else {
            completion(.failure(CarsRepositoryError.badCarsUrl))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("fetchData error: \(error.localizedDescription)")
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
    
    private func getSavedData() throws -> Cars {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let carsEntities = try CoreDataManager.shared.fetchRecordsForEntity(Entity.car, inManagedObjectContext: context)
        self.carsEntities = carsEntities as? [CarEntity]
        guard carsEntities.count > 0 else {
            throw CarsRepositoryError.emptyStoredData
        }
        return carsEntities.compactMap({ carEntity in
            guard let model = carEntity.value(forKey: CarEntityKey.model) as? String,
                let make = carEntity.value(forKey: CarEntityKey.make) as? String,
                let year = carEntity.value(forKey: CarEntityKey.year) as? Int,
                let image = carEntity.value(forKey: CarEntityKey.image) as? String,
                let equipments = carEntity.value(forKey: CarEntityKey.equipments) as? [String]? else { return nil }
           return Car(make: make, model: model, year: year, picture: image, equipments: equipments)
        })
    }
    
    private func createCarRecord(car: Car) throws {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let carEntity = try CoreDataManager.shared.createRecordForEntity(Entity.car, inManagedObjectContext: context)
        carEntity.setValue(car.model, forKey: CarEntityKey.model)
        carEntity.setValue(car.make, forKey: CarEntityKey.make)
        carEntity.setValue(car.year, forKey: CarEntityKey.year)
        carEntity.setValue(car.equipments, forKey: CarEntityKey.equipments)
        carEntity.setValue(car.picture, forKey: CarEntityKey.image)
    }
    
    private func deleteCarsRecords() {
        if let carsEntities = carsEntities {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            CoreDataManager.shared.delete(objects: carsEntities, inManagedObjectContext: context)
        }
    }
    
    func getCars(completion: @escaping (Result<Cars, Error>) -> Void, refreshed: ((Result<Cars, Error>) -> Void)?) {
        
        do {
            let cars = try getSavedData()
            completion(.success(cars))
        } catch {
            print("get saved cars error \(error.localizedDescription), so get local cars")
            do {
                completion(.success(try self.getLocalCars()))
            } catch {
                completion(.failure(error))
            }
        }

        if needToRefreshCars() {
            print("needToRefreshCars, so fetchData")
            fetchData(completion: { [weak self] result in
                guard let self = self else { return }
                if case .success(let data) = result, let cars = try? self.parseData(data: data) {
                    cars.forEach {
                        do {
                            self.deleteCarsRecords()
                            try self.createCarRecord(car: $0)
                            let context = CoreDataManager.shared.persistentContainer.viewContext
                            CoreDataManager.shared.saveContext(inManagedObjectContext: context)
                            self.lastCarsStoredDate = Date()
                        } catch {
                            print("can not store car")
                        }
                    }
                    refreshed?(.success(cars))
                }
            })
        }
    }
}
