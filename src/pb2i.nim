import std/xmltree
import std/strtabs

{.push warning[ImplicitDefaultValue]: off.}

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
        implicitSplitting*: bool
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
    Water* = ref object of BaseNamedMapObject
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
    
    Vehicle* = ref object of BaseNamedMapObject
        side*, tox*, toy*, hpPercent*: int
        model*: string

    # Player & Enemy.
    Character* = ref object of BaseNamedMapObject
        isPlayer*: bool # We need to know if we should output player or normal enemy.
        tox*, toy*: int
        hea*, hmax*: int
        team*: int
        side*, skin*: int
        botAction*: int
        onDeath*: Trigger
        incar*: Vehicle
    
    Song* = ref object of BaseNamedMapObject
        url*: string
        volume*: int
        loop*: bool
        onEnd*: Trigger
    
    # Engine mark.
    EngineMarks* = enum
        CHANGE_SKY = "sky"
        SHADOW_MAP_SIZE = "shadowmap_size"
        CASUAL_MODE = "casual"
        NO_BASE_NOISE = "nobase"
        ALT_GAME = "game2"
        STRICT_CASUAL_MODE = "strict_casual"
        NO_AUTO_REVIVE = "no_auto_revive"
        FORCE_RAGDOLL_DISAPPEARMENT = "meat"
        MARINE_WEAPONS = "hero1_guns"
        PROXY_WEAPONS = "hero2_guns"
        PROXY_WEAPONS_NO_NADE = "hero2_guns_nonades"
        PROXY_WEAPONS_ONLY_NADES = "hero2_guns_nades"
        NO_PSI = "nopsi"
        GAME_SCALE = "gamescale"
        HE_NADES_COUNT = "he_nades_count"
        PORT_NADES_COUNT = "port_nades_count"
        SH_NADES_COUNT = "sh_nades_count"
        SNOW = "snow"
        WATER_COLOR = "watercolor"
        ACID_COLOR = "acidcolor"
        WATER_TITLE = "watertitle"
        ACIDT_ITLE = "acidtitle"
        SLOTS_ON_SPAWN = "dm_slots_on_spawn"
        MAX_GUNS_ON_SPAWN = "dm_max_guns_on_spawn"
        TRIGGER_ERROR_REPORTING = "level_errors"
        VAR_SYNC_ACTIONS = "var_sync"
        NO_LIGHT_BREAK = "no_light_break"
        NAIVE_HIT_CONFIRMATION = "naive_hit_confirmation"

    EngineMark* = ref object of BaseMapObject
        modifier*: EngineMarks
        parameter*: string
    
    Lamp* = ref object of BaseNamedMapObject
        power*: float
        hasFlare*: bool
    
    Barrel* = ref object of BaseNamedMapObject
        model*: string
        tox*, toy*: int
    
    Weapon* = ref object of BaseNamedMapObject
        model*: string
        team*, level*: int
    
    Pusher* = ref object of BaseNamedMapObject
        w*, h*, tox*, toy*, stabilityDamage*, damage*: int
        attachTo*: Movable
    
    Background* = ref object of BaseMapObject
        w*, h*, texX*, texY*, layer*: int
        showShadow*: bool
        hexMultiplier*, material*: string
        attachTo*: Movable
    
    Map* = ref object ## Object that holds everything.
        # Addressable objects. (Ones inheriting BaseNamedMapObject)
        triggers*: seq[Trigger]
        timers*: seq[Timer]
        characters*: seq[Character]
        movables*: seq[Movable]
        decorations*: seq[Decoration]
        regions*: seq[Region]
        songs*: seq[Song]
        lamps*: seq[Lamp]
        barrels*: seq[Barrel]
        weapons*: seq[Weapon]
        pushers*: seq[Pusher]
        vehicles*: seq[Vehicle]
        waters*: seq[Water]

        # Unaddressable objects.
        boxes*: seq[Box]
        engineMarks*: seq[EngineMark]
        backgrounds*: seq[Background]


# Others
let DO_NOTHING = Action(opID: -1, args: @[])
proc `$`*(pbvar: PBVar): string {.borrow.} ## Gives name of `pbvar`.

# Dumping
proc dump*(movable: Movable): string =
    ## Dumps movable.
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
    ## Dumps region.
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
    ## Dumps timer.
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
    ## Dumps wall.
    return $(<>box(
        x = $box.x,
        y = $box.y,
        w = $box.w,
        h = $box.h,
        m = $box.material
    ))

proc dump*(water: Water): string =
    ## Dumps water.
    return $(<>water(
        uid = water.name,
        x = $water.x,
        y = $water.y,
        w = $water.w,
        h = $water.h,
        damage = $water.damage,
        friction = $water.friction
    ))

proc dump*(decor: Decoration): string =
    ## Dumps decoration.
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
    ## Dumps character.
    var onDeath = "-1"
    if not character.onDeath.isNil:
        onDeath = character.onDeath.name
    var incar = "-1"
    if not character.incar.isNil:
        incar = character.incar.name
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
        incar = incar,
        botaction = $character.botAction,
        ondeath = ondeath,
        char = $character.skin
    )
    if not character.isPlayer:
        a.tag = "enemy"
    return $a

proc dump*(song: Song): string =
    ## Dumps song.
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
    ## Dumps engine mark.
    result = $(<>inf(
        x = $engineMark.x,
        y = $engineMark.y,
        mark = $engineMark.modifier,
        forteam = engineMark.parameter
    ))

proc dump*(lamp: Lamp): string =
    ## Dumps lamp.
    result = $(<>lamp(
        uid = lamp.name,
        x = $lamp.x,
        y = $lamp.y,
        power = $lamp.power,
        flare = $lamp.hasFlare
    ))

proc dump*(barrel: Barrel): string =
    ## Dumps barrel.
    result = $(<>barrel(
        uid = barrel.name,
        x = $barrel.x,
        y = $barrel.y,
        tox = $barrel.tox,
        toy = $barrel.toy,
        model = barrel.model
    ))

proc dump*(weapon: Weapon): string =
    ## Dumps weapon.
    result = $(<>gun(
        uid = weapon.name,
        x = $weapon.x,
        y = $weapon.y,
        model = weapon.model,
        upg = $weapon.level,
        command = $weapon.team
    ))

proc dump*(pusher: Pusher): string =
    ## Dumps pusher.
    var attachTo = "-1"
    if not pusher.attachTo.isNil:
        attachTo = pusher.attachTo.name
    result = $(<>pushf(
        uid = pusher.name,
        x = $pusher.x,
        y = $pusher.y,
        w = $pusher.w,
        h = $pusher.h,
        tox = $pusher.tox,
        toy = $pusher.toy,
        stab = $pusher.stabilityDamage,
        damage = $pusher.damage,
        attach = attachTo
    ))

proc dump*(bg: Background): string =
    ## Dumps background.
    var attachTo = "-1"
    if not bg.attachTo.isNil:
        attachTo = bg.attachTo.name
    result = $(<>bg(
        x = $bg.x,
        y = $bg.y,
        w = $bg.w,
        h = $bg.h,
        c = bg.hexMultiplier,
        m = bg.material,
        u = $bg.texX,
        v = $bg.texY,
        f = $bg.layer,
        a = attachTo,
        s = $bg.showShadow
    ))

proc dump*(vehicle: Vehicle): string =
    ## Dumps vehicle.
    result = $(<>vehicle(
        uid = vehicle.name,
        x = $vehicle.x,
        y = $vehicle.y,
        tox = $vehicle.tox,
        toy = $vehicle.toy,
        side = $vehicle.side,
        hpp = $vehicle.hpPercent
    ))

proc chunk(actions: seq[Action]): seq[seq[Action]] =
    for i in 0..<(actions.len div 9):
        result.add(actions[i*9..<i*9+9])
    result.add(actions[^(actions.len mod 9)..<actions.len])

proc switchExecution*(trigger: Trigger, target: Trigger): Action {.discardable.}
proc newTrigger*(name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[], implicitSplitting = true): Trigger

proc dump*(trigger: Trigger): string =
    ## Dumps trigger. The output will be either 1 trigger or 2+ trigger depending on actions the trigger holds.
    if trigger.actions.len < 11:
        var element = newElement("trigger")
        var attribs = {
            "uid": trigger.name,
            "x": $trigger.x,
            "y": $trigger.y,
            "enabled": $trigger.enabled,
            "maxcalls": $trigger.maxCalls
        }.toXmlAttributes
        for i in 0..<10:
            var action = DO_NOTHING
            if i < trigger.actions.len:
                action = trigger.actions[i]
            var args = action.args
            attribs["actions_" & $(i+1) & "_type"] = $action.opID
            if args.len > 0:
                attribs["actions_" & $(i+1) & "_targetA"] = args[0]
            if args.len > 1:
                attribs["actions_" & $(i+1) & "_targetB"] = args[1]
        element.attrs = attribs
        return $element

    if not trigger.implicitSplitting:
        raise LibraryError.newException(">10 actions in trigger that has `implicitSplitting` disabled is not allowed, but trigger " & trigger.name & " has " & $trigger.actions.len & " actions.")

    var triggers: seq[Trigger]
    var actionGroups = trigger.actions.chunk()
    for group in actionGroups:
        if group.len == 0:
            continue
        if group[^1].opID in [123, 361, 364, 365]:
            raise LibraryError.newException("An 'Skip next trigger' action is in end of trigger `" & trigger.name & "`, please fix this yourself")
    if actionGroups[^1].len == 0:
        discard actionGroups.pop
    triggers.add(newTrigger(
        name = trigger.name,
        x = trigger.x,
        y = trigger.y,
        enabled = trigger.enabled,
        maxCalls = trigger.maxCalls,
        actions = actionGroups[0]
    ))
    for index in 1..<actionGroups.len:
        var st = newTrigger(
            name = trigger.name & "-" & $index,
            x = trigger.x,
            y = trigger.y,
            enabled = true,
            maxCalls = -1,
            actions = actionGroups[index]
        )
        triggers[^1].switchExecution(st)
        triggers.add(st)
    for trigger in triggers:
        result.add trigger.dump


template strAddIteratively[T](what: seq[T]): untyped =
    for i in what:
        result.add(i.dump)

proc dump*(map: Map): string =
    ## Dumps every single object the `map` holds.
    strAddIteratively(map.regions)
    strAddIteratively(map.pushers)
    strAddIteratively(map.vehicles)
    strAddIteratively(map.backgrounds)
    strAddIteratively(map.decorations)
    strAddIteratively(map.boxes)
    strAddIteratively(map.engineMarks)
    strAddIteratively(map.songs)
    strAddIteratively(map.lamps)
    strAddIteratively(map.barrels)
    strAddIteratively(map.weapons)
    strAddIteratively(map.waters)
    strAddIteratively(map.characters)
    strAddIteratively(map.triggers)
    strAddIteratively(map.timers)
    strAddIteratively(map.movables)

# Constructors.
proc newMap*(): Map =
    ## Creates new map object which you use to create objects. 
    return Map()

proc newMovable*(map: Map, name: string, x, y, w, h, tarx, tary = 0, speed = 10, visible = true, moving = false, attachTo: Movable = nil): Movable {.discardable.} =
    ## Creates new movable.
    result = Movable(
        name: name,
        x: x, y: y, w: w, h: h, tarx: tarx, tary: tary,
        speed: speed,
        visible: visible,
        attachTo: attachTo,
        moving: moving
    )
    map.movables.add(result)

proc newRegion*(map: Map, name: string, x, y, w, h = 0, actTrigger: Trigger = nil, actOn = NOTHING, attachTo: Movable = nil): Region {.discardable.} =
    ## Creates new region.
    result = Region(
        name: name,
        x: x, y: y, w: w, h: h,
        actTrigger: actTrigger,
        actOn: actOn,
        attachTo: attachTo
    )
    map.regions.add(result)

proc newTimer*(map: Map, name: string, x, y = 0, enabled = true, callback: Trigger = nil, maxCalls = 1, delay = 30): Timer {.discardable.} =
    ## Creates new timer.
    result = Timer(
        name: name,
        x: x, y: y,
        enabled: enabled,
        callback: callback,
        delay: delay,
        maxCalls: maxCalls
    )
    map.timers.add(result)

proc newTrigger*(map: Map, name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[], implicitSplitting = true): Trigger {.discardable.} =
    ## Creates new trigger.
    result = Trigger(
        implicitSplitting: implicitSplitting,
        name: name,
        x: x, y: y,
        enabled: enabled,
        maxCalls: maxCalls,
        actions: actions
    )
    map.triggers.add(result)

proc newTrigger(name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[], implicitSplitting = true): Trigger {.discardable.} =
    result = Trigger(
        implicitSplitting: implicitSplitting,
        name: name,
        x: x, y: y,
        enabled: enabled,
        maxCalls: maxCalls,
        actions: actions
    )

proc newBox*(map: Map, x, y, w, h, material = 0): Box {.discardable.} =
    ## Creates new wall.
    result = Box(
        x:x, y:y, w:w, h:h, 
        material: material
    )
    map.boxes.add(result)

proc newWater*(map: Map, name: string, x, y, w, h, damage = 0, friction = true): Water {.discardable.} =
    ## Creates new water.
    result = Water(
        name: name,
        x: x, y: y, w: w, h: h,
        damage: damage,
        friction: friction
    )
    map.waters.add(result)

proc newDecoration*(map: Map, name: string, x, y, texX, texY, rotation, layer = 0, scaleX, scaleY = 1, model = "stone", attachTo: Movable = nil): Decoration {.discardable.} =
    ## Creates new decoration.
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

proc newCharacter*(map: Map, name: string, x, y, tox, toy = 0, hea, hmax = 130, team = 0, side = 1, skin = -1, incar: Vehicle = nil, botAction = 4, onDeath: Trigger = nil, isPlayer = true): Character {.discardable.} =
    ## Creates new character.
    result = Character(
        name: name,
        x: x, y: y, tox: tox, toy: toy,
        hea: hea, hmax: hmax,
        team: team, side: side,
        skin: skin, botAction: botAction,
        onDeath: onDeath,
        isPlayer: isPlayer,
        incar: incar
    )
    map.characters.add(result)

proc newSong*(map: Map, name: string, x, y = 0, url = "", volume = 1, loop = true, onEnd: Trigger = nil): Song {.discardable.} =
    ## Creates new song.
    result = Song(
        name: name,
        x: x, y:y,
        url: url,
        loop: loop,
        onEnd: onEnd,
        volume: volume
    )
    map.songs.add(result)

proc newEngineMark*(map: Map, x, y = 0, modifier = EngineMarks.MARINE_WEAPONS, parameter = "0"): EngineMark {.discardable.} =
    ## Creates new engine mark.
    result = EngineMark(
        x: x, y: y,
        modifier: modifier,
        parameter: parameter
    )
    map.engineMarks.add(result)

proc newLamp*(map: Map, name: string, x, y = 0, power = 0.4, hasFlare = true): Lamp {.discardable.} =
    ## Creates new lamp.
    result = Lamp(
        name: name,
        x: x, y: y,
        power: power, hasFlare: hasFlare
    )
    map.lamps.add(result)

proc newBarrel*(map: Map, name: string, x, y, tox, toy = 0, model = "bar_orange"): Barrel {.discardable.} =
    ## Creates new barrel.
    result = Barrel(
        name: name,
        x: x, y: y,
        tox: tox, toy: toy,
        model: model
    )
    map.barrels.add(result)

proc newWeapon*(map: Map, name: string, x, y, level = 0, team = -1, model = "gun_rifle"): Weapon {.discardable.} =
    ## Creates new weapon.
    result = Weapon(
        name: name,
        x: x, y: y,
        team: team, level: level,
        model: model
    )
    map.weapons.add(result)

proc newPusher*(map: Map, name: string, x, y, tox, toy, stabilityDamage, damage = 0, attachTo: Movable = nil): Pusher {.discardable.} =
    ## Creates new pusher.
    result = Pusher(
        name: name,
        x: x, y: y, tox: tox, toy: toy,
        stabilityDamage: stabilityDamage, 
        damage: damage,
        attachTo: attachTo
    )
    map.pushers.add(result)

proc newBackground*(map: Map, x, y, w, h, texX, texY, layer = 0, material = "0", hexMultiplier = "", showShadow = true, attachTo: Movable = nil): Background {.discardable.} =
    ## Creates new background.
    result = Background(
        x:x, y: y, w:w, h:h, texX: texX, texY: texY,
        layer: layer,
        hexMultiplier: hexMultiplier,
        showShadow: showShadow,
        attachTo: attachTo,
        material: material
    )
    map.backgrounds.add(result)

proc newVehicle*(map: Map, model = "veh_jeep", x, y, tox, toy = 0, side = 1, hpPercent = 100): Vehicle {.discardable.} =
    ## Creates new vehicle.
    result = Vehicle(
        x: x, y: y, tox: tox, toy: toy,
        model: model,
        side: side,
        hpPercent: hpPercent,
    )
    map.vehicles.add(result)

# Trigger.
proc addAction*(trigger: Trigger, action: Action) {.inline.} =
    ## Adds action to `trigger.actions`
    trigger.actions.add(action)
proc addAction*(trigger: Trigger, opID: int, args: seq[string]): Action {.discardable.} =
    ## Makes action with `opID` and `args` and then adds it to `trigger.actions`
    result = Action(opID: opID, args: args)
    trigger.actions.add(result)


proc move*(trigger: Trigger, mov: Movable, reg: Region): Action {.discardable.} =
    ## Move movable 'A' to region 'B'
    trigger.addAction(0, @[mov.name, reg.name])
proc move*(trigger: Trigger, reg1, reg2: Region): Action {.discardable.} =
    ## Move region 'A' to region 'B'
    trigger.addAction(2, @[reg1.name, reg2.name])
proc move*(trigger: Trigger, water: Water, reg: Region): Action {.discardable.} =
    ## Move water 'A' to region 'B'
    trigger.addAction(392, @[water.name, reg.name])


proc changeDamage*(trigger: Trigger, water: Water, val: varargs[string, `$`]): Action {.discardable.} =
    ## Change water 'A' damage to string-value/variable 'B'
    var B = ""
    for i in val:
        B.add i
    trigger.addAction(395, @[water.name, B])

proc changeSpeed*(trigger: Trigger, mov: Movable, value: int): Action {.discardable.} =
    ## Change movable 'A' speed to value 'B'
    trigger.addAction(1, @[mov.name, $value])


proc setVariable*(trigger: Trigger, pbvar: PBVar, value: string): Action {.discardable.} =
    ## Set variable 'A' to value 'B'
    trigger.addAction(100, @[$pbvar, value])
proc setVariableIfUndefined*(trigger: Trigger, pbvar1: PBVar, value: string): Action {.discardable.} =
    ## Set variable 'A' to value 'B' if variable 'A' is not defined
    trigger.addAction(101, @[$pbvar1, value])
proc setVariable*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    ## Set variable 'A' to value of variable 'B'
    trigger.addAction(125, @[$pbvar1, $pbvar2])

proc add*(trigger: Trigger, pbvar: PBVar, value: int): Action {.discardable.} =
    ## Add value 'B' to value of variable 'A'
    trigger.addAction(102, @[$pbvar, $value])
proc add*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    ## Add value of variable 'B' to value of variable 'A'
    trigger.addAction(104, @[$pbvar1, $pbvar2])
proc concatenate*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    ## Add string-value of variable 'B' at end of variable 'A'
    trigger.addAction(152, @[$pbvar1, $pbvar2])

proc randomFloat*(trigger: Trigger, pbvar: PBVar, value: float): Action {.discardable.} =
    ## Set variable 'A' to random floating number in range 0..B
    trigger.addAction(106, @[$pbvar, $value])
proc randomFloat*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    ## Set variable 'A' to random floating number in range 0..X where X is variable
    trigger.addAction(327, @[$pbvar1, $pbvar2])
proc randomInt*(trigger: Trigger, pbvar: PBVar, value: int): Action {.discardable.} =
    ## Set variable 'A' to random integer number in range 0..B-1
    trigger.addAction(107, @[$pbvar, $value])
proc randomInt*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action {.discardable.} =
    ## Set variable 'A' to random integer number in range 0..X-1 where X is variable
    trigger.addAction(328, @[$pbvar1, $pbvar2])


proc sendChatMessage*(trigger: Trigger, who = EXOS, texts: varargs[string, `$`]): Action {.discardable.} =
    ## Show text 'A' in chat with color 'B'
    var text = ""
    for stuff in texts:
        text.add stuff
    trigger.addAction(42, @[text, who])

proc execute*(trigger: Trigger, target: Trigger): Action {.discardable.} =
    ## Execute trigger 'A'
    trigger.addAction(99, @[target.name])

proc switchExecution*(trigger: Trigger, target: PBvar): Action {.discardable.} =
    ## Switch execution to trigger ID variable 'A'
    trigger.addAction(362, @[$target])
proc switchExecution*(trigger: Trigger, target: Trigger): Action {.discardable.} =
    ## Switch execution to trigger 'A'
    trigger.addAction(363, @[target.name])

proc activate*(trigger: Trigger, target: Timer): Action {.discardable.} =
    ## Activate timer 'A'
    trigger.addAction(25, @[target.name])
proc deactivate*(trigger: Trigger, target: Timer): Action {.discardable.} =
    ## Deactivate timer 'A'
    trigger.addAction(26, @[target.name])

proc sendRequest*(trigger: Trigger, url: PBVar, resp: PBVar): Action {.discardable.} =
    ## Request webpage in variable 'A' and save response to variable 'B'
    trigger.addAction(169, @[$url, $resp])

proc continueEquals*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Continue execution only if variable 'A' equals to value 'B'
    trigger.addAction(116, @[$var1, value])
proc continueEquals*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Continue execution only if variable 'A' equals to variable 'B'
    trigger.addAction(112, @[$var1, $var2])

proc continueNotEquals*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Continue execution only if variable 'A' is not equal to variable 'B'
    trigger.addAction(113, @[$var1, $var2])
proc continueNotEquals*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Continue execution only if variable 'A' is not equal to value 'B'
    trigger.addAction(117, @[$var1, value])

proc continueGT*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Continue execution only if variable 'A' is greater than variable 'B'
    trigger.addAction(110, @[$var1, $var2])
proc continueGT*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Continue execution only if variable 'A' is greater than value 'B'
    trigger.addAction(114, @[$var1, value])

proc continueLT*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Continue execution only if variable 'A' is less than variable 'B'
    trigger.addAction(111, @[$var1, $var2])
proc continueLT*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Continue execution only if variable 'A' is less than value 'B'
    trigger.addAction(115, @[$var1, value])

proc replaceVars*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Replace variables in string-value of variable 'B' with their value and save into variable 'A'
    trigger.addAction(325, @[$var1, $var2])
proc replaceVars*(trigger: Trigger, var1: PBVar, value: varargs[string, `$`]): Action {.discardable.} =
    ## Replace variables in string-value 'B' with their value and save into variable 'A'
    var B = ""
    for i in value:
        B.add i
    trigger.addAction(326, @[$var1, B])

proc contains*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Set variable 'A' to 1 if variable 'A' contains string-value 'B', set to 0 in else case
    trigger.addAction(149, @[$var1, value])
proc contains*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Set variable 'A' to 1 if variable 'A' contains string-value of variable 'B', set to 0 in else case
    trigger.addAction(150, @[$var1, $var2])

proc doNothing*(trigger: Trigger): Action {.discardable.} =
    trigger.addAction(DO_NOTHING)

proc switchLevel*(trigger: Trigger, map_id: string): Action {.discardable.} =
    ## Complete mission and switch to level id 'A'
    trigger.addAction(50, @[map_id])

proc getCurrent*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to current player slot
    trigger.addAction(137, @[$var1])
proc getInitiator*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to slot of player-initiator
    trigger.addAction(180, @[$var1])
proc getKiller*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to slot of player-killer
    trigger.addAction(181, @[$var1])
proc getTalker*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to slot of player-talker
    trigger.addAction(159, @[$var1])

proc getLogin*(trigger: Trigger, var1: PBVar, slot: int): Action {.discardable.} =
    ## Set value of variable 'A' to login of player slot 'B'
    trigger.addAction(184, @[$var1, $slot])
proc getLogin*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to login of player slot of variable 'B'
    trigger.addAction(187, @[$var1, $var2])

proc getDisplay*(trigger: Trigger, var1: PBVar, slot: int): Action {.discardable.} =
    ## Set value of variable 'A' to login of player slot 'B'
    trigger.addAction(185, @[$var1, $slot])
proc getDisplay*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Set value of variable 'A' to login of player slot of variable 'B'
    trigger.addAction(188, @[$var1, $var2])

proc skipIfNotEquals*(trigger: Trigger, var1: PBVar, value: string): Action {.discardable.} =
    ## Skip next trigger action if variable 'A' doesnt equal to value 'B'
    trigger.addAction(123, @[$var1, $value])
proc skipIfEquals*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Skip next trigger action if variable 'A' equals variable 'B'
    trigger.addAction(361, @[$var1, $var2])
proc skipIfGT*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Skip next trigger action if variable 'A' is greater than variable 'B'
    trigger.addAction(364, @[$var1, $var2])
proc skipIfLT*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Skip next trigger action if variable 'A' is less than variable 'B'
    trigger.addAction(365, @[$var1, $var2])


proc registerChatListener*(trigger: Trigger, listener: Trigger): Action {.discardable.} =
    ## Set trigger 'A' as player chat message receiver
    trigger.addAction(156, @[listener.name])

proc getMessage*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Set string-value of variable 'A' to text being said
    trigger.addAction(160, @[$var1])

proc variableCheck(var1: PBVar) =
    for i in ['#', '&', ';', '|', '=']:
        if i in $var1:
            raise LibraryError.newException("[PB2I]: Variable " & $var1 & " contains reserved character: " & i & ". You cannot synchronize this variable.")

proc sync*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Synchronize value of variable 'A' overriding value
    variableCheck(var1)
    trigger.addAction(223, @[$var1])
proc syncDefined*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Synchronize value of variable 'A' by defined value
    variableCheck(var1)
    trigger.addAction(224, @[$var1])
proc syncMax*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Synchronize value of variable 'A' by maximum value
    variableCheck(var1)
    trigger.addAction(225, @[$var1])
proc syncMin*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Synchronize value of variable 'A' by minimum value
    variableCheck(var1)
    trigger.addAction(226, @[$var1])
proc syncLongest*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Synchronize value of variable 'A' by longest string value
    variableCheck(var1)
    trigger.addAction(227, @[$var1])


proc createArray*(trigger: Trigger, var1: PBVar): Action {.discardable.} =
    ## Create array at variable 'A'
    trigger.addAction(354, @[$var1])

proc split*(trigger: Trigger, var1: PBVar, by: string): Action {.discardable.} =
    ## Split variable 'A' by value 'B'
    trigger.addAction(349, @[$var1, by])
proc split*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Split variable 'A' by variable 'B'
    trigger.addAction(399, @[$var1, $var2])

proc join*(trigger: Trigger, var1: PBVar, by: string): Action {.discardable.} =
    ## Join array 'A' by 'B'
    trigger.addAction(405, @[$var1, $by])

proc index*(trigger: Trigger, var1: PBVar, index: int): Action {.discardable.} =
    ## Index variable 'A' with 'B' and save into variable 'A'
    trigger.addAction(350, @[$var1, $index])

proc append*(trigger: Trigger, var1: PBVar, element: varargs[string, `$`]): Action {.discardable.} =
    ## Add element 'B' to array 'A'
    var B = ""
    for i in element:
        B.add i
    trigger.addAction(352, @[$var1, B])

proc length*(trigger: Trigger, var1, var2: PBVar): Action {.discardable.} =
    ## Get length 'B' and save into 'A'
    trigger.addAction(151, @[$var1, $var2])

proc createColourMatrix*(trigger: Trigger, var1: PBVar, mat: array[4 * 5, float]): Action {.discardable.} =
    ## Convenience procedure that inserts matrix. (takes 2 actions)
    var val = ""
    for item in mat:
        val.add($item)
        val.add(",")
    val = val[0 ..< ^1]
    trigger.setVariable(var1, val)
    trigger.split(var1, ",")

proc colorGunWithMatrix*(trigger: Trigger, gun: Weapon, var1: PBVar): Action {.discardable.} =
    ## Colors weapon 'A' with matrix stored in variable 'B'
    trigger.addAction(403, @[gun.name, $var1])

{.pop.}