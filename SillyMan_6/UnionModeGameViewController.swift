//
//  GameViewController.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit

class UnionModeGameViewController: UIViewController{
    
    var settingsView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 游戏开始后 改为显示
        
        let skView = self.view as! SKView
        let scene = UnionModeGameScene(size:skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
    }
    
    func hiddenSettingsButton() {
        
    }
    
    
    
    @IBAction func settingsAction(sender: UIButton) {
        
//        let view = ModalView.instantiateFromNib()
//        
//        let window = UIApplication.sharedApplication().delegate?.window
//        let modal = PathDynamicModal()
//        modal.showMagnitude = 200.0
//        modal.closeMagnitude = 130.0
//        view.closeButtonHandler = {[weak modal] in
//            modal?.closeWithLeansRandom()
//            return
//        }
//        view.bottomButtonHandler = {[weak modal] in
//            modal?.closeWithLeansRandom()
//            return
//        }
//        modal.show(modalView: view, inView: window!!)
    }
    
    func openSettingsUI() {
//        settingsView = UIView(frame: CGRectMake(100, 100, 300, 300))
//        settingsView?.backgroundColor = UIColor.whiteColor()
//        self.view.addSubview(settingsView!)
        
        
    }

    //MARK: GameCenter 游戏中心
    // 三大功能 1.成就 achievements, 2. 排行榜 leaderboards 3. 实时多人游戏  real-time multiplayer gaming
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("didReceiveMemoryWarning ->>>>>>>> ", appendNewline: false)
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
//    var smvc:SettingsViewController?
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "EmbedSettings" {
//            smvc = segue.destinationViewController as? SettingsViewController
//            //  do something
//        }
//    }
    
    
//    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        
//    }
}
