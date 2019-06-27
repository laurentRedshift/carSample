import Foundation

struct Resource {
    let url: URL
}

extension Resource: CustomStringConvertible {
    public var description: String {
        return url.absoluteString
    }
}

protocol NetworkApi {
    func requestResult(resource: Resource, completion: @escaping (Result<Data, Error>) -> Void)
}

enum NetworkError: Error {
    case noData
}

class NetworkApiImpl: NetworkApi {
    func requestResult(resource: Resource, completion: @escaping (Result<Data, Error>) -> Void) {
        
        URLSession.shared.dataTask(with: resource.url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("request data error: \(error.localizedDescription) for url: \(resource)")
                    completion(.failure(error))
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                completion(.success(data))
            }
            }.resume()
    }
}
