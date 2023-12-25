import ../pb2i

## Submodule of PB2I library to have convenience procedures for trigger actions.

{.push discardable.}

proc move*(trigger: Trigger, mov: Movable, reg: Region): Action  =
    ## Move movable 'A' to region 'B'
    trigger.addAction(0, @[mov.name, reg.name])
proc move*(trigger: Trigger, reg1, reg2: Region): Action  =
    ## Move region 'A' to region 'B'
    trigger.addAction(2, @[reg1.name, reg2.name])
proc move*(trigger: Trigger, water: Water, reg: Region): Action  =
    ## Move water 'A' to region 'B'
    trigger.addAction(392, @[water.name, reg.name])


proc changeDamage*(trigger: Trigger, water: Water, val: varargs[string, `$`]): Action  =
    ## Change water 'A' damage to string-value/variable 'B'
    var B = ""
    for i in val:
        B.add i
    trigger.addAction(395, @[water.name, B])

proc changeSpeed*(trigger: Trigger, mov: Movable, value: int): Action  =
    ## Change movable 'A' speed to value 'B'
    trigger.addAction(1, @[mov.name, $value])


proc setVariable*(trigger: Trigger, pbvar: PBVar, value: string): Action  =
    ## Set variable 'A' to value 'B'
    trigger.addAction(100, @[$pbvar, value])
proc setVariableIfUndefined*(trigger: Trigger, pbvar1: PBVar, value: string): Action  =
    ## Set variable 'A' to value 'B' if variable 'A' is not defined
    trigger.addAction(101, @[$pbvar1, value])
proc setVariable*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action  =
    ## Set variable 'A' to value of variable 'B'
    trigger.addAction(125, @[$pbvar1, $pbvar2])

proc add*(trigger: Trigger, pbvar: PBVar, value: int): Action  =
    ## Add value 'B' to value of variable 'A'
    trigger.addAction(102, @[$pbvar, $value])
proc add*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action  =
    ## Add value of variable 'B' to value of variable 'A'
    trigger.addAction(104, @[$pbvar1, $pbvar2])
proc concatenate*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action  =
    ## Add string-value of variable 'B' at end of variable 'A'
    trigger.addAction(152, @[$pbvar1, $pbvar2])

proc randomFloat*(trigger: Trigger, pbvar: PBVar, value: float): Action  =
    ## Set variable 'A' to random floating number in range 0..B
    trigger.addAction(106, @[$pbvar, $value])
proc randomFloat*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action  =
    ## Set variable 'A' to random floating number in range 0..X where X is variable
    trigger.addAction(327, @[$pbvar1, $pbvar2])
proc randomInt*(trigger: Trigger, pbvar: PBVar, value: int): Action  =
    ## Set variable 'A' to random integer number in range 0..B-1
    trigger.addAction(107, @[$pbvar, $value])
proc randomInt*(trigger: Trigger, pbvar1, pbvar2: PBVar): Action  =
    ## Set variable 'A' to random integer number in range 0..X-1 where X is variable
    trigger.addAction(328, @[$pbvar1, $pbvar2])


proc sendChatMessage*(trigger: Trigger, who = EXOS, texts: varargs[string, `$`]): Action  =
    ## Show text 'A' in chat with color 'B'
    var text = ""
    for stuff in texts:
        text.add stuff
    trigger.addAction(42, @[text, who])

proc execute*(trigger: Trigger, target: Trigger): Action  =
    ## Execute trigger 'A'
    trigger.addAction(99, @[target.name])

proc activate*(trigger: Trigger, target: Timer): Action  =
    ## Activate timer 'A'
    trigger.addAction(25, @[target.name])
proc deactivate*(trigger: Trigger, target: Timer): Action  =
    ## Deactivate timer 'A'
    trigger.addAction(26, @[target.name])

proc sendRequest*(trigger: Trigger, url: PBVar, resp: PBVar): Action  =
    ## Request webpage in variable 'A' and save response to variable 'B'
    trigger.addAction(169, @[$url, $resp])

proc continueEquals*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Continue execution only if variable 'A' equals to value 'B'
    trigger.addAction(116, @[$var1, value])
proc continueEquals*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Continue execution only if variable 'A' equals to variable 'B'
    trigger.addAction(112, @[$var1, $var2])

proc continueNotEquals*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Continue execution only if variable 'A' is not equal to variable 'B'
    trigger.addAction(113, @[$var1, $var2])
proc continueNotEquals*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Continue execution only if variable 'A' is not equal to value 'B'
    trigger.addAction(117, @[$var1, value])

proc continueGT*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Continue execution only if variable 'A' is greater than variable 'B'
    trigger.addAction(110, @[$var1, $var2])
proc continueGT*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Continue execution only if variable 'A' is greater than value 'B'
    trigger.addAction(114, @[$var1, value])

proc continueLT*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Continue execution only if variable 'A' is less than variable 'B'
    trigger.addAction(111, @[$var1, $var2])
proc continueLT*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Continue execution only if variable 'A' is less than value 'B'
    trigger.addAction(115, @[$var1, value])

proc replaceVars*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Replace variables in string-value of variable 'B' with their value and save into variable 'A'
    trigger.addAction(325, @[$var1, $var2])
proc replaceVars*(trigger: Trigger, var1: PBVar, value: varargs[string, `$`]): Action  =
    ## Replace variables in string-value 'B' with their value and save into variable 'A'
    var B = ""
    for i in value:
        B.add i
    trigger.addAction(326, @[$var1, B])

proc contains*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Set variable 'A' to 1 if variable 'A' contains string-value 'B', set to 0 in else case
    trigger.addAction(149, @[$var1, value])
proc contains*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Set variable 'A' to 1 if variable 'A' contains string-value of variable 'B', set to 0 in else case
    trigger.addAction(150, @[$var1, $var2])

proc doNothing*(trigger: Trigger): Action  =
    trigger.addAction(DO_NOTHING)

proc switchLevel*(trigger: Trigger, map_id: string): Action  =
    ## Complete mission and switch to level id 'A'
    trigger.addAction(50, @[map_id])

proc getCurrent*(trigger: Trigger, var1: PBVar): Action  =
    ## Set value of variable 'A' to current player slot
    trigger.addAction(137, @[$var1])
proc getInitiator*(trigger: Trigger, var1: PBVar): Action  =
    ## Set value of variable 'A' to slot of player-initiator
    trigger.addAction(180, @[$var1])
proc getKiller*(trigger: Trigger, var1: PBVar): Action  =
    ## Set value of variable 'A' to slot of player-killer
    trigger.addAction(181, @[$var1])
proc getTalker*(trigger: Trigger, var1: PBVar): Action  =
    ## Set value of variable 'A' to slot of player-talker
    trigger.addAction(159, @[$var1])

proc getLogin*(trigger: Trigger, var1: PBVar, slot: int): Action  =
    ## Set value of variable 'A' to login of player slot 'B'
    trigger.addAction(184, @[$var1, $slot])
proc getLogin*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Set value of variable 'A' to login of player slot of variable 'B'
    trigger.addAction(187, @[$var1, $var2])

proc getDisplay*(trigger: Trigger, var1: PBVar, slot: int): Action  =
    ## Set value of variable 'A' to login of player slot 'B'
    trigger.addAction(185, @[$var1, $slot])
proc getDisplay*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Set value of variable 'A' to login of player slot of variable 'B'
    trigger.addAction(188, @[$var1, $var2])

proc skipIfNotEquals*(trigger: Trigger, var1: PBVar, value: string): Action  =
    ## Skip next trigger action if variable 'A' doesnt equal to value 'B'
    trigger.addAction(123, @[$var1, $value])
proc skipIfEquals*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Skip next trigger action if variable 'A' equals variable 'B'
    trigger.addAction(361, @[$var1, $var2])
proc skipIfGT*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Skip next trigger action if variable 'A' is greater than variable 'B'
    trigger.addAction(364, @[$var1, $var2])
proc skipIfLT*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Skip next trigger action if variable 'A' is less than variable 'B'
    trigger.addAction(365, @[$var1, $var2])


proc registerChatListener*(trigger: Trigger, listener: Trigger): Action  =
    ## Set trigger 'A' as player chat message receiver
    trigger.addAction(156, @[listener.name])

proc getMessage*(trigger: Trigger, var1: PBVar): Action  =
    ## Set string-value of variable 'A' to text being said
    trigger.addAction(160, @[$var1])

proc variableCheck(var1: PBVar) =
    for i in ['#', '&', ';', '|', '=']:
        if i in $var1:
            raise LibraryError.newException("[PB2I]: Variable " & $var1 & " contains reserved character: " & i & ". You cannot synchronize this variable.")

proc sync*(trigger: Trigger, var1: PBVar): Action  =
    ## Synchronize value of variable 'A' overriding value
    variableCheck(var1)
    trigger.addAction(223, @[$var1])
proc syncDefined*(trigger: Trigger, var1: PBVar): Action  =
    ## Synchronize value of variable 'A' by defined value
    variableCheck(var1)
    trigger.addAction(224, @[$var1])
proc syncMax*(trigger: Trigger, var1: PBVar): Action  =
    ## Synchronize value of variable 'A' by maximum value
    variableCheck(var1)
    trigger.addAction(225, @[$var1])
proc syncMin*(trigger: Trigger, var1: PBVar): Action  =
    ## Synchronize value of variable 'A' by minimum value
    variableCheck(var1)
    trigger.addAction(226, @[$var1])
proc syncLongest*(trigger: Trigger, var1: PBVar): Action  =
    ## Synchronize value of variable 'A' by longest string value
    variableCheck(var1)
    trigger.addAction(227, @[$var1])


proc createArray*(trigger: Trigger, var1: PBVar): Action  =
    ## Create array at variable 'A'
    trigger.addAction(354, @[$var1])

proc split*(trigger: Trigger, var1: PBVar, by: string): Action  =
    ## Split variable 'A' by value 'B'
    trigger.addAction(349, @[$var1, by])
proc split*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Split variable 'A' by variable 'B'
    trigger.addAction(399, @[$var1, $var2])

proc join*(trigger: Trigger, var1: PBVar, by: string): Action  =
    ## Join array 'A' by 'B'
    trigger.addAction(405, @[$var1, $by])

proc index*(trigger: Trigger, var1: PBVar, index: int): Action  =
    ## Index variable 'A' with 'B' and save into variable 'A'
    trigger.addAction(350, @[$var1, $index])

proc append*(trigger: Trigger, var1: PBVar, element: varargs[string, `$`]): Action  =
    ## Add element 'B' to array 'A'
    var B = ""
    for i in element:
        B.add i
    trigger.addAction(352, @[$var1, B])

proc length*(trigger: Trigger, var1, var2: PBVar): Action  =
    ## Get length 'B' and save into 'A'
    trigger.addAction(151, @[$var1, $var2])

proc createColourMatrix*(trigger: Trigger, var1: PBVar, mat: array[4 * 5, float]): Action  =
    ## Convenience procedure that inserts matrix. (takes 2 actions)
    var val = ""
    for item in mat:
        val.add($item)
        val.add(",")
    val = val[0 ..< ^1]
    trigger.setVariable(var1, val)
    trigger.split(var1, ",")

proc colorGunWithMatrix*(trigger: Trigger, gun: Weapon, var1: PBVar): Action  =
    ## Colors weapon 'A' with matrix stored in variable 'B'
    trigger.addAction(403, @[gun.name, $var1])

{.pop.}