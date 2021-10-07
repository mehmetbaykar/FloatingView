import UIKit.UIView

extension UIView{
    class func animateSafely(withDuration duration:TimeInterval = 0.35, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: options,
                       animations: {
            animations()
        }) { isFinished in
            if !isFinished{
                animations()
            }
            completion?(isFinished)
        }
    }
}
