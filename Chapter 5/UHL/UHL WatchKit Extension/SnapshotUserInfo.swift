import Foundation

struct SnapshotUserInfo {
  let handler: () -> Void
  let destination: ContentView.Destination
  let matchId: Match.ID?
  
  init(handler: @escaping () -> Void, destination: ContentView.Destination, matchId: Match.ID? = nil) {
    self.handler = handler
    self.destination = destination
    self.matchId = matchId
  }
  
  private enum Keys: String {
    case handler
    case destination
    case matchId
  }
  
  func encode() -> [AnyHashable: Any] {
    return [
      Keys.handler.rawValue: handler,
      Keys.destination.rawValue: destination,
      Keys.matchId.rawValue: matchId as Any
    ]
  }
  
  static func from(notification: Notification) throws -> Self {
    guard let userInfo = notification.userInfo else {
      throw SnapshotError.noUserInfo
    }
    guard let handler = userInfo[Keys.handler.rawValue] as? () -> Void else {
      throw SnapshotError.noHandler
    }
    guard let destination = userInfo[Keys.destination.rawValue] as? ContentView.Destination else {
      throw SnapshotError.badDestination
    }
    
    return .init(handler: handler, destination: destination, matchId: userInfo[Keys.matchId.rawValue] as? Match.ID)
  }
}

enum SnapshotError: Error {
  case noHandler
  case badDestination
  case badMatchId
  case noUserInfo
}
