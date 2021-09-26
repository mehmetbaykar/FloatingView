import UIKit

public protocol FloatingViewDelegate: NSObjectProtocol {
    
    func floatingViewDidBeginDragging(view:FloatingView)
    func floatingViewDidEndDragging(view:FloatingView)
    
    func floatingViewDidMove(view:FloatingView)
    
    func floatingViewDidTap(view:FloatingView)
    
    func floatingViewFinishedPartiallyHideAnimation(view:FloatingView)
}

public extension FloatingViewDelegate {
    
    func floatingViewDidBeginDragging(view:FloatingView) { }
    func floatingViewDidEndDragging(view:FloatingView) { }
    
    func floatingViewDidMove(view:FloatingView) { }
    
    func floatingViewDidTap(view:FloatingView) { }
    
    func floatingViewFinishedPartiallyHideAnimation(view:FloatingView) { }
}
