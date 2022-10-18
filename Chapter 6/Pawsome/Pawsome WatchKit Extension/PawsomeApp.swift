import SwiftUI

@main
struct PawsomeApp: App {
  @WKExtensionDelegateAdaptor(ExtensionDelegate.self)
  private var extensionDelegate
  private let local = LocalNotifications()

  @SceneBuilder var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }

    WKNotificationScene(
      controller: NotificationController.self,
      category: LocalNotifications.categoryIdentifier
    )
    WKNotificationScene(
      controller: RemoteNotificationController.self,
      category: RemoteNotificationController.categoryIdentifier
    )
  }
}

import WatchKit
import UserNotifications

final class ExtensionDelegate: NSObject, WKExtensionDelefate {
  func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
    print(deviceToket.reduce("") { $0 + String(format: "%02x", $1) })
  }
  
  func applicationDidFinishLaunching() {
    Task {
      do {
        let success = try await UNUserNotificationCenter
          .current
          .requestAuthorization(options: [.badge, .sound, .alert])
        guard success else { return }
        await MainActor.run {
          WKExtension.shared().registerForRemoteNotifications()
        }
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
