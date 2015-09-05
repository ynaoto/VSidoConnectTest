//
//  IKParamsViewController.swift
//  VsidoTest3
//
//  Created by Naoto Yoshioka on 2015/04/12.
//  Copyright (c) 2015年 Naoto Yoshioka. All rights reserved.
//

import Cocoa

class IKParamsViewController: NSViewController {

    @IBOutlet weak var 有効チェック: NSButton!
    var 名前: String!
    var kid: UInt8!
    
    var 有効: Bool = false
    var 目標値設定_位置x: Int8 = 0
    var 目標値設定_位置y: Int8 = 0
    var 目標値設定_位置z: Int8 = 0
    var 目標値設定_姿勢x: Int8 = 0
    var 目標値設定_姿勢y: Int8 = 0
    var 目標値設定_姿勢z: Int8 = 0
    var 目標値設定_トルクx: Int8 = 0
    var 目標値設定_トルクy: Int8 = 0
    var 目標値設定_トルクz: Int8 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        var topLevelObjects: NSArray?
        let result = NSBundle.mainBundle().loadNibNamed("IKParamsViewController", owner: self, topLevelObjects: &topLevelObjects)
        assert(result, "could not load XIB file")
        for obj in topLevelObjects! as Array {
            if let view = obj as? NSView {
                self.view.addSubview(view)
            }
        }
        有効チェック.title = 名前
    }
    
}
