
import UIKit

extension UIView {
    func showShadow() {
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize.zero
//        layer.shadowRadius = 10
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 1, height: 1)
//        layer.shadowRadius = 3
//
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
//        layer.shouldRasterize = true
//        layer.rasterizationScale = 1
    }
    
    func roundCorner() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
//        self.clipsToBounds = true

        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 0.5
    }
}
