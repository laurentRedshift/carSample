import Kingfisher

extension UIImageView {
    
    public func assignImage(url: URL? = nil, placeholder: UIImage? = nil, completionHandler: ((UIImage?, Error?, URL?) -> Void)? = nil) {
        setImage(with: url, placeholder: placeholder, completionHandler: completionHandler)
    }
    
    private func setImage(with resource: URL?, placeholder: UIImage? = nil, completionHandler: ((UIImage?, Error?, URL?) -> Void)? = nil) {
        kf.setImage(with: resource, placeholder: placeholder, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error, nil)
            }
        }
    }
}
