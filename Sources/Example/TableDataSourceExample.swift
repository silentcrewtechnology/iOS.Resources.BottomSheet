import UIKit
import DesignSystem
import Components
// TODO: убрать зависимость от Services, когда вынесем Example
import Services

private class TableDataSourceExample: NSObject, UITableViewDataSource {
    
    private var cardNumberFormatter = CardNumberFormatter()
    private var cardExpirationDateFormatter = CardExpirationDateFormatter()
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 8 // для тестирования меняем количество ячеек
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return createTitleRow(tableView, indexPath: indexPath)
        case 1:
            return createInputCardRow(tableView, indexPath: indexPath)
        case 2:
            return createInputDateRow(tableView, indexPath: indexPath)
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
            return createInputCardRow(tableView, indexPath: indexPath)
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
    
    private func createInputCardRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        var cardViewProperties = CardImageView.ViewProperties()
        let cardStyle = CardImageViewStyle(
            paymentSystem: .Mir,
            backgroundImage: .ic24CardMirLight)
        cardStyle.update(viewProperties: &cardViewProperties)
        
        var buttonViewProperties = ButtonView.ViewProperties(attributedText: "Label".attributed)
        let buttonStyle = ButtonViewStyle(
            context: .action(.contained),
            state: .default,
            size: .sizeXS
        )
        buttonStyle.update(viewProperties: &buttonViewProperties)
        
        var inputViewProperties = InputTextField.ViewProperties()
        inputViewProperties.keyboardType = .numberPad
        inputViewProperties.text = "".attributed
        inputViewProperties.placeholder = "Номер карты".attributed
        inputViewProperties.delegateAssigningClosure = { [weak self] textView in
            guard let self else { return }
            textView.delegate = self.cardNumberFormatter
        }
        
        let row = CreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.card(cardViewProperties)),
            center: .atom(.input(inputViewProperties)),
            trailing: .atom(.button(buttonViewProperties))
        )
        return row
    }
    
    private func createInputDateRow(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        var inputViewProperties = InputTextField.ViewProperties()
        inputViewProperties.keyboardType = .numberPad
        inputViewProperties.text = "".attributed
        inputViewProperties.placeholder = "мм/гг".attributed
        inputViewProperties.delegateAssigningClosure = { [weak self] textView in
            guard let self else { return }
            textView.delegate = self.cardExpirationDateFormatter
        }
        
        let row = CreationRowsViewService().createCellRowWithBlocks(
            tableView: tableView,
            indexPath: indexPath,
            leading: .atom(.input(inputViewProperties))
        )
        return row
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row: \(indexPath.row)")
    }
}
