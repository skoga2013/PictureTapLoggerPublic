//
//  MyNotrhHead.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/30.
//

import Foundation
import UIKit

class MyNorthHead: MyPoint {
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
        
        path.move(to: CGPoint(x:centerP.x, y:centerP.y - 60)) //頂点
        path.addLine(to: CGPoint(x:centerP.x + 20, y:centerP.y - 30))
        path.addLine(to: CGPoint(x:centerP.x + 10, y:centerP.y - 30))
        path.addLine(to: CGPoint(x:centerP.x + 10, y:centerP.y + 50))

        var radS:CGFloat = 0 * .pi / 180
        var radE:CGFloat = 180 * .pi / 180
        path.addArc(withCenter: CGPoint(x: centerP.x, y:centerP.y + 50) , radius: 10, startAngle: radS, endAngle: radE, clockwise: true)


        path.move(to: CGPoint(x:centerP.x - 10, y:centerP.y + 50))
        path.addLine(to: CGPoint(x:centerP.x - 10, y:centerP.y - 30))
        path.addLine(to: CGPoint(x:centerP.x - 20, y:centerP.y - 30))
        path.addLine(to: CGPoint(x:centerP.x, y:centerP.y - 60)) //頂点


        path.stroke()
        UIColor(red: 1, green: 0, blue: 0, alpha: 0.4).setFill()
        path.fill()

        path.removeAllPoints()
        path.move(to: CGPoint(x:centerP.x, y:centerP.y - 60)) //頂点
        path.addLine(to: CGPoint(x:centerP.x, y:0))
        path.stroke()



        
        

    }
}
