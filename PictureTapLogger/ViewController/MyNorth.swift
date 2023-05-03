//
//  MyNorth.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/13.
//

import Foundation
import UIKit

class MyNorth: MyPoint {
    
    func addPoint(point:CGPoint) {
        if myPoint.count >= 2 {
            return
        }
        let inPoint = roundPoint(point: point)
        let rp = RoutePoint()
        rp.point = inPoint
        myPoint.append(rp)
        self.setNeedsDisplay()
    }

    override func addPoint(point:CGPoint, history: Bool = true, number: Int = -1, mode: Int = -1) {
        if myPoint.count >= 2 {
            return
        }
        let inPoint = roundPoint(point: point)
        let rp = RoutePoint()
        rp.point = inPoint
        if myPoint.count == 0 {
            rp.mode = 1 //先頭
        } else {
            rp.mode = 0
        }
        if mode != -1 {
            rp.mode = mode
        }
        rp.time = Date()
        rp.number = number
        myPoint.append(rp)
        indexPoint = myPoint.count - 1
        if history {
            addHistory()
        }
        self.setNeedsDisplay()
    }
    override func getLog() -> String {
        return ""
    }

    //描画する
    override func draw(_ rect: CGRect) {
        
        if myPoint.count < 2 {
            return
        }
        let path = UIBezierPath()
        path.move(to: myPoint[0].point)
        path.addLine(to: myPoint[1].point)
        path.lineWidth = 4.0 // 線の太さ
        UIColor.black.setStroke() // 色をセット
        path.stroke()
        
        var circle1 = UIBezierPath(arcCenter: myPoint[0].point, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
        UIColor.blue.setFill()
        circle1.fill()

        let font = UIFont.boldSystemFont(ofSize: 12)
        
        "S".draw(at: CGPoint(x: myPoint[0].point.x - 5, y:myPoint[0].point.y-7), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : font,
        ])

        circle1 = UIBezierPath(arcCenter: myPoint[1].point, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
        UIColor.red.setFill()
        circle1.fill()

        "N".draw(at: CGPoint(x: myPoint[1].point.x - 5, y:myPoint[1].point.y-7), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : font,
        ])
    }
 
}
