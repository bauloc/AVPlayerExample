
import UIKit

protocol FSeekingPlayerDelegate: class {
    func seekingPlayer(in player: UIView, seekTo seconds: Int)
}

class FSeekingPlayer: UIView {
    //  MARK: Variables
    
    /// A double tap as a seek.
    /// The number of seconds that will be forward or backward per seek.
    var seccondsPerSeek: Int = 10 {
        didSet {
            seekingView.secondsPerSeek = seccondsPerSeek
        }
    }
    
    /// FSeekingView showing time.
    var seekingTimingShow: Double = 1 {
        didSet {
            seekingView.timingShow = seekingTimingShow
        }
    }
    
    /// If seeking when player is being in playbackBufferEmpty, we will add the seeking time to seekedTimeRemain.
    /// We will seek to seekedTimeRemain immediately when play change state to playbackLikelyToKeepUp
    fileprivate var seekedTimeRemain: Int = 0
    
    /// Indicate whether player is playing or loading
    var isPlaybackBufferEmpty = false {
        didSet {
            guard !isPlaybackBufferEmpty, seekedTimeRemain != 0 else { return }
            delegate?.seekingPlayer(in: self, seekTo: seekedTimeRemain)
            seekedTimeRemain = 0
        }
    }
    
    /// Default true. Enable or disable seeking.
    var isEnableSeeking = true
    
    /// Delegate to trigger seeking action.
    weak var delegate: FSeekingPlayerDelegate?
    
    /// Gesture recognizers
    fileprivate var doubleTapLeft: UITapGestureRecognizer!
    fileprivate var doubleTapRight: UITapGestureRecognizer!
    
    /// Views
    private var seekingView = FSeekingView()
    private var receivingDoubleTapViewLeft = UIView()
    private var receivingDoubleTapViewRight = UIView()
    
    //  MARK: Initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        initialGestures()
        
        initialReveivingDoubleTapViews()
        
        initialSeekingView()
    }
    
    private func initialGestures() {
        /// Left
        doubleTapLeft = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapRecognized(doubleTap:)))
        doubleTapLeft.numberOfTapsRequired = 2
        doubleTapLeft.delegate = self
        
        /// Right
        doubleTapRight = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapRecognized(doubleTap:)))
        doubleTapRight.numberOfTapsRequired = 2
        doubleTapRight.delegate = self
    }
    
    private func initialReveivingDoubleTapViews() {
        /// Left
        receivingDoubleTapViewLeft.backgroundColor = UIColor.clear
        receivingDoubleTapViewLeft.addGestureRecognizer(doubleTapLeft)
        addSubview(receivingDoubleTapViewLeft)
        
        /// Right
        receivingDoubleTapViewRight.backgroundColor = UIColor.clear
        receivingDoubleTapViewRight.addGestureRecognizer(doubleTapRight)
        addSubview(receivingDoubleTapViewRight)
    }
    
    private func initialSeekingView() {
        seekingView.timingShow = seekingTimingShow
        seekingView.secondsPerSeek = seccondsPerSeek
        seekingView.delegate = self
        addSubview(seekingView)
    }
    
    //  MARK: Override
    override func layoutSubviews() {
        super.layoutSubviews()
        /// Seeking View is updated frame
        seekingView.frame = bounds
        
        /// Receiving View Left is updated frame
        let centerBlank: CGFloat = 180
        let width = bounds.width/2 - centerBlank/2
        let origin = CGPoint(x: 0, y: 0)
        let size = CGSize(width: width, height: bounds.height)
        let frameLeft = CGRect(origin: origin, size: size)
        receivingDoubleTapViewLeft.frame = frameLeft
        
        /// Receiving View Right is updated frame
        let originRight = CGPoint(x: bounds.width - width, y: 0)
        let frameRight = CGRect(origin: originRight, size: size)
        receivingDoubleTapViewRight.frame = frameRight
    }
    
    //  MARK: Actions
    @objc private func onDoubleTapRecognized(doubleTap: UITapGestureRecognizer) {
        guard isEnableSeeking && seekingView.isHidden else { return }
        let type: FSeekingType = doubleTap == doubleTapLeft ? .backward : .forward
        seekingView.show(type)
    }
}

//  MARK: Seeking View Delegate
extension FSeekingPlayer: FSeekingViewDelegate {
    func didPressBackward() {
        seekTo(-seccondsPerSeek)
    }
    
    func didPressForward() {
        seekTo(seccondsPerSeek)
    }
    
    private func seekTo(_ seconds: Int) {
        if isPlaybackBufferEmpty {
            seekedTimeRemain += seconds
        } else {
            delegate?.seekingPlayer(in: self, seekTo: seconds)
        }
    }
}

//  MARK: UI Gesture Recognizer Delegate
extension FSeekingPlayer: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == doubleTapLeft || gestureRecognizer == doubleTapRight
    }
}

