//
//  LogViewController.swift
//  TapLogger
//
//  Created by 古賀真一郎 on 2023/03/07.
//

import UIKit

class LogViewController: UIViewController{
    
    var printingImage: UIImage?
    @IBOutlet weak var textLog: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
         printingImage = UIImage(named: "3000007_1F.png")
        navigationItem.setTitleView(withTitle: "時刻の記録", subTitile: "時刻の記録の表示・修正・許有ができます。")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefault = UserDefaults.standard
        let log = userDefault.string(forKey: "log")
        textLog.text = log


    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
  

    @IBAction func ActionShare(_ sender: UIBarButtonItem) {
        print("share")
        //let activityItems: Array<Any> = [self.printingImage!]
        let activityItems: Array<Any> = [self.textLog.text!]

         let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        let excludedActivityTypes: Array<UIActivity.ActivityType> = [
             // UIActivityType.addToReadingList,
             // UIActivityType.airDrop,
             // UIActivityType.assignToContact,
             // UIActivityType.copyToPasteboard,
             // UIActivityType.mail,
             // UIActivityType.message,
             // UIActivityType.openInIBooks,
             // UIActivityType.postToFacebook,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo
             // UIActivityType.postToTwitter,
             // UIActivityType.postToVimeo,
             // UIActivityType.postToWeibo,
             // UIActivityType.print,
             // UIActivityType.saveToCameraRoll,
             // UIActivityType.markupAsPDF
         ]
         activityViewController.excludedActivityTypes = excludedActivityTypes

        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in

             guard completed else { return }

             switch activityType {
             case UIActivity.ActivityType.postToTwitter:
                 print("Tweeted")
             case UIActivity.ActivityType.print:
                 print("Printed")
             case UIActivity.ActivityType.saveToCameraRoll:
                 print("Saved to Camera Roll")
             default:
                 print("Done")
             }
         }

        if UIDevice.current.userInterfaceIdiom == .pad {
            let screenSize = UIScreen.main.bounds
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x:screenSize.size.width/2, y: screenSize.size.height-200, width: 0, height: 0)
        }
         self.present(activityViewController, animated: true, completion: nil)    }
}

