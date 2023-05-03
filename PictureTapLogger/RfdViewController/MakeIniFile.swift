//
//  MakeIniFile.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/18.
//
// rfdファイルからiniファイルを生成する

import Foundation

class MakeIniFile {
    
    var rfdFile = ""
    var iniFile = ""
    var folder = ""
    var imgFile = ""
    var ant:[String] = []
    var area:[String] = []
    var pixel = ""
    var meter = ""
    var antIndex = 0
    var areaIndex = 0
    var angle:Double = 0
    
    init(folder: String, rfdFile: String, iniFile: String) {
        self.folder = folder
        self.rfdFile = rfdFile
        self.iniFile = iniFile
    }
    func setFolder(folder:String) {
        self.folder = folder
    }
    func setImageFile(imageFile: String) {
        self.imgFile = imageFile
    }
    func setFile(file:String, folder:String, encording:String.Encoding = .utf8) {
        self.folder = folder
        self.rfdFile = file

    }
    func makeFile() {
        makeList()
        var str:[String] = []
        str.append("[File]")
        str.append("Background="+imgFile)
        str.append("[FileEnd]")
        str.append("[Ant]")
        str.append(self.ant.joined(separator: "\r\n"))
        str.append("[AntEnd]")
        str.append("[Wall]")
        str.append("[WallEnd]")
        str.append("[Area]")
        str.append(self.area.joined(separator: "\r\n"))
        str.append("[AreaEnd]")
        str.append("[Info]")
        str.append("Angle=" + self.angle.description)
        str.append("Pixel="+self.pixel)
        str.append("Meter="+self.meter)
        str.append("[InfoEnd]")

        let path = NSHomeDirectory() + "/Documents/" + self.folder + "/" + self.iniFile

        do {
            // テキストの書き込みを実行
            try str.joined(separator: "\r\n").write(toFile: path, atomically: true, encoding: .utf8)
            print("成功\nopen", path)

        } catch {
            //　テストの書き込みに失敗
            print("失敗:", error )
        }
                   
        
    }
    func makeList() {
        let pf = Profile(file: self.rfdFile, folder: self.folder)
        let sections = pf.getSections()
        for section in sections {
            if section.contains("ANT") {
                pf.setSection(section: section)
                let x = pf.getString(key: "X")
                let y = pf.getString(key: "Y")
                let antNo = pf.getString(key: "AntNo")
                let powerFix = pf.getString(key: "POWERFIX")
                var inShop = pf.getString(key: "InShop")
                if inShop == "true" {
                    inShop = "1"
                } else {
                    inShop = "0"
                }
                let sc = "0"
                let otherLoss = "26.5"
                let freq = "2170"
                let q = "2"
                var str = String(self.antIndex)
                str += "="
                str += x + "," + y + ","
                str += powerFix + ","
                str += sc + ","
                str += inShop + ","
                str += otherLoss + ","
                str += freq + ","
                str += q + "," + antNo
                print(str)
                self.ant.append(str)
                self.antIndex += 1
            } else if section.contains("AREA") {
                pf.setSection(section: section)
                let xArray = pf.getString(key: "X").split(separator: ",")
                let yArray = pf.getString(key: "Y").split(separator: ",")
                let fill = pf.getString(key: "FILL")
                let fillcolor = pf.getString(key: "FILLCOLOR")
                let linecolor = pf.getString(key: "LINECOLOR")
                var str = String(areaIndex)
                str += "="
                for i in 0 ..< xArray.count {
                    let x = xArray[i]
                    let y = yArray[i]
                    if i == 0 {
                        str += fill + ","
                        str += linecolor + ","
                        str += fillcolor + ","
                        str += x + "," + y
                    } else {
                        str += "," + x + "," + y
                    }
                }
                print(str)
                self.area.append(str)
                
            } else if section.contains("SCALE") {
                pf.setSection(section: section)
                let x1 = pf.getString(key: "X1")
                let x2 = pf.getString(key: "X2")
                let y1 = pf.getString(key: "Y1")
                let y2 = pf.getString(key: "Y2")
                let x1d:Double = Double(x1)!
                let x2d:Double = Double(x2)!
                let y1d:Double = Double(y1)!
                let y2d:Double = Double(y2)!
                self.pixel = String(sqrt(pow((x1d - x2d), 2) + pow((y1d - y2d), 2)))
                self.meter = pf.getString(key: "DIST")
            } else if section.contains("ARROW") {
                pf.setSection(section: section)
                let x1 = pf.getString(key: "X1")
                let x2 = pf.getString(key: "X2")
                let y1 = pf.getString(key: "Y1")
                let y2 = pf.getString(key: "Y2")
                let x1d:Double = Double(x1)!
                let x2d:Double = Double(x2)!
                let y1d:Double = Double(y1)!
                let y2d:Double = Double(y2)!
                var angleSin:Double = 0
                var angleCos:Double = 0
                var angle:Double = 0
                
                //x1d = 150
                //y1d = 200
                //x2d = 200
                //y2d = 100
                
                let hypo:Double = sqrt(pow(x1d-x2d,2)+pow(y1d-y2d,2))

                angleCos = acos((x1d-x2d)/hypo) * 180 / Double.pi
                angleSin = asin((y2d-y1d)/hypo)  * 180 / Double.pi
                
                if angleCos <= 90 {
                    if angleSin >= 0 {
                        //右上
                        angle = 90 - angleCos
                    } else {
                        //右下
                        angle = 90 + angleCos
                    }
                } else {
                    if angleSin >= 0 {
                        //左上
                        angle = 90 - angleCos
                    } else {
                        //左下
                        angle = -90 + angleCos
                    }
                }
                self.angle = angle
                print(angle)
            }
            
        }
    }
}
