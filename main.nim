#import std/with
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
trigger.setVariable(var1, "0")
for i in 1..15:
    trigger.add(var1, i)
trigger.sendChatMessage(Proxy, "Variable: ", var1)


#with trigger:
#    actions = @[]
#    generateIntNumber(var1, 10)
#    sendChatMessage(EXOS, "Number: ", var1)

echo timer.dump & trigger.dump