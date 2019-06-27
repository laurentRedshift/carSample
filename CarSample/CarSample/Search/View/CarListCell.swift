import UIKit

struct CarListViewModel {
   let carImage: String
   let make: String
   let model: String
}

class CarListCell: UITableViewCell {
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    
    private func colorizeLabel(searchValue: String, labelValue: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: labelValue)
        let range = (labelValue.lowercased() as NSString).range(of: searchValue.lowercased())
        let highlightsAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.red]
        attributedString.addAttributes(highlightsAttributes, range: range)
        return attributedString
    }
    
    func configure(carListViewModel: CarListViewModel, searchValue: String?) {
        let placeholder = UIImage(named: "carPlaceholder")
        if let url = URL(string: carListViewModel.carImage) {
            carImageView.assignImage(url: url, placeholder: placeholder, completionHandler: nil)
        } else {
            carImageView.image = placeholder
        }
        makeLabel.text = carListViewModel.make
        if let searchValue = searchValue {
            modelLabel.attributedText = colorizeLabel(searchValue: searchValue, labelValue: carListViewModel.model)
            makeLabel.attributedText = colorizeLabel(searchValue: searchValue, labelValue: carListViewModel.make)
        } else {
            makeLabel.attributedText = nil
            modelLabel.attributedText = nil
            modelLabel.text = carListViewModel.model
            makeLabel.text = carListViewModel.make
        }
    }
}
