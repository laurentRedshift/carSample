import UIKit

struct CarViewModel {
    let carImage: String
    let make: String
    let model: String
    let year: Int
    let equipments: [String]?
}

class CarDetailViewController: UIViewController {
    
    var carDetailPresenter: CarDetailPresenter!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var equipmentTitleLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var equipmentsLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = carDetailPresenter.model
        setupUI()
        carDetailPresenter.viewDidLoad()
    }
    
    private func setupUI() {
        displayedCarInfos = false
        if #available(iOS 11, *) {
            navigationController?.navigationItem.largeTitleDisplayMode = .automatic
            scrollView.contentInsetAdjustmentBehavior = .automatic
        }
    }
    
    private var displayedCarInfos: Bool = false {
        didSet {
            let alpha = displayedCarInfos ? 1 : 0
            let isHidden = displayedCarInfos ? false : true

            [self.yearLabel, self.markLabel, self.equipmentTitleLabel, self.equipmentsLabel, self.carImageView].forEach({ $0?.isHidden = isHidden })
            UIView.animate(withDuration: 0.3) {
                [self.yearLabel, self.markLabel, self.equipmentTitleLabel, self.equipmentsLabel, self.carImageView].forEach({ $0?.alpha = CGFloat(alpha) })
            }
        }
    }
}

extension CarDetailViewController: CarInterface {
    func display(carViewModel: CarViewModel) {
        loadingIndicator.stopAnimating()
        displayedCarInfos = true
        yearLabel.text = "\(carViewModel.year)"
        markLabel.text = carViewModel.make
        let placeholder = UIImage(named: "carPlaceholder")
        if let url = URL(string: carViewModel.carImage) {
            carImageView.assignImage(url: url, placeholder: placeholder, completionHandler: nil)
        } else {
            carImageView.image = placeholder
        }
        
        if let equipments = carViewModel.equipments, !equipments.isEmpty {
            equipmentsLabel.text = equipments.joined(separator: ", ")
        } else {
            equipmentsLabel.text = "Non Renseigné"
        }
    }
}
