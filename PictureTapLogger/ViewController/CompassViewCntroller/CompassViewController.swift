//
//  CompassViewController.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/15.
//

import Foundation
import UIKit
import CoreLocation
class CompassViewController: UIViewController, UIGestureRecognizerDelegate,UIScrollViewDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView! //背景の画像
    var myView :MyView! //タップで記録した
    var myLandmark:MyLandmark!  //目印　RFDの場合はアンテナ
    var myArea:MyArea!
    var myCompass:MyCompass!
    var myNorthHead:MyNorthHead!
    var targetView:MyPoint! //対象がmyViewかmyLandmarkを指定
    var norrhHeaEnable:Bool=true
    
    var prevPinch:CGFloat = 1
    var tapPoint = CGPoint(x: 0, y: 0)
    var searchIndexPoint = -1
    var searchIndexLine = -1
    //元の画像のタップ座標用変数
    var originalTapPoint = CGPoint(x: 0, y: 0)
    var angleMap:CGFloat = 0
    var angleMapDone:CGFloat = 0

    var imgWidth:CGFloat=0
    var imgHeight:CGFloat=0
    var top_left = CGPoint(x: 0, y: 0)
    var prevDragPoint: CGPoint!
    var lastPoint:CGPoint!
    var offsetX:CGFloat = 0
    var offsetY:CGFloat = 0
 
    let radarR:CGFloat = 500
    // ロケーションマネージャ
    var locationManager: CLLocationManager?
    var angle:Double = 0 //図上の北の角度　0:上　90:右 -90:左　180:下
    var pixel:Double = 100
    var meter:Double = 100
    
    @IBOutlet weak var baseView: UIView!
    
    var timer = Timer()
    var transform = CGAffineTransform()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale =  0.6

        
        imageView = UIImageView()
        imageView.contentMode = .topLeft
        //imageView.isHidden = true
        
        //myLandmark = MyLandmark(frame: CGRect(x:0, y:0, width:imgWidth,height:imgHeight))
        myLandmark = MyLandmark()
        myLandmark.isOpaque = false //透過

        myView = MyView()
        myView.isOpaque = false //透過

        //Area
        myArea = MyArea()
        myArea.isOpaque = false //透過

        //Beam 向いてる方向に線を描く
        myCompass = MyCompass(frame: CGRect(x: 0, y: 0, width: radarR * 2, height: radarR * 2))
        myCompass.isOpaque = false //透過

        myNorthHead = MyNorthHead(frame: CGRect(x: 0, y: 0, width: radarR * 2, height: radarR * 2))
        myNorthHead.isOpaque = false //透過

        imageView.addSubview(myLandmark)
        imageView.addSubview(myView)
        imageView.addSubview(myArea)
        scrollView.addSubview(imageView)
        scrollView.addSubview(myCompass)
        scrollView.addSubview(myNorthHead)
        self.view.addSubview(scrollView)
        targetView = myLandmark

        if UIDevice.current.userInterfaceIdiom == .phone {
           // 使用デバイスがiPhoneの場合

            locationManager = CLLocationManager()

            // CLLocationManagerがCLLocationManagerDelegateプロトコルの抽象メソッドを実行するときは、
            // CLLocationManagerDelegateプロトコルの実装クラスであるViewControllerに実行してもらう
            locationManager!.delegate = self

            // アプリの使用中のみ位置情報サービスの利用許可を求める
            locationManager!.requestWhenInUseAuthorization()


            
//            if CLLocationManager.locationServicesEnabled() {
                
                // 何度動いたら更新するか（デフォルトは1度）
                locationManager!.headingFilter = kCLHeadingFilterNone
                
                // デバイスのどの向きを北とするか（デフォルトは画面上部）
                locationManager!.headingOrientation = .portrait

                locationManager!.startUpdatingHeading()
//            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            // 使用デバイスがiPadの場合

         }
        
        // 1秒毎に処理を実行する 反応が良すぎると歩行時に逆に見にくい
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
             // 一定時間ごとに実行したい処理を記載する
             //self.myLandmark.layer.anchorPoint = self.lastPoint
            self.imageView.layer.anchorPoint = self.lastPoint
            //self.myCompass.layer.anchorPoint = CGPoint(x: 0.5, y: 0.75)
            //self.myNorthHead.layer.anchorPoint = CGPoint(x: 0.5, y: 0.75)
            self.norrhHeaEnable = false
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.transform = self.transform
                self.myCompass.transform = CGAffineTransform.init(rotationAngle: 0)
                self.myNorthHead.transform = CGAffineTransform.init(rotationAngle: 0)
            }) { _ in
                //元に戻す
               // self.identity()
            }
            self.angleMapDone = self.angleMap
            self.norrhHeaEnable = true
        })

     }
    //画面の回転を許可するかどうか
    override var shouldAutorotate: Bool {
        //回転を許可しない
        return false
    }
    //回転の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        //縦表示
        return .portrait
    }
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    // 角度の更新で呼び出されるデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // コンパスの針の方向計算
        self.angleMap = CGFloat(newHeading.magneticHeading) * CGFloat.pi / 180
        //self.angleMap = 0
        //self.angle = 0
        transform = CGAffineTransform.init(rotationAngle: -self.angleMap + self.angle)
        //transform = transform.concatenating(CGAffineTransform.init(translationX: offsetX, y: offsetY))
        if norrhHeaEnable {
            //self.myNorthHead.layer.anchorPoint = CGPoint(x: 0.5, y: 0.75)
            self.myNorthHead.transform = CGAffineTransform.init(rotationAngle: self.angleMap - self.angleMapDone)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Scroll後の処理
        let offsetX = scrollView.contentOffset.x
        let offsetY = scrollView.contentOffset.y
        print(offsetX)
        print(offsetY)
        let zoomScale = scrollView.zoomScale
        top_left.x = CGFloat(offsetX/zoomScale)
        top_left.y = CGFloat(offsetY/zoomScale)
        
        //myCompass.center =  CGPoint(x: myCompass.frame.width / 2 - top_left.x, y: myCompass.frame.height / 2 - top_left.y)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //scrollView.frame = self.view.frame
        let ud = UserDefaults.standard
        let folder = ud.string(forKey: "folder") ?? ""
        if folder == "" {
            return
        }

        let fileManager = FileManager.default
        var documentDirectoryFileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! //Documentsフォルダ
        let subFolder = folder.split(separator: "/")
        for sub in subFolder {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(String(sub), isDirectory: true) //圧縮ファイル名のサブフォルダ
        }
        var imgWidth:CGFloat = 0
        var imgHeight:CGFloat = 0
        //背景画像を表示する
        let backimage = ud.string(forKey: "backimage") ?? ""
        if backimage != "" {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(backimage, isDirectory: false) //画像ファイル
 
            if fileManager.fileExists(atPath: documentDirectoryFileURL.path) {
                imageView.image = UIImage(contentsOfFile: documentDirectoryFileURL.path)
                imgWidth = imageView.image!.size.width
                imgHeight = imageView.image!.size.height
                
                scrollView.contentSize.width = imgWidth * 2
                scrollView.contentSize.height = imgHeight * 2
                imageView.frame = CGRect(x: imgWidth / 2, y: imgHeight / 2, width: imgWidth, height: imgHeight)
                myCompass.frame = CGRect(x: imgWidth / 2, y: imgHeight / 2, width: imgWidth, height: imgHeight)
                myNorthHead.frame = CGRect(x: imgWidth / 2, y: imgHeight / 2, width: imgWidth, height: imgHeight)
                let scrfrane = scrollView.frame.size
                
                print(folder + "/" + backimage + "を開く")
             } else {
                imageView.image = nil
                print(folder + "/" + backimage + "を開く")
 
            }
        }

        let inifile = ud.string(forKey: "inifile") ?? ""
        if inifile != "" {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(inifile, isDirectory: false) //設定ファイル
            
            //アンテナを表示する
            myLandmark.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            myView.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            myLandmark.delPont()
            let pf = Profile(file: inifile, folder: folder)
            let antNum = pf.getSectionNum(section: "Ant")
            for i in 0..<antNum {
                let antData = pf.getString(section: "Ant", key: String(i))
                let ant:[String] = antData.components(separatedBy: ",")
                let x:CGFloat = CGFloat(truncating: NumberFormatter().number(from: ant[0]) ?? 0.0)
                let y:CGFloat = CGFloat(truncating: NumberFormatter().number(from: ant[1]) ?? 0.0)
                let number:Int = Int(ant[8]) ?? -1
                myLandmark.addPoint(point: CGPoint(x:x, y:y), number: number)
            }
            myLandmark.initPoint()

            //対策範囲を表示する
            myArea.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            myArea.delArea()
            let areaNum = pf.getSectionNum(section: "Area")
            for i in 0..<areaNum {
                let areaData = pf.getString(section: "Area", key: String(i))
                myArea.addArea(area: areaData)
            }
            myArea.initArea()

            //図上の北の角度を読み出し設定する
            let angleStr = pf.getString(section: "Info", key: "Angle")
            let pixelStr = pf.getString(section: "Info", key: "Pixel")
            let meterStr = pf.getString(section: "Info", key: "Meter")
            self.angle = Double(angleStr) ?? 9999
            self.pixel = Double(pixelStr) ?? 9999
            self.meter = Double(meterStr) ?? 9999
            
            //myBeam.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            //myBeam.magneticHeading = self.angle
            myCompass.setSccale(pixel: self.pixel, meter: self.meter)
            myNorthHead.setSccale(pixel: self.pixel, meter: self.meter)


        }
        //ルートの最後の点を取得する
        let routeFile = inifile.replacingOccurrences(of: "ini", with: "txt")
        if routeFile != "" {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(inifile, isDirectory: false) //設定ファイル
            
            let pf = Profile(file: routeFile, folder: folder)
            let routeNum = pf.getSectionNum(section: "Route")
            for i in 0..<routeNum {
                let routeData = pf.getString(section: "Route", key: String(i))
                let route:[String] = routeData.components(separatedBy: ",")
                let x:CGFloat = CGFloat(truncating: NumberFormatter().number(from: route[0]) ?? 0.0)
                let y:CGFloat = CGFloat(truncating: NumberFormatter().number(from: route[1]) ?? 0.0)
                let number:Int = i
                let mode:Int!
                if route.count > 4 {
                    mode = Int(route[4]) ?? -1
                } else {
                    mode = -1
                }
                myView.addPoint(point: CGPoint(x:x, y:y), number: number, mode: mode)
                 
                self.originalTapPoint = CGPoint(x:x, y:y)
                self.lastPoint = CGPoint(x: x / imgWidth, y: y / imgHeight) //全幅、全高を１とした割合
            }
            myView.initPoint()
//            myLandmark.addPoint(point: self.originalTapPoint, number: 0)
        }
        var radarPointX = UIScreen.main.bounds.width / 2
        var radarPointY = UIScreen.main.bounds.height - 300
        offsetX = radarPointX - imgWidth / 2
        offsetY = radarPointY - imgHeight / 2
        scrollView.contentOffset.x = imageView.frame.size.width / 2 - offsetX
        scrollView.contentOffset.y = imageView.frame.size.height  / 2  - offsetY

    
        self.myCompass.layer.anchorPoint = CGPoint(x: 0.5, y: 0.75)
        self.myNorthHead.layer.anchorPoint = CGPoint(x: 0.5, y: 0.75)
        self.norrhHeaEnable = false
        self.myCompass.transform = CGAffineTransform.init(rotationAngle: 0)
        self.myNorthHead.transform = CGAffineTransform.init(rotationAngle: 0)

        //myCompass.center = CGPoint(x: imgWidth / 2 + self.originalTapPoint.x, y: imgHeight / 2 + self.originalTapPoint.y)
        //myCompass.center = CGPoint(x:0, y:0)
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // タイマーを停止する
        timer.invalidate()
     }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return self.imageView
   }

}
// Delegateプロトコルの抽象メソッドを実装
// → ここで具体的な処理が実装される
extension CompassViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // 位置情報サービスの認証情報が変更された場合に実行する処理
  }
}
extension UINavigationController {
    open override var shouldAutorotate: Bool {
        guard let viewController = self.visibleViewController else { return true }
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let viewController = self.visibleViewController else { return .portrait }
        return .portrait
    }
}
