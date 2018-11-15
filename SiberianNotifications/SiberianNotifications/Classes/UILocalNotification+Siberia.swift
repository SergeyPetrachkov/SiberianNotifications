//
//  UserNotification_Siberia.swift
//  SiberianNotifications
//
//  Created by Sergey Petrachkov on 15/11/2018.
//  Copyright © 2018 Sergey Petrachkov. All rights reserved.
//

import Foundation

extension UILocalNotification: SystemNotification {
  public func siberianNotification() -> SiberianNotification? {
    guard let userInfo = self.userInfo, let id = userInfo[SiberianNotificationsKeys.id] as? String else {
      return nil
    }
    let siberianNotification = SiberianNotification(id: id)
    
    self.userInfo?.forEach({ (keyValuePair) in
      siberianNotification.setUserInfo(value: keyValuePair.value, forKey: keyValuePair.key)
    })
    siberianNotification.title = self.alertTitle

    siberianNotification.badge = self.applicationIconBadgeNumber as NSNumber
    
    var repeatPolicy: NotificationRepeatPolicy
    switch self.repeatInterval {
    case NSCalendar.Unit.hour:
      repeatPolicy = .hour
    case NSCalendar.Unit.day:
      repeatPolicy = .day
    case NSCalendar.Unit.weekOfYear:
      repeatPolicy = .week
    case NSCalendar.Unit.month:
      repeatPolicy = .month
    default:
      repeatPolicy = .none
    }
    
    siberianNotification.repeatPolicy = repeatPolicy
    siberianNotification.scheduled = true
    
    return siberianNotification
  }
}
