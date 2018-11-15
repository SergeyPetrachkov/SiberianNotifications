//
//  SiberianNotification.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation

public protocol SystemNotification {
  func siberianNotification() -> SiberianNotification?
}
public enum SchedulerError: Error {
  case maxNumberReached
  case alreadyExists
  case alreadyScheduled
}
public let MaxAllowedNumberOfNotifications = 64
public enum NotificationRepeatPolicy: String {
  case none  = "None"
  case hour  = "Hour"
  case day   = "Day"
  case week  = "Week"
  case month = "Month"
}
public enum SiberianNotificationsKeys: String {
  case id = "siberianNotificationId"
  case date = "siberianNotificationDate"
}

public class SiberianNotification: NSObject {
  public private(set) var id: String
  
  public init(id: String, body: String = "") {
    self.id = id
    self.body = body
  }
  
  /// The body string of the notification.
  public var body: String
  
  /// The date in which the notification is set to fire on.
  public var date: Date! {
    didSet {
      self.userInfo[SiberianNotificationsKeys.date] = self.date
    }
  }
  
  /// A dictionary that holds additional information.
  private(set) public var userInfo: [AnyHashable : Any] = [:]
  
  /// The title string of the notification.
  public var title: String? = nil
  
  /// The number the notification should display on the app icon.
  public var badge: NSNumber? = nil
  
  /// The repeat interval of the notification.
  public var repeatPolicy: NotificationRepeatPolicy = .none
  
  /// The status of the notification.
  internal(set) public var scheduled: Bool = false
  
  
  /// Creates a `SiberianNotification` from the passed `SystemNotification`. For the details of the creation process, have a look at the system notifications extensions that implement the `SystemNotification` protocol.
  ///
  /// - Parameter notification: The system notification to create the `SiberianNotification` from.
  /// - Returns: The `SiberianNotification` if the creation succeeded, nil otherwise.
  public static func notification(withSystemNotification notification: SystemNotification) -> SiberianNotification? {
    return notification.siberianNotification()
  }
  
  /// Adds a value to the specified key in the `userInfo` property. Note that the value is not added if the key is equal to the `SiberianNotificationsKeys.id` or `SiberianNotificationsKeys.date`.
  ///
  /// - Parameters:
  ///   - value: The value to set.
  ///   - key: The key to set the value of.
  public func setUserInfo(value: Any, forKey key: AnyHashable) {
    if let keyString = key as? String {
      if (keyString == SiberianNotificationsKeys.id.rawValue || keyString == SiberianNotificationsKeys.date.rawValue) {
        return
      }
    }
    self.userInfo[key] = value;
  }
  
  /// Removes the value of the specified key. Note that the value is not removed if the key is equal to the `SiberianNotificationsKeys.id` or `SiberianNotificationsKeys.date`.
  ///
  /// - Parameter key: The key to remove the value of.
  public func removeUserInfoValue(forKey key: AnyHashable) {
    if let keyString = key as? String {
      if (keyString == SiberianNotificationsKeys.id.rawValue || keyString == SiberianNotificationsKeys.date.rawValue) {
        return
      }
    }
    self.userInfo.removeValue(forKey: key)
  }
}

public func ==(lhs: SiberianNotification, rhs: SiberianNotification) -> Bool {
  return lhs.id == rhs.id
}

public func <(lhs: SiberianNotification, rhs: SiberianNotification) -> Bool {
  return lhs.date.compare(rhs.date) == ComparisonResult.orderedAscending
}
