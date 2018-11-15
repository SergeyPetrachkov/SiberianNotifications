//
//  UserNotificationsScheduler.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation
import UserNotifications

@available(iOS 10.0, *)
internal class UserNotificationsScheduler: Scheduler {
  func requestAuthorization(forOptions options: NotificationsAuthorizationOptions) {
    let center: UNUserNotificationCenter             = UNUserNotificationCenter.current()
    let authorizationOptions: UNAuthorizationOptions = UNAuthorizationOptions(rawValue: options.rawValue)
    
    center.requestAuthorization(options: authorizationOptions) { (granted, error) in }
  }
  
  private func trigger(forDate date: Date, repeats: NotificationRepeatPolicy) -> UNCalendarNotificationTrigger {
    var dateComponents: DateComponents = DateComponents()
    let shouldRepeat: Bool = repeats != .none
    let calendar: Calendar = Calendar.current
    
    switch repeats {
    case .none:
      dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    case .month:
      dateComponents = calendar.dateComponents([.day, .hour, .minute], from: date)
    case .week:
      dateComponents.weekday = calendar.component(.weekday, from: date)
      fallthrough
    case .day:
      dateComponents.hour = calendar.component(.hour, from: date)
      fallthrough
    case .hour:
      dateComponents.minute = calendar.component(.minute, from: date)
      dateComponents.second = 0
    }
    
    return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: shouldRepeat)
  }
  
  func schedule(notification: SiberianNotification) throws -> SiberianNotification {
    if notification.scheduled == true {
      throw SchedulerError.alreadyScheduled
    }
    
    if (self.scheduledCount() >= MaxAllowedNumberOfNotifications) {
      throw SchedulerError.maxNumberReached
    }
    
    let content = UNMutableNotificationContent()
    
    if let title = notification.title {
      content.title = title
    }
    
    content.body = notification.body
    
    content.userInfo = notification.userInfo
    
    content.badge = notification.badge
    
    let trigger: UNCalendarNotificationTrigger = self.trigger(forDate: notification.date, repeats: notification.repeatPolicy)
    
    let request: UNNotificationRequest = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.add(request, withCompletionHandler: nil)
    notification.scheduled = true
    
    return notification
  }
  
  func reschedule(notification: SiberianNotification) throws -> SiberianNotification {
    self.cancel(notification: notification)
    
    return try self.schedule(notification: notification)
  }
  
  func cancel(notification: SiberianNotification) {
    if notification.scheduled == false {
      return
    }
    
    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [notification.id])
    notification.scheduled = false
  }
  
  func cancel(withIdentifier identifier: String) {
    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [identifier])
  }
  
  func cancelAll() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    print("All scheduled system notifications have been canceled.")
  }
  
  func notification(withIdentifier identifier: String) -> SiberianNotification? {
    let semaphore = DispatchSemaphore(value: 0)
    var notification: SiberianNotification?  = nil

    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      for request in requests {
        if request.identifier == identifier {
          notification = SiberianNotification.notification(withSystemNotification: request)

          semaphore.signal()

          break
        }
      }
      semaphore.signal()
    }

    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return notification
  }
  
  func scheduledCount() -> Int {
    let semaphore = DispatchSemaphore(value: 0)
    var count: Int = 0
    
    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      count = requests.count
      semaphore.signal()
    }
    
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    
    return count
  }
  
  //    MARK:- Testing
  
  func printScheduled() {
    if (self.scheduledCount() == 0) {
      print("There are no scheduled system notifications.")
      return
    }
    
    let semaphore = DispatchSemaphore(value: 0)
    let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
      for request in requests {
        let notification: SiberianNotification = request.siberianNotification()!
        print(notification)
      }
      semaphore.signal()
    }
    
    let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }
}
