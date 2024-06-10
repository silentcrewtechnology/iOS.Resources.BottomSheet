import UIKit
import DesignSystem
import Components

private class TableDataSourceExample: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 5 // для тестирования меняем количество ячеек
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return createTitleRow(tableView, indexPath: indexPath)
        case 1:
            return createImageWithTitleRow(tableView, indexPath: indexPath)
        case 2:
            return createImageWithTitleSubtitleRow(tableView, indexPath: indexPath)
        case 3:
            return createImageWithButtonRow(tableView, indexPath: indexPath)
        case 4:
            return createImageWithToggleRow(tableView, indexPath: indexPath)
        case 5:
            return createImageWithCheckboxRow(tableView, indexPath: indexPath)
        case 6:
            return createImageWithIndexRow(tableView, indexPath: indexPath)
        case 7:
            return createImageWithIndexIcons20Row(tableView, indexPath: indexPath)
        case 8:
            return createCardWithTitleButtonRow(tableView, indexPath: indexPath)
        case 9:
            return createInputRow(tableView, indexPath: indexPath)
        case 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22:
            return createCardWithTitleButtonRow(tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
}

extension TableDataSourceExample {
    // MARK: - Row Creation Methods
    
    private func createTitleRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let titleStyle = LabelViewStyle(variant: .title(isCopied: false))
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.title("Title", titleStyle))
        )
    }
    
    private func createImageWithTitleRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .atom(.title("Title", nil))
        )
    }
    
    private func createImageWithTitleSubtitleRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.titleWithSubtitle(("Title", nil), ("Subtitle", nil)))
        )
    }
    
    private func createImageWithButtonRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.subtitleWithTitle(("Subtitle", nil), ("Title", nil))),
            trailing: .atom(.button("Label", { }, nil))
        )
    }
    
    private func createImageWithToggleRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.subtitleWithTitle(("Subtitle", nil), ("Title", nil))),
            trailing: .atom(.toggle(true, { _ in }, nil))
        )
    }
    
    private func createImageWithCheckboxRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.subtitleWithTitle(("Subtitle", nil), ("Title", nil))),
            trailing: .atom(.checkbox(true, { _ in }, nil))
        )
    }
    
    private func createImageWithIndexRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.subtitleWithTitle(("Subtitle", nil), ("Title", nil))),
            trailing: .molecule(.indexWithIcon24(("Index", nil), (.ic24ChevronSmallRight, nil)))
        )
    }
    
    private func createImageWithIndexIcons20Row(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.image40(.ic24UserFilled, nil)),
            center: .molecule(.subtitleWithTitle(("Subtitle", nil), ("Title", nil))),
            trailing: .molecule(.indexWithIcons20(("Index", nil), [(.ic24BoxFilled, nil), (.ic24BoxFilled, nil)]))
        )
    }
    
    private func createCardWithTitleButtonRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        return DSCreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.card(.ic24CardMirLight, nil)),
            center: .atom(.title("Title", nil)),
            trailing: .atom(.button("Label", { }, nil))
        )
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row: \(indexPath.row)")
    }
}
