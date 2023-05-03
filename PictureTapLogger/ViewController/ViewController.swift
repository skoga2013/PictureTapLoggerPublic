//
//  ViewController.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/02/25.
//

import UIKit
import UniformTypeIdentifiers
import ZIPFoundation
import CoreLocation

class ViewController: UIViewController, UIGestureRecognizerDelegate,UIScrollViewDelegate, UIDocumentPickerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    var imageView: UIImageView! //背景の画像
    var myView :MyView! //タップで記録した
    var myLandmark:MyLandmark!  //目印　RFDの場合はアンテナ
    var myArea:MyArea!
    var myBeam:MyBeam!
    var myNorth:MyNorth!
    var targetView:MyPoint! //対象がmyViewかmyLandmarkを指定
    
    
    var myMarker: MyMarker!
    var myDust: MyDust!
    var myUndo: MyUndo!
    var myRedo: MyRedo!
    var mySymbol: MySymbol!
    var myStart: MyStart!
    var myNeedle: MyNeedle!
    var myArrow: MyArrow!
    

    var prevPinch:CGFloat = 1
    var tapPoint = CGPoint(x: 0, y: 0)
    var searchIndexPoint = -1
    var searchIndexLine = -1
    //元の画像のタップ座標用変数
    var originalTapPoint = CGPoint(x: 0, y: 0)
    
    var imgWidth:CGFloat=0
    var imgHeight:CGFloat=0
    var top_left = CGPoint(x: 0, y: 0)
    var prevDragPoint: CGPoint!
 
    // ロケーションマネージャ
    var locationManager: CLLocationManager?
    var angle:Double = 0 //図上の北の角度　0:上　90:右 -90:左　180:下
    var pixel:Double = 100
    var meter:Double = 100
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale =  0.6
        
        imageView = UIImageView()
        imageView.contentMode = .topLeft
        
        myLandmark = MyLandmark()
        myLandmark.isOpaque = false //透過

        myView = MyView()
        myView.isOpaque = false //透過

        //Area
        myArea = MyArea()
        myArea.isOpaque = false //透過

        //Beam 向いてる方向に線を描く
        myBeam = MyBeam(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        myBeam.isOpaque = false //透過
        
        myNorth = MyNorth()
        myNorth.isOpaque = false
        myNorth.isHidden = true

        //ゴミ箱
        myDust = MyDust(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        myDust.backgroundColor = UIColor.cyan
        myDust.layer.masksToBounds = true
        myDust.layer.cornerRadius = 40.0
        myDust.isOpaque = false
        myDust.alpha = 0.4
        myDust.isHidden = true

        //長押しした時の十字マーカー
        myMarker = MyMarker(frame: CGRect(x: 0, y: 80, width: 80, height: 80))
        myMarker.backgroundColor = UIColor.red
        myMarker.layer.masksToBounds = true
        myMarker.layer.cornerRadius = 40.0
        myMarker.isOpaque = false
        myMarker.alpha = 0.4
        myMarker.isHidden = true

        //Undo
        myUndo = MyUndo(frame: CGRect(x: 0, y: 160, width: 80, height: 80))
        myUndo.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0)
        myUndo.layer.masksToBounds = true
        myUndo.layer.cornerRadius = 40.0
        myUndo.isOpaque = false
        myUndo.alpha = 1
        myUndo.isHidden = false

        //Redo
        myRedo = MyRedo(frame: CGRect(x: 0, y: 240, width: 80, height: 80))
        myRedo.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.9, alpha: 1.0)
        myRedo.layer.masksToBounds = true
        myRedo.layer.cornerRadius = 40.0
        myRedo.isOpaque = false
        myRedo.alpha = 1.0
        myRedo.isHidden = false

        //シンボル設定
        mySymbol = MySymbol(frame: CGRect(x: 0, y: 320, width: 80, height: 80))
        mySymbol.backgroundColor = UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0)
        mySymbol.layer.masksToBounds = true
        mySymbol.layer.cornerRadius = 40.0
        mySymbol.isOpaque = false
        mySymbol.alpha = 0.4
        mySymbol.isHidden = true

        //スタート（線を切る）
        myStart = MyStart(frame: CGRect(x: 0, y: 400, width: 80, height: 80))
        myStart.backgroundColor = UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0)
        myStart.layer.masksToBounds = true
        myStart.layer.cornerRadius = 40.0
        myStart.isOpaque = false
        myStart.alpha = 0.4
        myStart.isHidden = true

        //方位磁針
        myNeedle = MyNeedle(frame: CGRect(x: 0, y: 480, width: 80, height: 80))
        myNeedle.backgroundColor = UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0)
        myNeedle.layer.masksToBounds = true
        myNeedle.layer.cornerRadius = 40.0
        myNeedle.isOpaque = false
        myNeedle.alpha = 1
        myNeedle.isHidden = false

        //地図の北向　スケール
        myArrow = MyArrow(frame: CGRect(x: 0, y: 560, width: 80, height: 80))
        myArrow.backgroundColor = UIColor.white
        myArrow.layer.masksToBounds = true
        myArrow.layer.cornerRadius = 40.0
        myArrow.isOpaque = false
        myArrow.alpha = 1
        myArrow.isHidden = false

        imageView.addSubview(myLandmark)
        imageView.addSubview(myView)
        imageView.addSubview(myMarker)
        imageView.addSubview(myArea)
        imageView.addSubview(myBeam)
        imageView.addSubview(myNorth)
        imageView.addSubview(myDust)
        imageView.addSubview(myUndo)
        imageView.addSubview(myRedo)
        imageView.addSubview(mySymbol)
        imageView.addSubview(myStart)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // 使用デバイスがiPhoneの場合
            imageView.addSubview(myNeedle)
        }
        imageView.addSubview(myArrow)
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedSingle(_:)))
        singleTap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTap)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTappedDouble(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        singleTap.require(toFail: doubleTap)
        
        
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.longPressAction(_:))
        )


        //デリゲートをセット
        longPressGesture.delegate = self

        //viewにlongPressGestureを追加
        self.view.addGestureRecognizer(longPressGesture)

        //selectPicture()
        
        //ファイルアプリから見えるように最低１つのフォイルが必要
        let fm = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        //let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsPath + "/myfile.txt"
        if !fm.fileExists(atPath: filePath) {
            fm.createFile(atPath: filePath, contents: nil, attributes: [:])
        }
        
        targetView = myView
        //targetView = myLandmark
        //targetView = myNorth
        checkUndoRedo(targetView: targetView)

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
        //print( newHeading.magneticHeading)
        myNeedle.transform = CGAffineTransform.init(rotationAngle: CGFloat(newHeading.magneticHeading+self.angle) * CGFloat.pi / 180)
        myBeam.transform = CGAffineTransform.init(rotationAngle: CGFloat(newHeading.magneticHeading+self.angle) * CGFloat.pi / 180)
        //myBeam.setMagneticHeading(angle: newHeading.magneticHeading+self.angle)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
 
            
            //imageView = UIImageView()
            //imageView.contentMode = .topLeft
            if fileManager.fileExists(atPath: documentDirectoryFileURL.path) {
                imageView.image = UIImage(contentsOfFile: documentDirectoryFileURL.path)
                //imageView.image = UIImage(named: "3000007_1F.png")
                imgWidth = imageView.image!.size.width
                imgHeight = imageView.image!.size.height
                
                imageView.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
                scrollView.contentSize = imageView.frame.size

                print(folder + "/" + backimage + "を開く")
                navigationItem.setTitleView(withTitle: "", subTitile: backimage)
            } else {
                imageView.image = nil
                print(folder + "/" + backimage + "を開く")
                navigationItem.setTitleView(withTitle: "", subTitile: "")

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

            myNorth.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            myNorth.delPont()
            myNorth.addPoint(point: CGPoint(x:100,y:300))
            myNorth.addPoint(point: CGPoint(x:100, y:100))

            print(folder + "/" + inifile + "を開く")
            //図上の北の角度を読み出し設定する
            let angleStr = pf.getString(section: "Info", key: "Angle")
            let pixelStr = pf.getString(section: "Info", key: "Pixel")
            let meterStr = pf.getString(section: "Info", key: "Meter")
            self.angle = Double(angleStr) ?? 9999
            self.pixel = Double(pixelStr) ?? 9999
            self.meter = Double(meterStr) ?? 9999
            myArrow.magneticHeading = self.angle
            myArrow.pixel = self.pixel
            myArrow.meter = self.meter
            
            //myBeam.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
            //myBeam.magneticHeading = self.angle
            myBeam.pixel = self.pixel
            myBeam.meter = self.meter

            
        }

        //ルートを表示する
        let routeFile = inifile.replacingOccurrences(of: "ini", with: "txt")
        if routeFile != "" {
            documentDirectoryFileURL = documentDirectoryFileURL.appendingPathComponent(inifile, isDirectory: false) //設定ファイル
            
            myView.delPont()
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
            }
            myView.initPoint()

            print(folder + "/" + routeFile + "を開く")
            
        }


    }


    

     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Scroll後の処理
        let offsetX = scrollView.contentOffset.x
        let offsetY = scrollView.contentOffset.y
        let zoomScale = scrollView.zoomScale
        top_left.x = CGFloat(offsetX/zoomScale) + 40
        top_left.y = CGFloat(offsetY/zoomScale) + 40
        
        myDust.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 40)
        myUndo.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 120)
        myRedo.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 200)
        mySymbol.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 280)
        myStart.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 360)
        if UIDevice.current.userInterfaceIdiom == .phone {
            myNeedle.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 440)
        }
        myArrow.center = CGPoint(x: (offsetX/zoomScale) + 40, y: (offsetY/zoomScale) + 520)
        
        
    }
    //長押し時に実行されるメソッド
    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
       print("logn Press")
        tapPoint = sender.location(in: imageView)
        switch sender.state {
        case .possible:
            print("possible")
        case .began:
            print("begain")
            
            if myMarker.isHidden == true {
                searchIndexPoint = targetView.searchNearPoint(point: tapPoint)
                if searchIndexPoint != -1 {
                    prevDragPoint = targetView.getPoint(index: searchIndexPoint)
                    //Pointの近くでロングタップ
                    myMarker.center = targetView.getPoint(index: searchIndexPoint)
                    myDust.center = top_left
                    myMarker.backgroundColor = UIColor.red
                    myMarker.isHidden = false
                    myDust.isHidden = false
                    mySymbol.isHidden = false
                    myStart.isHidden = false
                    myUndo.isHidden = true
                    myRedo.isHidden = true
                } else {
                    searchIndexLine = targetView.searchNearLine(point: tapPoint)
                    if searchIndexLine != -1 {
                        //Lineの近くでロングタップ

                        searchIndexPoint = searchIndexLine + 1
                        myMarker.center = tapPoint
                        myDust.center = top_left
                        myMarker.backgroundColor = UIColor.magenta
                        myMarker.isHidden = false
                        myDust.isHidden = false
                        myUndo.isHidden = true
                        myRedo.isHidden = true
                        targetView.insertPoint(index: searchIndexPoint, point: tapPoint,history: false)

                    } else {
                        //Pointの近くでもLineの近くでもないところでロングタップ
                        myMarker.center = tapPoint
                        myMarker.backgroundColor = UIColor.green
                        myMarker.isHidden = false
                        myDust.isHidden = false
                        myUndo.isHidden = true
                        myRedo.isHidden = true
                        targetView.addPoint(point: tapPoint, history: false)
                        searchIndexPoint = targetView.getPointCount()-1
                   }
                }
            }
        case .changed:
            print("changed")
            if searchIndexPoint != -1 {
                targetView.setPoint(point: sender.location(in: imageView), histroy: false)
                myMarker.center = tapPoint
                
                if myDust.isInArea(point: tapPoint) {
                    myDust.alpha = 1
                } else {
                    myDust.alpha = 0.4
                }
                if mySymbol.isInArea(point: tapPoint) {
                    mySymbol.alpha = 1
                } else {
                    mySymbol.alpha = 0.4
                }
                if myStart.isInArea(point: tapPoint) {
                    myStart.alpha = 1
                } else {
                    myStart.alpha = 0.4
                }
            }
     case .ended:
            print("ended")
            if targetView == myView || targetView == myLandmark {
                if myView.getPointCount() > 0 {
                    myBeam.nowPoint = myView.getPointLast()
                }
                if myDust.alpha == 1 {
                    //ゴミ箱の中
                    targetView.delPoint(index: searchIndexPoint)
                    checkUndoRedo(targetView: targetView)
                    myDust.alpha = 0.4
                } else if mySymbol.alpha == 1 {
                    //シンボル設定の中
                    var pointProperty = targetView.getPointMode(index: searchIndexPoint)
                    if (pointProperty & 2) != 0 {
                        pointProperty &= 1
                    } else {
                        pointProperty |= 2
                    }
                    targetView.setPoint(point: prevDragPoint, index: searchIndexPoint, mode: pointProperty)
                    checkUndoRedo(targetView: targetView)
                    mySymbol.alpha = 0.4
                } else if myStart.alpha == 1 {
                    //連続しない線の始まり設定内
                    var pointProperty = targetView.getPointMode(index: searchIndexPoint)
                    if (pointProperty & 1) != 0 {
                        pointProperty &= 2
                    } else {
                        pointProperty |= 1
                    }
                    targetView.setPoint(point: prevDragPoint, index: searchIndexPoint, mode: pointProperty)
                    checkUndoRedo(targetView: targetView)
                    myStart.alpha = 0.4
                } else {
                    //
                    if searchIndexPoint != -1 {
                        targetView.setPoint(point: sender.location(in: imageView), index: searchIndexPoint)
                        checkUndoRedo(targetView: targetView)
                        myMarker.isHidden = true
                    } else {
                        if searchIndexLine == -1 {
                            targetView.addPoint(point: sender.location(in: imageView))
                            checkUndoRedo(targetView: targetView)
                            myMarker.isHidden = true
                        } else {
                            // myView.setRouteLine()
                        }
                    }
                    
                }
                targetView.SaveLog()
                myMarker.isHidden = true
                myDust.isHidden = true
                mySymbol.isHidden = true
                myStart.isHidden = true
                myUndo.isHidden = false
                
                myRedo.isHidden = false
            } else if targetView == myNorth {
                if searchIndexPoint != -1 {
                    targetView.setPoint(point: sender.location(in: imageView), index: searchIndexPoint)
                    checkUndoRedo(targetView: targetView)
                    myMarker.isHidden = true
                    
                    let x1 = myNorth.getPoint(index: 1).x
                    let x2 = myNorth.getPoint(index: 0).x
                    let y1 = myNorth.getPoint(index: 1).y
                    let y2 = myNorth.getPoint(index: 0).y
                    let x1d:Double = Double(x1)
                    let x2d:Double = Double(x2)
                    let y1d:Double = Double(y1)
                    let y2d:Double = Double(y2)
                    var angleSin:Double = 0
                    var angleCos:Double = 0
                    var angle:Double = 0
                    
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
                            angle = 90 + angleCos
                        }
                    }
                    self.angle = angle
                    myArrow.setAngle(angle: angle)
                    
                }

            }
        case .cancelled:
            print("cancelled")
            if searchIndexPoint != -1 {
                myMarker.isHidden = true
            }
        case .failed:
            print("failed")
        default:
            print("default")
        }
        print(sender.state.rawValue)
        checkNearAnt()

    }
    func checkNearAnt() {
        //近くのアンテナを検索する
        let cc = ClossCheck()
        
        for i in 0..<myView.getPointCount() {
            var nearNum:Int = -1
            var mminLen:Double = 40
            for j in 0..<myLandmark.getPointCount() {
                let len = cc.distance_vertex(p1: myView.getPoint(index: i), p2: myLandmark.getPoint(index: j))
                if len < mminLen {
                    mminLen = len
                    nearNum = myLandmark.getPointNumber(index: j)
                }
            }
            myView.setPointNear(index: i, near: nearNum)
            
        }
    }
    @objc func imageViewTappedSingle(_ sender: UITapGestureRecognizer) {

        //ImageView上のタップ座標を取得
        tapPoint = sender.location(in: imageView)

        //サイズの倍率を算出し、UIImage上でのタップ座標を求める
        originalTapPoint.x = imageView.frame.size.width/imageView.frame.width * tapPoint.x
        originalTapPoint.y = imageView.frame.size.height/imageView.frame.height * tapPoint.y
        
        //print(originalTapPoint.x )
        //print(originalTapPoint.y )

        if myUndo.isInArea(point: originalTapPoint) && myUndo.isHidden == false{
            print("Undo")
            // myUndoアニメーション.
            UIView.animate(withDuration: 0.2, // アニメーションの秒数
                           delay: 0, // アニメーションが開始するまでの秒数
                           options: [.curveLinear], // アニメーションのオプション 等速 | 繰り返し
                           animations: {
                            // アニメーション処理
                            self.myUndo.alpha = 0
            }, completion: { (finished: Bool) in
                // アニメーション終了に行う処理
                if self.targetView.isUndo() {
                    self.myUndo.alpha = 1
                } else {
                    self.myUndo.alpha = 0.4
                }
            })
 
            targetView.undoHistory()
            targetView.SaveLog()
            checkUndoRedo(targetView: targetView)
        } else if myRedo.isInArea(point: originalTapPoint) && myRedo.isHidden == false{
                print("Redo")
            // myRedoアニメーション.
            UIView.animate(withDuration: 0.2, // アニメーションの秒数
                           delay: 0, // アニメーションが開始するまでの秒数
                           options: [.curveLinear], // アニメーションのオプション 等速 | 繰り返し
                           animations: {
                            // アニメーション処理
                            self.myRedo.alpha = 0
            }, completion: { (finished: Bool) in
                // アニメーション終了に行う処理
                if self.targetView.isRedo() {
                    self.myRedo.alpha = 1
                } else {
                    self.myRedo.alpha = 0.4
                }
            })
            targetView.redoHistory()
            targetView.SaveLog()
            checkUndoRedo(targetView: targetView)
        } else if UIDevice.current.userInterfaceIdiom == .phone && myNeedle.isInArea(point: originalTapPoint) && myNeedle.isHidden == false{
            
                    
            self.performSegue(withIdentifier: "ShowNeedle", sender: nil)

        } else {
            print("addRoutePoint")
            targetView.addPoint(point: originalTapPoint)
            targetView.SaveLog()
            checkUndoRedo(targetView: targetView)
            myBeam.setNowPoint(point: originalTapPoint)

       }
        if myView.getPointCount() > 0 {
            myBeam.nowPoint = myView.getPointLast()
        }
    }
    func checkUndoRedo(targetView:MyPoint) {
        //Undo Redoが可能かどうかをmyViewに問い合わせて可能ならalpha=1 不可能ならalpha=0.4とする
        if targetView.isUndo() {
            myUndo.alpha = 1
        } else {
            myUndo.alpha = 0.4
        }
        if targetView.isRedo() {
            myRedo.alpha = 1
        } else {
            myRedo.alpha = 0.4
        }
    }
    @objc func imageViewTappedDouble(_ sender: UITapGestureRecognizer) {
        print("ダブルタップ")
        //myView.putOnBack()
        //selectPicture()
    }
    

    
    @IBOutlet weak var btnRouteSelect: UIBarButtonItem!
    @IBAction func ActionRouteSelect(_ sender: UIBarButtonItem) {
        targetView = myView
        btnRouteSelect.image = UIImage(systemName: "checkmark")
        btnLandmarkSelect.image = UIImage(systemName: "")
        btnNorthSelect.image = UIImage(systemName: "")
        myNorth.isHidden = true
    }
    
    @IBOutlet weak var btnLandmarkSelect: UIBarButtonItem!
    @IBAction func ActionLandmarkSelect(_ sender: UIBarButtonItem) {
        targetView = myLandmark
        btnRouteSelect.image = UIImage(systemName: "")
        btnLandmarkSelect.image = UIImage(systemName: "checkmark")
        btnNorthSelect.image = UIImage(systemName: "")
        myNorth.isHidden = true

    }
    
    @IBOutlet weak var btnNorthSelect: UIBarButtonItem!
    @IBAction func ActionNorthSelect(_ sender: UIBarButtonItem) {
        targetView = myNorth
        btnRouteSelect.image = UIImage(systemName: "")
        btnLandmarkSelect.image = UIImage(systemName: "")
        btnNorthSelect.image = UIImage(systemName: "checkmark")
        
        let len:CGFloat = 100
        let x1:CGFloat = top_left.x + 200
        let y1:CGFloat = top_left.y + 200
        let x2:CGFloat = x1 + len * sin(self.angle * .pi / 180)
        let y2:CGFloat = y1 - len * cos(self.angle * .pi / 180)
        myNorth.delPont()
        myNorth.addPoint(point: CGPoint(x:x1, y:y1))
        myNorth.addPoint(point: CGPoint(x:x2, y:y2))

        myNorth.isHidden = false
    }
        
    @IBAction func ActionUndo(_ sender: UIBarButtonItem) {
        targetView.undoHistory()
        targetView.SaveLog()
        checkUndoRedo(targetView: targetView)
    }
    
    @IBAction func ActionRedo(_ sender: UIBarButtonItem) {
        targetView.redoHistory()
        targetView.SaveLog()
        checkUndoRedo(targetView: targetView)
    }
    
    @IBAction func ActionTrush(_ sender: UIBarButtonItem) {
        targetView.delPont()
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
    // 写真を選んだまたはカメラで撮影した後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 選択した写真を取得する
        let image = info[.originalImage] as! UIImage
        var imgWidth = image.size.width
        var imgHeight = image.size.height
        let targetHeight:CGFloat = 900
        
        imgWidth = targetHeight*imgWidth/imgHeight
        imgHeight = targetHeight
        
        // 背景に読み込むときに画像の高さを900（横はアスペクト比に応じる）にサイズ変更する。
        imageView.image = image.resized(size: CGSize(width: imgWidth, height: imgHeight))


        imageView.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        scrollView.contentSize = imageView.frame.size

        let ud = UserDefaults.standard
        ud.setValue("", forKey: "backimage")

        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }

}


extension UIImage {
    func resized(size: CGSize) -> UIImage {
        // リサイズ後のサイズを指定して`UIGraphicsImageRenderer`を作成する
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { (context) in
            // 描画を行う
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// Delegateプロトコルの抽象メソッドを実装
// → ここで具体的な処理が実装される
extension ViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // 位置情報サービスの認証情報が変更された場合に実行する処理
  }
}
