import ../src/pb2i
import ../src/pb2i/actions

var map = newMap()

var water = map.newWater("#water*1", h = 20, w = 20)
var region = map.newRegion("#region*0", x = 50, h = 20, w = 20)

var trig = map.newTrigger("#trigger*0")
trig.move(water, region)

map.newTimer("#timer*1", delay = 0, callback = trig)

map.newCharacter("#player*0", isPlayer = true, x = -20)
map.newBox(h = 50, w = 50, x = -20, y = -10)

"map.xml".writeFile map.dump