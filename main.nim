import std/with
import src/pb2i

var map = newMap()
var trigger = map.newTrigger("#trigger*0")
var timer = map.newTimer(
    "#timer*0", 
    x = trigger.x-10, 
    y = trigger.y-10,
    enabled = true,
    callback = trigger,
    maxCalls = 1,
    delay = 0
)

var var1 = "#var1".PBVar

with trigger:
    setVariable(var1, "0")
    add(var1, 1)
    add(var1, 2)
    add(var1, 3)
    add(var1, 4)
    add(var1, 5)
    add(var1, 6)
    add(var1, 7)
    add(var1, 8)
    add(var1, 9)
    add(var1, 10)
    add(var1, 11)
    add(var1, 12)
    add(var1, 13)
    add(var1, 14)
    add(var1, 15)
    sendChatMessage(Proxy, "Variable: ", var1)


#with trigger:
#    actions = @[]
#    generateIntNumber(var1, 10)
#    sendChatMessage(EXOS, "Number: ", var1)

echo timer.dump & trigger.dump