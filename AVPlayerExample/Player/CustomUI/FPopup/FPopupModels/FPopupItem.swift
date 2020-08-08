
import UIKit

class FPopupItem {
    
    var id      = ""
    var title   = ""
    var icon    = ""
    var hideIcon = false
    
    init() {
        
    }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    init(id: String, title: String, icon: String) {
        self.id = id
        self.title = title
        self.icon = icon
    }

}
