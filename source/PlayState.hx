package;

#if (!wiiu || !cafe)

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.math.CitroMath;
import citro.CitroG;
import citro.backend.CitroColor;

import haxe3ds.services.HID;

class PlayState extends CitroState
{
    public var kris:DSPlayer;
    public var noelle:DSNoelle;
    var closetDoor:DSDarkDoor;
    var camera:CitroCamera;

    override public function create()
    {
        super.create();

        // 1. Setup Camera
        camera = new CitroCamera(false);
        add(camera);

        var background = new CitroSprite(0, 0);
        background.makeGraphic(400, 240, 0xff1d1d24);
        camera.add(background);

        kris = new DSPlayer(200, 120, false);
        camera.add(kris);

        noelle = new DSNoelle(450, 120);
        noelle.target = kris;
        camera.add(noelle);

        closetDoor = new DSDarkDoor(300, 100);
        camera.add(closetDoor);

        camera.follow(kris, true);
        
        trace("PlayState created. Kris X: " + kris.x + " Y: " + kris.y);
    }

    override public function update(delta:Int):Void
    {
        super.update(delta);
        
        var distToDoor = CitroMath.distanceBetween(kris, closetDoor);
        var isNearDoor = distToDoor < 40;

        if (HID.keyPressed(HIDKey.A) && isNearDoor && !kris.isBusy)
        {
            trace("Triggering Dark World Transition!");
            kris.isBusy = true;
            
            var transition = new DSDarkWorldTransition(kris, closetDoor, camera);
            transition.onComplete = function() {
                spawnDarkWorldEntities();
            };
            
            add(transition);
            camera.add(transition);
        }
    }

    function spawnDarkWorldEntities()
    {
        trace('[spawnDarkWorldEntities] Transition done. Unfreezing Kris.');
        kris.isBusy = false;
    }
}

#end