
import UIKit

class FPopupContentViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    
    var sections = [FPopupSection]()
    var type = FPopupType.dropdown
    var handler: (IndexPath) -> Void = {_ in}
    var isScrollable = true
    var cellHeight: CGFloat = 44
    
    var highlightedIndexPath: IndexPath? {
        didSet {
            guard tableview != nil else { return }
            
            if let oldValue = oldValue, let oldHighlightedCell = tableview.cellForRow(at: oldValue) as? FPopupCommonCell {
                oldHighlightedCell.makeHighlight(false)
            }
            
            if let newValue = highlightedIndexPath, let newHighlightedCell = tableview.cellForRow(at: newValue) as? FPopupCommonCell {
                newHighlightedCell.makeHighlight(true)
            }
        }
    }
    
    private var selectedIndexPath: IndexPath?
    
    ///MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.reloadData()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.isScrollEnabled = isScrollable
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let indexPath = selectedIndexPath {
            tableview.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    //  MARK: Funcs
    func scrollTo(item: Int, section: Int) {
        guard isScrollable else { return }
        guard section >= 0, item >= 0 else { return }
        guard sections.count > section  else { return }
        guard sections[section].items.count > item else { return }
        
        selectedIndexPath = IndexPath(item: item, section: section)
    }
}

//MARK: Table view datasource
extension FPopupContentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: "FPopupCommonCell", for: indexPath) as! FPopupCommonCell
        cell.isHighlightable = highlightedIndexPath == nil || highlightedIndexPath! == indexPath
        cell.item = item
        cell.type = type
        return cell
    }
}

//MARK: Table view delegate
extension FPopupContentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        highlightedIndexPath = indexPath
        handler(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let psSection = sections[section]
        let sectionCell = tableView.dequeueReusableCell(withIdentifier: "FPopupCommonSection") as! FPopupCommonSection
        sectionCell.lbTitle.text = psSection.title
        sectionCell.type = type
        return sectionCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections.count == 1 && sections[0].title == "" {
            return 0
        }
        
        return cellHeight
    }
}
