import UIKit
import ArchitectureTableView
import SnapKit

public final class BottomSheetViewController: UIViewController {
    
    // MARK: - Properties
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
        
        public init(
            headerView: UIView = UIView(),
            headerViewHeight: CGFloat = 0,
            contentView: UIView = UIView(),
            contentHeight: CGFloat? = nil,
            topSafeAreaHeight: CGFloat = 0,
            bottomSafeAreaHeight: CGFloat = 0,
            cornerRadius: CGFloat = 0,
            bottomSafeAreaColor: UIColor = .white,
            clouseGestureYpoint: CGFloat = 20,
            keyboardWillShowAction: ((CGFloat) -> Void)? = nil
        ) {
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
    private var contentView: UIView = UIView()
    private var keyboardProjectionView = UIView()
    private var bottomSafeAreaView = UIView()
    
    private var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var initialContentViewY: CGFloat = 0
    private var insetHeight: CGFloat = 0
    
    private var heightContainerViewConstraint: Constraint?
    private var topContainerViewConstraint: Constraint?
    
    private var viewProperties: ViewProperties = .init()
    
    // MARK: - Initialization
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Deinit BottomSheetViewController")
    }
    
    // MARK: - life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        setupKeyboardObservers()
        view.alpha = 0.0
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1.0
        }
        
        containerView.transform = CGAffineTransform(translationX: 0, y: insetHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
        applyUpperCornerRadiusForHeaderView()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Проверяем, коснулся ли пользователь вне контейнера
        if let touch = touches.first {
            let touchLocation = touch.location(in: self.view)
            if !containerView.frame.contains(touchLocation) {
                closeBottomSheet()
            }
        }
    }
    
    // MARK: - Public Methods
    public func updateData(with viewProperties: ViewProperties) {
        self.viewProperties = viewProperties
        contentView = viewProperties.contentView
        headerView = viewProperties.headerView
        
        bottomSafeAreaView.backgroundColor = viewProperties.bottomSafeAreaColor
    }
    
    public func updateUI(with viewProperties: ViewProperties) {
        insetHeight = viewProperties.contentHeight ?? contentView.frame.size.height
        updateUI()
    }
}

// MARK: - UI Settings
extension BottomSheetViewController {
    private func setupUI() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            self.topContainerViewConstraint =  $0.top.equalToSuperview().offset(viewProperties.topSafeAreaHeight).constraint
            self.heightContainerViewConstraint = $0.height.equalTo(0).constraint
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
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
        }
    }
    
    private func updateUI() {
        if (UIScreen.main.bounds.height - viewProperties.topSafeAreaHeight) < viewProperties.contentHeight ?? 0 {
            topContainerViewConstraint?.activate()
            topContainerViewConstraint?.update(offset: viewProperties.topSafeAreaHeight)
            heightContainerViewConstraint?.deactivate()
        } else {
            topContainerViewConstraint?.deactivate()
            heightContainerViewConstraint?.activate()
            heightContainerViewConstraint?.update(offset: (viewProperties.contentHeight ?? 0))
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func applyUpperCornerRadiusForHeaderView() {
        let maskPath = UIBezierPath(
            roundedRect: headerView.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: viewProperties.cornerRadius,
                                height: viewProperties.cornerRadius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        headerView.layer.mask = maskLayer
    }
}

// MARK: - Gesture Settings
extension BottomSheetViewController {
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
    
    private func closeBottomSheet() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0.0
            self.containerView.frame.origin.y = self.view.frame.size.height
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

// MARK: - Keyboard Methods
extension BottomSheetViewController {
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
            self.containerView.layoutIfNeeded()
        }
    }
}
