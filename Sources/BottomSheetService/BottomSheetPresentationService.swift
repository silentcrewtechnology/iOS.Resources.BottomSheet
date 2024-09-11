import UIKit
import DesignSystem
import ArchitectureTableView
import Router

public final class BottomSheetPresentationService: NSObject {
    
    // MARK: - Properties
    private weak var presentingViewController: UIViewController?
    private var activeTextField: UITextField?
    private var dataSource: UITableViewDataSource
    private var delegate: UITableViewDelegate
    private var headerViewHeight: CGFloat
    private var cornerRadius: CGFloat
    private var headerView: UIView
    private var tableViewBuilder: TableViewBuilder?
    private var tableViewBackgroundColor: UIColor
    private var bottomSheetBackgroundAlpha: CGFloat
    private var bottomSheetVC: BottomSheetViewController
    private let routerService: RouterService?
    
    private var isBottomSheetOpen: Bool = false
    
    // Очередь для управления синхронизацией
    private let queue = DispatchQueue(label: "bottomsheet.queue", attributes: .concurrent)
    
    // MARK: - Initialization
    public init(
        // TODO: перевести на единый роутинг сервис PCABO3-11543
        presentingViewController: UIViewController? = nil,
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate,
        headerViewHeight: CGFloat,
        cornerRadius: CGFloat,
        headerView: UIView,
        tableViewBackgroundColor: UIColor,
        bottomSheetBackgroundAlpha: CGFloat,
        bottomSheetVC: BottomSheetViewController = BottomSheetViewController(),
        // TODO: перевести на единый роутинг сервис PCABO3-11543
        routerService: RouterService? = nil
    ) {
        self.presentingViewController = presentingViewController
        self.dataSource = dataSource
        self.delegate = delegate
        self.headerViewHeight = headerViewHeight
        self.cornerRadius = cornerRadius
        self.headerView = headerView
        self.tableViewBackgroundColor = tableViewBackgroundColor
        self.bottomSheetBackgroundAlpha = bottomSheetBackgroundAlpha
        self.bottomSheetVC = bottomSheetVC
        tableViewBuilder = .init(with: .init(
            backgroundColor: .white,
            dataSources: dataSource,
            delegate: delegate
        ))
        self.routerService = routerService
        super.init()
        setup()
    }
    
    private func setup() {
        configureTextFieldsDelegate()
        setupScrollEnabled()
        setupBottomSheetVC()
    }
    
    public func updateTable(
        dataSource: UITableViewDataSource,
        delegate: UITableViewDelegate
    ) {
        tableViewBuilder?.viewUpdater.state = .updateViewProperties(TableView.ViewProperties(
            backgroundColor: tableViewBackgroundColor,
            dataSources: dataSource,
            delegate: delegate
        ))
        
        tableViewBuilder?.view.isScrollEnabled = isNeedTableScrollEnabled()
        
        guard let contentView = tableViewBuilder?.view else { return }
        let safeAreaInset = setupSafeAreaInset()
        let viewProperties = BottomSheetViewController.ViewProperties(
            headerView: headerView,
            headerViewHeight: headerViewHeight,
            contentView: contentView,
            contentHeight: calculateContentHeight(),
            topSafeAreaHeight: safeAreaInset.top,
            bottomSafeAreaHeight: safeAreaInset.bottom,
            cornerRadius: cornerRadius,
            keyboardWillShowAction: { [weak self] keyboardHeight in
                self?.tableViewBuilder?.view.isScrollEnabled = self?.isNeedTableScrollEnabled(with: keyboardHeight) ?? false
            })
        
        bottomSheetVC.updateData(with: viewProperties)
        bottomSheetVC.updateUI(with: viewProperties)
    }
    
    private func setupSafeAreaInset() -> UIEdgeInsets {
        var safeAreaInset: UIEdgeInsets = .zero
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            safeAreaInset = window.safeAreaInsets
        }
        
        return safeAreaInset
    }
    
    private func setupBottomSheetVC() {
        guard let contentView = tableViewBuilder?.view else { return }
        let safeAreaInset = setupSafeAreaInset()
        let viewProperties = BottomSheetViewController.ViewProperties(
            headerView: headerView,
            headerViewHeight: headerViewHeight,
            contentView: contentView,
            contentHeight: calculateContentHeight(),
            topSafeAreaHeight: safeAreaInset.top,
            bottomSafeAreaHeight: safeAreaInset.bottom,
            cornerRadius: cornerRadius,
            keyboardWillShowAction: { [weak self] keyboardHeight in
                self?.tableViewBuilder?.view.isScrollEnabled = self?.isNeedTableScrollEnabled(with: keyboardHeight) ?? false
            })
        
        bottomSheetVC.updateData(with: viewProperties)
        bottomSheetVC.updateUI(with: viewProperties)
        
        bottomSheetVC.view.backgroundColor = UIColor.black.withAlphaComponent(bottomSheetBackgroundAlpha)
        bottomSheetVC.modalPresentationStyle = .overFullScreen
    }
    
    // MARK: - Private Methods
    private func setupScrollEnabled(with keyboardHeight: CGFloat = 0) {
        tableViewBuilder?.view.isScrollEnabled = isNeedTableScrollEnabled(with: keyboardHeight)
    }
    
    private func isNeedTableScrollEnabled(with keyboardHeight: CGFloat = 0) -> Bool {
        let expectedHeight = calculateContentHeight() + keyboardHeight
        return UIScreen.main.bounds.height < expectedHeight
    }
    
    private func calculateContentHeight() -> CGFloat {
        let safeAreaInsets = setupSafeAreaInset()
        let height = safeAreaInsets.top + headerViewHeight + (tableViewBuilder?.view.contentSize.height ?? 0) + safeAreaInsets.bottom
        return height
    }
    
    private func scrollToActiveTextField() {
        guard let tableView = bottomSheetVC.view as? TableView,
              let activeTextField = activeTextField,
              let indexPath = tableView.indexPathForRow(at: activeTextField.convert(activeTextField.bounds.origin, to: tableView)) else {
            return
        }
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func configureTextFieldsDelegate() {
        guard let contentView = tableViewBuilder?.view else { return }
        for cell in contentView.visibleCells {
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

// TODO: перевести на единый роутинг сервис PCABO3-11543
// MARK: - Routing
extension BottomSheetPresentationService {
    public func present() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if !self.isBottomSheetOpen {
                DispatchQueue.main.async {
                    self.presentingViewController?.present(self.bottomSheetVC, animated: true, completion: nil)
                    self.isBottomSheetOpen = true
                    self.updateTable(dataSource: self.dataSource, delegate: self.delegate)
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
    
    public func routerPresent() {
        routerService?.present(
            with: .viewController(bottomSheetVC),
            animation: true,
            transitionStyle: .coverVertical,
            presentationStyle: .overFullScreen
        )
    }
    
    public func routerDismiss(completion: @escaping (() -> Void) = {}) {
        routerService?.dismiss(animated: true, completion: completion)
    }
}
