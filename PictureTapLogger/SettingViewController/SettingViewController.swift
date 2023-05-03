//
//  SettingViewController.swift
//  PictureTapLogger
//
//  Created by 古賀真一郎 on 2023/03/14.
//

import Foundation
import UIKit

class SettingViewController: UIViewController{
    
    

    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationItem.setTitleView(withTitle: "設定", subTitile: "設定を変更できます。")
        setupNavigationBarTitle()
    }

    private func setupNavigationBarTitle() {
        title = "設定"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        // LargeTitleのフォントを小さくする
        setAppearanceForLargeTitleText()
        
    }
    private func setAppearanceForLargeTitleText() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label,
                                               .font: UIFont.systemFont(ofSize: 17, weight: .bold)]
        appearance.backgroundColor = .systemBackground
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(SettingCellView.nib(), forCellReuseIdentifier: SettingCellView.reuseIdentifier)

        tableView.rowHeight = 100
    }
}
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingCellView.reuseIdentifier, for: indexPath) as? SettingCellView else { return UITableViewCell() }


        switch indexPath.row {
        case 0:

            cell.bind(title1: "圧縮の文字コードはUTC-8", label1: "Windowsで圧縮した場合は、文字コードがshiftJISの場合があります。その時はOFFにしてください。",key: "zipcode")
            break
        case 1:
            //cell.bind(title1: "開くファイルの文字コードはUTC-8", label1: "Windowsで作ったファイルは文字コードがShiftJISの場合がありますその場合はShitJISにしてください。",key: "faileode")
            cell.bind2(title1: "保存するファイルの文字コード",  label1: "Windowsで作ったファイルは文字コードがShiftJISの場合がありますその場合はShitJISにしてください。",key: "filecode")
            break
        case 2:
            cell.bind(title1: "圧縮ファイルで選択できるのは拡張子がzipのみ", label1: "全てのファイルを選択対象とするときはOFFしてください。",key: "RfdSwitch")
            break
        default:
            break

        }
        return cell
    }
    
}
extension UINavigationItem {

    func setTitleView(withTitle title: String, subTitile: String) {

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black

        let subTitleLabel = UILabel()
        subTitleLabel.text = subTitile
        subTitleLabel.font = .systemFont(ofSize: 14)
        subTitleLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical

        self.titleView = stackView
    }
}
