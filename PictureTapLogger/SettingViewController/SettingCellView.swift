//
//  SettingViewCellController.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/23.
//

import Foundation
import UIKit

final class SettingCellView: UITableViewCell {
    static let reuseIdentifier = "SettingCellView"
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var select1: UIButton!
    
    var key:String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    
    private var selectedMenuType = MenuType.utf8
    
    static func nib() -> UINib {
        return UINib(nibName: SettingCellView.reuseIdentifier, bundle: nil)
    }
    static func hiight() -> Double {
        return 50
        
    }
    
    func bind(title1: String, label1: String="", key: String) {
        self.title1.text = title1
        self.label1.text = label1
        self.switch1.isHidden = false
        self.select1.isHidden = true
        self.key = key
        let ud = UserDefaults.standard
        self.switch1.isOn = ud.bool(forKey: self.key)
    }
    func bind2(title1: String, label1: String="", key: String) {
        self.title1.text = title1
        self.label1.text = label1
        self.switch1.isHidden = true
        self.select1.isHidden = false
        self.key = key
        let ud = UserDefaults.standard
        let val = ud.string(forKey: self.key)
        switch val {
        case MenuType.utf8.title:
            selectedMenuType = MenuType.utf8
            break
        case MenuType.shiftjis.title:
            selectedMenuType = MenuType.shiftjis
            break
        case MenuType.unicode.title:
            selectedMenuType = MenuType.unicode
            break
        default:
            selectedMenuType = MenuType.utf8
            break
        }
        configureMenuButton()

    }
    func key(key:String) {
        self.key = key
    }
    private func configureMenu() {
        let actions = MenuType.allCases
            .compactMap { type in
                UIAction(
                    title: type.title,
                    state: type == selectedMenuType ? .on : .off,
                    handler: { _ in
                        self.selectedMenuType = type
                        self.configureMenu()
                    })
            }
        select1.menu = UIMenu(title: "", options: .displayInline, children: actions)
        select1.showsMenuAsPrimaryAction = true
        select1.setTitle(selectedMenuType.title, for: .normal)
    }
    
    @IBAction func changeSwitch(_ sender: UISwitch) {
        print("change switch")
        let ud = UserDefaults.standard
        ud.set(switch1.isOn, forKey: self.key)
    }
    
    
    private func configureMenuButton() {
        var actions = [UIMenuElement]()
        // UTF-8
        actions.append(UIAction(title: MenuType.utf8.title, image: nil, state: self.selectedMenuType == MenuType.utf8 ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .utf8
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                    print("UTF-8")
                                    let ud = UserDefaults.standard
                                    ud.set(self.selectedMenuType.title, forKey: self.key)
                                }))
        // ShiftJIS
        actions.append(UIAction(title: MenuType.shiftjis.title, image: nil, state: self.selectedMenuType == MenuType.shiftjis ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .shiftjis
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                    print("ShiftJIS")
                                    let ud = UserDefaults.standard
                                    ud.set(self.selectedMenuType.title, forKey: self.key)
                                }))
        // UNICODE
        actions.append(UIAction(title: MenuType.unicode.title, image: nil, state: self.selectedMenuType == MenuType.unicode ? .on : .off,
                                handler: { (_) in
                                    self.selectedMenuType = .unicode
                                    // UIActionのstate(チェックマーク)を更新するためにUIMenuを再設定する
                                    self.configureMenuButton()
                                    print("UNICODE")
                                    let ud = UserDefaults.standard
                                    ud.set(self.selectedMenuType.title, forKey: self.key)
                                }))

        // UIButtonにUIMenuを設定
        select1.menu = UIMenu(title: "", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        select1.showsMenuAsPrimaryAction = true
        // ボタンの表示を変更
        select1.setTitle(self.selectedMenuType.title, for: .normal)
    }

    
}

enum MenuType: CaseIterable {
    case utf8
    case shiftjis
    case unicode

    var title: String {
        switch self {
        case .utf8:
            return "UTF-8"
        case .shiftjis:
            return "ShiftJIS"
        case .unicode:
            return "UNICODE"
        }
    }
}
