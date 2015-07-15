/*
 * Copyright (c) 2013-2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

class AnimatingSprite : SKSpriteNode {
  
  enum SpriteDirection : Int {
    case Forward, Back, Left, Right
  }
  
  var facingForwardAnim : SKAction?
  var facingBackAnim : SKAction?
  var facingSideAnim : SKAction?
 
  // 1
  var facingDirection: SpriteDirection = .Forward {
    // 2
    didSet {
      // 3
      switch facingDirection {
        case .Forward:
          runAction(facingForwardAnim)
        case .Back:
          runAction(facingBackAnim)
        case .Left:
          runAction(facingSideAnim)
        case .Right:
          runAction(facingSideAnim)
      }
      // 4
      if facingDirection == .Right && xScale > 0 ||
        facingDirection != .Right && xScale < 0  {
        xScale *= -1
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    facingForwardAnim =
      aDecoder.decodeObjectForKey("AS-ForwardAnim") as? SKAction
    facingBackAnim =
      aDecoder.decodeObjectForKey("AS-BackAnim") as? SKAction
    facingSideAnim =
      aDecoder.decodeObjectForKey("AS-SideAnim") as? SKAction
    facingDirection =
      AnimatingSprite.SpriteDirection(rawValue: 
        aDecoder.decodeIntegerForKey("AS-Direction"))!
  }
  
  init(texture: SKTexture) {
    super.init(texture: texture, color: nil,
               size: texture.size())
  }
  
  override func encodeWithCoder(aCoder: NSCoder) {
    super.encodeWithCoder(aCoder)
    
    aCoder.encodeObject(facingForwardAnim!,
                        forKey: "AS-ForwardAnim")
    aCoder.encodeObject(facingBackAnim!,
                        forKey: "AS-BackAnim")
    aCoder.encodeObject(facingSideAnim!,
                        forKey: "AS-SideAnim")
    
    aCoder.encodeInteger(
      facingDirection.rawValue, forKey: "AS-Direction")
  }
  
  class func createAnimWithPrefix(prefix: String,
                                  suffix: String) -> SKAction {
    let atlas = SKTextureAtlas(named: "characters")
  
    let textures = [atlas.textureNamed("\(prefix)_\(suffix)1"),
                    atlas.textureNamed("\(prefix)_\(suffix)2")]
  
    textures[0].filteringMode = .Nearest
    textures[1].filteringMode = .Nearest
  
    return SKAction.repeatActionForever(
      SKAction.animateWithTextures(textures, timePerFrame:0.20))
  }
}
