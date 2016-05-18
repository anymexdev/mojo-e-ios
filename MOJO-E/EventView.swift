//
//  EventView.swift
//  Demos
//
//  Created by Dominik Pich on 13/10/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import UIKit
import EventKit

class EventView: DDCalendarEventView {
    override var active : Bool {
        didSet {
            var c = Utility.greenL0Color()
//            if let ek = self.event.userInfo["event"] as? EKEvent {
//                c = UIColor(CGColor: ek.calendar.CGColor)
//            }

            if(active) {
                self.backgroundColor = c.colorWithAlphaComponent(0.9)
                self.layer.borderColor = c.CGColor
                self.layer.borderWidth = 1
            }
            else {
                self.backgroundColor = c.colorWithAlphaComponent(0.7)
                self.layer.borderColor = nil
                self.layer.borderWidth = 0
            }
        }
    }
}
