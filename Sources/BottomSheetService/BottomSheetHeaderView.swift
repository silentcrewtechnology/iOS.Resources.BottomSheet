import UIKit
import SnapKit

public final class BottomSheetHeaderView: UIView {
    
    public struct ViewProperties {
        public var height: CGFloat
        public var backgroundColor: UIColor
        public var grabberViewBackgroundColor: UIColor
        public var grabberViewCornerRadius: CGFloat
        public var grabberViewSize: CGSize
        
        public init(
            height: CGFloat = 0,
            backgroundColor: UIColor = .clear,
            grabberViewBackgroundColor: UIColor = .clear,
            grabberViewCornerRadius: CGFloat = 0,
            grabberViewSize: CGSize = .zero
        ) {
            self.height = height
            self.backgroundColor = backgroundColor
            self.grabberViewBackgroundColor = grabberViewBackgroundColor
            self.grabberViewCornerRadius = grabberViewCornerRadius
            self.grabberViewSize = grabberViewSize
        }
    }
    
    private var viewProperties: ViewProperties = .init()
    
    private let grabberView: UIView = {
        let view = UIView()
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func update(with viewProperties: ViewProperties) {
        backgroundColor = viewProperties.backgroundColor
        grabberView.backgroundColor = viewProperties.grabberViewBackgroundColor
        grabberView.layer.cornerRadius = viewProperties.grabberViewCornerRadius
        updateAllConstraints(with: viewProperties)
        self.viewProperties = viewProperties
    }
    
    private func updateAllConstraints(with viewProperties: ViewProperties) {
        snp.updateConstraints {
            $0.height.equalTo(viewProperties.height)
        }
        
        grabberView.snp.updateConstraints {
            $0.size.equalTo(viewProperties.grabberViewSize)
        }
    }
    
    private func setupView() {
        addSubview(grabberView)
        grabberView.snp.makeConstraints() {
            $0.centerX.centerY.equalToSuperview()
            $0.size.equalTo(0) // будет обновляться
        }
        
        snp.makeConstraints {
            $0.height.equalTo(0) // будет обновляться
        }
    }
}
