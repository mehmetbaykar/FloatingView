import UIKit

public class FloatingViewManager {
    
    public static let shared = FloatingViewManager()
    
    private var floatingViews: Set<FloatingView> = []
    
    private init(){}
    
    public func startFloatingView(floatingView:FloatingView,
                                  on:UIView,
                                  origin:CGPoint) {
        let (isNew, _) = self.floatingViews.insert(floatingView)
        guard isNew  else {return}
        floatingView.frame.origin = origin
        on.addSubview(floatingView)
        on.bringSubviewToFront(floatingView)
    }
    
    
    public func removeFloatingView(floatingView:FloatingView) {
        floatingView.removeFromSuperview()
        floatingView.delegate = nil
        self.floatingViews.remove(floatingView)
    }
    
    public func reset(){
        self.floatingViews.forEach {
            $0.delegate = nil
            $0.removeFromSuperview()
        }
        self.floatingViews.removeAll()
    }
}
