import UIKit

open class FloatingView:UIView,
                        FloatingViewProtocol{
    
    private struct AssociatedKeys {
        static var floatingPanGestureKey = "floatingPanGestureKey"
        static var floatingTapGestureKey = "floatingTapGestureKey"
        static var floatingDelegateKey = "floatingDelegateKey"
    }
    
    public let component = FloatingViewProtocolComponent()
    
    deinit{
        self.delegate = nil
        print("\(self.debugDescription) has been denited")
    }
    
    public weak var delegate: FloatingViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.floatingDelegateKey) as? FloatingViewDelegate
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.floatingDelegateKey, newValue as FloatingViewDelegate?, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    private var floatingPanGesture: UIPanGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.floatingPanGestureKey) as? UIPanGestureRecognizer
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.floatingPanGestureKey, newValue as UIPanGestureRecognizer?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var floatingTapGesture: UITapGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.floatingTapGestureKey) as? UITapGestureRecognizer
        }
        set {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.floatingTapGestureKey, newValue as UITapGestureRecognizer?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isShrinked = true{
        didSet{
           self.handleFloatingViewTap()
        }
    }
    
    private var isPartiallyAnimating = false
    
    public init() {
        super.init(frame: CGRect(origin: .zero, size:.zero))
        intialConfigure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialConfigure()
    }
    
    private func intialConfigure() {
        backgroundColor = .cyan
        layer.cornerRadius = 5
        addFloatingPanGestureRecognizer()
    }
    
    private func addTapGestureRecognizer() {
        guard floatingTapGesture == nil else { return }
        floatingTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFloatingViewTap))
        floatingTapGesture?.delegate = self
        addGestureRecognizer(floatingTapGesture!)
    }
    
    private func addFloatingPanGestureRecognizer() {
        guard floatingPanGesture == nil else { return }
        floatingPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleFloatingViewPanGesture))
        floatingPanGesture?.delegate = self
        addGestureRecognizer(floatingPanGesture!)
    }
    
    
    
    @objc private func handleFloatingViewTap(){
        let size : CGSize = isShrinked ? self.minSize : self.maxSize
        
        UIView.animateSafely(withDuration: self.component.expandShrinkAnimationDuration, options: [.curveLinear,
                                                                                                   .layoutSubviews,], animations: {
            self.frame.size = size
            self.animateToAdsorb()
        }){ _ in
            
        }
    }
    
    @objc private func handleFloatingViewPanGesture(_ pan: UIPanGestureRecognizer) {
        guard self.isDraggable else { return }
        
        switch pan.state {
        case .began:
            delegate?.floatingViewDidBeginDragging?(view: self)
        case .changed:
            defer {
                pan.setTranslation(.zero, in: self)
            }
            let translation = pan.translation(in: self)
            modifyOrigin(withTranslation: translation)
            delegate?.floatingViewDidMove?(view: self,to:translation)
        case .ended:
            animateToAdsorb()
            delegate?.floatingViewDidEndDragging?(view: self)
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
        

        if (tmpOriginX <= maxOriginX && translation.x > 0) || (tmpOriginX >= minOriginX && translation.x < 0) {
            frame.origin.x = tmpOriginX
        }
        
        if (tmpOriginY <= maxOriginY && translation.y > 0) || (tmpOriginY >= minOriginY && translation.y < 0) {
            frame.origin.y = tmpOriginY
        }
    }
    
    private func animateToAdsorb() {
        
        guard let superview = superview,
              self.isAutoAdsorb,
              self.floatingEdgeInsets.left + self.floatingEdgeInsets.right + frame.width * 2 <= superview.frame.width,
              self.floatingEdgeInsets.top + self.floatingEdgeInsets.bottom + frame.height * 2 <= superview.frame.height
        else { return }
        
        let accessibleCenterX = (superview.frame.width + self.floatingEdgeInsets.left - self.floatingEdgeInsets.right) / 2
        let accessibleCenterY = (superview.frame.height + self.floatingEdgeInsets.top - self.floatingEdgeInsets.bottom) / 2
        
        let accessibleMinX = self.floatingEdgeInsets.left
        let accessibleMinY = self.floatingEdgeInsets.top
        
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
        
    
        switch self.adsorbPriority {
            
        case .horizontalHigher:
            guard adsorbedEdges.count == 2 else { break }
            if adsorbedEdges.contains(.top) {
                destinationOrigin.y = max(frame.origin.y, accessibleMinY, 0)
            } else if adsorbedEdges.contains(.bottom) {
                destinationOrigin.y = min(frame.origin.y, accessibleMaxY - bounds.height, superview.frame.height - bounds.height)
            }
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
        
        if destinationOrigin != frame.origin {
            UIView.animateSafely(withDuration: self.adsorbAnimationDuration, options:  [.curveLinear], animations: {
                self.frame.origin = destinationOrigin
            }) { _ in
                self.animatePartiallyHideView(atEdges: adsorbedEdges)
            }
        }else{
            self.animatePartiallyHideView(atEdges: adsorbedEdges)
        }
    }
    
    
    private func animatePartiallyHideView(atEdges edges: [FloatingAdsorbableEdges]) {
        
        
        
        guard self.isAutoPartiallyHide,
              !isPartiallyAnimating,
              self.isShrinked else { return }
        
        isPartiallyAnimating = true
        
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
                destinationOrigin.x += frame.width * self.partiallyHidePercent
            }
        }
        
        guard destinationOrigin != frame.origin
        else { return }
        
        UIView.animateSafely(withDuration: self.partiallyHideAnimationDuration,
                       options: [.curveLinear],
                       animations: {
            self.frame.origin = destinationOrigin
        }) { _ in
            self.isPartiallyAnimating = false
            self.delegate?.floatingViewFinishedPartiallyHideAnimation?(view: self)
        }
    }
    
}

extension FloatingView:UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
