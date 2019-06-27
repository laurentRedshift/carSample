import UIKit

struct EditAccountViewModel {
    let firstName: String
    let lastName: String
    let address: String
    let birthDate: Date
}

extension DateFormatter {
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
}

class EditAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var adressTextField: UITextField!
    let datePicker = UIDatePicker()
    
    var presenter: EditAccountPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        navigationItem.title = NSLocalizedString("account.edit", comment: "")
       let saveButtonItem = UIBarButtonItem(title: NSLocalizedString("account.item.save", comment: ""), style: .plain, target: self, action: #selector(tapToSave))
        navigationItem.rightBarButtonItems = [saveButtonItem]
        firstNameTextField.becomeFirstResponder()
        configureDatePicker()
        updateSaveButtonStatus()
    }
    
    private func updateSaveButtonStatus() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = allFieldWithSomething()
    }
    
    private func allFieldWithSomething(exceptTextField: UITextField? = nil) -> Bool {
        var textFields = [firstNameTextField, ageTextField, nameTextField, adressTextField]
        if let exceptTextField = exceptTextField {
            textFields = textFields.filter({ $0 != exceptTextField })
        }
        
        for textField in textFields where textField?.text == nil || textField?.text?.isEmpty ?? true {
            return false
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        updateSaveButtonStatus()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            navigationItem.rightBarButtonItems?.first?.isEnabled = allFieldWithSomething(exceptTextField: textField) && !string.isEmpty
            return true
        }
        
        var currentFieldWithSomething = true
        if let range = Range(range, in: text), text.replacingCharacters(in: range, with: string).isEmpty {
            currentFieldWithSomething = false
        }
        navigationItem.rightBarButtonItems?.first?.isEnabled = allFieldWithSomething(exceptTextField: textField) && currentFieldWithSomething
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateSaveButtonStatus()
        return true
    }
    
    @objc
    func tapToSave(_ sender: UIBarButtonItem) {
        print("Save")
        presenter.viewDidTapSave()
    }
    
    private func configureDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        ageTextField.inputAccessoryView = toolbar
        ageTextField.inputView = datePicker
    }
    
    @objc
    func doneDatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        ageTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
        updateSaveButtonStatus()
    }
    
    @objc
    func cancelDatePicker() {
        self.view.endEditing(true)
        updateSaveButtonStatus()
    }
}

extension EditAccountViewController: EditAccountInterface {
    
    var editAccountViewModel: EditAccountViewModel? {
        guard let firstName = firstNameTextField.text, let name = nameTextField.text, let address = adressTextField.text else { return nil }
        return EditAccountViewModel(firstName: firstName, lastName: name, address: address, birthDate: datePicker.date)
    }
    
    func display(editAccountViewModel: EditAccountViewModel) {
        firstNameTextField.text = editAccountViewModel.firstName
        nameTextField.text = editAccountViewModel.lastName
        adressTextField.text = editAccountViewModel.address
        ageTextField.text = DateFormatter.dateFormatter().string(from: editAccountViewModel.birthDate)
        datePicker.date = editAccountViewModel.birthDate
        updateSaveButtonStatus()
    }
    
    func displayEmptyAccount() {
        updateSaveButtonStatus()
    }
    
    func displaySaveError() {
        let controller = UIAlertController(title: "Erreur", message: "La sauvegarde n'a pas fonctionnée", preferredStyle: .alert)
        present(controller, animated: true, completion: nil)
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
}
