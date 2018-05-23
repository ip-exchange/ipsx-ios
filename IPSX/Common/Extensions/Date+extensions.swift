//
//  Date+extensions.swift
//  IPSX
//
//  Created by Calin Chitu on 14/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import UIKit

extension Date {
    
    func dateToString(format: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func isFromToday() -> Bool
    {
        let calendar = NSCalendar.current
        return calendar.isDateInToday(self)
    }
}
