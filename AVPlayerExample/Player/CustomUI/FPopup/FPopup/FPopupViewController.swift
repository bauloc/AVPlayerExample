
import UIKit

enum FPopupType {
    case dropdown
    case sheet
}

class FPopupViewController: UIViewController {
    //MARK: Static method
    static func show(items: [FPopupItem],
                     frameSender: CGRect,
                     heightLimiting: CGFloat = 0,
                     type: FPopupType,
                     highlightIndexPath: IndexPath? = nil,
                     handler: @escaping (IndexPath) -> Void) -> FPopupViewController{
        
        let sections = [FPopupSection(title: "", items: items)]
        return FPopupViewController.show(sections: sections, frameSender: frameSender, type: type, highlightIndexPath: highlightIndexPath, handler: handler)
    }
    
    static func show(sections: [FPopupSection],
                     frameSender: CGRect,
                     heightLimiting: CGFloat = 0,
                     type: FPopupType,
                     highlightIndexPath: IndexPath? = nil,
                     handler: @escaping (IndexPath) -> Void) -> FPopupViewController {
        
        let fPopupVC = FPopupViewController.getViewVC()
        fPopupVC.sections = sections
        fPopupVC.frameSender = frameSender
        fPopupVC.heightLimiting = heightLimiting
        fPopupVC.type = type
        fPopupVC.highlightIndexPath = highlightIndexPath
        fPopupVC.handler = handler
        fPopupVC.initWindow()
        return fPopupVC
    }
    
    static private func getViewVC() -> FPopupViewController {
        let storyboard = UIStoryboard(name: "FPopup", bundle: nil)
        let fPopupVC = storyboard.instantiateViewController(withIdentifier: "FPopupViewController") as! FPopupViewController
        return fPopupVC
    }
    
    //MARK: Public variables
    var sections: [FPopupSection] = [FPopupSection]()
    var handler: (IndexPath) -> Void = {_ in}
    var frameSender: CGRect = CGRect.zero
    var heightLimiting: CGFloat = 0
    var type: FPopupType = FPopupType.dropdown
    var highlightIndexPath: IndexPath?
    
    //MARK: Variables
    private var alertWindow: UIWindow?
    private var popupContentVC: FPopupContentViewController?
    
    //MARK: IBOutlets
    @IBOutlet weak var contentView: UIView!
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeOrientation),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        setupContentView()
        goInAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fpopup.segue.fpopupcontent") {
            if let fPopupContentVC = segue.destination as? FPopupContentViewController {
                weak var weakSelf = self
                fPopupContentVC.sections = sections
                fPopupContentVC.type = type
                fPopupContentVC.highlightedIndexPath = highlightIndexPath
                fPopupContentVC.cellHeight = cCellHeight
                fPopupContentVC.handler = { selectedIndexPath in
                    weakSelf?.handler(selectedIndexPath)
                    weakSelf?.onDismissPopup(UIButton())
                }
                
                fPopupContentVC.isScrollable = isFullHeight
                
                popupContentVC = fPopupContentVC
            }
        }
    }
    
    //MARK: Methods
    func scrollTo(item: Int, section: Int) {
        popupContentVC?.scrollTo(item: item, section: section)
    }
    
    //  MARK: Private methods
    private func initWindow() {
        alertWindow = UIWindow(frame: getWindowFrame())
        alertWindow?.windowLevel = .alert
        alertWindow?.rootViewController = self
        alertWindow?.makeKeyAndVisible()
        alertWindow?.backgroundColor = UIColor.clear
    }
    
    private func setupView() {
        switch type {
        case .dropdown:
            view.backgroundColor = UIColor.clear
            break
            
        case .sheet:
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            break
        }
    }
    
    private func setupContentView() {
        contentView.frame = contentViewFrame
        contentView.backgroundColor = type == .sheet ? UIColor(hex: "#151616") : UIColor.clear
    }
    
    //MARK: Actions
    @IBAction func onDismissPopup(_ sender: UIButton) {
        weak var weakSelf = self
        goOutAnimation {
            FPopup.instance.fPopupVC = nil
            weakSelf?.alertWindow = nil
        }
    }
    
    @objc
    func didChangeOrientation() {
        onDismissPopup(UIButton())
    }
}
