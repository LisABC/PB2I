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
        name*: string
        x*, y*: int

    # Trigger
    Action* = ref object
        opID*: int
        args*: seq[string]

    Trigger* = ref object of BaseMapObject
        enabled*: bool
        maxCalls*: int
        actions*: seq[Action]
    
    # Timer
    Timer* = ref object of BaseMapObject
        enabled*: bool
        callback*: Trigger
        delay*, maxCalls*: int
    
    # Movable
    Movable* = ref object of BaseMapObject
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


    Region* = ref object of BaseMapObject
        w*, h*: int
        actTrigger*: Trigger
        actOn*: RegionActivation
        attachTo*: Movable

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

# Constructors.
proc newMovable*(name: string, x, y, w, h, tarx, tary = 0, speed = 10, visible = true, moving = false, attachTo: Movable = nil): Movable =
    result = Movable(
        name: name,
        x: x, y: y, w: w, h: h, tarx: tarx, tary: tary,
        speed: speed,
        visible: visible,
        attachTo: attachTo,
        moving: moving
    )

proc newRegion*(name: string, x, y, w, h = 0, actTrigger: Trigger = nil, actOn = NOTHING, attachTo: Movable = nil): Region =
    result = Region(
        name: name,
        x: x, y: y, w: w, h: h,
        actTrigger: actTrigger,
        actOn: actOn,
        attachTo: attachTo
    )

proc newTimer*(name: string, x, y = 0, enabled = true, callback: Trigger = nil, maxCalls = 1, delay = 30): Timer =
    result = Timer(
        name: name,
        x: x, y: y,
        enabled: enabled,
        callback: callback,
        delay: delay,
        maxCalls: maxCalls
    )

proc newTrigger*(name: string, x, y = 0, enabled = true, maxCalls = 1, actions: seq[Action] = @[]): Trigger =
    result = Trigger(
        name: name,
        x: x, y: y,
        enabled: enabled,
        maxCalls: maxCalls,
        actions: actions
    )

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


proc sendChatMessage*(trigger: Trigger, who = EXOS, texts: varargs[string, `$`]): Action {.discardable.} =
    # Show text 'A' in chat with color 'B'
    var text = ""
    for stuff in texts:
        text.add stuff
    trigger.addAction(42, @[text, who])