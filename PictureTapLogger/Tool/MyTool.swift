//
//  MyTool.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/05.
//

import Foundation
import UIKit

class MyTool: UIView {
    func isInArea(point: CGPoint) -> Bool {
        let dx = Double(self.center.x - point.x)
        let dy = Double(self.center.y - point.y)
        let diff = sqrt(dx*dx + dy*dy)
        if diff < (self.frame.height / 2.0) {
            return true
        } else {
            return false
        }

    }
}
