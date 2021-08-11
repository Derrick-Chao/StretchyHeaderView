
import Foundation
import UIKit

open class StretchyHeaderView: UIView {
    // MARK:- Public property
    public let containerView = UIView()
    public private(set) var headerHeight: CGFloat = 0.0
    /// 開關上滑後是否縮小 HeaderView 置頂
    open var shrinkOnTheTop: Bool = false
    /// 開啟上滑縮小後 HeaderView 的顯示高度，非瀏海機預設 64.0，瀏海機 84.0
    open var shrinkHeight: CGFloat = 64.0 {
        didSet {
            if shrinkHeight > headerHeight {
                shrinkHeight = headerHeight
            }
        }
    }
    
    // MARK:- Private property
    private var topAnchorConstraint: NSLayoutConstraint!
    private var containerViewHeightConstraint: NSLayoutConstraint!
    private var containerViewTopConstraint: NSLayoutConstraint!
    private var contentOffsetObservation: NSKeyValueObservation?
    
    // MARK:- Initialization
    public init(headerHeight: CGFloat) {
        guard headerHeight > 0 else { fatalError("headerHeight must be greater than zero") }
        
        self.headerHeight = headerHeight
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: headerHeight)))
        
        configureContainerView()
        setShrikHeight()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureContainerView()
        setShrikHeight()
    }
    
    deinit {
        print("StretchyHeaderView deinit.")
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print("didMoveToSuperview superView: \(superview)")
        if superview is UIScrollView , let scrollView = self.superview as? UIScrollView {
//            scrollView = superview as? UIScrollView
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                heightAnchor.constraint(equalToConstant: headerHeight),
                centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            ])
            topAnchorConstraint = topAnchor.constraint(equalTo: scrollView.topAnchor)
            topAnchorConstraint.isActive = true
            // Key value observation
            contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, changed in
                guard let self = self else { return }
                
                self.scrollViewDidScroll(scrollView: scrollView)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    // MARK:- Layouts
    private func configureContainerView() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalTo: heightAnchor)
        containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: topAnchor)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            containerViewTopConstraint,
            containerViewHeightConstraint
        ])
    }
    
    private func setShrikHeight() {
        
        if UIScreen.main.bounds.height >= 812.0 {
            shrinkHeight = 84.0
        } else {
            shrinkHeight = 64.0
        }
    }
    
    // MARK:- Public methods
    open func scrollViewDidScroll(scrollView: UIScrollView) {
        print("scrollView.contentInset: \(scrollView.contentInset), scrollView.contentOffset.y: \(scrollView.contentOffset.y)")
//        containerViewHeightConstraint.constant = scrollView.contentInset.top
        /*
         contentOffset.y
         手指往上滑動時為 正數
         手指往下滑動時為 負數
         */
        let offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
            handleFingerScrollDown(offset: offsetY, scrollView: scrollView)
        } else if offsetY > 0 {
            handleFingerScrollUp(offset: offsetY, scrollView: scrollView)
        }
    }
    
    // MARK:- Private methods
    func handleFingerScrollUp(offset: CGFloat, scrollView: UIScrollView) {
        
        let offsetY = offset + scrollView.contentInset.top
        containerView.clipsToBounds = true
        containerViewTopConstraint.constant = 0.0
        containerViewHeightConstraint.constant = 0.0
        if shrinkOnTheTop && offsetY >= (headerHeight - shrinkHeight) {
            topAnchorConstraint.constant = offsetY - (headerHeight - shrinkHeight)
        } else {
            topAnchorConstraint.constant = 0.0
        }
    }
    
    func handleFingerScrollDown(offset: CGFloat, scrollView: UIScrollView) {
        
        let offsetY = -(offset + scrollView.contentInset.top)
        containerView.clipsToBounds = false
        containerViewTopConstraint.constant = -max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        containerViewHeightConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        topAnchorConstraint.constant = 0.0
    }
    
    // MARK:- Actions
}
