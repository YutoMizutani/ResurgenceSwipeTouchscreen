//
//  DropboxUploaderView.swift
//
//  Created by Yuto Mizutani on 2017/01/30.
//  Copyright © 2017年 Yuto Mizutani. All rights reserved.
//

import Foundation
import SwiftyDropbox

class UploaderView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView = UITableView()
    var items: [String] = []

    let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/UploadErrorFiles"

    override func viewDidLoad() {
        LoadDfiles()
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        layoutRect()
    }

    private func layoutRect() {
        // DropboxLoginButton
        let size: CGFloat = 75
        let button = UIButton(frame: CGRect(x: screenWidth - size - 10, y: statusbarHeight + 10, width: size, height: size))
        button.setImage(UIImage(named: "02"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        view.addSubview(button)
        let iview = UIImageView(frame: CGRect(x: screenWidth - size - 10 + 5, y: statusbarHeight + 10 + 5, width: size - 5 * 2, height: size - 5 * 2))
        iview.isUserInteractionEnabled = false
        iview.image = UIImage(named: "dropbox-ios")
        view.addSubview(iview)

        let buttonB = UIButton(frame: CGRect(x: 10, y: statusbarHeight + 10, width: 50, height: 50))
        buttonB.setImage(UIImage(named: "back"), for: .normal)
        buttonB.tag = 2
        buttonB.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        view.addSubview(buttonB)

        let labelTitle = UILabel(frame: CGRect(x: 0, y: screenHeight / 20, width: screenWidth, height: screenHeight / 10))
        labelTitle.text = "Dropbox Uploader"
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.systemFont(ofSize: screenHeight / 10 / 3 / 2 * 3)
        view.addSubview(labelTitle)

        tableView = UITableView(frame: CGRect(x: screenWidth / 10, y: screenHeight / 20 * 5, width: screenWidth - screenWidth / 10 * 2, height: (screenHeight - (screenHeight / 20 * 5)) * 9 / 10 - screenHeight / 20))
        tableView.tag = 3
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.cornerRadius = 8
        view.addSubview(tableView)

        let button14 = UIButton(frame: CGRect(x: screenWidth / 2 / 2, y: screenHeight / 20 * (5 + 12 + 1), width: screenWidth / 2, height: screenHeight / 20))
        button14.setTitle("Upload to Dropbox", for: .normal)
        button14.setTitleColor(UIColor.blue, for: .normal)
        button14.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        button14.titleLabel?.textAlignment = NSTextAlignment.center
        button14.tag = 14
        button14.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button14.layer.borderWidth = 1
        button14.layer.borderColor = UIColor.lightGray.cgColor
        button14.layer.cornerRadius = 8
        view.addSubview(button14)

        let buttonrl = UIButton(frame: CGRect(x: screenWidth / 10 * 3, y: screenHeight / 20 * (3 + 1 / 2), width: screenWidth / 10 * 4, height: screenHeight / 20))
        buttonrl.setTitle("Check updates", for: .normal)
        buttonrl.setTitle("Reloading..", for: .disabled)
        buttonrl.setTitleColor(UIColor.blue, for: .normal)
        buttonrl.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 10 / 3 / 2)
        buttonrl.titleLabel?.textAlignment = NSTextAlignment.center
        buttonrl.tag = 13
        buttonrl.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        buttonrl.layer.borderWidth = 1
        buttonrl.layer.borderColor = UIColor.lightGray.cgColor
        buttonrl.layer.cornerRadius = 8
        view.addSubview(buttonrl)
    }

    private func LoadDfiles() {
        do {
            try FileManager.default.createDirectory(atPath: libraryPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("couldn't create directory..")
        }
        func list() -> [String] {
            do {
                return try FileManager.default.contentsOfDirectory(atPath: libraryPath)
            } catch {
                print("couldn't load files..")
                return []
            }
        }
        items = list()
        print(items)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("セルを選択しました！ #\(indexPath.row)")
    }

    @IBAction private func setTUIT(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                              UIApplication.shared.openURL(url)
                                                          })
        case 2:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

    @IBAction private func setTUI(_ sender: UIButton) {
        switch sender.tag {
        case 10:
            let viewController = ViewController()
            viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            present(viewController, animated: true, completion: nil)
        case 13:
            print("tapped")
            LoadDfiles()
            tableView.reloadData()
            let button = view.viewWithTag(13) as! UIButton
            button.isEnabled = false
            let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(TimerEvent(_:)), userInfo: nil, repeats: false)
            timer.fire()
        case 14:
            // ※順番にアップロード，ログイン(key確認できない場合)していない場合はログイン画面を出す
            dropboxUpload()
        default:
            break
        }
    }

    @objc private func TimerEvent(_ timer: Timer) {
        EnableButton()
    }

    private func EnableButton() {
        (view.viewWithTag(13) as! UIButton).isEnabled = true
    }

    private func dropboxUpload() {
        if !items.isEmpty {
            print("ありまぁす！")
            forloop: for i in 0 ..< items.count {
                (view.viewWithTag(14) as! UIButton).setTitle("Uploading... " + i.description + "/" + items.count.description, for: .normal)
                view.updateConstraintsIfNeeded()
                let file = "/" + items[i]
                let filePath = libraryPath + file
                let fileURL = URL(fileURLWithPath: filePath)
                var text = ""
                do {
                    try text = String(contentsOf: fileURL, encoding: String.Encoding.utf8)
                    print("ありまぁした！")
                } catch {
                    print("couldn't load file..")
                    break forloop
                }

                var sbjName: String = ""
                var sessNum: String = ""
                var bool: Bool = true
                for i in items[i] {
                    switch i {
                    case "_":
                        bool = false
                    default:
                        if bool {
                            sbjName += i.description
                        } else {
                            sessNum += i.description
                        }
                    }
                }

                if client != nil {
                    let fileData = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                    let request = client?.files.upload(path: "/" + sbjName + "/" + sbjName + "_" + sessNum, mode: Files.WriteMode.add, autorename: true, clientModified: nil, mute: true, input: fileData)
                        .response { response, error in
                            if let response = response {
                                print("response: " + response.description)
                                self.FileDelete(Path: filePath, index: i)
                            } else if let error = error {
                                print("couldn't upload file..")
                                print("error: " + error.description)
                            }
                        }
                        .progress { progressData in
                            print("progressData: " + progressData.description)
                        }
                } else {
                    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                                  controller: self,
                                                                  openURL: { (url: URL) -> Void in
                                                                      UIApplication.shared.openURL(url)
                                                                  })
                }
            }
            (view.viewWithTag(14) as! UIButton).setTitle("Upload to Dropbox", for: .normal)
        }
    }

    func FileDelete(Path: String, index: Int) {
        do {
            try FileManager.default.removeItem(atPath: Path)
            if items.count > index {
                items.remove(at: index)
                print("削除しました。")
            }
            tableView.reloadData()
        } catch {
            print("couldn't delete uploaded file..")
        }
    }
}
