
import UIKit
import MediaPlayer
import AVKit

fileprivate enum AVPlayerScaleMode: String {
    case Auto = "Auto"
    case Resize = "Toàn màn hình (Resize)"
    case Fit = "Toàn màn hình (Fit)"
    case Fill = "Toàn màn hình (Fill)"
}

fileprivate enum UIPanGestureRecognizerDirection {
    case undefined
    case left
    case right
    case up
    case down
}

class PlayerViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var viewPlayer: PlayerView!
    
    //MARK: - IBOutlet PlayerControl
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak fileprivate var viewPlayerControl: UIView!
    
    @IBOutlet weak fileprivate var btnDismiss: UIButton!
    @IBOutlet weak fileprivate var btnOption: UIButton!
    @IBOutlet weak fileprivate var timeSlider: UISlider!
    @IBOutlet weak fileprivate var lblCurrentTime: UILabel!
    @IBOutlet weak fileprivate var lblDurationTime: UILabel!
    @IBOutlet weak fileprivate var btnPlayPausePlayer: UIButton!
    @IBOutlet weak fileprivate var lblTitle: UILabel!
    @IBOutlet weak fileprivate var btnNext: UIButton!
    @IBOutlet weak fileprivate var btnBack: UIButton!
    @IBOutlet weak fileprivate var btnFastForward: UIButton!
    @IBOutlet weak fileprivate var btnBackForward: UIButton!
    @IBOutlet weak fileprivate var btnLockControl: UIButton!
    
    //MARK: - Variables
    fileprivate var sliderIsTracking = false
    fileprivate var timerCheckViewPlayerControl:Timer?
    fileprivate var tapRecognizer:UITapGestureRecognizer?
    fileprivate var panRecognizer:UIPanGestureRecognizer?
    fileprivate var panGestureDirection:UIPanGestureRecognizerDirection?
    fileprivate var currentVideoPlayerMode:AVPlayerScaleMode = .Auto

    fileprivate static var KVOContext = 0
    fileprivate var timeObserverToken: AnyObject?
    @objc dynamic var player = AVPlayer()
    
    fileprivate var isPlayerPlaying: Bool = false {
        willSet {
            if isPlayerPlaying != newValue && newValue == true {
                setHidePlayerControl(time: 2.0)
            }
        }
        didSet {
            if isPlayerPlaying {
                btnPlayPausePlayer.setImage(UIImage(named: "ic_pause_new"), for: .normal)
            } else {
                btnPlayPausePlayer.setImage(UIImage(named: "ic_play_new"), for: .normal)
                setShowPlayerControl()
            }
        }
    }
    
    var isPlayerBuffering: Bool = false {
        didSet {
            if isPlayerBuffering {
                indicator.startAnimating()
                btnPlayPausePlayer.isHidden = true
                viewPlayer.isPlaybackBufferEmpty = true
            } else {
                indicator.stopAnimating()
                btnPlayPausePlayer.isHidden = isLockPlayerControl ? true : false
                viewPlayer.isPlaybackBufferEmpty = false
            }
        }
    }
    
    fileprivate var isLockPlayerControl = false {
        didSet {
            btnNext.isHidden = isLockPlayerControl
            btnBack.isHidden = isLockPlayerControl
            btnFastForward.isHidden = isLockPlayerControl
            btnBackForward.isHidden = isLockPlayerControl
            viewPlayer.isEnableSeeking = !isLockPlayerControl
            btnPlayPausePlayer.isHidden = isLockPlayerControl
            btnOption.isHidden = isLockPlayerControl
            timeSlider.isEnabled = !isLockPlayerControl
            panRecognizer?.isEnabled = !isLockPlayerControl
            
            let imageLock = isLockPlayerControl ? "btn_lock_player" : "btn_unlock_player"
            btnLockControl.setImage(UIImage(named: imageLock ), for: .normal)
        }
    }
    
    fileprivate var currentTime: Double {
        get {
            if CMTIME_IS_VALID(player.currentTime()) && !CMTIME_IS_INDEFINITE(player.currentTime()) {
                return CMTimeGetSeconds(player.currentTime())
            } else {
                return 0
            }
        }
        set {
            if CMTIME_IS_VALID(player.currentTime()) && !CMTIME_IS_INDEFINITE(player.currentTime()) {
                let timescale = player.currentTime().timescale
                let newTime = CMTimeMakeWithSeconds(newValue, preferredTimescale: timescale)
                player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
    
    fileprivate var durationTime: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    fileprivate var rate: Float {
        get { return player.rate }
        set { player.rate = newValue }
    }
    
    //MARK: - ViewLifeCycle
    deinit {
        removeObserverPlayerItem()
        removeObserverKVO()
        
        if timeObserverToken != nil {
            player.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
        
        print("deinit PlayerViewController")
    }
    
    static func instantiate() -> PlayerViewController {
        let rootViewController = UIStoryboard(name: "PlayerViewController", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        rootViewController.loadViewIfNeeded()
        return rootViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayerView()
        setupFeatureView()
        setupPlayer()
        
        addObserverKVO()
                
        initGestures()
        
        forceAppLandscape()
    }
    
    private func forceAppPortrait() {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    private func forceAppLandscape() {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    //MARK: - IBActions
    @IBAction func tapBtnDismiss(_ sender: UIButton) {
        dismissPlayer()
    }
    
    @IBAction func tapBtnNext(_ sender: UIButton) {
    }
    
    @IBAction func tapBtnBack(_ sender: UIButton) {
        
    }
    
    @IBAction func tapBtnOption(_ sender: UIButton) {
        showOptionVideoScaleMode(sender: sender)
    }
    
    @IBAction func tapBtnPlayPause(_ sender: UIButton) {
        if isPlayerPlaying {
            pausePlayer()
            
        } else {
            playPlayer()
        }
    }
    
    @IBAction func tapBtnFastForward(_ sender: UIButton) {
        currentTime += 10
    }
    
    @IBAction func tapBtnBackForward(_ sender: UIButton) {
        currentTime -= 10
    }
    
    @IBAction func tapBtnLockControl(_ sender: UIButton) {
        isLockPlayerControl.toggle()
    }
    
    @IBAction func sliderStartTracking(_ sender: UISlider) {
        sliderIsTracking = true
    }
    
    @IBAction func sliderEndedTracking(_ sender: UISlider) {
        hidePlayerControl(2.0)
        sliderIsTracking = false
        
        currentTime = Double(sender.value)
        playPlayer()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        timerCheckViewPlayerControl?.invalidate()
        sliderIsTracking = true
    }
    
    //MARK: - KVO Observation
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &PlayerViewController.KVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
                
        if keyPath == "player.currentItem.duration" {
                        
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = CMTime.zero
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            
            if hasValidDuration {
                timeSlider.maximumValue = Float(newDurationSeconds)
                timeSlider.value = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
                timeSlider.isEnabled = hasValidDuration
                
                lblCurrentTime.isEnabled = hasValidDuration
                lblDurationTime.isEnabled = hasValidDuration
            }
            
        } else if keyPath == "player.rate" {
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            
            if newRate != 0.0 {
                isPlayerPlaying = true
            } else {
                isPlayerPlaying = false
            }
                        
        }
        else if keyPath == "player.currentItem.status" {
            
            let newStatus: AVPlayerItem.Status
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue) ?? .unknown
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .readyToPlay {
                isPlayerBuffering = false
            }
            
            if newStatus == .failed {
                let error = player.currentItem?.error as NSError?
                print(error?.localizedDescription ?? "")
                showAlert(message: error?.localizedDescription ?? "Không thể phát video này. Lỗi không xác định.")
            }
            
        } else if keyPath == "player.currentItem.playbackLikelyToKeepUp" || keyPath == "player.currentItem.playbackBufferFull" {
            isPlayerBuffering = false
            
        } else if keyPath == "player.currentItem.playbackBufferEmpty" {
            isPlayerBuffering = true
            
        } else if keyPath == "player.currentItem" {
            isPlayerBuffering = true
            
//            let asset = player.currentItem?.asset
//            let urlAsset = asset as? AVURLAsset
            
        }
    }
}

//MARK: - Player
fileprivate extension PlayerViewController {
    
    func setupFeatureView() {
        
        viewPlayer.delegate = self
        viewPlayer.seccondsPerSeek = 10
        viewPlayer.seekingTimingShow = 1
    }
    
    func setupPlayerView() {
        
        Bundle.main.loadNibNamed("PlayerViewController", owner: self, options: nil)
        
        viewPlayerControl.frame = view.bounds
        viewPlayerControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(viewPlayerControl)
    }
    
    func setupPlayer() {
        
        player.allowsExternalPlayback = true
        viewPlayer.playerLayer.player = player

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        }
        catch {
        }
    }
}

//MARK: - Player Control
fileprivate extension PlayerViewController {
    
    func initGestures() {
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandle(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        //        tapRecognizer?.delegate = self
        tapRecognizer?.delaysTouchesEnded = false
        tapRecognizer?.delaysTouchesBegan = false
        
        view.addGestureRecognizer(tapRecognizer!)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action:#selector(panGestureHandle(_:)))
        panRecognizer?.minimumNumberOfTouches = 1
        panRecognizer?.maximumNumberOfTouches = 1
        panRecognizer?.delegate = self

        view.addGestureRecognizer(panRecognizer!)
    }
    
    @objc
    func tapGestureHandle(_ recognizer: UIGestureRecognizer) {
        toggleViewPlayerControl()
    }
    
    func toggleViewPlayerControl() {
        
        if viewPlayerControl.alpha > 0 {
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.viewPlayerControl?.alpha = 0.0
            })
            
        } else {
            
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.viewPlayerControl?.alpha = 1.0
                self?.hidePlayerControl(2)
            })
        }
    }
    
    func setHidePlayerControl( time: TimeInterval ) {
        viewPlayerControl.alpha = 1.0
        hidePlayerControl(time)
    }
    
    func setShowPlayerControl() {
        timerCheckViewPlayerControl?.invalidate()
        viewPlayerControl.alpha = 1.0
    }
    
    func hidePlayerControl( _ time: TimeInterval ) {
        
        timerCheckViewPlayerControl?.invalidate()
        timerCheckViewPlayerControl = Timer.scheduledTimer( timeInterval: time, target: self, selector: #selector(removePlayerControl), userInfo: nil, repeats: false)
    }
    
    @objc
    func removePlayerControl() {
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.viewPlayerControl?.alpha = 0.0
        })
    }
}

//MARK: - Feature
fileprivate extension PlayerViewController {
    
    @objc
    func panGestureHandle(_ recognizer: UIPanGestureRecognizer) {
                
        switch recognizer.state {
        case .began:
            
            let velocity:CGPoint = recognizer.velocity(in: recognizer.view)
            detectPanDirection(velocity: velocity)
            
            break
            
        case .changed:
            
            if ( panGestureDirection == .down || panGestureDirection == .up ) {
                
                let changedY = recognizer.translation(in: view).y
                let changedYPer10 = (-1)*changedY/view.bounds.height
                
                let x:CGFloat = recognizer.location(in: view).x
                
                if x < view.frame.size.width / 2 {
                    //left side
                    adjustBrightness(value: CGFloat(changedYPer10/10))
                    
                } else {
                    //right side
                    adjustVolume(value: Float(changedYPer10) )
                }
            }
            
            break
            
        case .ended:
            break
            
        default:
            break
        }
    }
    
    func detectPanDirection(velocity:CGPoint) {
        
        let isVerticalGesture:Bool = abs(velocity.y) > abs(velocity.x)
        if isVerticalGesture {
            if velocity.y > 0 {
                panGestureDirection = .down
            } else {
                panGestureDirection = .up
            }
        } else {
            if velocity.x > 0 {
                panGestureDirection = .right
            } else {
                panGestureDirection = .left
            }
        }
    }
    
    private func adjustBrightness(value: CGFloat) {
        
        let currentBrightness = UIScreen.main.brightness
        var nextValue = value + currentBrightness
        
        if nextValue > 1 { nextValue = 1 }
        if nextValue < 0 { nextValue = 0 }
        
        UIScreen.main.brightness = nextValue
        
        print("Độ sáng \(Int(nextValue*100))%")
    }
    
    private func adjustVolume( value: Float) {
        
        let volume = value + getCurrentVolue()//+ currentValue
        
        if volume <= 1 && volume >= 0 {
            MPVolumeView.adjustVolume(volume)
        }
        
        print(volume)
    }
    
    private func getCurrentVolue() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
}

//MARK: - Feature set video scale mode
fileprivate extension PlayerViewController {
    
    func showOptionVideoScaleMode( sender: UIView ) {
        
        let iconCheckMark = "iconCheckMark"
        
        let optionItems = [
            ( "i0", AVPlayerScaleMode.Auto.rawValue, currentVideoPlayerMode == .Auto ? iconCheckMark : ""),
            ( "i1", AVPlayerScaleMode.Resize.rawValue, currentVideoPlayerMode == .Resize ? iconCheckMark : ""),
            ( "i2", AVPlayerScaleMode.Fit.rawValue, currentVideoPlayerMode == .Fit ? iconCheckMark : ""),
            ( "i3", AVPlayerScaleMode.Fill.rawValue, currentVideoPlayerMode == .Fill ? iconCheckMark : "") ]
        
        var listItems = [FPopupItem]()
        
        for (_id, _title, _icon) in optionItems {
            listItems.append( FPopupItem(id: _id, title: _title, icon: _icon ) )
        }
        
        weak var weakSelf = self
        FPopup.instance.show(withItems: listItems, frameSender: sender.frame, type: FPopupType.dropdown, handler: { selectedIndexPath in
            switch selectedIndexPath.row {
            case 0:
                weakSelf?.currentVideoPlayerMode = .Auto
                weakSelf?.setVideoScaleMode(mode: .Auto)
                break
            case 1:
                weakSelf?.currentVideoPlayerMode = .Resize
                weakSelf?.setVideoScaleMode(mode: .Resize)
                break
            case 2:
                weakSelf?.currentVideoPlayerMode = .Fit
                weakSelf?.setVideoScaleMode(mode: .Fit)
                break
            case 3:
                weakSelf?.currentVideoPlayerMode = .Fill
                weakSelf?.setVideoScaleMode(mode: .Fill)
                break
                
            default:
                break
            }
        })
    }
    
    func setVideoScaleMode( mode:AVPlayerScaleMode ) {
        switch mode {
        case .Auto: viewPlayer?.playerLayer.videoGravity = .resizeAspect
        case .Resize: viewPlayer?.playerLayer.videoGravity = .resize
        case .Fit: viewPlayer?.playerLayer.videoGravity = .resizeAspect
        case .Fill: viewPlayer?.playerLayer.videoGravity = .resizeAspectFill
        }
    }
}

//MARK: - PanGestureDelagate
extension PlayerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizerView = gestureRecognizer.view, gestureRecognizerView.frame.origin.y < 0  else { return true }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Volume Helper
fileprivate extension MPVolumeView {
    
    static func adjustVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            slider?.value = volume
        }
    }
}

// MARK: - FSeekingPlayerDelegate
extension PlayerViewController: FSeekingPlayerDelegate {
    
    func seekingPlayer(in player: UIView, seekTo seconds: Int) {
        currentTime += Double(seconds)
    }
}

//MARK: - Notification
extension PlayerViewController {
    
    fileprivate func addObserverPlayerItem() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFinishPlayItem),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector( accessLogEvent(_:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: player.currentItem)
        
        NotificationCenter.default.addObserver(self, selector:#selector(newErrorLogEntry), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        
        NotificationCenter.default.addObserver(self, selector:#selector(failedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        
    }
    
    fileprivate func removeObserverPlayerItem() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: player.currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                                  object: player.currentItem)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemNewErrorLogEntry,
                                                  object: player.currentItem)
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemFailedToPlayToEndTime,
                                                  object: player.currentItem)
    }
    
    fileprivate func addObserverKVO() {
                
        addObserver(self, forKeyPath: "player.currentItem", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.rate", options: [.new], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.currentItem.status", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.currentItem.duration", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.currentItem.playbackLikelyToKeepUp", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.currentItem.playbackBufferFull", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        addObserver(self, forKeyPath: "player.currentItem.playbackBufferEmpty", options: [.new, .initial], context: &PlayerViewController.KVOContext)
        
        //
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) {
            [weak self] time in
            
            if self?.player.currentItem?.duration != CMTime.indefinite {
                self?.updatePlayerControl()
            }
            
            } as AnyObject?
    }
    
    fileprivate func removeObserverKVO() {
                
        removeObserver(self, forKeyPath: "player.currentItem", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.rate", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.currentItem.status", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.currentItem.duration", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.currentItem.playbackLikelyToKeepUp", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.currentItem.playbackBufferFull", context: &PlayerViewController.KVOContext)
        removeObserver(self, forKeyPath: "player.currentItem.playbackBufferEmpty", context: &PlayerViewController.KVOContext)
    }
    
    fileprivate func updatePlayerControl() {
        
        isPlayerBuffering = false
        
        lblCurrentTime.text = convertSecondIntToPlayerTimeString(seconds: currentTime)
        lblDurationTime.text = convertSecondIntToPlayerTimeString(seconds: durationTime)
        
        if !sliderIsTracking {
            timeSlider.value = Float(currentTime)
//            timeSlider.seekButtonByPlayer(at: Float(currentTime))
        }
    }
    
    @objc fileprivate func didFinishPlayItem() {
        
    }
    
    @objc fileprivate func accessLogEvent( _ notification: NSNotification) {
        
    }
    
    @objc func newErrorLogEntry() {
        
    }
    
    @objc func failedToPlayToEndTime( _ notification: Notification) {
        
        guard let userInfo = notification.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
            return
        }
        
        print(#function)
        print(error.localizedDescription)
        
        showAlert(message: error.localizedDescription)
    }
}

//MARK: - Public function
extension PlayerViewController {
    
    func reloadStream (source_url: String, title:String) {
        
        lblTitle.text = title
        
        guard let contentURL = URL(string: source_url ) else {
            showAlert(message: "Link không tồn tại! Chi tiết lỗi: \(source_url)")
            return
        }
        
        print(" \n LINK ---->>> \(source_url) \n")
        
        let asset = AVURLAsset(url: contentURL)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        
        removeObserverPlayerItem()
        addObserverPlayerItem()
        
        player.play()
    }
    
    func stopPlayer() {
        player.replaceCurrentItem(with: nil)
    }
    
    func pausePlayer() {
        player.pause()
    }
    
    func playPlayer() {
        player.play()
    }
    
    func dismissPlayer() {
        
        forceAppPortrait()
        
        stopPlayer()
                
        dismiss(animated: true) {
            
        }
    }
    
    func showAlert( message:String ) {
        print( "Không thể phát video này. Chi tiết lỗi: \(message)")
    }
}

func convertSecondIntToPlayerTimeString(seconds: Double?) -> String {
    
    if seconds          == nil { return "" }
    let wholeMinutes    = Int(trunc(seconds! / 60))
    let hour            = Int(wholeMinutes/60)
//
    if hour >= 1 {
        return String(format:"%d:%02d:%02d",hour, wholeMinutes - hour*60 , Int(trunc(seconds!)) - wholeMinutes * 60)
        
    } else {
        return String(format:"%d:%02d", wholeMinutes, Int(trunc(seconds!)) - wholeMinutes * 60)
    }
}
