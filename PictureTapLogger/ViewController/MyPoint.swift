//
//  MyPoint.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/08.
//

import Foundation
import UIKit

class MyPoint: UIView {
    var myPoint:[RoutePoint] = []
    var myPointHistory:[[RoutePoint]] = []
    var indexHistory = 0
    

    var indexPoint = -1 //カレントなルートポイントのインデックス,
    var indexLine = -1 //searchNearLineで見つかったルートラインのインデックス
    var isStep:Bool = true //10ピクセル刻み
    var stepPixcel = 5.0
    let maxDistance = 10.0 //検索時の最大距離
    
    func setStep(step: Bool) {
        isStep = step
    }
    func delPont(){
        myPoint.removeAll()
        addHistory()
        self.setNeedsDisplay()
    }
    func initPoint() {
        addHistory()
        self.setNeedsDisplay()
    }
    func initPoint(pointArray:[CGPoint]) {
        for i in 0..<pointArray.count {
            addPoint(point: pointArray[i],history: false)
        }
        addHistory()
        self.setNeedsDisplay()
    }
    
    // isStepがtrueならstepPixcelで丸める
    func roundPoint(point:CGPoint) -> CGPoint {
        var inPoint = point
        if isStep {
            let x = inPoint.x
            let y = inPoint.y
            let intx = Int(x/stepPixcel)
            let inty = Int(y/stepPixcel)
            inPoint.x = CGFloat(intx)*stepPixcel
            inPoint.y = CGFloat(inty)*stepPixcel
        }
        return inPoint
    }
    
    func addPoint(point:CGPoint, history: Bool = true, number: Int = -1, mode: Int = -1) {
        let inPoint = roundPoint(point: point)
        let rp = RoutePoint()
        rp.point = inPoint
        if myPoint.count == 0 {
            rp.mode = 1 //先頭
        } else {
            rp.mode = 0
        }
        if mode != -1 {
            rp.mode = mode
        }
        rp.time = Date()
        rp.number = number
        myPoint.append(rp)
        indexPoint = myPoint.count - 1
        if history {
            addHistory()
        }
        self.setNeedsDisplay()
    }
    
    func searchNearPoint(point: CGPoint) -> Int {
        var minIndex = -1
        var minDistance = maxDistance
        if myPoint.count == 0 {
            return -1
        }
        for i in 0...myPoint.count - 1 {
            let dx = Double(point.x - myPoint[i].point.x)
            let dy = Double(point.y - myPoint[i].point.y)
            let distance = sqrt(dx*dx + dy*dy)
            if distance < minDistance {
                minIndex = i
                minDistance = distance
            }
        }
        indexPoint = minIndex
        return minIndex
    }
    func searchNearLine(point: CGPoint) -> Int {
        var minIndex = -1
        var minDistance = maxDistance
        if myPoint.count < 2 {
            return -1
        }
        for i in 0...myPoint.count - 2 {
            let A = myPoint[i].point!
            let B = myPoint[i+1].point!
            let clossLine = ClossCheck()
            let distance = clossLine.NearPosOnLine(P: point, A: A, B: B)
            if distance.ret == 0 {
                if distance.dist < minDistance {
                    minIndex = i
                    minDistance = distance.dist
                }
            }
        }
        indexLine = minIndex
        return minIndex
    }

    func getPoint(index: Int) -> CGPoint {
        return myPoint[index].point
    }
    func getPointMode(index: Int) -> Int {
        return myPoint[index].mode
    }
    func getRPointTime(index: Int) -> Date {
        return myPoint[index].time
    }
    func getPointNote(index: Int) -> String {
        return myPoint[index].note
    }
    func getPointNumber(index: Int) -> Int {
        return myPoint[index].number
    }
    func getPointNear(index: Int) -> Int {
        return myPoint[index].near
    }
    func getPointLast() -> CGPoint {
        return myPoint[myPoint.count-1].point
    }
    //indexの位置にpointの座標を追加する　mode=0 time=現時刻
    func insertPoint(index: Int, point: CGPoint, history: Bool = true) {
        let inPoint = roundPoint(point: point)
        let rp = RoutePoint()
        rp.point = inPoint
        rp.mode = 4
        rp.time = Date()
        myPoint.insert(rp, at: index)
        indexPoint = index
        if history {
            addHistory()
        }
        self.setNeedsDisplay()
    }
    //indexの位置にpointの座標を変更する　mode=変更なし time=変更なし
    func setPoint(point: CGPoint, histroy: Bool = true) {
        if indexPoint == -1 {
            return
        }
        if indexPoint < myPoint.count {
            myPoint[indexPoint].point = point
            if histroy {
                addHistory()
            }
            self.setNeedsDisplay()
        }
    }
    //カレントな位置のpointの座標を変更する　mode=変更する time=変更なし
    func setPoint(point: CGPoint, mode: Int, histroy: Bool = true) {
        if indexPoint == -1 {
            return
        }
        if indexPoint < myPoint.count {
            myPoint[indexPoint].point = point
            myPoint[indexPoint].mode = mode
            if histroy {
                addHistory()
            }
            self.setNeedsDisplay()
        }
    }
    //indexの位置のpointの座標を変更する　mode=変更なし time=変更なし
    func setPoint(point: CGPoint, index: Int, histroy: Bool = true) {
        if index < myPoint.count {
            myPoint[index].point = point
            if histroy {
                addHistory()
            }
            self.setNeedsDisplay()
        }
    }
    //indexの位置のpointの座標を変更する　mode=変更する time=変更なし
    func setPoint(point: CGPoint, index: Int, mode: Int, histroy: Bool = true) {
        if index < myPoint.count {
            myPoint[index].point = point
            myPoint[index].mode = mode
            if histroy {
                addHistory()
            }
            self.setNeedsDisplay()
        }
    }
    func setPointNear(index: Int, near: Int) {
        myPoint[index].near = near
        self.setNeedsDisplay()
    }
    //最後のポイントを削除する
    func delPointLast(history: Bool = true) {
        let last = myPoint.count - 1
        myPoint.remove(at: last)
        if history {
            addHistory()
        }
        self.setNeedsDisplay()
        
    }
    //indexで指定されたポイントを削除する
    func delPoint(index: Int,history: Bool = true) {
        myPoint.remove(at: index)
        if history {
            addHistory()
        }
        self.setNeedsDisplay()
        
    }
    //ポイントの数を返す
    func getPointCount() -> Int {
        return myPoint.count
    }
    func addHistory() {
        if indexHistory < myPointHistory.count - 1 {
            for _ in indexHistory+1..<myPointHistory.count {
                myPointHistory.remove(at: indexHistory+1)
            }
        }
        var tmpPoint:[RoutePoint] = []
        for i in 0..<myPoint.count {
            let rp = RoutePoint()
            rp.point = myPoint[i].point
            rp.mode = myPoint[i].mode
            tmpPoint.append(rp)
        }
        myPointHistory.append(tmpPoint)
        indexHistory = myPointHistory.count - 1
    }
    func undoHistory() {
        if indexHistory != 0 {
            indexHistory -= 1
            myPoint = myPointHistory[indexHistory]
            myPoint.removeAll()
            for i in 0..<myPointHistory[indexHistory].count {
                let rp = RoutePoint()
                rp.point = myPointHistory[indexHistory][i].point
                rp.mode = myPointHistory[indexHistory][i].mode
                myPoint.append(rp)
            }

            self.setNeedsDisplay()
       }
    }
    
    func redoHistory() {
        if indexHistory < myPointHistory.count - 1 {
            indexHistory += 1
            myPoint.removeAll()
            for i in 0..<myPointHistory[indexHistory].count {
                let rp = RoutePoint()
                rp.point = myPointHistory[indexHistory][i].point
                rp.mode = myPointHistory[indexHistory][i].mode
                myPoint.append(rp)
            }
            self.setNeedsDisplay()
        }
    }
    func isUndo() -> Bool {
        if indexHistory > 0 {
            return true
        } else {
            return false
        }
    }
    func isRedo() -> Bool {
        if indexHistory <= myPointHistory.count-2 {
            return true
        } else {
            return false
        }
    }
    func getLog() -> String {
        var sb:[String] = []
        let f = DateFormatter()
        
        f.timeStyle = .medium
        f.dateStyle = .short
        f.locale = Locale(identifier: "ja_JP")
        sb.append("[Route]")
        for i in 0..<myPoint.count {
            let now = myPoint[i].time ?? Date()
            let time:[String] = f.string(from: now).components(separatedBy: " ")
            let x = String(format: "%.0f",myPoint[i].point.x)
            let y = String(format: "%.0f",myPoint[i].point.y)
            let mode = String(format: "%d",myPoint[i].mode)
            sb.append(String(i) + "=" + x + "," + y + "," + time[0] + "," + time[1] + "," + mode)
        }
        return sb.joined(separator: "\r\n")
    }

    func SaveLog()  {
        let log = getLog()
        let userDefault = UserDefaults.standard
        userDefault.set(log, forKey: "log")

        let ud = UserDefaults.standard
        let folder = ud.string(forKey: "folder") ?? ""
        if folder == "" {
            return
        }
        let inifile = ud.string(forKey: "inifile") ?? ""
        let routeFile = inifile.replacingOccurrences(of: "ini", with: "txt")
        
        let fileManager = FileManager.default
        var documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
        let subFolder = folder.split(separator: "/")
        for sub in subFolder {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(String(sub), isDirectory: true) //圧縮ファイル名のサブフォルダ
        }
        documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(routeFile, isDirectory: false) //画像ファイル

        do {
            try log.write(to: documentDirectoryFileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
        

    }

}
extension String {
    func size(with font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font : font]
        return (self as NSString).size(withAttributes: attributes)
    }
}
