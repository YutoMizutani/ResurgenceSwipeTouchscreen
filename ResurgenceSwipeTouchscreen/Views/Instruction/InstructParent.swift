import Foundation
import UIKit

class InstructParent: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func load() {
        var instStr: String = ""
        var instFontName: String = "System Font"
        var instFontSize: Int = 10
        var InstFontColor: UIColor = UIColor.black

        let userDefaults = UserDefaults.standard
        instStr = (userDefaults.object(forKey: "instStr") != nil) ? userDefaults.string(forKey: "instStr")! : ""
        instFontName = (userDefaults.object(forKey: "instFontName") != nil) ? userDefaults.string(forKey: "instFontName")! : ""
        instFontSize = (userDefaults.object(forKey: "instFontSize") != nil) ? userDefaults.integer(forKey: "instFontSize") : 0
        var ColorRGB: [CGFloat] = [0, 0, 0]
        if userDefaults.object(forKey: "userColorR") != nil {
            ColorRGB[0] = CGFloat(userDefaults.float(forKey: "userColorR"))
            ColorRGB[1] = CGFloat(userDefaults.float(forKey: "userColorG"))
            ColorRGB[2] = CGFloat(userDefaults.float(forKey: "userColorB"))
        }
        InstFontColor = UIColor(red: ColorRGB[0], green: ColorRGB[1], blue: ColorRGB[2], alpha: 1.0)

        DispatchQueue.main.async {
            self.textv.text = instStr
            let str: String = instFontName
            let size: CGFloat = CGFloat(instFontSize)
            if str == "System Font" {
                self.textv.font = UIFont.systemFont(ofSize: size)
            } else {
                self.textv.font = UIFont(name: str, size: size)
            }
            self.textv.textColor = InstFontColor
        }
    }

    // finalCheckとしてtag(10-XX)の連番とその＋10のerrorlogLabelとtag-10数のtrue arrayが存在。追加時注意！
    var finalCheck: [Bool] = [true, true, true, true]
    var StartB: UIButton = UIButton()
    var textv = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth / 4 * 3, height: screenHeight / 20 * 13))

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutRect()
        layoutStartB()
        load()
    }

    private func layoutRect() {
        let labelTitle = UILabel(frame: CGRect(x: 0, y: screenHeight / 20, width: screenWidth, height: screenHeight / 10))
        labelTitle.text = "Instructions"
        labelTitle.textAlignment = NSTextAlignment.center
        labelTitle.font = UIFont.systemFont(ofSize: screenHeight / 10 / 2)
        view.addSubview(labelTitle)

        textv.isUserInteractionEnabled = false
        textv = UITextView(frame: CGRect(x: 0, y: 0, width: screenWidth / 4 * 3, height: screenHeight / 20 * 13))
        textv.center = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        textv.textAlignment = .left
        textv.isEditable = false
        textv.layer.borderWidth = 1
        textv.layer.borderColor = UIColor.lightGray.cgColor
        textv.layer.cornerRadius = 2
        view.addSubview(textv)

        let buttonB = UIButton(frame: CGRect(x: 10, y: statusbarHeight + 10, width: 50, height: 50))
        buttonB.setImage(UIImage(named: "back"), for: .normal)
        buttonB.tag = 2
        buttonB.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        view.addSubview(buttonB)
    }

    private func layoutStartB() {
        StartB.setTitle("START ", for: .normal)
        StartB.setTitle("ERROR...", for: .disabled)
        StartB.setTitleColor(UIColor.blue, for: .normal)
        StartB.setTitleColor(UIColor.blue, for: .disabled)
        StartB.titleLabel!.font = UIFont.systemFont(ofSize: screenHeight / 40)
        StartB.backgroundColor = UIColor.lightGray
        StartB.frame = CGRect(x: 0, y: screenHeight * 9 / 10, width: screenWidth, height: screenHeight / 10)
        StartB.addTarget(self, action: #selector(setTUI), for: .touchUpInside)
        StartB.tag = 3
        view.addSubview(StartB)
    }

    @IBAction private func setTUI(_ sender: UIButton) {
        switch sender.tag {
        case 2:
            backButtonTUI()
        case 3:
            startButtonTUI()
        default:
            break
        }
    }

    func backButtonTUI() {}
    func startButtonTUI() {}
}
