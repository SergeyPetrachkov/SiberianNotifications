//
//  UNNotificationRequest+Siberia.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation

import UserNotifications

@available(iOS 10.0, *)
extension UNNotificationRequest: SystemNotification {
  
  public func siberianNotification() -> SiberianNotification? {
    let content = self.content
    
    let siberianNotification = SiberianNotification(id: self.identifier, body: content.body)
    
    let userInfo = content.userInfo
    for (key, value) in userInfo {
      siberianNotification.setUserInfo(value: value, forKey: key)
    }
    if content.title.trimmingCharacters(in: .whitespaces).count > 0 {
      siberianNotification.title = content.title
    }
    
    if let trigger = self.trigger as? UNCalendarNotificationTrigger {
      var date: Date?
      if let originalDate = siberianNotification.userInfo[SiberianNotificationsKeys.date] as? Date {
        date = originalDate
      }
      siberianNotification.repeatPolicy = self.repeats(dateComponents: trigger.dateComponents)
      siberianNotification.date = self.date(fromDateComponents: trigger.dateComponents,
                                            repeats: siberianNotification.repeatPolicy,
                                            originalDate: date)
    }
    
    siberianNotification.badge = content.badge
    siberianNotification.scheduled = true
    return siberianNotification
  }
  
  /// Since repeating a `UNCalendarNotificationTrigger` nullifies some of the
  /// date components, the original date needs to be stored. This date is stored
  /// in the notification's `userInfo` property using `SiberianNotificationsKeys.date`.
  /// This original date is used to fill those nullified components.
  ///
  /// - Parameters:
  ///   - dateComponents: The `UNCalendarNotificationTrigger` date components.
  ///   - repeats: The repeat interval of the trigger.
  ///   - originalDate: The original date stored to fill the nullified components. Uses current date if passed as `nil`.
  /// - Returns: The filled date using the original date.
  private func date(fromDateComponents dateComponents: DateComponents, repeats: NotificationRepeatPolicy, originalDate: Date?) -> Date {
    let calendar: Calendar = Calendar.current
    var components: DateComponents = dateComponents
    
    var date: Date
    if let origDate = originalDate {
      date = origDate
    } else {
      date = Date()
    }
    
    switch repeats {
    case .none:
      return calendar.date(from: components)!
    case .month:
      let comps = calendar.dateComponents([.year, .month], from: date)
      components.year = comps.year
      components.month = comps.month
      
      return calendar.date(from: components)!
    case .week:
      let comps = calendar.dateComponents([.year, .month, .day], from: date)
      components.year = comps.year
      components.month = comps.month
      components.day = comps.day
      
      return calendar.date(from: components)!
    case .day:
      let comps = calendar.dateComponents([.year, .month, .day], from: date)
      components.year = comps.year
      components.month = comps.month
      components.day = comps.day
      
      return calendar.date(from: components)!
    case .hour:
      let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)
      components.year = comps.year
      components.month = comps.month
      components.day = comps.day
      components.hour = comps.hour
      
      return calendar.date(from: components)!
    }
  }
  
  private func repeats(dateComponents components: DateComponents) -> NotificationRepeatPolicy {
    if self.doesRepeatNone(dateComponents: components) {
      return .none
    } else if doesRepeatMonth(dateComponents: components) {
      return .month
    } else if doesRepeatWeek(dateComponents: components) {
      return .week
    } else if doesRepeatDay(dateComponents: components) {
      return .day
    } else if doesRepeatHour(dateComponents: components) {
      return .hour
    }
    
    return .none
  }
  
  private func doesRepeatNone(dateComponents components: DateComponents) -> Bool {
    return components.year != nil && components.month != nil && components.day != nil && components.hour != nil && components.minute != nil
  }
  
  private func doesRepeatMonth(dateComponents components: DateComponents) -> Bool {
    return components.day != nil && components.hour != nil && components.minute != nil
  }
  
  private func doesRepeatWeek(dateComponents components: DateComponents) -> Bool {
    return components.weekday != nil && components.hour != nil && components.minute != nil && components.second != nil
  }
  
  private func doesRepeatDay(dateComponents components: DateComponents) -> Bool {
    return components.hour != nil && components.minute != nil && components.second != nil
  }
  
  private func doesRepeatHour(dateComponents components: DateComponents) -> Bool {
    return components.minute != nil && components.second != nil
  }
}
