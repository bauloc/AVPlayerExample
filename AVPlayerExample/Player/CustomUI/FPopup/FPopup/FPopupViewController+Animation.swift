
import UIKit

extension FPopupViewController {
    func goInAnimation() {
        switch type {
        case .dropdown:
            fadeIn()
            break
            
        case .sheet:
            fadeIn()
            B2T()
            break
        }
    }
    
    func goOutAnimation(completeHandler: @escaping ()->Void) {
        switch type {
        case .dropdown:
            fadeOut(completeHandler)
            break
            
        case .sheet:
            fadeOut(completeHandler)
            T2B()
            break
        }
    }
    
    private func fadeIn() {
        weak var weakSelf = self
        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            weakSelf?.view.alpha = 1
        }
    }
    
    private func fadeOut(_ completeHandler: @escaping ()->Void) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3, animations: {
            weakSelf?.view.alpha = 0
        }) { (success) in
            completeHandler()
        }
    }
    
    /// B2T means animating from Bottom to Top
    private func B2T() {
        weak var weakSelf = self
        let backupPointY = contentView.frame.origin.y
        contentView.frame.origin.y = bottomPointY
        UIView.animate(withDuration: 0.3) {
            weakSelf?.contentView.frame.origin.y = backupPointY
        }
    }
    
    /// T2B means animating from Top to Bottom
    private func T2B() {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.3) {
            weakSelf?.contentView.frame.origin.y = weakSelf?.bottomPointY ?? 0
        }
    }
}
