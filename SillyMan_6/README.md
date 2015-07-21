# SKSimpleButton+

SKSimpleButton is a simple button implementation for `SpriteKit` which using `Swift`.

Based off of haruair's https://github.com/haruair/SKSimpleButton .
## Adding to Your Project

Manually add to your project:

1. Add `SKSimpleButton.swift` to your project.
2. Add https://github.com/ataugeron/SpriteKit-Spring to your project.

## Working with the Button

```swift
let normalTexture = SKTexture(imageNamed: "ball")
        
        let simpleButton = SKSimpleButton(normalTexture: normalTexture)
        simpleButton.addText(buttonText: "HOE", fontSize: nil, font: nil, fontColor: nil)
        
        simpleButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        simpleButton.targetTouchUpInside = self
        simpleButton.actionTouchUpInside = "actionMethod"
        
        self.addChild(simpleButton)
```

Easy as that.

