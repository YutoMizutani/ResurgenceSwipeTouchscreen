import Foundation
import UIKit

class SetInstructions: AlertColorSlider {
    let fonts: [String] = [
        "System Font",
        "AmericanTypewriter",
        "Arial",
        "Baskerville-SemiBold",
        "Thonburi-Bold",
        "Times New Roman",
        "BodoniOrnamentsITCTT"
    ]

    static var instStr: String = ""
    static var instFontName: String = "System Font"
    static var instFontSize: Int = 10
    /// preview時に使用
    static var InstFontColor: UIColor = UIColor.clear

    override func viewDidLoad() {
        layoutRect()
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        let userDefaults = UserDefaults.standard
        SetInstructions.instStr = (userDefaults.object(forKey: "instStr") != nil)
            ? userDefaults.string(forKey: "instStr")!
            : ""
        SetInstructions.instFontName = (userDefaults.object(forKey: "instFontName") != nil)
            ? userDefaults.string(forKey: "instFontName")!
            : "System Font"
        SetInstructions.instFontSize = (userDefaults.object(forKey: "instFontSize") != nil)
            ? userDefaults.integer(forKey: "instFontSize")
            : 10
        textf0Load()
    }

    override func setTUIC11_add() {
        let button3: UIButton = view.viewWithTag(12) as! UIButton
        button3.setTitle(getColorStr(), for: .normal)
        button3.backgroundColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)

        textf0.textColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)
    }

    var textf0: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    private func layoutRect() {
        let buttonB = UIButton(frame: CGRect(x: 10, y: statusbarHeight + 10, width: 50, height: 50))
        buttonB.setImage(UIImage(named: "back"), for: .normal)
        buttonB.tag = 2
        buttonB.addTarget(self, action: #selector(setTUITR), for: .touchUpInside)
        view.addSubview(buttonB)

        let labelTitle = UILabel(frame: CGRect(x: 0, y: screenHeight / 20, width: screenWidth, height: screenHeight / 10))
        labelTitle.text = "Edit Instructions"
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2)
        view.addSubview(labelTitle)
        let l1 = UILabel(frame: CGRect(x: 0, y: screenHeight / 10 * 8, width: screenWidth, height: screenHeight / 10))
        l1.font = UIFont.systemFont(ofSize: screenHeight / 10 / 5)
        l1.text = ""
        l1.textColor = UIColor.blue
        l1.textAlignment = NSTextAlignment.center
        view.addSubview(l1)

        let label0 = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenHeight / 20))
        label0.center = CGPoint(x: screenWidth / 4, y: screenHeight * 2 / 10)
        label0.text = "Text:"
        label0.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2 / 2)
        textf0 = UITextView(frame: CGRect(x: screenWidth / 8, y: label0.frame.maxY, width: screenWidth / 4 * 3, height: screenHeight / 3))
        textf0.text = SetInstructions.instStr
        textf0.tag = 10000
        textf0.layer.borderColor = UIColor.gray.cgColor
        textf0.layer.borderWidth = 1
        textf0.layer.cornerRadius = 10
        view.addSubview(label0)
        view.addSubview(textf0)

        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenHeight / 20))
        label1.center = CGPoint(x: screenWidth / 4, y: screenHeight * 6 / 10)
        label1.text = "FontSize:"
        let textf1 = UITextField(frame: CGRect(x: 0, y: 0, width: screenWidth / 2, height: screenHeight / 20))
        textf1.center = CGPoint(x: screenWidth * 13 / 20, y: screenHeight * 6 / 10)
        textf1.text = SetInstructions.instFontSize.description
        textf1.tag = 10
        textf1.borderStyle = .roundedRect
        textf1.keyboardType = .numberPad
        view.addSubview(label1)
        view.addSubview(textf1)
        textf1.addTarget(self, action: #selector(textCheck), for: UIControl.Event.editingChanged)

        let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenHeight / 20))
        label2.center = CGPoint(x: screenWidth / 4, y: screenHeight * 7 / 10)
        label2.text = "FontName:"
        let button2 = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 2, height: screenHeight / 20))
        button2.center = CGPoint(x: screenWidth * 13 / 20, y: screenHeight * 7 / 10)
        button2.setTitle(SetInstructions.instFontName, for: .normal)
        button2.tag = 11
        button2.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        button2.layer.borderColor = UIColor.blue.cgColor
        button2.setTitleColor(UIColor.blue, for: .normal)
        button2.layer.borderWidth = 1
        button2.layer.cornerRadius = 10
        view.addSubview(label2)
        view.addSubview(button2)

        let label3 = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 4, height: screenHeight / 20))
        label3.center = CGPoint(x: screenWidth / 4, y: screenHeight * 8 / 10)
        label3.text = "FontColor:"
        let button3 = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 2, height: screenHeight / 20))
        button3.center = CGPoint(x: screenWidth * 13 / 20, y: screenHeight * 8 / 10)
        button3.setTitle(getColorStr(), for: .normal)
        button3.tag = 12
        button3.addTarget(self, action: #selector(setTUIT), for: .touchUpInside)
        button3.backgroundColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)
        button3.setTitleColor(UIColor.blue, for: .normal)
        button3.layer.borderColor = UIColor.blue.cgColor
        button3.layer.borderWidth = 1
        button3.layer.cornerRadius = 10
        view.addSubview(label3)
        view.addSubview(button3)

        let SetB = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 5 * 2, height: screenHeight / 10))
        SetB.center = CGPoint(x: screenWidth / 10 * 7.2, y: screenHeight - screenHeight / 10 / 3 * 2)
        SetB.setTitle("Save", for: .normal)
        SetB.setTitleColor(UIColor.blue, for: .normal)
        SetB.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        SetB.layer.borderWidth = 1
        SetB.layer.borderColor = UIColor.blue.cgColor
        SetB.layer.cornerRadius = 8
        SetB.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        SetB.tag = 3
        view.addSubview(SetB)

        let PreVB = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 5 * 2, height: screenHeight / 10))
        PreVB.center = CGPoint(x: screenWidth / 10 * 2.8, y: screenHeight - screenHeight / 10 / 3 * 2)
        PreVB.setTitle("Preview", for: .normal)
        PreVB.setTitleColor(UIColor.blue, for: .normal)
        PreVB.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        PreVB.layer.borderWidth = 1
        PreVB.layer.borderColor = UIColor.blue.cgColor
        PreVB.layer.cornerRadius = 8
        PreVB.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        PreVB.tag = 4
        view.addSubview(PreVB)
    }

    func checkChangeValue() -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "instStr") != nil {
            if SetInstructions.instStr != userDefaults.string(forKey: "instStr") ?? "" {
                return true
            }
            if SetInstructions.instFontName != userDefaults.string(forKey: "instFontName") ?? "System Font" {
                return true
            }
            if SetInstructions.instFontSize != userDefaults.integer(forKey: "instFontSize") {
                return true
            }
            if userDefaults.object(forKey: "userColorR") != nil {
                if ColorRGB[0] != CGFloat(userDefaults.float(forKey: "userColorR")) {
                    return true
                }
                if ColorRGB[1] != CGFloat(userDefaults.float(forKey: "userColorG")) {
                    return true
                }
                if ColorRGB[2] != CGFloat(userDefaults.float(forKey: "userColorB")) {
                    return true
                }
            }
        }

        return false
    }

    @IBAction private func setTUITR(_ sender: UIButton) {
        switch sender.tag {
        case 2:
            // 変化していれば戻る前に警告を出す
            if checkChangeValue() {
                let alert = UIAlertController(
                    title: "Changes have not been made",
                    message: "Are you sure you want to leave this page?",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Leave", style: .default) { (_: UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(UIAlertAction(title: "Stay", style: .cancel))
                present(alert, animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }

    func textf0Load() {
        textf0.text = SetInstructions.instStr
        (view.viewWithTag(10) as! UITextField).text = SetInstructions.instFontSize.description
        (view.viewWithTag(11) as! UIButton).setTitle(SetInstructions.instFontName, for: .normal)
        textf0Update()
        setTUIC11_add()
    }

    func getColorStr() -> String {
        return "R:" + Int(ColorRGB[0] * 255).description + ", G:" + Int(ColorRGB[1] * 255).description + ", B:" + Int(ColorRGB[2] * 255).description
    }

    func FontChange(_ str: String) {
        SetInstructions.instFontName = str
        DispatchQueue.main.async {
            (self.view.viewWithTag(11) as! UIButton).setTitle(SetInstructions.instFontName, for: .normal)
        }
        textf0Update()
    }

    func textf0Change(_ str: String) {
        SetInstructions.instFontSize = Int(str)!
        // self.textf0.font!.withSize(CGFloat(SetInstructions.instFontSize))
        textf0Update()
    }

    func textf0Update() {
        let str: String = SetInstructions.instFontName
        let size: CGFloat = CGFloat(SetInstructions.instFontSize)
        DispatchQueue.main.async {
            if str == self.fonts[0] {
                self.textf0.font = UIFont.systemFont(ofSize: size)
            } else {
                self.textf0.font = UIFont(name: str, size: size)
            }
        }
    }

    @IBAction private func setTUI(_ sender: UIButton) {
        switch sender.tag {
        case 11:
            let alert = UIAlertController(
                title: "Select Font",
                message: "",
                preferredStyle: .alert
            )
            for i in 0 ... fonts.count - 1 {
                alert.addAction(UIAlertAction(title: fonts[i], style: .default) { (_: UIAlertAction!) -> Void in
                    self.FontChange(self.fonts[i])
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
        case 12:
            break
        case 3:
            SetInstructions.instStr = textf0.text

            let userDefaults = UserDefaults.standard
            userDefaults.set(ColorRGB[0], forKey: "userColorR")
            userDefaults.set(ColorRGB[1], forKey: "userColorG")
            userDefaults.set(ColorRGB[2], forKey: "userColorB")
            userDefaults.set(SetInstructions.instStr, forKey: "instStr")
            userDefaults.set(SetInstructions.instFontName, forKey: "instFontName")
            userDefaults.set(SetInstructions.instFontSize, forKey: "instFontSize")

            let alert: UIAlertController = UIAlertController(title: "", message: "Instruction Sevd", preferredStyle: UIAlertController.Style.alert)
            let defaultAct: UIAlertAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: {
                (_: UIAlertAction!) -> Void in
            })
            alert.addAction(defaultAct)
            present(alert, animated: true, completion: nil)
        case 4:
            SetInstructions.InstFontColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)
            SetInstructions.instStr = textf0.text
            let viewController = InstructPreview()
            viewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
            present(viewController, animated: true, completion: nil)
        default:
            break
        }
    }

    @IBAction func textCheck(_ sender: UITextField) {
        let str: String = sender.text!
        if str == "" {
            DispatchQueue.main.async {
                sender.text = "0"
            }
        } else {
            var s: String = ""
            let a = NSPredicate(format: "SELF MATCHES '\\\\d+'") // 正規表現
            if !a.evaluate(with: str) {
                for i in str {
                    switch i {
                    case "0":
                        if s != "" { // 最初の0は加えない
                            s += String(i)
                        }
                        continue
                    case "1", "2", "3", "4", "5", "6", "7", "8", "9":
                        s += String(i)
                        continue
                    default:
                        break
                    }
                }
            } else {
                for i in str {
                    switch i {
                    case "0":
                        if s != "" { // 最初の0は加えない
                            s += String(i)
                        }
                        continue
                    default:
                        s += String(i)
                        continue
                    }
                }
            }
            if s == "" { // 変更後が0000の場合，0を代入
                s = "0"
            }
            DispatchQueue.main.async {
                sender.text = s
                self.textf0Change(s)
            }
        }
    }
}
