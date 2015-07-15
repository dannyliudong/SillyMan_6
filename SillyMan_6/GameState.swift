//
//  AppDelegate.swift
//  TinyWings
//
//  Created by liudong on 15/5/26.
//  Copyright (c) 2015年 liudong. All rights reserved.
//

import Foundation

class GameState {
    
    var movingScore: Int
    var highScore: Int
    var stars: Int
    
    
    // 用户设置的状态
    var musicState: Bool // 游戏场景背景音乐开关
    //var soundEffectState: Bool // 音效开关
    //var iCloudState: Bool // iCloud 开关
    
    class var sharedInstance :GameState {
        struct Singleton {
            static let instance = GameState()
        }
        
        return Singleton.instance
    }
    
    init() {
        // Init
        
        print("GameState Init ..........")
        
        movingScore = 0
        highScore = 0
        stars = 0
        
        
        // 用户设置数据
        
        // Load game state
        let defaults = NSUserDefaults.standardUserDefaults()
        
        musicState = defaults.boolForKey("musicState")
        //iCloudState = defaults.boolForKey("iCloudState")
        
        //movingScore = defaults.integerForKey("movingScore")
        highScore = defaults.integerForKey("highScore")
        stars = defaults.integerForKey("stars")
        
    }
    
    func saveState() {
        // Update highScore if the current score is greater
        highScore = max(movingScore, highScore)
        
        // Store in user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(movingScore, forKey: "movingScore")
        defaults.setInteger(highScore, forKey: "highScore")
        defaults.setInteger(stars, forKey: "stars")
        
        // 保存设置状态
        defaults.setBool(musicState, forKey: "musicState")
        //defaults.setBool(iCloudState, forKey: "iCloudState")
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
