import UIKit

enum ImageError: Error {
    case canNotCompressImage
    case canNotRetrieveImage
}

protocol AccountImageRepository {
    func store(image: UIImage) throws
    func get() throws -> UIImage
}

class AccountImageRepositoryImpl: AccountImageRepository {
    
    static let imageName = "accountImage.jpg"
    
    private var directory: FileManager.SearchPathDirectory
    init(directory: FileManager.SearchPathDirectory) {
        self.directory = directory
    }
    
    func store(image: UIImage) throws {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw ImageError.canNotCompressImage
        }
        let documentDirectory = try FileManager.default.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false)
        let localPath = documentDirectory.appendingPathComponent(AccountImageRepositoryImpl.imageName)
        try data.write(to: localPath, options: Data.WritingOptions.atomic)
    }
    
    func get() throws -> UIImage {
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        guard let image = UIImage(contentsOfFile: URL(fileURLWithPath: documentDirectory.absoluteString).appendingPathComponent(AccountImageRepositoryImpl.imageName).path) else {
            throw ImageError.canNotRetrieveImage
        }
        return image
    }
}
