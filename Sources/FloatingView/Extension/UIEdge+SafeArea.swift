import UIKit

extension UIEdgeInsets{
     static let `default`:UIEdgeInsets = {
         
        guard let window = UIApplication.shared.windows.last
        else { return UIEdgeInsets.zero}
         
         var topPadding:CGFloat = .zero
         var bottomPadding:CGFloat = .zero
         
         if #available(iOS 11.0, *) {
             topPadding = window.safeAreaInsets.top
             bottomPadding = window.safeAreaInsets.bottom
         }
        
        return UIEdgeInsets(top: topPadding, left: .zero, bottom: bottomPadding, right: .zero)
    }()
}
