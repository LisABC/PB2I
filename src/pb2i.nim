import std/xmltree
import std/strtabs

## Module that acts as an API for PB2 maps.

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
let DO_NOTHING* = Action(opID: -1, args: @[])
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

{.push discardable.}

proc newMovable*(map: Map, name: string, x, y, w, h, tarx, tary = 0, speed = 10, visible = true, moving = false, attachTo: Movable = nil): Movable  =
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

proc newRegion*(map: Map, name: string, x, y, w, h = 0, actTrigger: Trigger = nil, actOn = NOTHING, attachTo: Movable = nil): Region  =
    ## Creates new region.
    result = Region(
        name: name,
        x: x, y: y, w: w, h: h,
        actTrigger: actTrigger,
        actOn: actOn,
        attachTo: attachTo
    )
    map.regions.add(result)

proc newTimer*(map: Map, name: string, x, y = 0, enabled = true, callback: Trigger = nil, maxCalls = 1, delay = 30): Timer  =
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

proc newTrigger*(map: Map, name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[], implicitSplitting = true): Trigger  =
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

proc newTrigger(name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[], implicitSplitting = true): Trigger  =
    result = Trigger(
        implicitSplitting: implicitSplitting,
        name: name,
        x: x, y: y,
        enabled: enabled,
        maxCalls: maxCalls,
        actions: actions
    )

proc newBox*(map: Map, x, y, w, h, material = 0): Box  =
    ## Creates new wall.
    result = Box(
        x:x, y:y, w:w, h:h, 
        material: material
    )
    map.boxes.add(result)

proc newWater*(map: Map, name: string, x, y, w, h, damage = 0, friction = true): Water  =
    ## Creates new water.
    result = Water(
        name: name,
        x: x, y: y, w: w, h: h,
        damage: damage,
        friction: friction
    )
    map.waters.add(result)

proc newDecoration*(map: Map, name: string, x, y, texX, texY, rotation, layer = 0, scaleX, scaleY = 1, model = "stone", attachTo: Movable = nil): Decoration  =
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

proc newCharacter*(map: Map, name: string, x, y, tox, toy = 0, hea, hmax = 130, team = 0, side = 1, skin = -1, incar: Vehicle = nil, botAction = 4, onDeath: Trigger = nil, isPlayer = true): Character  =
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

proc newSong*(map: Map, name: string, x, y = 0, url = "", volume = 1, loop = true, onEnd: Trigger = nil): Song  =
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

proc newEngineMark*(map: Map, x, y = 0, modifier = EngineMarks.MARINE_WEAPONS, parameter = "0"): EngineMark  =
    ## Creates new engine mark.
    result = EngineMark(
        x: x, y: y,
        modifier: modifier,
        parameter: parameter
    )
    map.engineMarks.add(result)

proc newLamp*(map: Map, name: string, x, y = 0, power = 0.4, hasFlare = true): Lamp  =
    ## Creates new lamp.
    result = Lamp(
        name: name,
        x: x, y: y,
        power: power, hasFlare: hasFlare
    )
    map.lamps.add(result)

proc newBarrel*(map: Map, name: string, x, y, tox, toy = 0, model = "bar_orange"): Barrel  =
    ## Creates new barrel.
    result = Barrel(
        name: name,
        x: x, y: y,
        tox: tox, toy: toy,
        model: model
    )
    map.barrels.add(result)

proc newWeapon*(map: Map, name: string, x, y, level = 0, team = -1, model = "gun_rifle"): Weapon  =
    ## Creates new weapon.
    result = Weapon(
        name: name,
        x: x, y: y,
        team: team, level: level,
        model: model
    )
    map.weapons.add(result)

proc newPusher*(map: Map, name: string, x, y, tox, toy, stabilityDamage, damage = 0, attachTo: Movable = nil): Pusher  =
    ## Creates new pusher.
    result = Pusher(
        name: name,
        x: x, y: y, tox: tox, toy: toy,
        stabilityDamage: stabilityDamage, 
        damage: damage,
        attachTo: attachTo
    )
    map.pushers.add(result)

proc newBackground*(map: Map, x, y, w, h, texX, texY, layer = 0, material = "0", hexMultiplier = "", showShadow = true, attachTo: Movable = nil): Background  =
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

proc newVehicle*(map: Map, model = "veh_jeep", x, y, tox, toy = 0, side = 1, hpPercent = 100): Vehicle  =
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
proc addAction*(trigger: Trigger, opID: int, args: seq[string]): Action  =
    ## Makes action with `opID` and `args` and then adds it to `trigger.actions`
    result = Action(opID: opID, args: args)
    trigger.actions.add(result)

proc switchExecution*(trigger: Trigger, target: PBvar): Action  =
    ## Switch execution to trigger ID variable 'A'
    trigger.addAction(362, @[$target])
proc switchExecution*(trigger: Trigger, target: Trigger): Action  =
    ## Switch execution to trigger 'A'
    trigger.addAction(363, @[target.name])

{.pop.}
{.pop.}