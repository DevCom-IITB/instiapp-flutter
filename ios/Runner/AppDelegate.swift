import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var previousScreenBrightness: CGFloat?
  private var screenCaptureOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureStatusChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: UIScreen.main
    )

    let applicationResult = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "instiapp/profile_screen_protection",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "enable":
          if self?.previousScreenBrightness == nil {
            self?.previousScreenBrightness = UIScreen.main.brightness
          }
          UIScreen.main.brightness = 1.0
          result(nil)
        case "disable":
          if let brightness = self?.previousScreenBrightness {
            UIScreen.main.brightness = brightness
          }
          self?.previousScreenBrightness = nil
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return applicationResult
  }

  @objc private func screenCaptureStatusChanged() {
    guard let window = window else { return }

    if UIScreen.main.isCaptured {
      if screenCaptureOverlay == nil {
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .black
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlay)
        screenCaptureOverlay = overlay
      }
    } else {
      screenCaptureOverlay?.removeFromSuperview()
      screenCaptureOverlay = nil
    }
  }
}
