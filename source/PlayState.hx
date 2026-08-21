package;

#if (!wiiu || !cafe)

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.object.CitroObject;
import citro.math.CitroMath;
import citro.util.CitroStringUtil;
import citro.CitroG;
import citro.backend.CitroColor;

import haxe3ds.services.HID;

class PlayState extends CitroState
{
    var rudinn:DSRudinn;
    public var kris:DSPlayer;
    public var noelle:DSNoelle;
    public var dialogueBox:DSDialogueBox;
    var closetDoor:DSDarkDoor;

    var dialogueStage:Int = 0;
    var camera:CitroCamera;

    var inputLockout:Float = 0;

    override public function create()
    {
        super.create();

        camera = new CitroCamera(false);
        add(camera);

        var background = new CitroSprite(0, 0);
        background.makeGraphic(1280, 720, 0xff1d1d24);
        camera.add(background);

        kris = new DSPlayer(CitroG.WIDTH / 2 - 160, CitroG.HEIGHT / 2);
        camera.add(kris);

        noelle = new DSNoelle(CitroG.WIDTH / 2 + 60, CitroG.HEIGHT / 2);
        noelle.target = kris;
        camera.add(noelle);

        camera.follow(kris, true);
        camera.target = kris;

        dialogueBox = new DSDialogueBox(20, CitroG.HEIGHT - 70);
        camera.add(dialogueBox);

        closetDoor = new DSDarkDoor(300, 100);
        camera.add(closetDoor);

        var greenBlock:CitroSprite;
        greenBlock = new CitroSprite(50, 50);
        greenBlock.makeGraphic(40, 40, CitroColor.GREEN); // or hex code 0xFF00FF00
        add(greenBlock);
    }

    override public function update(delta:Int):Void
    {
        super.update(delta);

        if (inputLockout > 0) {
            inputLockout -= delta / 1000.0;
            return;
        }

        separate(kris, noelle, !noelle.isFollowing);
        separate(noelle, closetDoor, greenBlock, true);

        var interactPressed = HID.keyPressed(HIDKey.A) || 
                            HID.keyPressed(HIDKey.START) || 
                            HID.keyPressed(HIDKey.R);

        if (CitroG.overlaps(kris, greenBlock) && HID.keyPressed(HIDKey.A)) {
           CitroG.substate = new SaveMenuSubState();
           CitroG.substate.create();
           inputLockout = 0.6;
        }

        if (dialogueStage == 0 && interactPressed && !kris.isBusy && CitroG.overlaps(kris, closetDoor))
        {
            kris.isBusy = true;
            
            var transition = new DSDarkWorldTransition(kris, closetDoor, camera);
            transition.onComplete = function() {
                spawnDarkWorldEntities();
            };
            add(transition);
            camera.add(transition);
            inputLockout = 0.6;
            return;
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

    function startBattle(targetEnemy:DSRudinn):Void
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

#end
