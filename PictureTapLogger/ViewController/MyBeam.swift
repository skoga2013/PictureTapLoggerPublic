//
//  MyBeam.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/09.
//

import Foundation
import UIKit

class MyBeam: UIView {

    var magneticHeading:CGFloat = 9999
    var pixel:Double = 9999
    var meter:Double = 9999
    var nowPoint:CGPoint!
    
    func setMagneticHeading(angle: CGFloat) {
        self.magneticHeading = angle
        self.setNeedsDisplay()
        
    }
    func setNowPoint(point:CGPoint) {
        self.nowPoint = point
        self.setNeedsDisplay()
    }
    //描画する
    override func draw(_ rect: CGRect) {
//        if self.magneticHeading != 9999 && nowPoint != nil {
        if nowPoint != nil {
            let pixel10:CGFloat = 10.0 * pixel / meter  //10mあたりのpixel
            
            let path = UIBezierPath()
            path.lineWidth = 1.0 // 線の太さ
            UIColor.green.setStroke() // 色をセット
            
            let center = CGPoint(x:500, y:500)
            
            path.move(to: center)
            path.addLine(to: CGPoint(x:500, y:500 - pixel10 * 4))
            path.move(to: center)
            
            let len:CGFloat = pixel10 * 4
            let rad:CGFloat = 30 * .pi / 180
            
            let dx:CGFloat = len * sin(rad)
            let dy:CGFloat = len * cos(rad)
            var x = center.x + dx
            var y = center.y - dy
            path.addLine(to: CGPoint(x:x, y:y))
            
            path.move(to: center)
            x = center.x - dx
            y = center.y - dy
            path.addLine(to: CGPoint(x:x, y:y))
            
            path.stroke()
            
            let radS:CGFloat = 240 * .pi / 180
            let radE:CGFloat = 300 * .pi / 180
             
            for i in 1...4 {
                
                let circle = UIBezierPath(arcCenter: center, radius: pixel10 * CGFloat(i), startAngle: radS, endAngle: radE, clockwise: true)
                // 線の太さ
                circle.lineWidth = 1.0
                // 線を塗りつぶす
                circle.stroke()
            }
            self.center = self.nowPoint
        }

        var pixel_meter:Double = self.meter / self.pixel * 60
        pixel_meter = pixel_meter.rounded(.toNearestOrAwayFromZero)
        
        let font = UIFont.boldSystemFont(ofSize: 9)
        
        String(pixel_meter).draw(at: CGPoint(x: 50,y:60), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font : font,
        ])

    }
}
