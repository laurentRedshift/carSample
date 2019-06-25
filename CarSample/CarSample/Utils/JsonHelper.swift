import Foundation

enum JsonHelper {
    
    public static func json(filename: String, bundle: Bundle) throws -> Data? {
        if let url = bundle.url(forResource: filename, withExtension: "json") {
            return try Data(contentsOf: url)
        }
        print("unable to load " + filename)
        return nil
    }
}
