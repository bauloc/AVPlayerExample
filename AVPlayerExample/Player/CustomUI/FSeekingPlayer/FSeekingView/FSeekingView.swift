
import UIKit

protocol FSeekingViewDelegate: class {
    func didPressBackward()
    func didPressForward()
}

enum FSeekingType {
    case backward
    case forward
}

class FSeekingView: UIView {
    //  MARK: IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var lbSecondBackward: UILabel!
    @IBOutlet weak var lbSecondForward: UILabel!
    
    //  MARK: Variables
    /// The number of seconds that will be forward or backward per seek
    var secondsPerSeek: Int = 0
    
    /// FSeekingView showing time
    var timingShow: Double = 1
    
    /// Timing Animation
    var timingFadeIn: Double = 0.3
    var timingFadeOut: Double = 0.3
    
    /// Delegate tot trigger seeking action
    weak var delegate: FSeekingViewDelegate?
    
    /// Timer to hide FSeeking View
    private var timer = Timer()
    
    /// Tap Gesture Recognizer to dismiss FSeeking View
    fileprivate var tapToDismiss: UITapGestureRecognizer!
    
    /// The number of seconds that player will backward
    private var secondsBackward = 0 {
        didSet {
            lbSecondBackward.isHidden = secondsBackward == 0
            lbSecondBackward.text = "\(secondsBackward) giây"
        }
    }
    
    /// The number of seconds that player will forward
    private var secondsForward = 0 {
        didSet {
            lbSecondForward.isHidden = secondsForward == 0
            lbSecondForward.text = "\(secondsForward) giây"
        }
    }
    
    //  MARK: Initial
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        /// Initial custom view
        Bundle.main.loadNibNamed("FSeekingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        /// Default is hidden
        isHidden = true
        lbSecondBackward.isHidden = true
        lbSecondForward.isHidden = true
        
        /// Initial tap to dismiss
        tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(onTapToDismissTriggered))
        tapToDismiss.delegate = self
        addGestureRecognizer(tapToDismiss)
    }
    
    //  MARK: Funcs
    func show(_ type: FSeekingType) {
        isHidden = false
        
        if type == .backward { onBackwardPressed(UIButton()) }
        else { onForwardPressed(UIButton()) }
        
        weak var weakSelf = self
        alpha = 0
        UIView.animate(withDuration: timingFadeIn, animations: {
            weakSelf?.alpha = 1
        }, completion: { _ in })
    }
    
    func hide() {
        
        secondsBackward = 0
        secondsForward = 0
        
        weak var weakSelf = self
        UIView.animate(withDuration: timingFadeOut, animations: {
            weakSelf?.alpha = 0
        }, completion: { _ in
            weakSelf?.isHidden = true
        })
    }
    
    //  MARK: Timer handler
    private func addTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: timingShow, target: self, selector: #selector(stopShowing), userInfo: nil, repeats: false)
    }
    
    @objc private func stopShowing() {
       hide()
    }
    
    //  MARK: Actions
    @IBAction func onBackwardPressed(_ sender: UIButton) {
        addTimer()
        delegate?.didPressBackward()
        
        secondsForward = 0
        secondsBackward += secondsPerSeek
    }
    
    @IBAction func onForwardPressed(_ sender: UIButton) {
        addTimer()
        delegate?.didPressForward()
        
        secondsBackward = 0
        secondsForward += secondsPerSeek
    }
    
    @objc private func onTapToDismissTriggered() {
        timer.invalidate()
        hide()
    }
}

//  MARK: UI Gesture Recognizer Delegate
extension FSeekingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == tapToDismiss
    }
}
