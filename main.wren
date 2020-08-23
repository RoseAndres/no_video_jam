import "graphics" for Canvas, Color
import "input" for Keyboard
import "audio" for AudioEngine
import "random" for Random
import "math" for M

class Game {
  static init() {
    setupConstants()
    AudioEngine.load("bing", "assets/sound effects/Bing.wav")
    AudioEngine.load("bing_back", "assets/sound effects/BackBing.wav")
    AudioEngine.load("bing_close", "assets/sound effects/CloseBing.wav")
  }

  static setupConstants() {
    __PLAYINGENTITIES = false
    __SOUNDCOOLDOWN = 0
    __R = Random.new()
    __LOCATIONDELAY = 15

    __ENTITIES = []
    createEntity(-20, 10)
    createEntity(-20, 20)
    createEntity(20, 20)
    createEntity(2, 10)
  }

  static createEntity() {
    __ENTITIES.add(
      {
        "pos": [1.0, 1.0]
      }
    )
  }

  static createEntity(x, y) {
    __ENTITIES.add(
      {
        "pos": [x * 1.0, y * 1.0]
      }
    )
  }

  static getAngleOfEntity(entity) {
    return M.atan( entity["pos"][1] / entity["pos"][0] )
  }

  static radToDeg(rad) {
    return rad * 180 / Num.pi
  }

  static distanceToEntity(entity) {
    return ( entity["pos"][0].pow(2) + entity["pos"][1].pow(2) ).sqrt
  }

  static panOfEntity(entity) {
    var pan = M.sin(getAngleOfEntity(entity))
    // shim until pan is fixed
    return pan < -0.5 ? -1.0 : pan > 0.5 ? 1.0 : pan
  }

  static update() {
    if (__SOUNDCOOLDOWN == 0 && !__PLAYINGENTITIES) {
      if (Keyboard.isKeyDown("SPACE")) {
        __SOUNDCOOLDOWN = 30
        __PLAYINGENTITIES = true
        __PLAYFRAME = 0
        __ENTITYINDEX = 0
      } 
    } else if (__SOUNDCOOLDOWN > 0) {
      __SOUNDCOOLDOWN = __SOUNDCOOLDOWN - 1
    }

    playEntityLocations()
  }

  static playEntityLocations() {
    if (__PLAYINGENTITIES) {
      if (__PLAYFRAME == 0) {
        if (__ENTITYINDEX < __ENTITIES.count) {
          playSound(__ENTITIES[__ENTITYINDEX])
          __ENTITYINDEX = __ENTITYINDEX + 1
          __PLAYFRAME = __LOCATIONDELAY
        } else {
          __PLAYINGENTITIES = false
          __ENTITYINDEX = 0
          __PLAYFRAME = 0
        }
      } else {
        __PLAYFRAME = __PLAYFRAME - 1
      }
    }
  }

  static playSound(entity) {
    // calculate pan and volume from sourcePos
    // 0.8 max vol for behind
    AudioEngine.play(
      entity["pos"][1] >= 0 ? "bing" : "bing_back", 
      calcVol(entity), 
      false, 
      panOfEntity(entity)
    )
  }

  static calcVol(entity) {
    var isFront = entity["pos"][1] >= 0
    var maxV = isFront ? 3.0 : 0.0
    var minV = isFront ? 0.2 : 0.1
    var maxD = isFront ? 20 : 18
    var minD = isFront ? 1.0 : 0.8
    var sound = isFront ? "bing" : "bing_back"
    var dist = distanceToEntity(entity)
    var result = 0

    if ( dist / maxD > 1 ) {
      result = minV
    } else if ( dist <= minD) {
      result = maxV
    } else {
      result = maxV * dist / maxD
    }

    return result
  }
  
  static draw(dt) {
    Canvas.cls()
    Canvas.print("PAN A: %(__PLAYFRAME))", 10, 10, Color.white)
    Canvas.print("PAN B: %(__ENTITYINDEX))", 10, 20, Color.white)
    Canvas.print("ENTITY ANGLE A: %(__PLAYINGENTITIES))", 10, 30, Color.white)
    Canvas.print("ENTITY ANGLE B: %(__SOUNDCOOLDOWN))", 10, 40, Color.white)
  }
}
