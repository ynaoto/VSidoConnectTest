//
//  IKViewController.swift
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/12.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//

import Cocoa

class IKViewController: NSViewController {
    
    var vsido: Vsido?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func 送信(sender: AnyObject) {
        var reqs: [IKSetReq!] = []
        for vc in childViewControllers {
            if let ikp = vc as? IKParamsViewController {
                println("\(ikp.名前) kid = \(ikp.kid) 有効=\(ikp.有効)")
                if ikp.有効 {
                    // IKF
                    let 現在値要求_位置: UInt8 = 0b00_001_000
                    let 現在値要求_姿勢: UInt8 = 0b00_010_000
                    let 現在値要求_トルク: UInt8 = 0b00_100_000
                    let 目標値設定_位置: UInt8 = 0b00_000_001
                    let 目標値設定_姿勢: UInt8 = 0b00_000_010
                    let 目標値設定_トルク: UInt8 = 0b00_000_100
                    
                    var ikf: UInt8 = 0
                    let kid = ikp.kid
                    var a: [NSNumber] = []
                    
                    if ikp.現在値要求_位置 {
                        ikf |= 現在値要求_位置
                    }
                    if ikp.現在値要求_姿勢 { // RCでは未サポート
                        ikf |= 現在値要求_姿勢
                    }
                    if ikp.現在値要求_トルク { // RCでは未サポート
                        ikf |= 現在値要求_トルク
                    }

                    if ikp.目標値設定_位置 {
                        ikf |= 目標値設定_位置
                        a.append(NSNumber(int: CInt(ikp.目標値設定_位置x) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_位置y) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_位置z) + 100))
                    }
                    if ikp.目標値設定_姿勢 { // RCでは未サポート
                        ikf |= 目標値設定_姿勢
                        a.append(NSNumber(int: CInt(ikp.目標値設定_姿勢x) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_姿勢y) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_姿勢z) + 100))
                    }
                    if ikp.目標値設定_トルク { // RCでは未サポート
                        ikf |= 目標値設定_トルク
                        a.append(NSNumber(int: CInt(ikp.目標値設定_トルクx) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_トルクy) + 100))
                        a.append(NSNumber(int: CInt(ikp.目標値設定_トルクz) + 100))
                    }

                    let req = IKSetReq(ikf: ikf, kid: kid, kdt: a)
                    reqs.append(req)
                }
            }
        }
        vsido?.vsido_k(reqs)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let KIDs = [ "体幹": 0, "頭部": 1, "右手": 2, "左手": 3, "右足": 4, "左足": 5 ]
        if let dst = segue.destinationController as? IKParamsViewController,
           let 名前 = segue.identifier,
           let kid = KIDs[名前] {
            dst.名前 = 名前
            dst.kid = UInt8(kid)
        }
    }
}
