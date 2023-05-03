//
//  RfdViewController.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/14.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import ZIPFoundation
import MobileCoreServices

class RfdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnPhoto: UIBarButtonItem!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    
    var filelist:[String] = []
    var dirlist:[String] = []
    var folder:String = ""
    var backimage:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.setTitleView(withTitle: "画像ファイルリスト", subTitile: "背景画像を圧縮してまとめて取り込むことができます。")
        setupNavigationBarTitle()
        setupTableView()
    }
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(FileCellView.nib(), forCellReuseIdentifier: FileCellView.reuseIdentifier)

        tableView.rowHeight = 100
    }
    override func viewWillAppear(_ animated: Bool) {
        //画面遷移した時
        let ud = UserDefaults.standard
        self.folder = ud.string(forKey: "folder") ?? ""
        //self.folder = ""
        self.backimage = ud.string(forKey: "backimage") ?? ""
        
        self.filelist.removeAll()
        self.dirlist.removeAll()
        
        self.dirlist = FileUtility.getDir(folder: self.folder)
        self.filelist = FileUtility.getImageFileList(folder: self.folder)
        tableView.reloadData()

    }
    
    
    private func setupNavigationBarTitle() {
        title = "画像ファイルリスト"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        // LargeTitleのフォントを小さくする
        setAppearanceForLargeTitleText()
        
    }
    private func setAppearanceForLargeTitleText() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label,
                                               .font: UIFont.systemFont(ofSize: 14, weight: .bold)]
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //セルの数を返す
        return self.filelist.count+self.dirlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを返す
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileCellView.reuseIdentifier, for: indexPath) as? FileCellView else { return UITableViewCell() }
        // セルに表示する値を設定する
        
        if self.dirlist.count > indexPath.row {
            let file = dirlist[indexPath.row]
            cell.FileName.text = file
            cell.sampleImage.image = UIImage(named: "Folder.png")
            cell.DirSign.text = ""
            return cell
     
        } else {
            let file = filelist[indexPath.row-dirlist.count]
            cell.FileName.text = file
            cell.sampleImage.image = UIImage(named: FileUtility.getURL(folder: self.folder, file: file).path)
            cell.DirSign.text = ""
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルをタップした時の動作
        if self.dirlist.count > indexPath.row {
            //フォルダーを選択
            let dir = dirlist[indexPath.row]
            if dir == ".." {
                let folders = folder.split(separator: "/")
                folder = ""
                for i in 0..<folders.count-1 {
                    if i > 0 {
                        folder += "/"
                    }
                    folder += folders[i]
                }
                        
            } else {
                folder += "/" + dirlist[indexPath.row]
            }
            self.filelist.removeAll()
            self.dirlist.removeAll()
            
            self.dirlist = FileUtility.getDir(folder: self.folder)
            self.filelist = FileUtility.getImageFileList(folder: self.folder)
            tableView.reloadData()
        } else {
            //画像を選択
            let ud = UserDefaults.standard
            ud.setValue(self.folder, forKey: "folder")
            var filename = self.filelist[indexPath.row-dirlist.count]
            ud.setValue(filename, forKey: "backimage")
            self.backimage = filename

            filename = filename.split(separator: ".").first! + ".ini"
            ud.setValue(filename, forKey: "inifile")
            
            self.performSegue(withIdentifier: "goViewController", sender: nil)

        }


    }

    @IBAction func ActionRfdFileSelect(_ sender: UIBarButtonItem) {
        showFilePicker()
    }
    private func showFilePicker() {
        // 2. forOpeningContentTypesでUTTypeで選択して欲しいファイル形式を指定する

        let ud = UserDefaults.standard
        let rfdSwtch = ud.bool(forKey: "RfdSwitch")
        
        if rfdSwtch == false {
            var picker:UIDocumentPickerViewController
            /*
            if #available(iOS 15.0, *) {
                // 端末のOSがiOS15以上ならここに書いた処理を実行
                picker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
            }
            else {  */
                // それ以外ならここの処理を実行
                picker = UIDocumentPickerViewController(
                    
                    forOpeningContentTypes: [
                        UTType.item //すべてのファイルを表示
                        //UTType.directory
                    ],
                    asCopy: true)
          //  }
            picker.delegate = self
            self.navigationController?.present(picker, animated: true, completion: nil)
            
        } else {
            let picker = UIDocumentPickerViewController(
                
                forOpeningContentTypes: [
                    UTType.zip,
                    UTType.archive
                ],
                asCopy: true)
            
            picker.delegate = self
            self.navigationController?.present(picker, animated: true, completion: nil)

        }
    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // ファイル選択後に呼ばれる
        // urls.first?.pathExtensionで選択した拡張子が取得できる

        if let filePath = urls.first?.description {
            if FileManager.default.fileExists(atPath: filePath) {
                print("folder")
            } else {
                print("file")
            }
            print("ファイルパス:\(filePath)")
            let ext = urls.first?.pathExtension
            switch ext {
            case "zip","rfdz":
                //zipファイルは　(1) 画像ファイルを圧縮　(2) フォルダを圧縮　した場合がある。
                //いずれもDocumentフォルダに圧縮ファイル名と同じフォルダーを作りその中に解凍する。
                //フォルダが圧縮されていた場合は、その中にフォルダが作られその中に解凍する。
                
                let fileManager = FileManager.default
                let sourceURL = urls.first! //zipファイル
                var folder = sourceURL.deletingPathExtension().lastPathComponent //拡張子を除いたファイル名が解凍先のフォルダになる
                let documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
                var destinationURL = documentDirectoryFileURL.appendingPathComponent(folder, isDirectory: true) //圧縮ファイル名のサブフォルダ
                var destinationStr = String(destinationURL.path)
                let ud = UserDefaults.standard
                ud.setValue(folder, forKey: "folder")
                self.folder = folder

                do {
                    //destinationと同名のフォルダがあれば削除する
                    if fileManager.fileExists(atPath: destinationStr) {
                        try fileManager.removeItem(atPath: destinationStr)
                    }
                    //destinationフォルダを作成する
                    try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)//フォルダ作成
                    //destinationフォルダに解凍する
                    let ud = UserDefaults.standard
                    let zipcode:String.Encoding!
                    let udzipcode = ud.bool(forKey: "zipcode")
                    if udzipcode {
                        zipcode = .utf8
                    } else {
                        zipcode =  .shiftJIS
                    }
                    try fileManager.unzipItem(at: sourceURL, to: destinationURL, skipCRC32: true, preferredEncoding: zipcode) //解凍

                    //解凍先のフォルダにフォルダがあればその中に解凍されているのでそこをfolderとする
                    var files: [String] = []
                    //フィイル、ディレクトリ一覧を取得する
                    files = try fileManager.contentsOfDirectory(atPath: destinationStr)
                    for file in files {
                        let subDestinationURL = destinationURL.appendingPathComponent(file, isDirectory: true)
                        let subDestinationStr = String(subDestinationURL.path)
                        var isDir: ObjCBool = false
                        if fileManager.fileExists(atPath: subDestinationStr, isDirectory: &isDir) {
                            if isDir.boolValue {
                                //ディレクトリの場合
                                destinationURL = destinationURL.appendingPathComponent(file, isDirectory: true) //圧縮ファイル名のサブフォルダ
                                destinationStr = String(destinationURL.path)

                                folder += "/" + file //この場合fileはサブフォルダ
                                ud.setValue(folder, forKey: "folder")
                                self.folder = folder
                            }
                        }
                    }
 
                } catch {
                    print("Extraction of ZIP archive failed with error:\(error)")
                }

                var files: [String] = []
                do {
                    files = try fileManager.contentsOfDirectory(atPath: destinationStr)
                    self.filelist.removeAll()
                } catch {
   
                }
  
                //rfdxが含まれた場合　rfdファイルまたはiniファイルが含まれる。rfdファイルの場合はrfdファイルからiniファイルを生成する
                var matchRfd = false
                for file in files {
                    let sep = file.split(separator: ".")
                    let ext = sep[sep.count-1]
                    if ext == "rfdx" {
                        let pf = Profile(file: file, folder: self.folder)
                        let sections = pf.getSections()
                        for section in sections {
                            let ini = pf.getString(section: section, key: "FILE")
                            if ini.contains(".rfd") {
                                let rfdFile = ini
                                let iniFile = ini.replacingOccurrences(of: "rfd", with: "ini")
                                let floor = Floor()
                                floor.setRfdFile(rfdFile: rfdFile,folder: self.folder,iniFile: iniFile) //iniファイルを作成する
                                //floor.setRfdFile(rfdFile: rfdFile,folder: self.folder,iniFile: iniFile,isMakeIni: false) //iniファイルを作成しない
                                filelist.append(floor.getImageFile())
                                matchRfd = true
                            } else if ini.contains(".ini") {
                                let floor = Floor()
                                floor.setIniFile(iniFile: ini,folder: self.folder)
                                filelist.append(floor.getImageFile())
                                matchRfd = true
                            }
                        
                        }
                        
                        break

                    }
                }
                if matchRfd == false {
                    //rfdxファイルを含まない
                    for file in files {
                        let sep = file.split(separator: ".")
                        let ext = sep[sep.count-1]
                        if ext == "bmp" || ext == "png" {
                            self.filelist.append(file)
                        }
                    }
                } else {
                    
                }
                
                tableView.reloadData()
 
 
            case "png","bmp":
                let fileManager = FileManager.default
                let sourceURL = urls.first!
                let destinationStr = sourceURL.deletingLastPathComponent().path  //ファイル名を除いたフォルダになる
 
                var files: [String] = []
                do {
                    files = try fileManager.contentsOfDirectory(atPath: destinationStr)
                    self.filelist.removeAll()
                } catch {
   
                }
  
                //rfdxが含まれた場合　rfdファイルまたはiniファイルが含まれる。rfdファイルの場合はrfdファイルからiniファイルを生成する
                var matchRfd = false
                for file in files {
                    let sep = file.split(separator: ".")
                    let ext = sep[sep.count-1]
                    if ext == "rfdx" {
                        let pf = Profile(file: file, folder: self.folder)
                        let sections = pf.getSections()
                        for section in sections {
                            let ini = pf.getString(section: section, key: "FILE")
                            if ini.contains(".rfd") {
                                let rfdFile = ini
                                let iniFile = ini.replacingOccurrences(of: "rfd", with: "ini")
                                let floor = Floor()
                                floor.setRfdFile(rfdFile: rfdFile,folder: self.folder,iniFile: iniFile)
                                filelist.append(floor.getImageFile())
                                matchRfd = true
                            } else if ini.contains(".ini") {
                                let floor = Floor()
                                floor.setIniFile(iniFile: ini,folder: self.folder)
                                filelist.append(floor.getImageFile())
                                matchRfd = true
                            }
                        
                        }
                        
                        break

                    }
                }
                if matchRfd == false {
                    //rfdxファイルを含まない
                    for file in files {
                        let sep = file.split(separator: ".")
                        let ext = sep[sep.count-1]
                        if ext == "bmp" || ext == "png" {
                            self.filelist.append(file)
                        }
                    }
                } else {
                    
                }
                
                tableView.reloadData()
 
                
                
                
                
                /*
               // let path = getFileURL(fileName: "2000024_1F").path
                if let imgPath = urls.first?.path{
                    if let imageData = UIImage(contentsOfFile: imgPath) {
                        imageView.image = imageData
                    }
                }*/
                break
                /*
            case "rfdz":

                let fileManager = FileManager.default
                let sourceURL = urls.first!
                let folder = sourceURL.deletingPathExtension().lastPathComponent //拡張子を除いたファイル名
                let documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
                let destinationURL = documentDirectoryFileURL.appendingPathComponent(folder, isDirectory: true) //圧縮ファイル名のサブフォルダ
                let destinationStr = String(destinationURL.path)
                let ud = UserDefaults.standard
                ud.setValue(folder, forKey: "folder")

                do {
                    //destinationと同名のフォルダは削除する
                    if fileManager.fileExists(atPath: destinationStr) {
                        try fileManager.removeItem(atPath: destinationStr)
                    }
                    //destinationフォルダを作成する
                    try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)//フォルダ作成
                    //destinationフォルダに解凍する
                    try fileManager.unzipItem(at: sourceURL, to: destinationURL, skipCRC32: true, preferredEncoding: .shiftJIS)
                    
                } catch {
                    print("Extraction of ZIP archive failed with error:\(error)")
                }

                var files: [String] = []
                do {
                    files = try fileManager.contentsOfDirectory(atPath: destinationStr)
                    filelist.removeAll()
                } catch {
   
                }
  
                for file in files {
                    let sep = file.split(separator: ".")
                    let ext = sep[sep.count-1]
                    if ext == "rfdx" {
                        let pf = Profile(file: file, folder: folder, encording: .shiftJIS)
                        let sections = pf.getSections()
                        for section in sections {
                            let ini = pf.getString(section: section, key: "FILE")
                            if ini.contains(".rfd") {
                                let rfdFile = ini
                                let iniFile = ini.replacingOccurrences(of: "rfd", with: "ini")
                                let floor = Floor()
                                floor.setRfdFile(rfdFile: rfdFile,folder: folder,iniFile: iniFile)
                            } else if ini.contains(".ini") {
                                let floor = Floor()
                                floor.setIniFile(iniFile: ini,folder: folder)
                                
                            }
                        
  /*                          if ini != "" {
                                let pf2 = Profile(file: ini, folder: folder, encording: .shiftJIS)
                                let img=pf2.getString(section: "[File]", key: "Background")
                                
                                filelist.append(img)
                            }
    */                    }
                        break

                    }
                }
                
                floorTableView.reloadData()
 
                /*
                for file in files {
                    let sep = file.split(separator: ".")
                    let exp = sep[sep.count-1]
                    if exp == "png" || exp == "bmp" {

                        filelist.append(file)
                    }
                }
                floorTableView.reloadData()
                 */
                break*/
            default:
                break
            }
            
        }
        
    }
    func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("キャンセル")
    }
    /// ファイル書き込みサンプル
    func writingToFile(text: String) {
        
        /// ①DocumentsフォルダURL取得
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("フォルダURL取得エラー")
        }
        
        /// ②対象のファイルURL取得
        let fileURL = dirURL.appendingPathComponent("output.txt")
 
        /// ③ファイルの書き込み
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    
    /// ファイル読み込みサンプル
    func readFromFile(filename: String) -> String {
        
        /// ①DocumentsフォルダURL取得
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("フォルダURL取得エラー")
        }
        
        /// ②対象のファイルURL取得
        let fileURL = dirURL.appendingPathComponent("output.txt")
 
        /// ③ファイルの読み込み
        guard let fileContents = try? String(contentsOf: fileURL) else {
            fatalError("ファイル読み込みエラー")
        }
        
        /// ④読み込んだ内容を戻り値として返す
        return fileContents
    }
    @IBAction func ActionPhotoSelect(_ sender: UIBarButtonItem) {
        //写真から背景画像を選択すr。
        selectPicture()
        
    }
    @IBAction func ActionCameraSelect(_ sender: UIBarButtonItem) {
        //背景をカメラで取り込む
        selectCamera()
        
    }
    func selectPicture() {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    func selectCamera() {
        // カメラロールが利用可能か？
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .camera
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
/*
    func deletePicture(_ sender: UIButton) {
        // アラート表示
        showAlert()
    }

    /// アラート表示
    func showAlert() {
        let alert = UIAlertController(title: "確認",
                                      message: "画像を削除してもいいですか？",
                                      preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler:{(action: UIAlertAction) -> Void in
                                        // デフォルトの画像を表示する
                                        self.imageView.image = UIImage(named: "no_image.png")
        })
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        // アラートにボタン追加
        alert.addAction(okButton)
        alert.addAction(cancelButton)

        // アラート表示
        present(alert, animated: true, completion: nil)
    }
 */
    // 写真を選んだまたはカメラで撮影した後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // 選択した写真を取得する
        var image = info[.originalImage] as! UIImage
        var imgWidth = image.size.width
        var imgHeight = image.size.height
        let targetHeight:CGFloat = 300
        
        imgWidth = targetHeight*imgWidth/imgHeight
        imgHeight = targetHeight
        
        // 背景に読み込むときに画像の高さを900（横はアスペクト比に応じる）にサイズ変更する。
        image = image.resized(size: CGSize(width: imgWidth, height: imgHeight))

        let fileManager = FileManager.default
        let folder = "MyPicture"
        let documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
        let destinationURL = documentDirectoryFileURL.appendingPathComponent(folder, isDirectory: true) //圧縮ファイル名のサブフォルダ
        let destinationStr = String(destinationURL.path)
        let ud = UserDefaults.standard
        ud.setValue(folder, forKey: "folder")
        self.folder = folder

        do {
            //destinationと同名のフォルダがなければ作成する
            if fileManager.fileExists(atPath: destinationStr) == false {
                //destinationフォルダを作成する
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)//フォルダ作成
            }

            let f = DateFormatter()
            
            f.timeStyle = .medium
            f.dateStyle = .short
            f.locale = Locale(identifier: "ja_JP")
            let now = Date()
            var time:[String] = f.string(from: now).components(separatedBy: " ")

            time[0] = time[0].replacingOccurrences(of: "/", with: "")
            time[1] = time[1].replacingOccurrences(of: ":", with: "")
            
            var destinationFileURL = destinationURL.appendingPathComponent("Picture" + time[0] + ".png", isDirectory: false) //圧縮ファイル名のサブフォルダ
            if fileManager.fileExists(atPath: destinationFileURL.path) == true {
                for i in 1...1000 {
                    destinationFileURL = destinationURL.appendingPathComponent("Picture" + time[0] + "(" + String(i)   + ").png", isDirectory: false) //圧縮ファイル名のサブフォルダ
                    if fileManager.fileExists(atPath: destinationFileURL.path) == false {
                        break
                    }

                }
            }
            
            imgWidth = image.size.width
            imgHeight = image.size.height

            let pngImageData = image.pngData()
            do {
                try pngImageData!.write(to: destinationFileURL, options: .atomic)
            } catch {
                print(error)
     
            }
 
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }

        


        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }

}
extension UTType {
  static var myappdoc: UTType {
    UTType(exportedAs: "com.kogagarage.PictureTapLogger.rfdz")    // define Exported UTI as static var
  }
}
