import Foundation
import NVActivityIndicatorView

// MARK: Alert
extension UIViewController {
   func showAlertSuccess() {
        let alert = UIAlertController(title: "successfully", message: "add completed.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertFail() {
         let alert = UIAlertController(title: "Fail", message: "An error occurred, please try again.", preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
    
    func showAlertFail(message: String) {
         let alert = UIAlertController(title: "Fail", message: message, preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
    
    func showAlertFailText() {
         let alert = UIAlertController(title: "Fail", message: "please enter username and password.", preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
    
    func showAlertOfflineUse(done: @escaping () -> Void) {
        let alert = UIAlertController(title: "Warning!", message: "Do you want to use it offline?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "continue", style: UIAlertAction.Style.default, handler: { _ in
            done()
        }))
        alert.addAction(UIAlertAction(title: "cancal", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertExp(done: @escaping () -> Void) {
        let alert = UIAlertController(title: "expired card!", message: "Do you want to continue using?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "continue", style: UIAlertAction.Style.default, handler: { _ in
            done()
        }))
        alert.addAction(UIAlertAction(title: "cancal", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertNoCard() {
         let alert = UIAlertController(title: "Fail", message: "No card present: Card is removed.", preferredStyle: UIAlertController.Style.alert)
         alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
         self.present(alert, animated: true, completion: nil)
     }
    
    func showAlertAboutUs() {
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            let alert = UIAlertController(title: "About Us", message: "app version: \(String(describing: appVersion))", preferredStyle: UIAlertController.Style.alert)
             alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
        }
     }
}

// MARK: Showprogress
extension UIViewController: NVActivityIndicatorViewable {
    func showProgress() {
        let size = CGSize(width: 42, height: 42)
        startAnimating(size, message: "",
                       type: NVActivityIndicatorType.ballPulseSync)
    }
    
    func showLongProgress() {
        let size = CGSize(width: 42, height: 42)
        startAnimating(size, message: "",
                       type: NVActivityIndicatorType.ballPulseSync,
                       minimumDisplayTime: 6)
    }
    
    func hideProgress() {
        stopAnimating()
    }
    
    func updateMessage(message: String) {
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
}
