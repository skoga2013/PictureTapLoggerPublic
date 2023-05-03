//
//  MyView.swift
//  RouteMaker
//
//  Created by 古賀真一郎 on 2023/02/22.
//

import Foundation
import UIKit

class MyView: MyPoint {
    
    
    //描画する
    override func draw(_ rect: CGRect) {

        if myPoint.count > 0 {
            //線を描く
            myPoint[0].mode |= 1
            for i in 0..<myPoint.count {
                
                if (myPoint[i].mode & 1) == 0 {
                    let path = UIBezierPath()
                    path.move(to: myPoint[i-1].point)
                    path.addLine(to: myPoint[i].point)
                    path.lineWidth = 4.0 // 線の太さ
                    UIColor.red.setStroke() // 色をセット
                    path.stroke()
                }
            }
            for i in 0..<myPoint.count {
                if (myPoint[i].mode & 4) != 0 {
                    //このポイントは後でインサートされたポイントなので時刻は前後のポイントの時刻を距離で補間する
                    let p1 = i
                    let cc = ClossCheck()
                    var len1:Double = 0
                    var len2:Double = 0
                    var time1:Date!
                    var time2:Date!
                    
                    //ポイントの前から時刻をもつポイントを探す
                    for j in (0...p1-1).reversed() {
                        len1 += cc.distance_vertex(p1: myPoint[j+1].point, p2:myPoint[j].point)
                        if (myPoint[j].mode & 4) == 0 {
                            time1 = myPoint[j].time
                            break
                        }
                    }
                    for j in (p1+1..<myPoint.count) {
                        len2 += cc.distance_vertex(p1: myPoint[j].point, p2:myPoint[j-1].point)
                        if (myPoint[j].mode & 4) == 0 {
                            time2 = myPoint[j].time
                            break
                        }
                    }
                    if time1 != nil && time2 != nil {
                        var span = time2.timeIntervalSince(time1) //time1とtime2の時間差（秒）
                        //span をlen1:len2の比で分割する
                        span = (len1 / (len1 + len2)) * span
                        myPoint[i].time = Date(timeInterval: span, since: time1)
                    }
                }
            }
            //ポイントを描く
            for i in 0..<myPoint.count {
                let font = UIFont.boldSystemFont(ofSize: 12)

                if (myPoint[i].mode & 2) != 0 {
                    let cPoint = myPoint[i].point!
                    let circle1 = UIBezierPath(arcCenter:  CGPoint(x:cPoint.x,y:cPoint.y-40.0), radius: 20, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                    UIColor.red.setFill()
                    circle1.fill()
                    
                    let path = UIBezierPath()
                    path.move(to: cPoint)
                    path.addLine(to: CGPoint(x:cPoint.x - 20.0,y:cPoint.y-35.0))
                    path.addLine(to: CGPoint(x:cPoint.x + 20.0 ,y:cPoint.y-35.0))
                    path.addLine(to: cPoint)
                    path.lineWidth = 1.0 // 線の太さ
                    
                    //path.stroke()
                    path.fill()
                    
                    let circle2 = UIBezierPath(arcCenter:  CGPoint(x:cPoint.x,y:cPoint.y-40.0), radius: 13, startAngle: 0.0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                    UIColor.white.setFill()
                    circle2.fill()
                    
                    let circle3 = UIBezierPath(arcCenter:  CGPoint(x:cPoint.x,y:cPoint.y-40.0), radius: 7, startAngle: 0.0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                    UIColor.red.setFill()
                    circle3.fill()
                    
                    String(myPoint[i].near).draw(at: CGPoint(x:cPoint.x,y:cPoint.y-40.0), withAttributes: [
                        NSAttributedString.Key.foregroundColor : UIColor.black,
                        NSAttributedString.Key.font : font,
                    ])
                }
                let circle1 = UIBezierPath(arcCenter:  myPoint[i].point, radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                // 大きい円の内側の色
                UIColor(red: 1, green: 0, blue: 0, alpha: 1).setFill()
                // 内側を塗りつぶす
                circle1.fill()
                // 線の色
                UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).setStroke()
                // 線の太さ
                circle1.lineWidth = 1.0
                // 線を描画
                circle1.stroke()
                
/*                let circle2 = UIBezierPath(arcCenter:  myPoint[i].point, radius: 5, startAngle: 0, endAngle: CGFloat(Double.pi)*2, clockwise: true)
                // 小さい内側の色
                UIColor(red: 1, green: 1, blue: 1, alpha: 1).setFill()
                // 内側を塗りつぶす
                circle2.fill()
                
                // 線の色
                UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).setStroke()
                // 線の太さ
                circle1.lineWidth = 1.0
                // 線を描画
                circle1.stroke()
  */
                
                
                let num = String(i+1)
                let numSize = num.size(with: font)
                var textPoint = myPoint[i].point!
                
                textPoint.x = textPoint.x - numSize.width/2
                textPoint.y = textPoint.y - numSize.height/2
                
                num.draw(at: textPoint, withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.white,
                    NSAttributedString.Key.font : font,
                ])
                
                let f = DateFormatter()
                f.timeStyle = .medium
                f.dateStyle = .short
                f.locale = Locale(identifier: "ja_JP")
                if myPoint[i].time != nil {
                    let time:[String] = f.string(from: myPoint[i].time).components(separatedBy: " ")
                    
                    let timeSize = time[1].size(with: font)
                    var timePoint = myPoint[i].point!
                    
                    timePoint.x = timePoint.x - timeSize.width/2
                    timePoint.y = textPoint.y + 20
                    
                    time[1].draw(at: timePoint, withAttributes: [
                        NSAttributedString.Key.foregroundColor : UIColor.black,
                        NSAttributedString.Key.font : font,
                    ])
                }
            }
        }

    }


}


