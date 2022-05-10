import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var cobrowseEventSink: FlutterEventSink?
    var currentTouchListenerView : CobrowseTouchListenerUIView?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController? = window?.rootViewController as? FlutterViewController
        
        if (controller?.binaryMessenger != nil) {
            self.initCobrowse(controller!.binaryMessenger)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
