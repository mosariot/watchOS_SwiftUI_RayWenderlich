import Foundation
import WatchConnectivity

final class Connectivity: NSObject, ObservableObject {
  static let shared = Connectivity()
  @Published var purchasedIds: [Int] = []
  
  override private init() {
    super.init()
#if !os(watchOS)
    guard WCSession.isSupported() else { return }
#endif
    WCSession.default.delegate = self
    WCSession.default.activate()
  }
  
  public func send(movieIds: [Int]) {
    guard WCSession.default.activationState == .activated else { return }
#if os(watchOS)
    guard WCSession.default.isCompanionAppInstalled else { return }
#elseif os(iOS)
    guard WCSession.default.isWatchAppInstalled else { return }
#endif
    let userInfo: [String: [Int]] = [
      ConnectivityUserInfoKey.purchased.rawValue: movieIds
    ]
    WCSession.default.transferUserInfo(userInfo)
  }
}

// MARK: - WCSessionDelegate

extension Connectivity: WCSessionDelegate {
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
#if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    WCSession.default.activate()
  }
#endif
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    let key = ConnectivityUserInfoKey.purchased.rawValue
    guard let ids = userInfo[key] as? [Int] else { return }
    self.purchasedIds = ids
  }
}
