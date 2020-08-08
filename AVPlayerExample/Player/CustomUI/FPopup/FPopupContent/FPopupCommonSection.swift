
import UIKit

class FPopupCommonSection: UITableViewCell {
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
    
    //MARK: IBOutlet
    @IBOutlet weak var lbTitle: UILabel!
}
