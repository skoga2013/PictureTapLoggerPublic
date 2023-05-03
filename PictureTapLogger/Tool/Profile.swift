//
//  Profile.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/16.
//

import Foundation
import UniformTypeIdentifiers

class Profile {
    var profile = ""
    var profiles:[String]!
    var section = ""
    var key = ""
    var folder = ""
    
    init(file:String, folder:String) {
        self.folder = folder
        let fileManager = FileManager.default
        var documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
        let files = self.folder.split(separator: "/")
        for file in files {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(String(file), isDirectory: true) //サブフォルダ
        }
        let fileURL = documentDirectoryFileURL.appendingPathComponent(file) //rfdxファイル
        var encode = String.Encoding.utf8
        var readDone = true
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: encode)
            self.profile = fileContents
            self.profiles = self.profile.components(separatedBy: "\r\n")
        } catch {
            print("ファイル読み込みエラー UTF-8")
            readDone = false
        }
        if readDone == false {
            encode = .shiftJIS
            do {
                let fileContents = try String(contentsOf: fileURL, encoding: encode)
                self.profile = fileContents
                self.profiles = self.profile.components(separatedBy: "\r\n")
            } catch {
                print("ファイル読み込みエラー shiftJIS")
                self.profile = ""
                self.profiles = self.profile.components(separatedBy: "\r\n")
            }
            
        }

    }
    func setSection(section: String = "") {
        self.section = section
    }
    func getSectionNum(section: String = "") -> Int{
        if section != "" {
            self.section = section
        }
        var num = 0
        var matchF = false
        for str in self.profiles {
            
            if str == "[" + self.section + "]" {
                matchF = true
                continue
            }
            if matchF == true && str.first == "[" {
                matchF = false
                continue
            }
            if matchF && str != "" {
                num += 1
            }
        }
        return num

    }
    func setKey(key: String = "") {
        self.key = key
    }
    func getString() -> String {
        return getString(section: self.section, key: self.key)
    }
    func getString(key: String) -> String {
        return getString(section: self.section, key: key)
    }
    func getString(section:String="", key:String="") -> String {
        if section != "" {
            self.section = section
        }
        if key != "" {
            self.key = key
        }
        var matchF = false
        for str in self.profiles {
            
            if str == "[" + self.section + "]" {
                matchF = true
                continue
            }
            if matchF == true && str.first == "[" {
                matchF = false
                continue
            }
            let strs = str.components(separatedBy: "=")
            if matchF == true && strs.first == self.key {
                return strs[1]
            }
        }
        return ""
    }
    func getSections() -> [String] {
        var sections:[String] = []
        for str in self.profiles {
            
            if str.first == "[" && str.last == "]"{
                var section = str.replacingOccurrences(of:"[", with: "")
                section = section.replacingOccurrences(of:"]", with: "")
                sections.append(section)
            }
         }
        return sections

    }
}
