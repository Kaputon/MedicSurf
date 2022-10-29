# MedicSurf

Medic Surf Practice allows you to spawn an entity orb that shoots rockets at you for the purpose of surf training.

***Console Commands:***

* *set_origin* - Places the orb where you are located. Use noclip to place it in the air.

* *fire_rocket* - Fires a single rocket. If you want to do this manually, I'd suggest [bind <key> "fire_rocket"].

* *ms_auto_shoot* [0/1 **OR** false/true] - Toggles whether or not the orb fires manually or automatically.

* *ms_random_speed* [0/1 **OR** false/true] - 0 for false, 1 for true. Alters the rockets projectile speed.

* *ms_rocket_speed* [Hammer Units] - If random speed is off, sets each rockets speed to the hammer unit you put in. (For reference, the stock moves at 1100.00 HU/s)

# Setting Up

Place the *.sp* file into `./addons/sourcemod/scripting` and place the *.smx* file into `./addons/sourcemod/plugins`.
