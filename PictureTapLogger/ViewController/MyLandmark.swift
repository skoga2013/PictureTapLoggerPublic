//
//  MyLandmark.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/08.
//

import Foundation
import UIKit

class MyLandmark: MyPoint {
    
    
    //描画する
    override func draw(_ rect: CGRect) {

        //目印を描画する
        if myPoint.count > 0 {
            for i in 0...myPoint.count - 1 {
                
                
                let circle1 = UIBezierPath(arcCenter:  myPoint[i].point, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                // 大きい円の内側の色
                UIColor(red: 0, green: 0, blue: 1, alpha: 1).setFill()
                // 内側を塗りつぶす
                circle1.fill()
                // 線の色
                UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).setStroke()
                // 線の太さ
                circle1.lineWidth = 1.0
                // 線を描画
                circle1.stroke()
                
 /*               let circle2 = UIBezierPath(arcCenter:  myPoint[i].point, radius: 5, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                // 小さい内側の色
                UIColor(red: 1, green: 1, blue: 1, alpha: 1).setFill()
                // 内側を塗りつぶす
                circle2.fill()
                
                // 線の色
                UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).setStroke()
                // 線の太さ
                circle1.lineWidth = 1.0
                // 線を描画
                circle1.stroke()
*/
                
                let font = UIFont.boldSystemFont(ofSize: 12)
                
                let num = String(myPoint[i].number)
                let numSize = num.size(with: font)
                var textPoint = myPoint[i].point!
                
                textPoint.x = textPoint.x - numSize.width/2
                textPoint.y = textPoint.y - numSize.height/2

                num.draw(at: textPoint, withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.white,
                    NSAttributedString.Key.font : font,
                    ])
                
            }
        }
    }
}


