//
//  SiberianNotificationsCenter.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation

public struct NotificationsAuthorizationOptions: OptionSet, RawRepresentable {
  public let rawValue: UInt
  
  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }
  
  public static let badge = NotificationsAuthorizationOptions(rawValue: 1 << 0)
  public static let sound = NotificationsAuthorizationOptions(rawValue: 1 << 1)
  public static let alert = NotificationsAuthorizationOptions(rawValue: 1 << 2)
}

public class SiberianNotificationsCenter: Scheduler {
  public static let shared: SiberianNotificationsCenter = SiberianNotificationsCenter()
  
  private var scheduler: Scheduler!
  
  /// The maximum number of allowed notifications to be scheduled. Four slots
  /// are reserved if you would like to schedule notifications without them being dropped
  /// due to unavialable notification slots.
  ///> Feel free to change this value.
  ///- Attention: iOS by default allows a maximum of 64 notifications to be scheduled
  /// at a time.
  ///- seealso: `MAX_ALLOWED_NOTIFICATIONS`
  public static let maximumAllowedNotifications = 60
  
  private init () {
    if #available(iOS 10, *) {
      self.scheduler = UserNotificationsScheduler()
    } else {
//      self.scheduler = UILocalNotificationScheduler()
    }
  }
  
  /// Requests and registers your preferred options for notifying the user.
  /// The method requests (Badge, Sound, Alert) options by default.
  ///
  /// - Parameter options: The notification options that your app requires.
  public func requestAuthorization(forOptions options: NotificationsAuthorizationOptions = [.badge, .sound, .alert]) {
    self.scheduler.requestAuthorization(forOptions: options)
  }
  
  /// Schedules the passed `SiberianNotification` if and only if there is an available notification slot and it is not already scheduled.
  ///
  /// - Attention: iOS will discard notifications having the exact same attribute values (i.e if two notifications have the same attributes, iOS will only schedule one of them).
  ///
  /// - Parameter notification: The notification to schedule.
  /// - Returns: The scheduled `SiberianNotification` if it was successfully scheduled, throws error otherwise.
  public func schedule(notification: SiberianNotification) throws -> SiberianNotification {
    return try scheduler.schedule(notification: notification)
  }
  
  /// Reschedules the passed `SiberianNotification` whether it is already scheduled or not. This simply cancels the `SiberianNotification` and schedules it again.
  ///
  /// - Parameter notification: The notification to reschedule.
  /// - Returns: The rescheduled `SiberianNotification` if it was successfully rescheduled, nil otherwise.
  public func reschedule(notification: SiberianNotification) throws -> SiberianNotification {
    return try scheduler.reschedule(notification: notification)
  }
  
  /// Cancels the passed notification if it is scheduled. If multiple notifications have identical identifiers, they will be cancelled as well.
  ///
  /// - Parameter notification: The notification to cancel.
  public func cancel(notification: SiberianNotification) {
    self.scheduler.cancel(notification: notification)
  }
  
  /// Cancels all scheduled notifications having the passed identifier.
  ///
  /// - Attention: If you hold references to notifications having this same identifier, use `cancel(notification:)` instead.
  ///
  /// - Parameter identifier: The identifier to match against scheduled system notifications to cancel.
  public func cancel(withIdentifier identifier: String) {
    self.scheduler.cancel(withIdentifier: identifier)
  }
  
  /// Cancels all scheduled system notifications.
  public func cancelAll() {
    self.scheduler.cancelAll()
  }
  
  /// Returns a `SiberianNotification` instance from a scheduled system notification that has an identifier matching the passed identifier.
  ///
  /// - Attention: Having a reference to a `SiberianNotification` instance is the same as having multiple references to several `SiberianNotification` instances with the same identifier. This is only the case when canceling notifications.
  ///
  /// - Parameter identifier: The identifier to match against a scheduled system notification.
  /// - Returns: The `SiberianNotification` created from a system notification
  public func notification(withIdentifier identifier: String) -> SiberianNotification? {
    return self.scheduler.notification(withIdentifier: identifier)
  }
  
  /// Returns the count of the scheduled notifications by iOS.
  ///
  /// - Returns: The count of the scheduled notifications by iOS.
  public func scheduledCount() -> Int {
    return self.scheduler.scheduledCount()
  }
  
  //    MARK:- Testing
  
  /// Use this method for development and testing.
  ///> Prints all scheduled system notifications.
  ///> You can freely modifiy it without worrying about affecting any functionality.
  public func printScheduled() {
    self.scheduler.printScheduled()
  }
}
