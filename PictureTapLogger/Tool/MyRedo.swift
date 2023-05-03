//
//  MyRedo.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/05.
//
import Foundation

import Foundation
import UIKit

class MyRedo: MyTool {

    override func draw(_ rect: CGRect) {
        
        UIImage(named: "Redo64.png")?.draw(at: CGPoint(x: 8, y: 8))
        
    }
}
