
import UIKit

extension FPopupViewController {
    var contentViewFrame: CGRect {
        get {
            switch type {
            case .dropdown:
                return DROPDOWN_ContentViewFrame
                
            case .sheet:
                return SHEET_ContentViewFrame
            }
        }
    }
    
    var cCellHeight: CGFloat {
        get {
            return 50
        }
    }
}

extension FPopupViewController {
    var bottomPointY: CGFloat {
        get {
            return UIScreen.main.bounds.height
        }
    }
    
    var isFullHeight: Bool {
        get {
            switch type {
            case .dropdown:
                return DROPDOWN_ContentViewHeight < DROPDOWN_ContentViewEstimatingHeight
                
            case .sheet:
                return SHEET_ContentViewHeight < SHEET_ContentViewEstimatingHeight
            }
        }
    }
}

//MARK: Dropdown frame calculation
extension FPopupViewController {
    fileprivate var DROPDOWN_ContentViewFrame: CGRect {
        get {
            return CGRect(origin: DROPDOWN_ContentViewPoint, size: DROPDOWN_ContentViewSize)
        }
    }
    
    fileprivate var DROPDOWN_ContentViewEstimatingHeight: CGFloat {
        get {
            var numberCells: CGFloat = 0
            for section in sections {
                numberCells += section.title == "" ? 0 : 1
                numberCells += CGFloat(section.items.count)
            }
            
            return cCellHeight * numberCells
        }
    }
    
    private var DROPDOWN_ContentViewEstimatingY: CGFloat {
        get {
            return frameSender.origin.y + frameSender.size.height
        }
    }
    
    fileprivate var DROPDOWN_ContentViewHeight: CGFloat {
        get {
            let maxHeight = isShownOnUpper ? frameSender.origin.y - limitEdgeTop : limitEdgeBottom - DROPDOWN_ContentViewEstimatingY
            let height = min(maxHeight, DROPDOWN_ContentViewEstimatingHeight)
            return heightLimiting != 0 && height > heightLimiting ? heightLimiting : height
        }
    }
    
    private var DROPDOWN_ContentViewWidth: CGFloat {
        get {
            var itemWidth: CGFloat = 0
            var sectionWidth: CGFloat = 0
            for section in sections {
                
                ///Calculate max width of section
                let sectionSize = sizeOfString(string: section.title)
                sectionWidth = max(sectionSize.width, sectionWidth)
                
                for item in section.items {
                    ///Calculate max width of item
                    let size = sizeOfString(string: item.title)
                    itemWidth = max(size.width, itemWidth)
                }
            }
            
            itemWidth = itemWidth + 16 + 24 + 16 + 16 //Constraints's constant of Cell on storyboard
            sectionWidth = sectionWidth + 16 + 16 //Constraints's constant of Section on storyboard
            
            return max(itemWidth, sectionWidth)
        }
    }
    
    private var minHeight: CGFloat {
        get {
            return 128
        }
    }
    
    private var limitEdgeLeft: CGFloat {
        get {
            var limit: CGFloat = 4
            ///Handle UI on iPhone X
            if #available(iOS 11.0, *) {
                limit += UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
            }
            return limit
        }
    }
    private var limitEdgeRight: CGFloat {
        get {
            var limit: CGFloat = 4
            ///Handle UI on iPhone X
            if #available(iOS 11.0, *) {
                limit += UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0
            }
            return view.frame.size.width - limit
        }
    }
    
    private var limitEdgeTop: CGFloat {
        get {
            return 4
        }
    }
    private var limitEdgeBottom: CGFloat {
        get {
            return view.frame.size.height - 4
        }
    }
    
    private var DROPDOWN_ContentViewSize: CGSize {
        get {
            return CGSize(width: DROPDOWN_ContentViewWidth, height: DROPDOWN_ContentViewHeight)
        }
    }
    
    private var DROPDOWN_ContentViewPoint: CGPoint {
        get {
            
            let btnEndX = frameSender.origin.x + frameSender.size.width
            let estimatingX = btnEndX - DROPDOWN_ContentViewWidth
            let maxX = limitEdgeRight - DROPDOWN_ContentViewWidth
            let x = estimatingX < limitEdgeLeft ? limitEdgeLeft : estimatingX > maxX ? maxX : estimatingX
            
            var y = isShownOnUpper ? frameSender.origin.y - DROPDOWN_ContentViewWidth : DROPDOWN_ContentViewEstimatingY
            
            ///Handle UI on iPhone X
            if #available(iOS 11.0, *) {
                y += UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            }
            
            return CGPoint(x: x, y: y)
        }
    }
    
    private var isShownOnUpper: Bool {
        get {
            let maxHeight = limitEdgeBottom - DROPDOWN_ContentViewEstimatingY
            return DROPDOWN_ContentViewEstimatingHeight > maxHeight &&  maxHeight < minHeight
        }
    }
}

//MARK: Sheet frame calculation
extension FPopupViewController {
    fileprivate var SHEET_ContentViewFrame: CGRect {
        get {
            return CGRect(origin: SHEET_ContentViewPoint, size: SHEET_ContentViewSize)
        }
    }
    
    private var SHEET_ContentViewSize: CGSize {
        get {
            var width = UIScreen.main.bounds.width
            ///Handle UI on iPhone X
            if #available(iOS 11.0, *) {
                width -= UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
                width -= UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0
            }
            return CGSize(width: width, height: SHEET_ContentViewHeight)
        }
    }
    
    private var SHEET_ContentViewPoint: CGPoint {
        get {
            var x: CGFloat = 0
            ///Handle UI on iPhone X
            if #available(iOS 11.0, *) {
                x += UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
            }
            return CGPoint(x: x, y: SHEET_ContentViewY)
        }
    }
    
    fileprivate var SHEET_ContentViewEstimatingHeight: CGFloat {
        get {
            var numberCells: CGFloat = 0
            for section in sections {
                numberCells += section.title == "" ? 0 : 1
                numberCells += CGFloat(section.items.count)
            }
            
            ///Handle UI on iPhone X
            var additional: CGFloat = 0
            if #available(iOS 11.0, *) {
                additional += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            }
            
            return cCellHeight * numberCells + additional
        }
    }
    
    fileprivate var SHEET_ContentViewHeight: CGFloat {
        get {
            let estimatingHeight = SHEET_ContentViewEstimatingHeight
            let maxHeight = 2*UIScreen.main.bounds.height/3
            return min(maxHeight, estimatingHeight)
        }
    }
    
    private var SHEET_ContentViewY: CGFloat {
        get {
            let contentViewHeight = SHEET_ContentViewHeight
            let y = bottomPointY - contentViewHeight
            return max(0, y)
        }
    }
}
