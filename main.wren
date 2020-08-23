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
    __VOL = 0

    __ENTITIES = []
    createEntity(0, 10)
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
        "pos": {
          "x": x * 1.0, 
          "y": y * 1.0
        }
      }
    )
  }

  static turn(leftOrRight) {
    var polar = {}
    for (entity in __ENTITIES) {
      polar = cartToPol( entity["pos"] )

      polar["theta"] = polar["theta"] + ( leftOrRight ? degToRad(3) : degToRad(-3) )

      entity["pos"] = polToCart(polar)
    }
  }

  static move(forwardOrBack) {
    for (entity in __ENTITIES) {
      entity["pos"]["y"] = entity["pos"]["y"] + ( forwardOrBack ? 0.4 : -0.3 )
    }
  }

  static cartToPol(cart) {
    return { 
      "radius": dist(cart), 
      "theta": theta(cart) 
    }
  }

  static polToCart(pol) {
    return { 
      "x": pol["radius"] * M.cos( pol["theta"] ), 
      "y": pol["radius"] * M.sin( pol["theta"] ) 
    }
  }

  static dist(pos) {
    return ( pos["x"].pow(2) + pos["y"].pow(2) ).sqrt
  }

  static theta(pos) {
    // add quad offset because calculators are weird
    // https://www.mathsisfun.com/polar-cartesian-coordinates.html
    return M.atan( pos["y"] / pos["x"] ) + getQuadOffset(pos)
  }

  static getQuadOffset(pos) {
    if ( pos["x"] >= 0 ) {
      if ( pos["y"] >= 0 ) {
        return 0
      } else {
        return degToRad(360)
      }
    } else {
      return degToRad(180)
    }
  }

  static radToDeg(rad) {
    return rad * 180 / Num.pi
  }

  static degToRad(deg) {
    return deg * Num.pi / 180
  }

  static panOfEntity(entity) {
    var pan = M.cos( theta( entity["pos"] ) )
    // shim until pan is fixed
    return pan < -0.5 ? -1.0 : pan > 0.5 ? 1.0 : pan
  }

  static update() {
    playSounds()
    buttonInputs()
  }

  static buttonInputs() {
    if ( Keyboard.isKeyDown("W") ) {
      move(true)
    } else if ( Keyboard.isKeyDown("S") ) {
      move(false)
    }

    if ( Keyboard.isKeyDown("A") ) {
      turn( true )
    } else if ( Keyboard.isKeyDown("D") ) {
      turn( false )
    }
  }

  static playSounds() {
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
      entity["pos"]["y"] <= 0 ? "bing" : "bing_back", 
      calcVol(entity), 
      false, 
      panOfEntity(entity)
    )
  }

  static calcVol(entity) {
    var isFront = entity["pos"]["y"] <= 0
    var maxV = 1.0
    var minV = 0.1
    var maxD = 20
    var minD = 1
    var dist = dist( entity["pos"] )
    var result = 0

    if ( dist / maxD > 1 ) {
      result = minV
    } else if ( dist <= minD) {
      result = maxV
    } else {
      result = maxV * dist / maxD
    }

    __VOL = result
    return result
  }
  
  static draw(dt) {
    Canvas.cls()
    Canvas.print( "VOL: %(__VOL)", 10, 10, Color.white )
    Canvas.print( "IN FRONT: %(__ENTITIES[0]["pos"]["y"] <= 0)", 10, 20, Color.white )

    Canvas.circle(Canvas.width / 2, Canvas.height / 2, 5, Color.green)
    Canvas.circle((Canvas.width / 2) + __ENTITIES[0]["pos"]["x"] * 2, (Canvas.height / 2) + __ENTITIES[0]["pos"]["y"] * 2, 5, Color.blue)
  }
}
