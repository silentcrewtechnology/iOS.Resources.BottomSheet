import UIKit
import ArchitectureTableView
import SnapKit

final class BottomSheetViewController: UIViewController {
    
    public struct ViewProperties {
        public var headerView: UIView
        public var headerViewHeight: CGFloat
        public var contentView: UIView
        public var contentHeight: CGFloat?
        public var topSafeAreaHeight: CGFloat
        public var bottomSafeAreaHeight: CGFloat
        public var cornerRadius: CGFloat
        public var bottomSafeAreaColor: UIColor
        public var clouseGestureYpoint: CGFloat
        public var keyboardWillShowAction: ((CGFloat) -> ())?
        
        public init(headerView: UIView = UIView(),
                    headerViewHeight: CGFloat = 0,
                    contentView: UIView = UIView(),
                    contentHeight: CGFloat? = nil,
                    topSafeAreaHeight: CGFloat = 0,
                    bottomSafeAreaHeight: CGFloat = 0,
                    cornerRadius: CGFloat = 0,
                    bottomSafeAreaColor: UIColor = .white,
                    clouseGestureYpoint: CGFloat = 20,
                    keyboardWillShowAction: ((CGFloat) -> Void)? = nil) {
            self.headerView = headerView
            self.headerViewHeight = headerViewHeight
            self.contentView = contentView
            self.contentHeight = contentHeight
            self.topSafeAreaHeight = topSafeAreaHeight
            self.bottomSafeAreaHeight = bottomSafeAreaHeight
            self.cornerRadius = cornerRadius
            self.bottomSafeAreaColor = bottomSafeAreaColor
            self.clouseGestureYpoint = clouseGestureYpoint
            self.keyboardWillShowAction = keyboardWillShowAction
        }
    }
    
    private var containerView = UIView()
    private var headerView: UIView = UIView()
    public var contentView: UIView = UIView()
    private var keyboardProjectionView = UIView()
    private var bottomSafeAreaView = UIView()
    
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var initialContentViewY: CGFloat = 0
    private var insetHeight: CGFloat = 0
    
    private var heightContainerViewConstraint: Constraint?
    
    private var viewProperties: ViewProperties = .init()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deinit BottomSheetViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        setupKeyboardObservers()
        view.alpha = 0.0
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            viewProperties.keyboardWillShowAction?(keyboardHeight)
            let contentHeight = insetHeight + viewProperties.headerViewHeight + viewProperties.bottomSafeAreaHeight
            
            if contentHeight < keyboardHeight {
                containerView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(-keyboardHeight)
                }
                keyboardProjectionView.snp.updateConstraints {
                    $0.height.equalTo(0)
                }
            } else {
                containerView.snp.updateConstraints {
                    $0.bottom.equalToSuperview()
                }
                keyboardProjectionView.snp.updateConstraints {
                    $0.height.equalTo(keyboardHeight)
                }
            }
            
            bottomSafeAreaView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        containerView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
        
        keyboardProjectionView.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        
        bottomSafeAreaView.snp.updateConstraints {
            $0.height.equalTo(viewProperties.bottomSafeAreaHeight)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1.0
        }
        
        containerView.transform = CGAffineTransform(translationX: 0, y: insetHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
        applyUpperCornerRadiusForContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.main.bounds.height > insetHeight {
            updateTableViewHeight(contentHeight: insetHeight)
        }
    }
    
    func closeBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0.0
            self.containerView.frame.origin.y = self.view.frame.size.height
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    public func update(with viewProperties: ViewProperties) {
        self.viewProperties = viewProperties
        contentView = viewProperties.contentView
        headerView = viewProperties.headerView
        
        insetHeight = viewProperties.contentHeight ?? contentView.frame.size.height
        
        bottomSafeAreaView.backgroundColor = viewProperties.bottomSafeAreaColor
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            if UIScreen.main.bounds.height < insetHeight {
                $0.top.equalToSuperview().offset(viewProperties.topSafeAreaHeight)
            } else {
                self.heightContainerViewConstraint = $0.height.equalTo(0).constraint
            }
        }
        
        containerView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        view.backgroundColor = .clear
        
        containerView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(keyboardProjectionView)
        keyboardProjectionView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        containerView.addSubview(bottomSafeAreaView)
        bottomSafeAreaView.snp.makeConstraints {
            $0.top.equalTo(keyboardProjectionView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(viewProperties.bottomSafeAreaHeight)
        }
    }
    
    func updateTableViewHeight(contentHeight: CGFloat?) {
        let contentHeight = contentHeight
        heightContainerViewConstraint?.update(offset: (contentHeight ?? 0) + viewProperties.headerViewHeight + viewProperties.bottomSafeAreaHeight)
    }
    
    private func applyUpperCornerRadiusForContentView() {
        let maskPath = UIBezierPath(
            roundedRect: containerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: viewProperties.cornerRadius,
                                height: viewProperties.cornerRadius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        containerView.layer.mask = maskLayer
    }
    
    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        headerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.view.window)
        
        switch gestureRecognizer.state {
        case .began:
            initialTouchPoint = touchPoint
            initialContentViewY = containerView.frame.origin.y
        case .changed:
            let yOffset = max(0, touchPoint.y - initialTouchPoint.y) + initialContentViewY
            containerView.frame.origin.y = yOffset
        case .ended, .cancelled:
            if containerView.frame.origin.y >= (initialTouchPoint.y + viewProperties.clouseGestureYpoint) {
                closeBottomSheet()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.frame.origin.y = self.initialContentViewY
                }
            }
        default:
            break
        }
    }
}
