// ---------------------------------------
// Sprite definitions for 'GameSpriteAtlas'
// Generated with TexturePacker 3.8.0
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class GameSpriteAtlas {

    // sprite names
    let PHYSICSBODYTEXTURE     = "PhysicsBodyTexture"
    let BGSTAR_BGSTARMOON_0001 = "bgstar/bgstarmoon_0001"
    let BGSTAR_BGSTARMOON_0002 = "bgstar/bgstarmoon_0002"
    let BGSTAR_BGSTARMOON_0003 = "bgstar/bgstarmoon_0003"
    let BGSTAR_BGSTARMOON_0004 = "bgstar/bgstarmoon_0004"
    let CLOSEBUTTON            = "closeButton"
    let ENEMY                  = "enemy"
    let FACE_1_FACE_1_001      = "face_1/face_1_001"
    let FACE_1_FACE_1_002      = "face_1/face_1_002"
    let FACE_1_FACE_1_003      = "face_1/face_1_003"
    let FACE_1_FACE_1_004      = "face_1/face_1_004"
    let FACE_1_FACE_1_005      = "face_1/face_1_005"
    let FACE_1_FACE_1_006      = "face_1/face_1_006"
    let FACE_1_FACE_1_007      = "face_1/face_1_007"
    let FACE_1_FACE_1_008      = "face_1/face_1_008"
    let FINGER_FINGER01        = "finger/finger01"
    let FINGER_FINGER02        = "finger/finger02"
    let TENTACLES_TENTACLES_1  = "tentacles/tentacles_1"
    let TENTACLES_TENTACLES_10 = "tentacles/tentacles_10"
    let TENTACLES_TENTACLES_2  = "tentacles/tentacles_2"
    let TENTACLES_TENTACLES_3  = "tentacles/tentacles_3"
    let TENTACLES_TENTACLES_4  = "tentacles/tentacles_4"
    let TENTACLES_TENTACLES_5  = "tentacles/tentacles_5"
    let TENTACLES_TENTACLES_6  = "tentacles/tentacles_6"
    let TENTACLES_TENTACLES_7  = "tentacles/tentacles_7"
    let TENTACLES_TENTACLES_8  = "tentacles/tentacles_8"
    let TENTACLES_TENTACLES_9  = "tentacles/tentacles_9"
    let YELLOWSTAR             = "yellowStar"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "GameSpriteAtlas")


    // individual texture objects
    func PhysicsBodyTexture() -> SKTexture     { return textureAtlas.textureNamed(PHYSICSBODYTEXTURE) }
    func bgstar_bgstarmoon_0001() -> SKTexture { return textureAtlas.textureNamed(BGSTAR_BGSTARMOON_0001) }
    func bgstar_bgstarmoon_0002() -> SKTexture { return textureAtlas.textureNamed(BGSTAR_BGSTARMOON_0002) }
    func bgstar_bgstarmoon_0003() -> SKTexture { return textureAtlas.textureNamed(BGSTAR_BGSTARMOON_0003) }
    func bgstar_bgstarmoon_0004() -> SKTexture { return textureAtlas.textureNamed(BGSTAR_BGSTARMOON_0004) }
    func closeButton() -> SKTexture            { return textureAtlas.textureNamed(CLOSEBUTTON) }
    func enemy() -> SKTexture                  { return textureAtlas.textureNamed(ENEMY) }
    func face_1_face_1_001() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_001) }
    func face_1_face_1_002() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_002) }
    func face_1_face_1_003() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_003) }
    func face_1_face_1_004() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_004) }
    func face_1_face_1_005() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_005) }
    func face_1_face_1_006() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_006) }
    func face_1_face_1_007() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_007) }
    func face_1_face_1_008() -> SKTexture      { return textureAtlas.textureNamed(FACE_1_FACE_1_008) }
    func finger_finger01() -> SKTexture        { return textureAtlas.textureNamed(FINGER_FINGER01) }
    func finger_finger02() -> SKTexture        { return textureAtlas.textureNamed(FINGER_FINGER02) }
    func tentacles_tentacles_1() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_1) }
    func tentacles_tentacles_10() -> SKTexture { return textureAtlas.textureNamed(TENTACLES_TENTACLES_10) }
    func tentacles_tentacles_2() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_2) }
    func tentacles_tentacles_3() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_3) }
    func tentacles_tentacles_4() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_4) }
    func tentacles_tentacles_5() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_5) }
    func tentacles_tentacles_6() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_6) }
    func tentacles_tentacles_7() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_7) }
    func tentacles_tentacles_8() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_8) }
    func tentacles_tentacles_9() -> SKTexture  { return textureAtlas.textureNamed(TENTACLES_TENTACLES_9) }
    func yellowStar() -> SKTexture             { return textureAtlas.textureNamed(YELLOWSTAR) }


    // texture arrays for animations
    func bgstar_bgstarmoon_() -> [SKTexture] {
        return [
            bgstar_bgstarmoon_0001(),
            bgstar_bgstarmoon_0002(),
            bgstar_bgstarmoon_0003(),
            bgstar_bgstarmoon_0004()
        ]
    }

    func face_1_face_1_() -> [SKTexture] {
        return [
            face_1_face_1_001(),
            face_1_face_1_002(),
            face_1_face_1_003(),
            face_1_face_1_004(),
            face_1_face_1_005(),
            face_1_face_1_006(),
            face_1_face_1_007(),
            face_1_face_1_008()
        ]
    }

    func finger_finger() -> [SKTexture] {
        return [
            finger_finger01(),
            finger_finger02()
        ]
    }

    func tentacles_tentacles_() -> [SKTexture] {
        return [
            tentacles_tentacles_1(),
            tentacles_tentacles_2(),
            tentacles_tentacles_3(),
            tentacles_tentacles_4(),
            tentacles_tentacles_5(),
            tentacles_tentacles_6(),
            tentacles_tentacles_7(),
            tentacles_tentacles_8(),
            tentacles_tentacles_9(),
            tentacles_tentacles_10()
        ]
    }


}
