import UIKit
import DesignSystem
import ArchitectureTableView

public final class BottomSheetPresentationService: NSObject {
    
    // MARK: - Properties
    
    private weak var presentingViewController: UIViewController?
    private var bottomSheetViewController: BottomSheetViewController?
    private var activeTextField: UITextField?
    private var dataSource: UITableViewDataSource
    private var delegate: UITableViewDelegate
    private var headerViewHeight: CGFloat
    private var cornerRadius: CGFloat
    private var headerView: UIView
    private var tableView: TableView?
    private var tableViewBackgroundColor: UIColor
    private var bottomSheetBackgroundAlpha: CGFloat
    private var bottomSheetVC: BottomSheetViewController
    
    private var isBottomSheetOpen: Bool = false
    
    // Очередь для управления синхронизацией
    private let queue = DispatchQueue(label: "bottomsheet.queue", attributes: .concurrent)
    
    // MARK: - Initialization
    
    public init(
        presentingViewController: UIViewController,
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate,
        headerViewHeight: CGFloat,
        cornerRadius: CGFloat,
        headerView: UIView,
        tableViewBackgroundColor: UIColor,
        bottomSheetBackgroundAlpha: CGFloat
    ) {
        self.presentingViewController = presentingViewController
        self.dataSource = dataSource
        self.delegate = delegate
        self.headerViewHeight = headerViewHeight
        self.cornerRadius = cornerRadius
        self.headerView = headerView
        self.tableViewBackgroundColor = tableViewBackgroundColor
        self.bottomSheetBackgroundAlpha = bottomSheetBackgroundAlpha
        self.bottomSheetVC = BottomSheetViewController()
        super.init()
        setup()
    }
    
    private func setup() {
        setupTableView()
        configureTextFieldsDelegate()
        updateTableView()
        setupBottomSheetVC(setupSafeAreaInset())
    }
    
    private func setupTableView() {
        tableView = TableView(
            viewProperties: TableView.ViewProperties(
                dataSources: dataSource,
                delegate: delegate),
            style: .plain)
    }
    
    private func updateTableView() {
        guard let tableView else { return }
        tableView.update(with: TableView.ViewProperties(
            backgroundColor: tableViewBackgroundColor,
            dataSources: dataSource,
            delegate: delegate,
            isScrollEnabled: isNeedTableScrollEnabled()
        ))
    }
    
    private func setupSafeAreaInset() -> UIEdgeInsets {
        var safeAreaInset: UIEdgeInsets = .zero
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            safeAreaInset = window.safeAreaInsets
        }
        
        return safeAreaInset
    }
    
    private func setupBottomSheetVC(_ safeAreaInset: UIEdgeInsets) {
        guard let tableView else { return }
        
        let viewProperties = BottomSheetViewController.ViewProperties(
            headerView: headerView,
            headerViewHeight: headerViewHeight,
            contentView: tableView,
            contentHeight: tableView.contentSize.height,
            topSafeAreaHeight: safeAreaInset.top,
            bottomSafeAreaHeight: safeAreaInset.bottom,
            cornerRadius: cornerRadius,
            keyboardWillShowAction: { [weak self] keyboardHeight in
                tableView.isScrollEnabled = self?.isNeedTableScrollEnabled(with: keyboardHeight) ?? false
            })
        
        bottomSheetVC.update(with: viewProperties)
        
        bottomSheetVC.view.backgroundColor = UIColor.black.withAlphaComponent(bottomSheetBackgroundAlpha)
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        
        bottomSheetViewController = bottomSheetVC
    }
    
    // MARK: - Public Methods
    
    public func present() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if !self.isBottomSheetOpen {
                DispatchQueue.main.async {
                    self.presentingViewController?.present(self.bottomSheetVC, animated: true, completion: nil)
                    self.isBottomSheetOpen = true
                }
            }
        }
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if self.isBottomSheetOpen {
                DispatchQueue.main.async {
                    self.bottomSheetVC.dismiss(animated: true, completion: {
                        self.isBottomSheetOpen = false
                        completion?()
                    })
                }
            }
        }
    }
    
    private func isNeedTableScrollEnabled(with keyboardHeight: CGFloat = 0) -> Bool {
        return UIScreen.main.bounds.height < ((tableView?.contentSize.height ?? 0) + headerViewHeight + keyboardHeight)
    }
    
    private func scrollToActiveTextField() {
        guard let tableView = bottomSheetViewController?.contentView as? TableView,
              let activeTextField = activeTextField,
              let indexPath = tableView.indexPathForRow(at: activeTextField.convert(activeTextField.bounds.origin, to: tableView)) else {
            return
        }
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func configureTextFieldsDelegate() {
        guard let tableView else { return }
        for cell in tableView.visibleCells {
            for subview in cell.contentView.subviews {
                if let textField = subview as? UITextField {
                    textField.delegate = self
                }
            }
        }
    }
}

extension BottomSheetPresentationService: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        scrollToActiveTextField()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
