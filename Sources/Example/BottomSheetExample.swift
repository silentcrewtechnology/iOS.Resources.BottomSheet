import UIKit
import DesignSystem
import Components
import ArchitectureTableView

private class BottomSheetExample: UIViewController {
    
    private var bottomSheetService: BottomSheetPresentationService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = BottomSheetHeaderView()
        headerView.update(with: .init(
            height: 20,
            backgroundColor: .backgroundMain,
            grabberViewBackgroundColor: .init(hexString: "#3C3C434D"),
            grabberViewCornerRadius: 2,
            grabberViewSize: .init(width: 36, height: 4))
        )
        
        bottomSheetService = BottomSheetPresentationService(
            presentingViewController: self,
            dataSource: TableDataSourceExample(),
            delegate: TableDelegateExample(),
            headerViewHeight: 20,
            cornerRadius: 24,
            headerView: headerView,
            tableViewBackgroundColor: .backgroundMain,
            bottomSheetBackgroundAlpha: 0.5)
        
        let button = UIButton(type: .system)
        button.setTitle("Show Bottom Sheet", for: .normal)
        button.addTarget(self, action: #selector(showBottomSheet), for: .touchUpInside)
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc private func showBottomSheet() {
        bottomSheetService.present()
    }
}
