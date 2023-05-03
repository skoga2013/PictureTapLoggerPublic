//
//  MyArea.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/08.
//

import Foundation
import UIKit

class MyArea: UIView {
 
    var areas:[String] = []
    
    func addArea(area: String) {
        areas.append(area)
    }
    func initArea() {
        //addHistory()
        self.setNeedsDisplay()
    }

    func delArea(){
        areas.removeAll()
    }
    //描画する
    override func draw(_ rect: CGRect) {
        
        for area in areas {
            let sep = area.components(separatedBy: ",")
            if sep.count > 7 {
                let fill = Int(sep[0]) ?? 0
                let lineColor  = Int(sep[1]) ?? 0
                let fillColor  = Int(sep[2]) ?? 0

                let path = UIBezierPath()
                var x = CGFloat(Int(sep[3]) ?? 0)
                var y = CGFloat(Int(sep[4]) ?? 0)
                path.move(to: CGPoint(x:x, y:y))

                for i in 2...(sep.count-3)/2 {
                    x = CGFloat(Int(sep[i*2+1]) ?? 0)
                    y = CGFloat(Int(sep[i*2+2]) ?? 0)

                    path.addLine(to: CGPoint(x:x, y:y))

                }
                path.lineWidth = 4.0 // 線の太さ
                switch lineColor {
                case 0:
                    UIColor.black.setStroke() // 色をセット
                    break
                case 1:
                    UIColor.red.setStroke() // 色をセット
                    break

                default:
                    UIColor.red.setStroke() // 色をセット
                    break

                }
                switch fillColor {
                case 0:
                    UIColor.black.setFill() // 色をセット
                    break
                case 1:
                    UIColor.red.setFill() // 色をセット
                    break

                default:
                    UIColor.red.setFill() // 色をセット
                    break

                }
                if fill == 0 {
                    path.stroke()
                } else {
                    self.alpha = 0.3
                    path.fill()
                }
            }
        }
        
        
        
    }
    
}
