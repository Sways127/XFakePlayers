# XFakePlayers 14 beta
Extended fake players for Half-Life and mods (including Counter-Strike)

## AI features:

* Walking at world using NavMesh
* Buying weapons at round start (using "autobuy" command)
* Destroying breakable objects (glasses, boxes, doors, etc..)
* Using flashligh (a poor algorithm will check "LightStyles" array)
* Randomized behavior
* Scenario gameplay

### Half-Life scenarios

* Bots can search and pick up weapons, backpacks, ammo, medkits, etc.. 

### Counter-Strike scenarios

* Bots can search bomb places and plant C4, when playing DE_ maps as Terrorists
* Bots can search just planted C4 at bomb places and defuse it, when playing DE_ maps as CTs
* Bots can search just dropped C4 backpack and pick it up, when playing DE_ maps as Terrorists

## Features I want to do:

* NavMesh generation (now I using CS:CZ for generating navigation meshes)
* Using ladders at maps
* Rescuing hostages at CS_ maps
* VIP escaping at AS_ maps
* Using a better flashlight algorithm - we need to check light intensity at our position from world (.bsp) map

## Screenshots:

### Half-Life

![](https://i.imgur.com/hSkq19M.jpg)
![](https://i.imgur.com/qkXxVfm.jpg)
![](http://i.imgur.com/RUitMML.jpg)

### Counter-Strike

![](https://i.imgur.com/uS5rPGs.jpg)
![](https://i.imgur.com/gVcBWvR.jpg)