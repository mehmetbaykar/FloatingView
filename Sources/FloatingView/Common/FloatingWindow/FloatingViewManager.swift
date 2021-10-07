import UIKit

public class FloatingViewManager {
    
    private var floatingWindow: FloatingWindow?
    
    public static let shared = FloatingViewManager()
    
    
    private init(){}
    
    public func startFloatingView(
        statusBarStyle: UIStatusBarStyle = .default,
        viewController:FloatableViewController) {
        
        defer {
            FloatingViewManager.shared.floatingWindow?.makeKeyAndVisible()
        }
            
        guard FloatingViewManager.shared.floatingWindow == nil else { return }
        
            
        let floatingWindow = FloatingWindow(frame: UIScreen.main.bounds,
                                            statusBarStyle: statusBarStyle,
                                            viewController: viewController)
            FloatingViewManager.shared.floatingWindow = floatingWindow
    }
    
    
   public func removeFloatingView() {
        FloatingViewManager.shared.floatingWindow?.resignWindow()
        FloatingViewManager.shared.floatingWindow = nil
    }
    
   public func updateFloatingViewStatusBarStyle(to style: UIStatusBarStyle) {
        FloatingViewManager.shared.floatingWindow?.statusBarStyle = style
    }
}
