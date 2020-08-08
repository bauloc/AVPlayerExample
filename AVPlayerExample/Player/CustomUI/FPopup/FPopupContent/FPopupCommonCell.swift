
import UIKit

class FPopupCommonCell: UITableViewCell {
    
    //MARK: Variables
    var isHighlightable = false {
        willSet {
            makeHighlight(newValue)
        }
    }
    
    var item = FPopupItem() {
        didSet {
            loadData()
        }
    }
    
    var type = FPopupType.dropdown {
        didSet {
            switch type {
            case .dropdown:
                contentView.backgroundColor = UIColor(white: 0, alpha: 0.6)
                break
                
            case .sheet:
                contentView.backgroundColor = UIColor(hex: "#151616")
                break
            }
        }
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLeftPading: NSLayoutConstraint!
    
    //MARK: Override
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        contentView.backgroundColor = highlighted ? UIColor.gray : UIColor.black
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ivIcon.image = nil
        ivIcon.alpha = 1
        lbTitle.text = nil
        lbTitle.textColor = .white
    }
    
    //MARK: Funcs
    private func loadData() {
        
        lbTitle.text = item.title
        ivIcon.image = UIImage(named: item.icon)
        
        if item.hideIcon {
            ivIcon.isHidden     = true
            iconWidth.constant  = 0
            titleLeftPading.constant = 0
        }
        
    }
    
    func makeHighlight(_ isHighlight: Bool) {
        if isHighlight {
            ivIcon.alpha = 1
            lbTitle.textColor = .white
        } else {
            ivIcon.alpha = 0.5
            lbTitle.textColor = .gray
        }
    }
}
