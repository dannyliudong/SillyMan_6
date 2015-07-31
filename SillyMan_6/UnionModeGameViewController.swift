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
    
    
//    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        
//    }
}
