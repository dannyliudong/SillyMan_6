//
//  SKSimpleButton.swift
//  SpriteKitButton
//


import Foundation
import SpriteKit

class LDSKSimpleButton: SKSpriteNode {
    enum SKButtonActionType: Int {
        case TouchUpInside = 1
        case TouchDown = 2
        case TouchUp = 3
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var disabledTexture: SKTexture?
    
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    // MARK: Create button with textures
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        
        
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        
        super.init(texture: defaultTexture, color: UIColor.whiteColor(), size: defaultTexture.size())
        
        userInteractionEnabled = true
        
        // Adding this node as an empty layer. Without it the touch functions are not being called
        // The reason for this is unknown when this was implemented...?
        
        //let bugFixLayerNode = SKSpriteNode(texture: nil, size: defaultTexture.size())
        
        //bugFixLayerNode.position = self.position
        //addChild(bugFixLayerNode)
    }
    
    // MARK: Create button with SKSprite
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        
        self.defaultTexture = texture!
        self.selectedTexture = texture!
        self.disabledTexture = texture
        
        super.init(texture: texture, color: color, size: size)
        
        userInteractionEnabled = true
    }

    
    /**
    * Taking a target object and adding an action that is triggered by a button event.
    */
    func setButtonAction(target: AnyObject, triggerEvent event:SKButtonActionType, action:Selector) {
        switch (event) {
        case .TouchUpInside:
            targetTouchUpInside = target
            actionTouchUpInside = action
        case .TouchDown:
            targetTouchDown = target
            actionTouchDown = action
        case .TouchUp:
            targetTouchUp = target
            actionTouchUp = action
        }
    }
    
    // MARK: Touch Gesture
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.setScale(0.8)
        
        let touch: AnyObject! = touches.first
        _ = touch.locationInNode(parent!)
        
        if (!isEnabled) {
            return
        }
        isSelected = true
        if (targetTouchDown != nil && targetTouchDown!.respondsToSelector(actionTouchDown!)) {
            UIApplication.sharedApplication().sendAction(actionTouchDown!, to: targetTouchDown, from: self, forEvent: nil)
        }
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.locationInNode(parent!)
        
        if (CGRectContainsPoint(frame, touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        self.setScale(1)
        
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.respondsToSelector(actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.locationInNode(parent!)
            
            if (CGRectContainsPoint(frame, touchLocation) ) {
                UIApplication.sharedApplication().sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, forEvent: nil)
            }
        }
        
        if (targetTouchUp != nil && targetTouchUp!.respondsToSelector(actionTouchUp!)) {
            UIApplication.sharedApplication().sendAction(actionTouchUp!, to: targetTouchUp, from: self, forEvent: nil)
        }
    }
    
 
}