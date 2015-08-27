//
//  SettingsViewController.swift
//  SillyMan_6
//
//  Created by liudong on 15/8/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let switchOn = GameState.sharedInstance.musicState
        if !switchOn {
            musicButton.setBackgroundImage(UIImage(named: "button_sound_off"), forState: UIControlState.Normal)
            
        } else if switchOn {
            musicButton.setBackgroundImage(UIImage(named: "button_sound"), forState: UIControlState.Normal)
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeSettings(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    @IBAction func languageAction(sender: UIButton) {
        
    }
    
    @IBAction func musicAction(sender: UIButton) {
        
        let switchOn = GameState.sharedInstance.musicState
        // 根据开关 决定暂停音乐 还是恢复音乐播放
        if !switchOn {
            print("MUSIC_ON 恢复音乐播放")
            
            musicButton.setBackgroundImage(UIImage(named: "button_sound"), forState: UIControlState.Normal)
            
            SKTAudio.sharedInstance().resumeBackgroundMusic() // 恢复音乐播放
            GameState.sharedInstance.musicState = true
            GameState.sharedInstance.saveState()
            
        } else if switchOn {
            print("MUSIC_OFF 暂停音乐播放")
            musicButton.setBackgroundImage(UIImage(named: "button_sound_off"), forState: UIControlState.Normal)
            
            SKTAudio.sharedInstance().pauseBackgroundMusic() // 暂停音乐播放
            GameState.sharedInstance.musicState = false
            GameState.sharedInstance.saveState()
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
