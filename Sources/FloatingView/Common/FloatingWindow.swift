import UIKit

class FloatingWindow: UIWindow {
    
    private  let floatingWindowRootViewController: FloatableViewController
    private  var pointInsideCalled : Bool = true
    
    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            floatingWindowRootViewController.statusBarStyle = statusBarStyle
            UIView.animate(withDuration: 0.35) {
                self.floatingWindowRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    init(frame: CGRect,
         statusBarStyle: UIStatusBarStyle,
         viewController:FloatableViewController) {
        
        self.floatingWindowRootViewController = viewController
        self.statusBarStyle = statusBarStyle
        self.floatingWindowRootViewController.statusBarStyle = statusBarStyle
        
        super.init(frame: frame)
        self.rootViewController = floatingWindowRootViewController
        self.addSubview(viewController.floatingView)
        self.bringSubviewToFront(viewController.floatingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        for subView in subviews {
            if subView is FloatingViewProtocol, subView.bounds.contains(subView.convert(point, from: self)) {
                return super.point(inside: point, with: event)
            }
        }
        return false
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            self.pointInsideCalled = true
            return floatingWindowRootViewController.floatingView
        }
        if pointInsideCalled {
            self.pointInsideCalled = false
            return  floatingWindowRootViewController.floatingView
        }
        return nil
    }
    
    
    func resignWindow(){
        self.floatingWindowRootViewController.floatingView.floatingDelegate = nil
        self.rootViewController = nil
    }
}
