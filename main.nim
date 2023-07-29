import std/with
import src/pb2i

var map = newMap()
var trigger = map.newTrigger("#trigger*0")

var var1 = "#var1".PBVar
var var2 = "#var2".PBVar

with trigger:
    setVariable(var1, "No.")
    setVariable(var2, "Yes.")
    setVariable(var1, var2)
    sendChatMessage(EXOS, "Var is ", var1)


#with trigger:
#    actions = @[]
#    generateIntNumber(var1, 10)
#    sendChatMessage(EXOS, "Number: ", var1)

for action in trigger.actions:
    echo "opID: " & $action.opID & " args: " & $action.args