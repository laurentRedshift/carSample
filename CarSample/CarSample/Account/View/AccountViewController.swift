import UIKit

struct AccountViewModel {
    let name: String
    let adress: String
    let age: String
}

class AccountViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var addPictureButton: UIButton!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var noAccountLabel: UILabel!
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.sourceType = .photoLibrary
        return imagePickerController
    }()
    
    lazy var accountPresenter: AccountPresenter = {
        let presenter = AccountPresenterImpl(repository: AccountRepositoryImpl(), accountImageRepository: AccountImageRepositoryImpl(directory: .documentDirectory))
        presenter.interface = self
        return presenter
    }()
    
    private var displayedAccountInfos: Bool = false {
        didSet {
            let alpha = displayedAccountInfos ? 1 : 0
            let isHidden = displayedAccountInfos ? false : true
            
            [self.addPictureButton, self.nameLabel, self.ageLabel, self.adressLabel, self.pictureImageView].forEach({ $0?.isHidden = isHidden })
            self.noAccountLabel.isHidden = !isHidden
            UIView.animate(withDuration: 0.3) {
                [self.addPictureButton, self.nameLabel, self.ageLabel, self.adressLabel, self.pictureImageView].forEach({ $0?.alpha = CGFloat(alpha) })
                self.noAccountLabel.alpha = CGFloat(1 - alpha)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        accountPresenter.refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let viewController = segue.destination as? EditViewController {
            let editAccountPresenter = EditAccountPresenterImpl(repository: AccountRepositoryImpl())
            editAccountPresenter.interface = viewController
            viewController.presenter = editAccountPresenter
        }
    }
    
    private func setupUI() {
        navigationItem.title = "Account"
        displayedAccountInfos = false
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    @IBAction private func tapToEdit(_ sender: Any) {
    }
    
    @IBAction private func tapToCamera(_ sender: Any) {
        present(imagePickerController, animated: true)
    }
}

extension AccountViewController: AccountInterface {
    func display(accountViewModel: AccountViewModel) {
        nameLabel.text = accountViewModel.name
        adressLabel.text = accountViewModel.adress
        ageLabel.text = "\(accountViewModel.age) ans"
        displayedAccountInfos = true
    }
    
    func displayNoAccount() {
        displayedAccountInfos = false
    }
    
    func display(accountImage: UIImage) {
        pictureImageView.image = accountImage
    }
    
    func displaySaveImageError() {
        let controller = UIAlertController(title: "Erreur", message: "La sauvegarde de l'image n'a pas fonctionnée", preferredStyle: .alert)
        present(controller, animated: true, completion: nil)
    }
}

extension AccountViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        pictureImageView.image = image
        accountPresenter.imageSelected(image: image)
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AccountViewController: UINavigationControllerDelegate {
}
