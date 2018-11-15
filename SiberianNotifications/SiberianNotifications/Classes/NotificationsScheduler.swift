//
//  NotificationsScheduler.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation
internal protocol Scheduler: class {
  
//  /// Requests and registers your preferred options for notifying the user.
//  /// The method requests (Badge, Sound, Alert) options by default.
//  ///
//  /// - Parameter options: The notification options that your app requires.
  func requestAuthorization(forOptions options: NotificationsAuthorizationOptions)
  
  /// Schedules the passed notification if and only if there is an available notification slot and it is not already scheduled.
  ///
  /// - Attention: iOS will discard notifications having the exact same attribute values (i.e if two notifications have the same attributes, iOS will only schedule one of them).
  ///
  /// - Parameter notification: The notification to schedule.
  /// - Returns: The scheduled `SiberianNotification` if it was successfully scheduled, nil otherwise.
  func schedule(notification: SiberianNotification) throws -> SiberianNotification
  
  /// Reschedules the passed `SiberianNotification` whether it is already scheduled or not. This simply cancels the `SiberianNotification` and schedules it again.
  ///
  /// - Parameter notification: The notification to reschedule.
  /// - Returns: The rescheduled `SiberianNotification` if it was successfully rescheduled, nil otherwise.
  func reschedule(notification: SiberianNotification) throws -> SiberianNotification
  
  /// Cancels the passed notification if it is scheduled. If multiple notifications have identical identifiers, they will be cancelled as well.
  ///
  /// - Parameter notification: The notification to cancel.
  func cancel(notification: SiberianNotification)
  
  /// Cancels all scheduled notifications having the passed identifier.
  /// - Attention: If you hold references to notifications having this same identifier, use `cancel(notification:)` instead.
  ///
  /// - Parameter identifier: The identifier to match against scheduled notifications to cancel.
  func cancel(withIdentifier identifier: String)
  
  /// Cancels all scheduled system notifications.
  func cancelAll()
  
  /// Returns a `SiberianNotification` instance from a scheduled system notification that has an identifier matching the passed identifier.
  ///
  /// - Attention: Having a reference to a `SiberianNotification` instance is the same as having multiple references to several `SiberianNotification` instances with the same identifier. This is only the case when canceling notifications.
  ///
  /// - Parameter identifier: The identifier to match against a scheduled system notification.
  /// - Returns: The `SiberianNotification` created from a system notification
  func notification(withIdentifier identifier: String) -> SiberianNotification?
  
  /// Returns the count of the scheduled notifications by iOS.
  ///
  /// - Returns: The count of the scheduled notifications by iOS.
  func scheduledCount() -> Int
  
  //    MARK:- Testing
  
  /// Use this method for development and testing.
  ///> Prints all scheduled system notifications.
  ///> You can freely modifiy it without worrying about affecting any functionality.
  func printScheduled()
}
