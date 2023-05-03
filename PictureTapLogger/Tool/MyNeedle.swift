//
//  MyNeedle.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/01.
//

import Foundation
import UIKit
class MyNeedle: MyTool {

    override func draw(_ rect: CGRect) {
        
        UIImage(named: "Overhead2.png")?.draw(at: CGPoint(x: 8, y: 5))
        
    }



}
