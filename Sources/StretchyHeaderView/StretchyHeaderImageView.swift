//
//  StretchyHeaderImageView.swift
//  
//
//  Created by DerrickChao on 2021/8/4.
//

import Foundation
import UIKit

open class StretchyHeaderImageView: StretchyHeaderView {
    // MARK:- Public property
    /// 開關顯示毛玻璃效果
    open var showBlurEffect: Bool = false
    open var showBottomGradient: Bool = true
    
    // MARK:- Private property
    private var headerImage: UIImage?
    private lazy var headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = headerImage
        return imageView
    }()
    private var imageViewHeightConstraint: NSLayoutConstraint!
    private var blurEffectAnimator: UIViewPropertyAnimator!
    private var blurEffectView: UIVisualEffectView!
    private var gradientLayer: CAGradientLayer?
    
    // MARK:- Initialization
    public init(headerHeight: CGFloat, headerImage: UIImage? = nil) {
        self.headerImage = headerImage
        super.init(headerHeight: headerHeight)
        configureHeaderImageView()
        configureBlurEffectView()
        configureGradientLayer()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureHeaderImageView()
        configureBlurEffectView()
        configureGradientLayer()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if showBottomGradient == false {
            gradientLayer?.isHidden = true
        }
    }
    
    // MARK:- Layouts
    private func configureHeaderImageView() {
        
        containerView.addSubview(headerImageView)
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    private func configureBlurEffectView() {
        
        let blurEffect = UIBlurEffect(style: .regular)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.blurEffectView)
        NSLayoutConstraint.activate([
            self.blurEffectView.topAnchor.constraint(equalTo: self.headerImageView.topAnchor),
            self.blurEffectView.bottomAnchor.constraint(equalTo: self.headerImageView.bottomAnchor),
            self.blurEffectView.leadingAnchor.constraint(equalTo: self.headerImageView.leadingAnchor),
            self.blurEffectView.trailingAnchor.constraint(equalTo: self.headerImageView.trailingAnchor)
        ])
        
        blurEffectAnimator = UIViewPropertyAnimator(duration: 5.0, curve: .easeIn, animations: { [weak self] in
            guard let self = self else { return }
            self.blurEffectView.effect = nil
        })
        /*
         isReversed 反轉動畫效果
         這邊表示初始狀態為animations block裡的 self.blurEffectView.effect = nil，沒有毛玻璃效果
         當 fractionComplete 越接近數值 1 時，就會漸漸出現毛玻璃效果
         */
        blurEffectAnimator.isReversed = true
        blurEffectAnimator.fractionComplete = 0.0
    }
    
    private func configureGradientLayer() {
        
        let heightOffset: CGFloat = 30.0
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.75).cgColor]
        gradientLayer?.locations = [0.2, 1.0]
        gradientLayer?.frame = CGRect(x: 0.0, y: -heightOffset, width: bounds.width, height: bounds.height + heightOffset)
        layer.addSublayer(gradientLayer!)
    }
    
    // MARK:- Public methods
    open func setHeaderImage(image: UIImage?) {
        headerImageView.image = image
    }
    
    open override func scrollViewDidScroll(scrollView: UIScrollView, direction: FingerScrollDirection) {
        super.scrollViewDidScroll(scrollView: scrollView, direction: direction)
    }
    
    // MARK:- Private methods
    override func handleFingerScrollUp(offset: CGFloat, scrollView: UIScrollView) {
        super.handleFingerScrollUp(offset: offset, scrollView: scrollView)
        
        if showBlurEffect {
            blurEffectAnimator.fractionComplete = 0.0
        }
    }
    
    override func handleFingerScrollDown(offset: CGFloat, scrollView: UIScrollView) {
        super.handleFingerScrollDown(offset: offset, scrollView: scrollView)
        
        if showBlurEffect {
            blurEffectAnimator.fractionComplete = abs(offset) / 200.0
        }
    }
    
    // MARK:- Actions
}
