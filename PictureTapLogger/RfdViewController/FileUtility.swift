//
//  FileUtility.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/30.
//

import Foundation

class FileUtility {
 
    static func getImageFileList(folder: String) -> [String] {
        let fileManager = FileManager.default
        var filelist:[String] = []
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: self.getURL(folder: folder, file: "").path)
        } catch {
            return filelist
        }

        //rfdxが含まれた場合　rfdファイルまたはiniファイルが含まれる。rfdファイルの場合はrfdファイルからiniファイルを生成する
        var matchRfd = false
        for file in files {
            let sep = file.split(separator: ".")
            let ext = sep[sep.count-1]
            if ext == "rfdx" {
                let pf = Profile(file: file, folder: folder)
                let sections = pf.getSections()
                for section in sections {
                    let ini = pf.getString(section: section, key: "FILE")
                    if ini.contains(".rfd") {
                        let rfdFile = ini
                        let iniFile = ini.replacingOccurrences(of: "rfd", with: "ini")
                        let floor = Floor()
                        floor.setRfdFile(rfdFile: rfdFile,folder: folder, iniFile: iniFile, isMakeIni: false)
                        let filename = floor.getImageFile()
                        if filename != "" {
                            filelist.append(filename)
                            matchRfd = true
                        }
                    } else if ini.contains(".ini") {
                        let floor = Floor()
                        floor.setIniFile(iniFile: ini,folder: folder)
                        let filename = floor.getImageFile()
                        if filename != "" {
                            filelist.append(filename)
                            matchRfd = true
                        }
                    }
                    
                }
            }
        }
        if matchRfd == false {
            //rfdxファイルを含まない
            for file in files {
                let sep = file.split(separator: ".")
                let ext = sep[sep.count-1]
                if ext == "bmp" || ext == "png" {
                    filelist.append(file)
                }
            }
        } else {
            
        }
         return filelist
    }
    static func getURL(folder: String, file: String) -> URL {
        //DocumentsフォルダのサブディレクトリfolderのfilrのURLを返す
        let fileManager = FileManager.default
        var documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
        let subFolder = folder.split(separator: "/")
        for sub in subFolder {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(String(sub), isDirectory: true) //圧縮ファイル名のサブフォルダ
        }
        if file != "" {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(file, isDirectory: false) //画像ファイル
        }
        return documentDirectoryFileURL
    }
    static func getImageFile(folder: String) -> [String] {
        //Documentsフォルダのサブディレクトリ画像ファイルを[String]で返す
        let fileManager = FileManager.default
        var filelist:[String] = []
        var files: [String] = []
        do {
            files = try fileManager.contentsOfDirectory(atPath: self.getURL(folder: folder, file: "").path)
        } catch {
            return filelist
        }
        for file in files {
            let sep = file.split(separator: ".")
            let ext = sep[sep.count-1]
            if ext == "bmp" || ext == "png" {
                filelist.append(file)
            }
        }
        return filelist
    }
    static func getDir(folder: String) -> [String] {
        //Documentsフォルダのサブディレクトリ配下のディレクトリを[String]で返す
        let fileManager = FileManager.default
        var filelist:[String] = []
        var files: [String] = []
        if folder != "" {
            filelist.append("..")
        }
        do {
            files = try fileManager.contentsOfDirectory(atPath: self.getURL(folder: folder, file: "").path) //, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        } catch {
            return filelist
        }
        
        for file in files {
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: self.getURL(folder: folder, file: file).path, isDirectory: &isDir) {
                if isDir.boolValue {
                    filelist.append(file)
                }
            }
        }
        return filelist
 
    }
}
