//
//  MyMarker.swift
//  RouteMaker
//
//  Created by 古賀真一郎 on 2023/02/21.
//

import Foundation
import UIKit

class MyMarker: UIView {
    override func draw(_ rect: CGRect) {
        
        // 三角形 -------------------------------------
        // UIBezierPath のインスタンス生成
        let line = UIBezierPath();
        // 起点
        line.move(to: CGPoint(x: 0, y: 40));
        // 帰着点
        line.addLine(to: CGPoint(x: 80, y: 40));
        line.addLine(to: CGPoint(x: 80, y: 0));
        line.addLine(to: CGPoint(x: 40, y: 0));
        line.addLine(to: CGPoint(x: 40, y: 80));

        // ラインを結ぶ
        //line.close()
        // 色の設定
        UIColor.black
            .setStroke()
        // ライン幅
        line.lineWidth = 4
        // 描画
        line.stroke()
        
        
        
        
        
    }
}
