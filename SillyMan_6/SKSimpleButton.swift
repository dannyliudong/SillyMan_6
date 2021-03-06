import Foundation
import SpriteKit

class SKSimpleButton: SKSpriteNode {
    enum SKButtonActionType: Int {
        case TouchUpInside = 1
        case TouchDown = 2
        case TouchUp = 3
    }
    
    var defaultTexture: SKTexture
    var actionTouchUpInside: Selector?
    var actionTouchUp: Selector?
    var actionTouchDown: Selector?
    weak var targetTouchUpInside: AnyObject?
    weak var targetTouchUp: AnyObject?
    weak var targetTouchDown: AnyObject?
    
    var isEnabled: Bool = true
    var isSelected: Bool = false
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(normalTexture defaultTexture:SKTexture!) {
        
        self.defaultTexture = defaultTexture
        
        super.init(texture: defaultTexture, color: UIColor.whiteColor(), size: defaultTexture.size())
        
        userInteractionEnabled = true
    }
    
    func addText(buttonText text:NSString!, fontSize:CGFloat?, font:NSString?, fontColor:SKColor?)
    {
        let buttonText = text
        let textFontSize = fontSize
        let textFontColor = fontColor
        let textFont = font
        
        if buttonText != nil {
            let textNode = SKLabelNode(text: buttonText! as String)
            if textFontSize != nil {
                textNode.fontSize = textFontSize!
            }
            if textFont != nil {
                textNode.fontName = textFont! as String
            }
            if textFontColor != nil {
                textNode.fontColor = textFontColor!
            }
            textNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center;
            self.addChild(textNode)
        }

    }
    
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
        let touch: AnyObject! = touches.first
        let touchLocation = touch.locationInNode(parent)
        
        if (!isEnabled) {
            return
        }
        isSelected = true
        let scale = SKAction.scaleXTo(0.75, y: 0.75,
            duration: 0.2, delay: 0,
            usingSpringWithDamping: 0.05, initialSpringVelocity: 0)
        
        self.runAction(scale)
        
        if (targetTouchDown != nil && targetTouchDown!.respondsToSelector(actionTouchDown!)) {
            UIApplication.sharedApplication().sendAction(actionTouchDown!, to: targetTouchDown, from: self, forEvent: nil)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.locationInNode(parent)
        
        if (CGRectContainsPoint(frame, touchLocation)) {
            isSelected = true
            let scale = SKAction.scaleXTo(0.75, y: 0.75,
                duration: 0.2, delay: 0,
                usingSpringWithDamping: 0.05, initialSpringVelocity: 0)
            
            self.runAction(scale)
        } else {
            isSelected = false
            let scale = SKAction.scaleXTo(1.0, y: 1.0,
                duration: 0.2, delay: 0,
                usingSpringWithDamping: 0.05, initialSpringVelocity: 0)
            
            
            self.runAction(scale)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        let scale = SKAction.scaleXTo(1.0, y: 1.0,
            duration: 0.2, delay: 0,
            usingSpringWithDamping: 0.05, initialSpringVelocity: 0)
        
        self.runAction(scale)
        
        if (targetTouchUpInside != nil && targetTouchUpInside!.respondsToSelector(actionTouchUpInside!)) {
            let touch: AnyObject! = touches.first
            let touchLocation = touch.locationInNode(parent)
            
            if (CGRectContainsPoint(frame, touchLocation) ) {
                UIApplication.sharedApplication().sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, forEvent: nil)
            }
        }
        
        if (targetTouchUp != nil && targetTouchUp!.respondsToSelector(actionTouchUp!)) {
            UIApplication.sharedApplication().sendAction(actionTouchUp!, to: targetTouchUp, from: self, forEvent: nil)
        }
    }
}