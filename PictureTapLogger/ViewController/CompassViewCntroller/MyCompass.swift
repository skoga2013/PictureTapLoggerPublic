//
//  MyCompass.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/15.
//

import Foundation
import UIKit

class MyCompass: MyPoint {

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
    func setSccale(pixel:CGFloat, meter:CGFloat) {
        self.pixel = pixel
        self.meter = meter
        self.setNeedsDisplay()
    }
    //描画する
    override func draw(_ rect: CGRect) {

        let path = UIBezierPath()
        path.lineWidth = 1.0 // 線の太さ
        UIColor.red.setStroke() // 色をセット
        
        let imgWidth:CGFloat = self.frame.width
        let imgHeight:CGFloat = self.frame.height

        let centerP = CGPoint(x:imgWidth / 2, y: imgHeight * 0.75)
        
        var endP:[CGPoint] = []
        endP.append(CGPoint(x:centerP.x, y:0))//縦線 上
        endP.append(CGPoint(x:centerP.x, y:imgHeight))//縦線 下
        endP.append(CGPoint(x:0, y:centerP.y))//縦線 左
        endP.append(CGPoint(x:imgWidth, y:centerP.y))//縦線 右

        var rad:CGFloat = 30 * .pi / 180
        endP.append(CGPoint(x:centerP.x + centerP.y * tan(rad), y:0))//右上３０
        endP.append(CGPoint(x:centerP.x - centerP.y * tan(rad), y:0))//左上３０
        endP.append(CGPoint(x:centerP.x + (imgHeight - centerP.y) * tan(rad), y:imgHeight))//右下３０
        endP.append(CGPoint(x:centerP.x - (imgHeight - centerP.y) * tan(rad), y:imgHeight))//左下３０
        rad = 60 * .pi / 180
        endP.append(CGPoint(x:centerP.x + centerP.y * tan(rad), y:0))//右上６０
        endP.append(CGPoint(x:centerP.x - centerP.y * tan(rad), y:0))//左上６０
        endP.append(CGPoint(x:centerP.x + (imgHeight - centerP.y) * tan(rad), y:imgHeight))//右下６０
        endP.append(CGPoint(x:centerP.x - (imgHeight - centerP.y) * tan(rad), y:imgHeight))//左下６０

        for i in 0..<endP.count {
            path.move(to: centerP)
            path.addLine(to: endP[i])

        }
        path.stroke()
        
        // 円
        var radius:[CGFloat] = [100.0,200.0,300.0,400.0,500.0,600]
        for i in 0..<radius.count {
            var circle = UIBezierPath(arcCenter: centerP, radius: radius[i], startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
            circle.lineWidth = 0.5
            circle.stroke()

        }


        var radS:CGFloat = 300 * .pi / 180
        var radE:CGFloat = 240 * .pi / 180
        
        path.move(to: centerP)
        path.addArc(withCenter: centerP, radius: 1000, startAngle: radS, endAngle: radE, clockwise: true)
        UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 0.3).setFill()
        path.fill()

        
        radS = 0 * .pi / 180
        radE = 360 * .pi / 180
        path.removeAllPoints()
        path.addArc(withCenter: centerP, radius: 60, startAngle: radS, endAngle: radE, clockwise: true)
        path.addArc(withCenter: centerP, radius: 65, startAngle: radS, endAngle: radE, clockwise: true)
        path.stroke()


        path.removeAllPoints()
        path.move(to: CGPoint(x:centerP.x - 80, y:centerP.y - 300)) //頂点
        path.addLine(to: CGPoint(x:centerP.x + 80, y:centerP.y - 300))
        path.addLine(to: CGPoint(x:centerP.x + 80, y:centerP.y + 80))
        path.addLine(to: CGPoint(x:centerP.x - 80, y:centerP.y + 80))
        path.addLine(to: CGPoint(x:centerP.x - 80, y:centerP.y - 300)) //頂点
        path.stroke()

        path.removeAllPoints()
        path.move(to: CGPoint(x:centerP.x - 85, y:centerP.y - 305)) //頂点
        path.addLine(to: CGPoint(x:centerP.x + 85, y:centerP.y - 305))
        path.addLine(to: CGPoint(x:centerP.x + 85, y:centerP.y + 85))
        path.addLine(to: CGPoint(x:centerP.x - 85, y:centerP.y + 85))
        path.addLine(to: CGPoint(x:centerP.x - 85, y:centerP.y - 305)) //頂点
        path.stroke()

    }
}
