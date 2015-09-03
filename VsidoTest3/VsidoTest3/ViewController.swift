//
//  ViewController.swift
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/04.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//

import Cocoa

private var vsido = Vsido()
private var まとめて再生中 = false

class サーボ: NSObject {
    var 番号: Int!
    var 値 = 0
    
    convenience init(番号: Int) {
        self.init()
        self.番号 = 番号
    }
    
    func addObserver() {
        let options = NSKeyValueObservingOptions.New
        addObserver(self, forKeyPath: "値", options: options, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if !まとめて再生中 {
            println("番号 = \(self.番号) 値 = \(self.値)")
            let s = ServoAngleSetReq(sid: UInt8(self.番号), angle: Int16(self.値))
            vsido.vsido_o(1, servoAngles: [s])
        }
    }
}

class ViewController: NSViewController, VsidoDelegate {
    
    // スライダーからのbindingのため、個別の名前をつける
    var 腰ピッチ = サーボ(番号: 1)
    @IBOutlet weak var 腰ピッチLabel: NSTextField!
    var 首ヨー = サーボ(番号: 2)
    @IBOutlet weak var 首ヨーLabel: NSTextField!
    var 右上腕ピッチ = サーボ(番号: 3)
    @IBOutlet weak var 右上腕ピッチLabel: NSTextField!
    var 右上腕ロール = サーボ(番号: 4)
    @IBOutlet weak var 右上腕ロールLabel: NSTextField!
    var 右前腕ピッチ = サーボ(番号: 5)
    @IBOutlet weak var 右前腕ピッチLabel: NSTextField!
    var 左上腕ピッチ = サーボ(番号: 6)
    @IBOutlet weak var 左上腕ピッチLabel: NSTextField!
    var 左上腕ロール = サーボ(番号: 7)
    @IBOutlet weak var 左上腕ロールLabel: NSTextField!
    var 左前腕ピッチ = サーボ(番号: 8)
    @IBOutlet weak var 左前腕ピッチLabel: NSTextField!
    var 右大腿ヨー = サーボ(番号: 9)
    @IBOutlet weak var 右大腿ヨーLabel: NSTextField!
    var 右大腿ピッチ = サーボ(番号: 10)
    @IBOutlet weak var 右大腿ピッチLabel: NSTextField!
    var 右大腿ロール = サーボ(番号: 11)
    @IBOutlet weak var 右大腿ロールLabel: NSTextField!
    var 右膝ピッチ = サーボ(番号: 12)
    @IBOutlet weak var 右膝ピッチLabel: NSTextField!
    var 右足ピッチ = サーボ(番号: 13)
    @IBOutlet weak var 右足ピッチLabel: NSTextField!
    var 右足ロール = サーボ(番号: 14)
    @IBOutlet weak var 右足ロールLabel: NSTextField!
    var 左大腿ヨー = サーボ(番号: 15)
    @IBOutlet weak var 左大腿ヨーLabel: NSTextField!
    var 左大腿ピッチ = サーボ(番号: 16)
    @IBOutlet weak var 左大腿ピッチLabel: NSTextField!
    var 左大腿ロール = サーボ(番号: 17)
    @IBOutlet weak var 左大腿ロールLabel: NSTextField!
    var 左膝ピッチ = サーボ(番号: 18)
    @IBOutlet weak var 左膝ピッチLabel: NSTextField!
    var 左足ピッチ = サーボ(番号: 19)
    @IBOutlet weak var 左足ピッチLabel: NSTextField!
    var 左足ロール = サーボ(番号: 20)
    @IBOutlet weak var 左足ロールLabel: NSTextField!
    
    var サーボ群: [サーボ]!
    var サーボLabels: [NSTextField!]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        サーボ群 = [
            腰ピッチ,
            首ヨー,
            右上腕ピッチ, 右上腕ロール, 右前腕ピッチ,
            左上腕ピッチ, 左上腕ロール, 左前腕ピッチ,
            右大腿ヨー, 右大腿ピッチ, 右大腿ロール,
            右膝ピッチ, 右足ピッチ, 右足ロール,
            左大腿ヨー, 左大腿ピッチ, 左大腿ロール,
            左膝ピッチ, 左足ピッチ, 左足ロール,
        ]
        
        for s in サーボ群 {
            s.addObserver()
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults(["cyc": 10])
        userDefaults.registerDefaults(["前後の速度": -100])
        userDefaults.registerDefaults(["旋回速度": 0])
        
        vsido.delegate = self
        
        サーボLabels = [
            self.腰ピッチLabel,
            self.首ヨーLabel,
            self.右上腕ピッチLabel,
            self.右上腕ロールLabel,
            self.右前腕ピッチLabel,
            self.左上腕ピッチLabel,
            self.左上腕ロールLabel,
            self.左前腕ピッチLabel,
            self.右大腿ヨーLabel,
            self.右大腿ピッチLabel,
            self.右大腿ロールLabel,
            self.右膝ピッチLabel,
            self.右足ピッチLabel,
            self.右足ロールLabel,
            self.左大腿ヨーLabel,
            self.左大腿ピッチLabel,
            self.左大腿ロールLabel,
            self.左膝ピッチLabel,
            self.左足ピッチLabel,
            self.左足ロールLabel,
        ]
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func vsidoDataReceived(op: UInt8, data: [AnyObject]!) {
        let c = Character(UnicodeScalar(op))
        switch c {
            
        case "j":
            println("接続確認情報取得!")
            for i in 0..<data.count/2 {
                let sid = data[2*i] as! Int
                let tim = data[2*i + 1] as! Int
                let label = サーボLabels[sid - 1]
                if tim < 80 {
                    label.backgroundColor = NSColor.greenColor()
                } else {
                    label.backgroundColor = NSColor.yellowColor()
                }
            }
            
        case "d":
            println("サーボ情報取得!")
            let sid = data[0] as! Int
            println("SID = \(sid)")
            var slice = data[1..<data.count]
            var info = ServoInfo()
            vsido.convertToServoInfo(Array(slice), servoInfoOut: &info)
            dump(info)
            
        default:
            println("返信コマンド = \(c) データ長 = \(data.count)")
        }
    }
    
    @IBAction func 繋ぐ(sender: AnyObject) {
        if vsido.openSerialPortProfile() {
            println("接続開始")
        } else {
            println("なんか失敗")
        }
    }
    
    @IBAction func 記録(sender: NSButton) {
        let cell = sender.selectedCell() as! NSButtonCell
        let valueSet = cell.tag
        println("記録\(valueSet)")
        let userDafeults = NSUserDefaults.standardUserDefaults()
        let key = "valueSet\(valueSet)"
        let a = サーボ群.map { (s: サーボ) -> Int in return s.値 }
        userDafeults.setObject(a, forKey: key)
    }
    
    @IBAction func 再生(sender: NSMatrix) {
        let cell = sender.selectedCell() as! NSButtonCell
        let valueSet = cell.tag
        println("再生\(valueSet)")
        まとめて再生中 = true
        var servoAngles = [ServoAngleSetReq]()
        let userDafeults = NSUserDefaults.standardUserDefaults()
        let cyc = userDafeults.objectForKey("cyc") as! Int
        let key = "valueSet\(valueSet)"
        if let a = userDafeults.objectForKey(key) as! [Int]? {
            for i in 0..<a.count {
                サーボ群[i].setValue(a[i], forKey: "値")
                let s = ServoAngleSetReq(sid: UInt8(サーボ群[i].番号), angle: Int16(サーボ群[i].値))
                servoAngles.append(s)
            }
        }
        vsido.vsido_o(CInt(cyc), servoAngles: servoAngles)
        まとめて再生中 = false
    }

    @IBAction func 接続確認要求(sender: AnyObject) {
        for label in サーボLabels {
            label.drawsBackground = true
            label.backgroundColor = NSColor.redColor()
        }
        vsido.vsido_j()
    }
    
    @IBAction func 加速度センサ値要求(sender: AnyObject) {
        vsido.vsido_a()
    }
    
    @IBAction func 電源電圧値(sender: AnyObject) {
        vsido.vsido_v()
    }
    
    @IBAction func フィードバックID設定(sender: AnyObject) {
        let req = FeedbackSetReq(sid: 1)
        vsido.vsido_f([req])
    }
    
    @IBAction func フィードバック要求(sender: AnyObject) {
        let req = FeedbackGetReq(dad: 1, dln: 2)
        vsido.vsido_r(req)
    }
    
    @IBAction func サーボ情報要求(sender: AnyObject) {
        //let req = ServoInfoGetReq(sid: 2, dad: 1, dln: 54)
        let req = ServoInfoGetReq(sid: 2, dad: 0, dln: 54)
        vsido.vsido_d([req])
    }

    @IBAction func オートバランサー設定(sender: AnyObject) {
        let req = VIDSetReq(vid: 12, vdt_uint8: 1) // VID_Barancer_Flag
        vsido.vsido_s([req])
    }

    @IBAction func 移動情報指定(sender: AnyObject) {
        let userDafeults = NSUserDefaults.standardUserDefaults()
        let 前後の速度 = userDafeults.objectForKey("前後の速度") as! Int + 100
        let 旋回速度 = userDafeults.objectForKey("旋回速度") as! Int + 100
        let req = WalkSetReq(wad: 0, wln: 2, wdt: [ 前後の速度, 旋回速度 ])
        vsido.vsido_t([req])
    }
    
    @IBAction func IK制御(sender: AnyObject) {
        performSegueWithIdentifier("IK制御", sender: sender)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if let dst = segue.destinationController as? IKViewController {
            dst.vsido = vsido
        }
    }
}

