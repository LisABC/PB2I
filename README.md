# PB2I
Nim library to automate map related things

e.x: 
```nim
import pb2i
import pb2i/actions

var map = newMap()

map.newBox(w = 600, h = 100)
map.newCharacter(
    "#player*1",
    x = 20,
    skin = 1
)

var trigger = map.newTrigger("#N")
var var1 = "#var1".PBVar
trigger.sendChatMessage(Proxy, "Hello World!")
for i in 0..<5:
    trigger.randomInt(var1, 10)
    trigger.sendChatMessage(Proxy, $i, "I: ", var1)

map.newTimer("#NT", callback=trigger, delay=0)
"map.xml".writeFile map.dump
```

Click [here](https://lisabc.github.io/PB2I/) for documentation.
