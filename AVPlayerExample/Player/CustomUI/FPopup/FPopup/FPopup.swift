
import UIKit

class FPopup {
    static let instance = FPopup()
    
    var fPopupVC: FPopupViewController?
    var timer = Timer()
    
    func show(withItems items: [FPopupItem],
              frameSender: CGRect,
              heightLimiting: CGFloat = 0,
              type: FPopupType,
              highlightIndexPath: IndexPath? = nil,
              handler: @escaping (IndexPath) -> Void) {
        
        fPopupVC = FPopupViewController.show(items: items,
                                             frameSender: frameSender,
                                             heightLimiting: heightLimiting,
                                             type: type,
                                             highlightIndexPath: highlightIndexPath,
                                             handler: handler)
        
        if type == .dropdown {
            scheduleToHidePopup(5)
        }
    }
    
    func show(withSections sections: [FPopupSection],
              frameSender: CGRect,
              heightLimiting: CGFloat = 0,
              type: FPopupType,
              highlightIndexPath: IndexPath? = nil,
              handler: @escaping (IndexPath) -> Void) {
        
        fPopupVC = FPopupViewController.show(sections: sections,
                                             frameSender: frameSender,
                                             heightLimiting: heightLimiting,
                                             type: type,
                                             highlightIndexPath: highlightIndexPath,
                                             handler: handler)
        
        if type == .dropdown {
            scheduleToHidePopup(5)
        }
    }
    
    func hide() {
        fPopupVC?.onDismissPopup(UIButton())
    }
    
    func scrollTo(item: Int, section: Int = 0) {
        fPopupVC?.scrollTo(item: item, section: section)
    }
    
    //MARK: Timing
    func scheduleToHidePopup( _ time: TimeInterval ) {
        timer.invalidate()
        timer = Timer.scheduledTimer( timeInterval: time, target: self, selector: #selector(FPopup.hidePopup), userInfo: nil, repeats: false)
    }
    
    @objc private func hidePopup() {
        hide()
    }
}
