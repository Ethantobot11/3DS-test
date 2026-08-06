package;

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.object.CitroObject;
import citro.math.CitroMath;
import citro.util.CitroStringUtil;
import citro.CitroG;
import citro.backend.CitroColor;

import haxe3ds.services.HID;

import Player;
import Noelle;
import DialogueBox;
import Rudinn;
import DarkDoor;
import DarkWorldTransition;

class PlayState extends CitroState
{
    var rudinn:Rudinn;
    public var kris:Player;
    public var noelle:Noelle;
    public var dialogueBox:DialogueBox;
    var closetDoor:DarkDoor;

    var dialogueStage:Int = 0;
    var camera:CitroCamera;

    override public function create()
    {
        super.create();

        camera = new CitroCamera(false);
        add(camera);

        var background = new CitroSprite(0, 0);
        background.makeGraphic(1280, 720, 0xff1d1d24);
        add(background);
        camera.add(background);

        kris = new Player(CitroG.WIDTH / 2, CitroG.HEIGHT / 2);
        add(kris);
        camera.add(kris);

        noelle = new Noelle(CitroG.WIDTH / 2 + 60, CitroG.HEIGHT / 2);
        noelle.target = kris;
        add(noelle);
        camera.add(noelle);

        camera.follow(kris);

        dialogueBox = new DialogueBox(20, CitroG.HEIGHT - 70);
        add(dialogueBox);
        camera.add(dialogueBox);

        closetDoor = new DarkDoor(300, 100);
        add(closetDoor);
        camera.add(closetDoor);
    }

    override public function update(delta:Int):Void
    {
        super.update(delta);

        separate(kris, noelle, !noelle.isFollowing);
        separate(kris, closetDoor, true);

        var interactPressed = HID.keyPressed(HIDKey.A) || 
                              HID.keyPressed(HIDKey.START) || 
                              HID.keyPressed(HIDKey.R);

        if (interactPressed && !kris.isBusy && CitroG.overlaps(kris, closetDoor) && kris.facingDir == "up")
        {
            kris.isBusy = true;
            var transition = new DarkWorldTransition(kris, closetDoor, camera);
            transition.onComplete = function() {
                spawnDarkWorldEntities();
            };
            add(transition);
            camera.add(transition);
        }

        if (rudinn != null)
        {
            var distanceVal = CitroMath.distanceBetween(kris, rudinn);
            var isNear = distanceVal < 30;

            if (!kris.isBusy && (CitroG.overlaps(kris, rudinn) || isNear))
            {
                kris.isBusy = true;
                startBattle(rudinn);
            }
        }

        handleInputs();

        camera.update();
    }

    private function separate(obj1:CitroObject, obj2:CitroObject, condition:Bool = true):Bool
    {
        if (!condition || !CitroG.overlaps(obj1, obj2))
        {
            return false;
        }

        var overlapX1 = (obj1.x + (obj1.width * obj1.scale.x)) - obj2.x;
        var overlapX2 = (obj2.x + (obj2.width * obj2.scale.x)) - obj1.x;
        var overlapY1 = (obj1.y + (obj1.height * obj1.scale.y)) - obj2.y;
        var overlapY2 = (obj2.y + (obj2.height * obj2.scale.y)) - obj1.y;

        var minOverlapX = overlapX1 < overlapX2 ? overlapX1 : overlapX2;
        var minOverlapY = overlapY1 < overlapY2 ? overlapY1 : overlapY2;

        if (minOverlapX < minOverlapY)
        {
            if (overlapX1 < overlapX2)
            {
                obj1.x -= overlapX1;
            }
            else
            {
                obj1.x += overlapX2;
            }
        }
        else
        {
            if (overlapY1 < overlapY2)
            {
                obj1.y -= overlapY1;
            }
            else
            {
                obj1.y += overlapY2;
            }
        }

        return true;
    }

    function startBattle(targetEnemy:Rudinn):Void
    {
        trace('[startBattle()] Entering startBattle function...');
        kris.isBusy = true;
        
        var battleState = new BattleState(targetEnemy);
        
        CitroG.switchState(battleState);
    }

    function spawnDarkWorldEntities()
    {
        trace('[spawnDarkWorldEntities] Transition done. Unfreezing Kris and spawning Rudinn.');
        kris.isBusy = false;
        //rudinn = new Rudinn(kris.x + 100, kris.y, 150);
        //add(rudinn);
        //camera.add(rudinn);
    }

    private function handleInputs()
    {
        var interactPressed:Bool = HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START);
        var upPressed:Bool = HID.keyPressed(HIDKey.UP);
        var downPressed:Bool = HID.keyPressed(HIDKey.DOWN);

        if (dialogueBox.isChoosing)
        {
            if (upPressed || downPressed)
            {
                dialogueBox.navigateChoices(upPressed, downPressed);
            }

            if (interactPressed)
            {
                if (dialogueBox.selectedIndex == 0)
                {
                    noelle.isFollowing = true;
                    dialogueBox.startDialogue(CitroStringUtil.capitalize("* great! let's go!"), "spr_face_n_matome", "spr_face_n_matome-0", "light", false);
                    dialogueStage = 2;
                }
                else
                {
                    dialogueBox.startDialogue(CitroStringUtil.capitalize("* oh... okay, maybe later!"), "spr_face_n_matome", "spr_face_n_matome-1", "light", false);
                    dialogueStage = 2;
                }
            }
            return;
        }

        if (dialogueStage > 0 && interactPressed)
        {
            if (!dialogueBox.isFinished)
            {
                dialogueBox.skipTyping();
            }
            else if (dialogueStage == 2)
            {
                dialogueBox.visible = false;
                kris.isBusy = false;
                dialogueStage = 0;
            }
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingNoelle())
        {
            dialogueStage = 1;
            kris.isBusy = true;
            
            dialogueBox.startDialogue(
                "* Hi Kris!\n* Want me to come with you?", 
                "noelle_face",
                "spr_face_n_matome", 
                "spr_face_n_matome-0", 
                "light",
                true
            );
        }
    }

    private function isKrisFacingNoelle():Bool
    {
        var distance = CitroMath.distanceBetween(kris, noelle);
        if (distance > 35) return false;

        if (kris.facingDir == "right" && kris.x < noelle.x) return true;
        if (kris.facingDir == "left" && kris.x > noelle.x) return true;
        if (kris.facingDir == "up" && kris.y > noelle.y) return true;
        if (kris.facingDir == "down" && kris.y < noelle.y) return true;

        return false;
    }
}