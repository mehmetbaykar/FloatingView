import UIKit

@objc public protocol FloatingViewDelegate:AnyObject {
    
    @objc optional func floatingViewDidBeginDragging(view:FloatingView)
    @objc optional func floatingViewDidEndDragging(view:FloatingView)
    
    @objc optional func floatingViewDidMove(view:FloatingView)
    
    @objc optional func floatingViewDidShrink(view:FloatingView)
    
    @objc optional func floatingViewDidExpand(view:FloatingView)
    
    @objc optional func floatingViewFinishedPartiallyHideAnimation(view:FloatingView)
}
