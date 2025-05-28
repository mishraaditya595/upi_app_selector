import Flutter
import UIKit

public class SwiftGetUpiPlugin: NSObject, FlutterPlugin {
    var upiApps: [UPIAPPS] = [UPIAPPS(name: "Gpay", scheme: "gpay"),
                              UPIAPPS(name: "Phonepe", scheme:"phonepe"),
                              UPIAPPS(name: "Paytm", scheme:"paytmmp"),
                              UPIAPPS(name: "payzapp", scheme:"payzapp"),
                              UPIAPPS(name: "BHIM", scheme:"BHIM"),
                              UPIAPPS(name: "CRED", scheme:"CRED"),
                              UPIAPPS(name: "amazon", scheme:"amazon"),
                              
    ]
   

    var aryApps: [Dictionary<String, Any>] = []

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "GET_UPI_IPPO", binaryMessenger: registrar.messenger())
    let instance = SwiftGetUpiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {


    if (call.method == "get_available_upi"){
      self.aryApps = []
        //Check whether the app available in device
        for val in self.upiApps{
            let url = URL(string: val.scheme+"://upi/pay?pa=test@ybl&pn=gokul&am=1.00&tn=Test_Transaction")
            if(UIApplication.shared.canOpenURL(url!)) {
            self.aryApps.append([
                "name": val.name,
                "package": val.scheme
            ])
            }
        }
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: self.aryApps, options: .prettyPrinted)
            let theJSONText = String(data: theJSONData, encoding: .utf8)
            result(theJSONText!)
        } catch {
        }
    }else if call.method == "ios_intent" {
        if let arguments = call.arguments as? [String: Any],
            var url = arguments["url"] as? String,
            let package = arguments["package"] as? String
             {
              url = url.replacingOccurrences(of: "upi://", with: (package+"://"))
            openUpiIntent(url: url, result: result)
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument", details: nil))
        }
    }  else {
      result(FlutterMethodNotImplemented)
    }
  }


  }






private func openUpiIntent(url: String, result: @escaping FlutterResult) {
 
     print("my url in final stage ==> ", url)
    if let targetURL = URL(string: url), UIApplication.shared.canOpenURL(targetURL) {
        print("URL argument: \(targetURL)")
        UIApplication.shared.open(targetURL, options: [:]) { success in
            if success {
                result("UPI app opened successfully")
            } else {
                result("Failed to open UPI app")
            }
        }
    } else {
        result("Please make sure you've installed UPI apps")
    }
}

struct UPIAPPS {
    let name: String
    let scheme: String
}