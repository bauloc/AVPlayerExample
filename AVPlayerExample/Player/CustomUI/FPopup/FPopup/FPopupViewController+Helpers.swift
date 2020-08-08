
import UIKit

extension FPopupViewController {
    func getWindowFrame() -> CGRect {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.window?.frame ?? CGRect.zero
    }
    
    func sizeOfString(string: String) -> CGSize {
        let lb = UILabel()
        lb.text = string
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.lineBreakMode = .byTruncatingTail
        lb.textAlignment = .left
        
        return lb.intrinsicContentSize
    }
}
