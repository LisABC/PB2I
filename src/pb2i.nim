import xmltree

const
    EXOS* = "0"
    HERO* = "1"
    NOIR_LIME* = "2"
    PROXY* = "3"
    CIVIL_SECURITY* = "4"

type 
    PBVar* = distinct string

    BaseMapObject* = ref object of RootObj
        x*, y*: int

    BaseNamedMapObject* = ref object of BaseMapObject
        name*: string

    # Trigger
    Action* = ref object
        opID*: int
        args*: seq[string]

    Trigger* = ref object of BaseNamedMapObject
        enabled*: bool
        maxCalls*: int
        actions*: seq[Action]
    
    # Timer
    Timer* = ref object of BaseNamedMapObject
        enabled*: bool
        callback*: Trigger
        delay*, maxCalls*: int
    
    # Movable
    Movable* = ref object of BaseNamedMapObject
        w*, h*, speed*, tarx*, tary*: int
        visible*, moving*: bool
        attachTo*: Movable

    # Region
    RegionActivation* = enum
        NOTHING = -1,
        BUTTON = 1,
        BY_CHAR_NOT_IN_VEHICLE,
        BY_CHAR_IN_VEHICLE,
        BY_CHAR,
        BY_MOVABLE,
        BY_PLAYER,
        BY_ALL_HERO,
        INVISIBLE_BUTTON,
        RED_BUTTON,
        BLUE_BUTTON,
        INVISIBLE_RED_BUTTON,
        INVISIBLE_BLUE_BUTTON,
        BY_RED_PLAYER,
        BY_BLUE_PLAYER,
        INVISIBLE_BUTTON_WITHOUT_SOUND


    Region* = ref object of BaseNamedMapObject
        w*, h*: int
        actTrigger*: Trigger
        actOn*: RegionActivation
        attachTo*: Movable
    
    # Wall.
    Box* = ref object of BaseMapObject
        w*, h*, material*: int
    
    # Water.
    Water* = ref object of BaseMapObject
        w*, h*, damage*: int
        friction*: bool
    
    # Decor.
    Decoration* = ref object of BaseNamedMapObject
        model*: string
        layer*: int
        texX*, texY*: int
        rotation*: int
        scaleX*, scaleY*: int
        attachTo*: Movable
    
    # Player & Enemy.
    Character* = ref object of BaseNamedMapObject
        isPlayer*: bool # We need to know if we should output player or normal enemy.
        tox*, toy*: int
        hea*, hmax*: int
        team*: int
        side*, skin*, incar*: int
        botAction*: int
        onDeath*: Trigger
    
    Song* = ref object of BaseNamedMapObject
        url*: string
        volume*: int
        loop*: bool
        onEnd*: Trigger
    
    EngineMark* = ref object of BaseMapObject
        modifier*, parameter*: string
    
    Lamp* = ref object of BaseNamedMapObject
        power*: float
        hasFlare*: bool
    
    Barrel* = ref object of BaseNamedMapObject
        model*: string
        tox*, toy*: int
    
    Weapon* = ref object of BaseNamedMapObject
        model*: string
        team*, level*: int
    
    Map* = ref object
        # Addressable objects. (Ones inheriting BaseNamedMapObject)
        triggers: seq[Trigger]
        timers: seq[Timer]
        characters: seq[Character]
        movables: seq[Movable]
        decorations: seq[Decoration]
        regions: seq[Region]
        songs: seq[Song]
        lamps: seq[Lamp]
        barrels: seq[Barrel]
        weapons: seq[Weapon]

        # Unaddressable objects.
        waters: seq[Water]
        boxes: seq[Box]
        engineMarks: seq[EngineMark]


# Others
proc `$`*(pbvar: PBVar): string {.borrow.}

# Dumping
proc dump*(movable: Movable): string =
    var attachTo = "-1"
    if not movable.attachTo.isNil:
        attachTo = movable.attachTo.name

    return $(<>door(
        uid = movable.name,
        vis = $movable.visible,
        x = $movable.x,
        y = $movable.y,
        w = $movable.w,
        h = $movable.h,
        moving = $movable.moving,
        tarx = $movable.tarx,
        tary = $movable.tary,
        attach = attachTo,
        maxspeed = $movable.speed
    ))

proc dump*(region: Region): string =
    var attachTo = "-1"
    if not region.attachTo.isNil:
        attachTo = region.attachTo.name
    var useTarget = "-1"
    if not region.actTrigger.isNil:
        useTarget = region.actTrigger.name

    
    return $(<>region(
        uid = region.name,
        x = $region.x,
        y = $region.y,
        w = $region.w,
        h = $region.h,
        use_target = useTarget,
        use_on = $region.actOn.ord,
        attach = attachTo
    ))

proc dump*(timer: Timer): string =
    var callback = "-1"
    if not timer.callback.isNil:
        callback = timer.callback.name
    
    return $(<>timer(
        uid = timer.name,
        x = $timer.x,
        y = $timer.y,
        enabled = $timer.enabled,
        maxcalls = $timer.maxCalls,
        target = callback,
        delay = $timer.delay
    ))

proc dump*(box: Box): string =
    return $(<>box(
        x = $box.x,
        y = $box.y,
        w = $box.w,
        h = $box.h,
        m = $box.material
    ))

proc dump*(water: Water): string =
    return $(<>water(
        x = $water.x,
        y = $water.y,
        w = $water.w,
        h = $water.h,
        damage = $water.damage,
        friction = $water.friction
    ))

proc dump*(decor: Decoration): string =
    var attachTo = "-1"
    if not decor.attachTo.isNil:
        attachTo = decor.attachTo.name
    return $(<>decor(
        uid = decor.name,
        x = $decor.x,
        y = $decor.y,
        u = $decor.texX,
        v = $decor.texY,
        r = $decor.rotation,
        sx = $decor.scaleX,
        sy = $decor.scaleY,
        f = $decor.layer,
        model = decor.model,
        attach = attachTo
    ))

proc dump*(character: Character): string =
    var onDeath = "-1"
    if not character.onDeath.isNil:
        onDeath = character.onDeath.name
    var a = <>player(
        uid = character.name,
        x = $character.x,
        y = $character.y,
        tox = $character.tox,
        toy = $character.toy,
        hea = $character.hea,
        hmax = $character.hmax,
        team = $character.team,
        side = $character.side,
        incar = $character.incar,
        botaction = $character.botAction,
        ondeath = ondeath,
        char = $character.skin
    )
    if not character.isPlayer:
        a.tag = "enemy"
    return $a

proc dump*(song: Song): string =
    var callback = "-1"
    if not song.onEnd.isNil:
        callback = song.onEnd.name
    result = $(<>song(
        uid = song.name,
        x = $song.x,
        y = $song.y,
        volume = $song.volume,
        url = song.url,
        loop = $song.loop,
        callback = callback
    ))

proc dump*(engineMark: EngineMark): string =
    result = $(<>inf(
        x = $engineMark.x,
        y = $engineMark.y,
        mark = engineMark.modifier,
        forteam = engineMark.parameter
    ))

proc dump*(lamp: Lamp): string =
    result = $(<>lamp(
        uid = lamp.name,
        x = $lamp.x,
        y = $lamp.y,
        power = $lamp.power,
        flare = $lamp.hasFlare
    ))

proc dump*(barrel: Barrel): string =
    result = $(<>barrel(
        uid = barrel.name,
        x = $barrel.x,
        y = $barrel.y,
        tox = $barrel.tox,
        toy = $barrel.toy,
        model = barrel.model
    ))

proc dump*(weapon: Weapon): string =
    result = $(<>gun(
        uid = weapon.name,
        x = $weapon.x,
        y = $weapon.y,
        model = weapon.name,
        upg = $weapon.level,
        command = $weapon.team
    ))

# Constructors.
proc newMap*(): Map =
    return Map()

proc newMovable*(map: Map, name: string, x, y, w, h, tarx, tary = 0, speed = 10, visible = true, moving = false, attachTo: Movable = nil): Movable =
    result = Movable(
        name: name,
        x: x, y: y, w: w, h: h, tarx: tarx, tary: tary,
        speed: speed,
        visible: visible,
        attachTo: attachTo,
        moving: moving
    )
    map.movables.add(result)

proc newRegion*(map: Map, name: string, x, y, w, h = 0, actTrigger: Trigger = nil, actOn = NOTHING, attachTo: Movable = nil): Region =
    result = Region(
        name: name,
        x: x, y: y, w: w, h: h,
        actTrigger: actTrigger,
        actOn: actOn,
        attachTo: attachTo
    )
    map.regions.add(result)

proc newTimer*(map: Map, name: string, x, y = 0, enabled = true, callback: Trigger = nil, maxCalls = 1, delay = 30): Timer =
    result = Timer(
        name: name,
        x: x, y: y,
        enabled: enabled,
        callback: callback,
        delay: delay,
        maxCalls: maxCalls
    )
    map.timers.add(result)

proc newTrigger*(map: Map, name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[]): Trigger =
    result = Trigger(
        name: name,
        x: x, y: y,
        enabled: enabled,
        maxCalls: maxCalls,
        actions: actions
    )
    map.triggers.add(result)

proc newBox*(map: Map, x, y, w, h, material = 0): Box =
    result = Box(
        x:x, y:y, w:w, h:h, 
        material: material
    )
    map.boxes.add(result)

proc newWater*(map: Map, x, y, w, h, damage = 0, friction = true): Water =
    result = Water(
        x: x, y: y, w: w, h: h,
        damage: damage,
        friction: friction
    )
    map.waters.add(result)

proc newDecoration*(map: Map, name: string, x, y, texX, texY, rotation, layer = 0, scaleX, scaleY = 1, model = "stone", attachTo: Movable = nil): Decoration =
    result = Decoration(
        name: name,
        x: x, y: y,
        texX: texX, texY: texY,
        rotation: rotation, layer: layer,
        scaleX: scaleX, scaleY: scaleY,
        model: model,
        attachTo: attachTo
    )
    map.decorations.add(result)

proc newCharacter*(map: Map, name: string, x, y, tox, toy = 0, hea, hmax = 130, team = 0, side = 1, skin = -1, incar = -1, botAction = 4, onDeath: Trigger = nil, isPlayer = true): Character =
    result = Character(
        name: name,
        x: x, y: y, tox: tox, toy: toy,
        hea: hea, hmax: hmax,
        team: team, side: side,
        skin: skin, incar: incar, botAction: botAction,
        onDeath: onDeath,
        isPlayer: isPlayer
    )
    map.characters.add(result)

proc newSong*(map: Map, name: string, x, y = 0, url = "", volume = 1, loop = true, onEnd: Trigger = nil): Song =
    result = Song(
        name: name,
        x: x, y:y,
        url: url,
        loop: loop,
        onEnd: onEnd,
        volume: volume
    )
    map.songs.add(result)

proc newEngineMark*(map: Map, x, y = 0, modifier = "hero1_guns", parameter = "0"): EngineMark =
    result = EngineMark(
        x: x, y: y,
        modifier: modifier,
        parameter: parameter
    )
    map.engineMarks.add(result)

proc newLamp*(map: Map, name: string, x, y = 0, power = 0.4, hasFlare = true): Lamp =
    result = Lamp(
        name: name,
        x: x, y: y,
        power: power, hasFlare: hasFlare
    )
    map.lamps.add(result)

proc newBarrel*(map: Map, name: string, x, y, tox, toy = 0, model = "bar_orange"): Barrel =
    result = Barrel(
        name: name,
        x: x, y: y,
        tox: tox, toy: toy,
        model: model
    )
    map.barrels.add(result)

proc newWeapon*(map: Map, name: string, x, y, level = 0, team = -1, model = "gun_rifle"): Weapon =
    result = Weapon(
        name: name,
        x: x, y: y,
        team: team, level: level,
        model: model
    )
    map.weapons.add(result)

# Trigger.
proc addAction*(trigger: Trigger, action: Action) {.inline.} =
    trigger.actions.add(action)
proc addAction*(trigger: Trigger, opID: int, args: seq[string]): Action {.discardable.} =
    result = Action(opID: opID, args: args)
    trigger.actions.add(result)


proc move*(trigger: Trigger, mov: Movable, reg: Region): Action {.discardable.} =
    # Move movable 'A' to region 'B'
    trigger.addAction(0, @[mov.name, reg.name])
proc move*(trigger: Trigger, reg1, reg2: Region): Action {.discardable.} =
    # Move region 'A' to region 'B'
    trigger.addAction(2, @[reg1.name, reg2.name])


proc changeSpeed*(trigger: Trigger, mov: Movable, value: int): Action {.discardable.} =
    # Change movable 'A' speed to value 'B'
    trigger.addAction(1, @[mov.name, $value])


proc setVariable*(trigger: Trigger, pbvar: PBVar, value: string): Action {.discardable.} =
    # Set variable 'A' to value 'B'
    trigger.addAction(100, @[$pbvar, value])
proc setVariableIfUndefined*(trigger: Trigger, pbvar1: PBVar, value: string): Action {.discardable.} =
    # Set variable 'A' to value 'B' if variable 'A' is not defined
    trigger.addAction(101, @[$pbvar1, value])
proc setVariable*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    # Set variable 'A' to value of variable 'B'
    trigger.addAction(125, @[$pbvar1, $pbvar2])


proc generateFloatNumber*(trigger: Trigger, pbvar: PBVar, value: int): Action {.discardable.} =
    # Set variable 'A' to random floating number in range 0..B
    trigger.addAction(106, @[$pbvar, $value])
proc generateFloatNumber*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    # Set variable 'A' to random floating number in range 0..X where X is variable
    trigger.addAction(327, @[$pbvar1, $pbvar2])

proc generateIntNumber*(trigger: Trigger, pbvar: PBVar, value: int): Action {.discardable.} =
    # Set variable 'A' to random integer number in range 0..B-1
    trigger.addAction(107, @[$pbvar, $value])
proc generateIntNumber*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    # Set variable 'A' to random integer number in range 0..X-1 where X is variable
    trigger.addAction(328, @[$pbvar1, $pbvar2])


proc sendChatMessage*(trigger: Trigger, who = EXOS, texts: varargs[string, `$`]): Action {.discardable.} =
    # Show text 'A' in chat with color 'B'
    var text = ""
    for stuff in texts:
        text.add stuff
    trigger.addAction(42, @[text, who])