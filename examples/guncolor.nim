import ../src/pb2i
import ../src/pb2i/actions

var map = newMap()

var gun = map.newWeapon("#gun*0", model = "gun_rifle")
var var1 = "eh".PBVar
var trig = map.newTrigger("#hi")

trig.createColourMatrix(var1, [
    0.0, 0.0, 1.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0, 0.0,
    1.0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 1.0, 0.0
])

trig.colorGunWithMatrix(gun, var1)
map.newTimer("#no", callback = trig, delay = 0)

map.newBox(y = 10, h = 20, w = 30)
map.newCharacter("#no", isPlayer = true)

"map.xml".writeFile map.dump