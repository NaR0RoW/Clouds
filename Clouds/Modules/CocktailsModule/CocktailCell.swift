import UIKit

final class CocktailCell: UICollectionViewCell {
    private let cocktailNameLabel: UILabel = UILabel()
    private let gradient: CAGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemGray3
        configureCocktailNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CocktailCell {
    private func configureCocktailNameLabel() {
        addSubview(cocktailNameLabel)
        cocktailNameLabel.textColor = .systemBackground
        
        cocktailNameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10.0)
            make.centerY.equalToSuperview()
        }
    }
    
    func configureCell(with cocktail: Drinks?) {
        cocktailNameLabel.text = cocktail?.cocktailName
        layer.cornerRadius = 15.0
        clipsToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectCell()
            } else {
                deselectCell()
            }
        }
    }
    
    private func selectCell() {
        gradient.frame = bounds
        gradient.colors = [UIColor.systemRed.cgColor, UIColor.systemPurple.cgColor]
        
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func deselectCell() {
        gradient.removeFromSuperlayer()
    }
}
