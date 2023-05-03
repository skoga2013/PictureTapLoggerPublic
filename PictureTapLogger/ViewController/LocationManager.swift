//
//  LocationManager.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/04/01.
//

import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var heading:CLLocationDirection = 0.0
    let manager = CLLocationManager()

    override init() {
        super.init()

        manager.delegate = self
        manager.requestWhenInUseAuthorization()

        //電子コンパス設定
        manager.headingFilter      = kCLHeadingFilterNone
        manager.headingOrientation = .portrait
        manager.startUpdatingHeading()
    }

    //電子コンパス値取得
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.magneticHeading
    }

}
