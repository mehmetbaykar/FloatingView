import UIKit

open class FloatingView:UIView,
                        FloatingViewProtocol{
    
    private struct AssociatedKeys {
        static var floatingPanGestureKey = "floatingPanGestureKey"
        static var floatingDelegateKey = "floatingDelegateKey"
    }
    
    
    public var component = FloatingViewProtocolComponent()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        intialConfigure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialConfigure()
    }
    
    private func intialConfigure() {
        backgroundColor = UIColor.cyan
        layer.cornerRadius = 5
        addFloatingPanGestureRecognizer()
        addTapGestureRecognizer()
        addSwipeGestureRecognizer()
    }
    
public weak var floatingDelegate: FloatingViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.floatingDelegateKey) as? FloatingViewDelegate
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.floatingDelegateKey, newValue as FloatingViewDelegate?, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var floatingPanGesture: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.floatingPanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.floatingPanGestureKey, newValue as UIPanGestureRecognizer?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var isCollapsed = true
    
    func addFloatingPanGestureRecognizer() {
        guard floatingPanGesture == nil else { return }
        floatingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleFloatingViewPanGesture))
        addGestureRecognizer(floatingPanGesture!)
    }
    
    private func addTapGestureRecognizer(){
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapped)))
    }
    
    
    private func addSwipeGestureRecognizer(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipped(swipeGesture:)))
        swipe.direction = .right
        swipe.direction = .left
        self.addGestureRecognizer(swipe)
    }
    
    @objc private func didTapped(){
        let size : CGSize = isCollapsed ?  CGSize(width: 50, height: 100) : CGSize(width: 150, height: 300)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.layoutSubviews,.curveLinear]) {
            self.frame.size = size
            self.layer.cornerRadius = 5
            
            if !self.isCollapsed{
                self.animateToAdsorb()
            }
           
        } completion: { _ in
            self.isCollapsed = !self.isCollapsed
        }
    }
    
    @objc private func didSwipped(swipeGesture:UISwipeGestureRecognizer){
        self.isAutoPartiallyHide = true
        self.animateToAdsorb()
    }
    @objc private func handleFloatingViewPanGesture(_ pan: UIPanGestureRecognizer) {
        guard self.isDraggable else { return }
        
        switch pan.state {
        case .began:
            floatingDelegate?.floatingViewDidBeginDragging(panGestureRecognizer: pan)
        case .changed:
            defer {
                pan.setTranslation(.zero, in: self)
            }
            let translation = pan.translation(in: self)
            modifyOrigin(withTranslation: translation)
            floatingDelegate?.floatingViewDidMove(view: self)
        case .ended:
            animateToAdsorb()
            floatingDelegate?.floatingViewDidEndDragging(panGestureRecognizer: pan)
        default: break
        }
    }
    
    private func modifyOrigin(withTranslation translation: CGPoint) {
        guard let superview = superview else { return }
        
        let minOriginX = self.isAutoAdsorb ? min(self.floatingEdgeInsets.left, 0) : self.floatingEdgeInsets.left
        let minOriginY = self.isAutoAdsorb ? min(self.floatingEdgeInsets.top, 0) : self.floatingEdgeInsets.top
        let maxOriginX = self.isAutoAdsorb ? max(superview.bounds.width - bounds.width - self.floatingEdgeInsets.right, superview.bounds.width - bounds.width) : superview.bounds.width - bounds.width - self.floatingEdgeInsets.right
        let maxOriginY = self.isAutoAdsorb ? max(superview.bounds.height - bounds.height - self.floatingEdgeInsets.bottom, superview.bounds.height - bounds.height) : superview.bounds.height - bounds.height - self.floatingEdgeInsets.bottom
        let tmpOriginX = frame.origin.x + translation.x
        let tmpOriginY = frame.origin.y + translation.y
        
        // 未到最后仍向右移，未到最左仍向左移
        if (tmpOriginX <= maxOriginX && translation.x > 0) || (tmpOriginX >= minOriginX && translation.x < 0) {
            frame.origin.x = tmpOriginX
        }
        // 未到最下仍向下移，未到最上仍向上移
        if (tmpOriginY <= maxOriginY && translation.y > 0) || (tmpOriginY >= minOriginY && translation.y < 0) {
            frame.origin.y = tmpOriginY
        }
    }
    
    func animateToAdsorb() {
        guard let superview = superview,
              self.isAutoAdsorb else {
                  return
              }
        
        let accessibleCenterX = (superview.frame.width + self.floatingEdgeInsets.left - self.floatingEdgeInsets.right) / 2
        let accessibleCenterY = (superview.frame.height + self.floatingEdgeInsets.top - self.floatingEdgeInsets.bottom) / 2
        let accessibleMinX = self.floatingEdgeInsets.left
        let accessibleMinY = self.floatingEdgeInsets.top + 40
        let accessibleMaxX = superview.bounds.width - self.floatingEdgeInsets.right
        let accessibleMaxY = superview.bounds.height - self.floatingEdgeInsets.bottom
        var destinationOrigin = frame.origin
        var adsorbedEdges: [FloatingAdsorbableEdges] = []
        
        if self.adsorbableEdges.contains(.top), center.y < accessibleCenterY, frame.minY < self.minAdsorbableSpacings.top + accessibleMinY {
            destinationOrigin.y = max(accessibleMinY, 0)
            adsorbedEdges.append(.top)
        } else if self.adsorbableEdges.contains(.bottom), center.y >= accessibleCenterY, frame.maxY > accessibleMaxY - self.minAdsorbableSpacings.bottom {
            destinationOrigin.y = min(accessibleMaxY - frame.height, superview.frame.height - frame.height)
            adsorbedEdges.append(.bottom)
        }
        
        if self.adsorbableEdges.contains(.left), center.x < accessibleCenterX, frame.minX < self.minAdsorbableSpacings.left + accessibleMinX {
            destinationOrigin.x = max(accessibleMinX, 0)
            adsorbedEdges.append(.left)
        } else if self.adsorbableEdges.contains(.right), center.x >= accessibleCenterX, frame.maxX > accessibleMaxX - self.minAdsorbableSpacings.right {
            destinationOrigin.x = min(accessibleMaxX - frame.width, superview.frame.width - frame.width)
            adsorbedEdges.append(.right)
        }
        
        // 须在确定所有可吸附方向后再根据优先级筛选
        switch self.adsorbPriority {
        case .horizontalHigher:
            // 只有一个方向的时候，不需要再做多余处理
            guard adsorbedEdges.count == 2 else { break }
            if adsorbedEdges.contains(.top) {
                destinationOrigin.y = max(frame.origin.y, accessibleMinY, 0)
            } else if adsorbedEdges.contains(.bottom) {
                destinationOrigin.y = min(frame.origin.y, accessibleMaxY - bounds.height, superview.frame.height - bounds.height)
            }
            // 筛除后供 partiallyHide 使用
            adsorbedEdges = adsorbedEdges.filter { $0 == .left || $0 == .right }
        case .verticalHigher:
            guard adsorbedEdges.count == 2 else { break }
            if adsorbedEdges.contains(.left) {
                destinationOrigin.x = max(frame.origin.x, accessibleMinX, 0)
            } else if adsorbedEdges.contains(.right) {
                destinationOrigin.x = min(frame.origin.x, accessibleMaxX - bounds.width, superview.frame.width - bounds.width)
            }
            adsorbedEdges = adsorbedEdges.filter { $0 == .top || $0 == .bottom }
        default: break
        }
        
        guard destinationOrigin != frame.origin else { return }
        UIView.animate(withDuration: self.adsorbAnimationDuration,delay: 0.0, options:  [.curveLinear], animations: {
            self.frame.origin = destinationOrigin
        }) { isFinished in
            self.animatePartiallyHideView(atEdges: adsorbedEdges)
        }
    }
    
    private func animatePartiallyHideView(atEdges edges: [FloatingAdsorbableEdges]) {
        guard self.isAutoPartiallyHide else { return }
        
        var destinationOrigin = frame.origin
        for edge in edges {
            if edge == .top {
                destinationOrigin.y -= frame.height * self.partiallyHidePercent
            }
            if edge == .left {
                destinationOrigin.x -= frame.width * self.partiallyHidePercent
            }
            if edge == .bottom {
                destinationOrigin.y += frame.height * self.partiallyHidePercent
            }
            if edge == .right {
                destinationOrigin.x += frame.height * self.partiallyHidePercent
            }
        }
        
        guard destinationOrigin != frame.origin else { return }
        UIView.animate(withDuration: self.partiallyHideAnimationDuration,
                       delay: 0.0,
                       options: [.curveLinear],
                       animations: {
            self.frame.origin = destinationOrigin
        }) { isFinished in
            self.floatingDelegate?.floatingViewFinishedPartiallyHideAnimation()
        }
    }
    
}
