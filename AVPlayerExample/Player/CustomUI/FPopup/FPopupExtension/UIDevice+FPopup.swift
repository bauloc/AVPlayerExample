
import UIKit

extension UIDevice {
    static var isIphoneX: Bool {
        get {
            return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
        }
    }
}
