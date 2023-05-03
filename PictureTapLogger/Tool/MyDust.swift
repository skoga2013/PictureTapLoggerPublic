//
//  MyDust.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/03.
//

import Foundation
import UIKit

class MyDust: MyTool {

    override func draw(_ rect: CGRect) {
        
        UIImage(named: "ゴミ箱64.png")?.draw(at: CGPoint(x: 8, y: 8))
        
    }



}
