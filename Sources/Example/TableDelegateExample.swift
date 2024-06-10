import UIKit

private class TableDelegateExample: NSObject, UITableViewDelegate {
    private var componentsCell: [Any] = []
    
    public func update(with componentsCell: [Any]) {
        self.componentsCell = componentsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
