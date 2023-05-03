//
//  MyScale.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/02.
//

import Foundation
import UIKit
class MyArrow: MyTool {

    var magneticHeading:CGFloat = 9999
    var pixel:Double = 9999
    var meter:Double = 9999

    func setAngle(angle:CGFloat) {
        magneticHeading = angle
        self.setNeedsDisplay()
    }
    override func draw(_ rect: CGRect) {
        if self.magneticHeading != 9999 {
            //北向きの矢印
            let arrow:[CGPoint] = [CGPoint(x:40,y:20),CGPoint(x:30,y:30),CGPoint(x:40,y:5), CGPoint(x:40,y:55)]
     
            for i in 0..<arrow.count-1 {
                
                let path = UIBezierPath()
                path.move(to: arrow[i])
                path.addLine(to: arrow[i+1])
                path.lineWidth = 2.0 // 線の太さ
                UIColor.red.setStroke() // 色をセット
                path.stroke()
            }
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(self.magneticHeading) * CGFloat.pi / 180)

        }


        if !(self.meter == 9999 || self.pixel == 9999) {
            let measure:[CGPoint] = [CGPoint(x:10,y:50),CGPoint(x:10,y:60),CGPoint(x:70,y:60), CGPoint(x:70,y:50)]
     
            for i in 0..<measure.count-1 {
                
                let path = UIBezierPath()
                path.move(to: measure[i])
                path.addLine(to: measure[i+1])
                path.lineWidth = 2.0 // 線の太さ
                UIColor.red.setStroke() // 色をセット
                path.stroke()
            }

            var pixel_meter:Double = self.meter / self.pixel * 60 //スケール図の幅が60
            pixel_meter = pixel_meter.rounded(.toNearestOrAwayFromZero)
            
            let font = UIFont.boldSystemFont(ofSize: 9)
            
            String(pixel_meter).draw(at: CGPoint(x: 50,y:60), withAttributes: [
                NSAttributedString.Key.foregroundColor : UIColor.black,
                NSAttributedString.Key.font : font,
            ])
        }
        
        
    }



}
