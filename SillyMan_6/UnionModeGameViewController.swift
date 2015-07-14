//
//  GameViewController.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit
import SpriteKit

class UnionModeGameViewController: UIViewController, GamePlayDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad .........", appendNewline: false)
        // 游戏开始后 改为显示
        
        let skView = self.view as! SKView
        let scene = UnionModeGameScene(size:skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
        
        scene.gamePlaydelegate = self
        
    }
    
//    func continueGame() {
//        //  继续游戏
//        print("continueGame->>>", appendNewline: false)
//        
////        continueButton.removeFromSuperview()
////        tryAgainButton.removeFromSuperview()
////        goHomeButton.removeFromSuperview()
//        
//        let scene = (self.view as! SKView).scene!
//        scene.paused = false
//        
//    }
    

    
//    func tryAgainGame() {
//        // 重新创建游戏场景
//        print("tryAgainGame->>>", appendNewline: false)
//        
//        //continueButton.removeFromSuperview()
//        //tryAgainButton.removeFromSuperview()
//        //goHomeButton.removeFromSuperview()
//        
//        newGameScene()
//        
//    }
    
    func newGameScene() {
        print("newGameScene .........", appendNewline: false)
        let skView = self.view as! SKView
        //skView.paused = false
        
        let scene = UnionModeGameScene(size:skView.bounds.size)
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
        
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .AspectFill
        
        let outTr = SKTransition.fadeWithDuration(0.5)
        skView.presentScene(scene, transition: outTr)
        
        scene.gamePlaydelegate = self
    }
    
    
    //MARK: GameScene Delegate Method
    
    func gameGoHome() {
        print("gameGoHome 1111111111", appendNewline: false)
        newGameScene()
    }
    
    //MARK: GameCenter 游戏中心
    // 三大功能 1.成就 achievements, 2. 排行榜 leaderboards 3. 实时多人游戏  real-time multiplayer gaming
    
    
    //MARK:
    
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
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let ivc = segue.destinationViewController as? SettingsViewController {
//            if let identifier = segue.identifier {
//                
//            }
//        }
//    }
    
    
//    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
//        
//    }
}
