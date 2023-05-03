//
//  Floor.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/18.
//

import Foundation

class Floor {
    var iniFile = ""
    var rfdFile = ""
    var imgFile = ""
    var folder = ""
    func setFilder(folder: String) {
        self.folder = folder
    }
    func setIniFile(iniFile: String, folder: String) {
        self.iniFile = iniFile
        self.folder = folder
        let pf = Profile(file: iniFile, folder: folder)
        self.imgFile = pf.getString(section: "File", key: "Background")

        
    }
    func setRfdFile(rfdFile: String, folder: String, iniFile: String, isMakeIni: Bool=true) {
        self.rfdFile = rfdFile
        self.folder = folder
        self.iniFile = iniFile
        let pf = Profile(file: rfdFile, folder: folder)
        self.imgFile = pf.getString(section: "ImageFile", key: "FILE")
        if isMakeIni {
            let makeIniFile = MakeIniFile(folder: self.folder, rfdFile: self.rfdFile, iniFile: self.iniFile)
            makeIniFile.setImageFile(imageFile: imgFile)
            makeIniFile.makeFile()
        }
    }
    func getImageFile() -> String {
        return self.imgFile
    }
    
    
}
