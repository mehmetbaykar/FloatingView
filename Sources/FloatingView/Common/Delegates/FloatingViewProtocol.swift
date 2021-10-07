import UIKit

public protocol FloatingViewProtocol: NSObjectProtocol {
    var component: FloatingViewProtocolComponent { get set }
    var isDraggable: Bool { get set }
    var isAutoAdsorb: Bool { get set }
    var minSize: CGSize { get set }
    var maxSize: CGSize { get set }
    var adsorbableEdges: FloatingAdsorbableEdges { get set }
    var adsorbPriority: FloatingAdsorbPriority { get set }
    var adsorbAnimationDuration: TimeInterval { get set }
    var minAdsorbableSpacings: UIEdgeInsets { get set }
    var isAutoPartiallyHide: Bool { get set }
    var partiallyHidePercent: CGFloat { get set }
    var partiallyHideAnimationDuration: TimeInterval { get set }
    var floatingEdgeInsets: UIEdgeInsets { get set }
}

// MARK: - Default Implementation
public extension FloatingViewProtocol where Self: FloatingView {
    
    var minSize: CGSize {
        get {return component.minSize }
        set{component.minSize = newValue }
    }
    
    var maxSize: CGSize {
        get {return component.maxSize }
        set{component.maxSize = newValue }
    }
    
    var isDraggable: Bool {
        get { return component.isDraggable }
        set { component.isDraggable = newValue }
    }
    
    var isAutoAdsorb: Bool {
        get { return component.isAutoAdsorb }
        set { component.isAutoAdsorb = newValue }
    }
    
    var adsorbableEdges: FloatingAdsorbableEdges {
        get { return component.adsorbableEdges }
        set { component.adsorbableEdges = newValue }
    }
    
    var adsorbPriority: FloatingAdsorbPriority {
        get { return component.adsorbPriority }
        set { component.adsorbPriority = newValue }
    }
    
    var adsorbAnimationDuration: TimeInterval {
        get { return component.adsorbAnimationDuration }
        set { component.adsorbAnimationDuration = newValue }
    }
    
    var isAutoPartiallyHide: Bool {
        get { return component.isAutoPartiallyHide }
        set { component.isAutoPartiallyHide = newValue }
    }
    
    var partiallyHidePercent: CGFloat {
        get { return component.partiallyHidePercent }
        set { component.partiallyHidePercent = newValue }
    }
    
    var partiallyHideAnimationDuration: TimeInterval {
        get { return component.partiallyHideAnimationDuration }
        set { component.partiallyHideAnimationDuration = newValue }
    }
    
    var floatingEdgeInsets: UIEdgeInsets {
        get { return component.floatingEdgeInsets }
        set { component.floatingEdgeInsets = newValue }
    }
    
    var minAdsorbableSpacings: UIEdgeInsets {
        get {
            if let spacings = component.minAdsorbableSpacings {
                return spacings
            }
            guard let superview = superview else { return .zero }
            let halfSuperWidth = superview.frame.width / 2
            return UIEdgeInsets(
                top: self.floatingEdgeInsets.top > 0 ? 100 : 100 - self.floatingEdgeInsets.top,
                left: halfSuperWidth - self.floatingEdgeInsets.left,
                bottom: self.floatingEdgeInsets.bottom > 0 ? 100 : 100 - self.floatingEdgeInsets.bottom,
                right: halfSuperWidth - self.floatingEdgeInsets.right
            )
        }
        set {
            component.minAdsorbableSpacings = newValue
        }
    }
}
