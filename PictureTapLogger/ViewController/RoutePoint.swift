//
//  RoutePoint.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/05.
//

import Foundation

class RoutePoint {
    var point:CGPoint!
    var mode:Int = 0 //0:通常のポイント　1:先頭のポイント　2:シンボル　3:シンボルでかつ先頭 4:時刻のない通常のポイント　5...
    var number:Int = -1
    var time:Date!
    var note:String = ""
    var near:Int = -1    //
    
}
