//
//  myUndo.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/04.
//



import Foundation
import UIKit

class MyUndo: MyTool {

    override func draw(_ rect: CGRect) {
        
        UIImage(named: "Undo64.png")?.draw(at: CGPoint(x: 8, y: 8))
        
    }
}
