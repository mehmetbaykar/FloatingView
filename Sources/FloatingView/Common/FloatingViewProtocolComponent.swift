import UIKit

public struct FloatingAdsorbableEdges: OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let top = FloatingAdsorbableEdges(rawValue: 1)
    public static let left = FloatingAdsorbableEdges(rawValue: 1 << 1)
    public static let bottom = FloatingAdsorbableEdges(rawValue: 1 << 2)
    public static let right = FloatingAdsorbableEdges(rawValue: 1 << 3)
}

public enum FloatingAdsorbPriority: Int {
    case horizontalHigher
    case equal
    case verticalHigher
}

public struct FloatingViewProtocolComponent {
    var isDraggable = true
    var isAutoAdsorb = true
    var minSize = CGSize(width: 50,height: 50)
    var maxSize = CGSize(width: 200,height: 300)
    var adsorbableEdges: FloatingAdsorbableEdges = [.top, .left, .bottom, .right]
    var adsorbPriority: FloatingAdsorbPriority = .horizontalHigher
    var adsorbAnimationDuration: TimeInterval = 0.3
    var isAutoPartiallyHide = false
    var partiallyHidePercent: CGFloat = 0.5
    var expandShrinkAnimationDuration: TimeInterval = 0.35
    var partiallyHideAnimationDuration: TimeInterval = 0.3
    var floatingEdgeInsets: UIEdgeInsets = .default
    var minAdsorbableSpacings: UIEdgeInsets?
    
    public init() {}
}
