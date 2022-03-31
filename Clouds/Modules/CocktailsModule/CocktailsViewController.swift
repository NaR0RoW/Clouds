import SnapKit
import UIKit

final class CocktailsViewController: UIViewController {
    var cocktailsPresenter: CocktailsPresenterProtocol?

    private let cocktailsCollectionView: UICollectionView = {
        let item: NSCollectionLayoutItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .estimated(40.0),
                heightDimension: .absolute(48.0)
            )
        )
            
        let group: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50.0)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(8.0)
        
        let section: NSCollectionLayoutSection = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 15.0, leading: 15.0, bottom: 0.0, trailing: 15.0)
        section.interGroupSpacing = 8.0
        
        let layout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout(section: section)
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.registerCell(CocktailCell.self)
        collectionView.allowsMultipleSelection = true
        
        return collectionView
    }()
    
    private let cocktailSearchTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = "Cocktail name"
        textField.textAlignment = .center
        textField.backgroundColor = .systemBackground
        textField.layer.shadowOpacity = 0.5
        textField.layer.shadowRadius = 10.0
        textField.layer.shadowOffset = .zero
        textField.layer.shadowColor = UIColor.systemGray.cgColor
        textField.autocorrectionType = .no
        
        return textField
    }()
    
    private lazy var failureAlert: UIAlertController = {
        let alert: UIAlertController = UIAlertController(
            title: "An error occurred",
            message: "Oops, something went wrong! Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        return alert
    }()

    override func viewDidLoad() {
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension CocktailsViewController {
    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(cocktailsCollectionView)
        view.addSubview(cocktailSearchTextField)
        
        cocktailsCollectionView.dataSource = self
        cocktailSearchTextField.delegate = self
        
        configureCocktailsCollectionView()
        configureCocktailSearchTextField()
       
        addGestureRecognizer()
    }
    
    private func configureCocktailsCollectionView() {
        cocktailsCollectionView.snp.removeConstraints()
        cocktailsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.height).dividedBy(1.25)
        }
    }
    
    private func configureCocktailSearchTextField() {
        cocktailSearchTextField.snp.removeConstraints()
        cocktailSearchTextField.layer.cornerRadius = 15.0
        cocktailSearchTextField.snp.makeConstraints { make in
            make.top.equalTo(cocktailsCollectionView.snp.bottom).offset(15.0)
            make.leading.trailing.equalToSuperview().inset(16.0)
            make.height.greaterThanOrEqualTo(50.0)
        }
    }
    
    private func addGestureRecognizer() {
        cocktailsCollectionView.backgroundView = UIView(frame: view.frame)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        cocktailsCollectionView.backgroundView?.gestureRecognizers = [tapGestureRecognizer]
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        let responderAction: String = UIResponder.keyboardFrameEndUserInfoKey
        if let keyboardFrame: NSValue = notification.userInfo?[responderAction] as? NSValue {
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height
            
            cocktailSearchTextField.snp.removeConstraints()
            cocktailSearchTextField.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(keyboardHeight)
                make.width.equalToSuperview()
                make.height.equalTo(50.0)
            }
            cocktailSearchTextField.layer.cornerRadius = 0.0
            
            cocktailsCollectionView.snp.removeConstraints()
            cocktailsCollectionView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(cocktailSearchTextField.snp.top).inset(-15.0)
            }
            
            view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide() {
        configureCocktailsCollectionView()
        configureCocktailSearchTextField()
    }
}

extension CocktailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cocktailsPresenter?.numberOfItemsInSection() ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CocktailCell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CocktailCell
        let cocktail: Drinks? = cocktailsPresenter?.cocktailForItemAt(indexPath: indexPath)
        cell.configureCell(with: cocktail)
        
        return cell
    }
}

extension CocktailsViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let searchTerm: String = textField.text else { return false }
        
        cocktailsPresenter?.filterCocktails(searchTerm: searchTerm, range: range, string: string) { result in
            switch result {
            case .selectItem(let indexPath):
                cocktailsCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            case .deselectItem(let indexPath):
                cocktailsCollectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        
        return true
    }
}

extension CocktailsViewController: CocktailsViewProtocol {
    func success() {
        cocktailsCollectionView.reloadData()
    }
    
    func failure() {
        present(failureAlert, animated: true)
    }
}
