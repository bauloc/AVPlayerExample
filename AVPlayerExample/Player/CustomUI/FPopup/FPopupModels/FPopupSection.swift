
import UIKit

struct FPopupSection {
    var title = ""
    var items = [FPopupItem]()
    
    init(title: String, items: [FPopupItem]) {
        self.title = title
        self.items = items
    }
}
