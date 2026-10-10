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
    public var lacie:DSLacie;
    public var susie:DSSusie;
    public var dialogueBox:DSDialogueBox;
    public var greenBlock:CitroSprite;
    var closetDoor:DSDarkDoor;

    var dialogueStage:Int = 0;
    var camera:CitroCamera;
    var inputLockout:Float = 0;

    function playerChar():String return "kris";

    override public function create()
    {
        AchievementManager.unlock("first_steps");
        inputLockout = 0.6;

        camera = new CitroCamera(false);
        add(camera);

        var background = new CitroSprite(0, 0);
        background.makeGraphic(1280, 720, 0xff1d1d24);
        camera.add(background);

        kris = new DSPlayer(CitroG.WIDTH / 2 - 160, CitroG.HEIGHT / 2, false, playerChar());
        camera.add(kris);

        noelle = new DSNoelle(CitroG.WIDTH / 2 + 60, CitroG.HEIGHT / 2);
        noelle.target = kris;
        camera.add(noelle);

        lacie = new DSLacie(CitroG.WIDTH / 2 + 120, CitroG.HEIGHT / 2);
        lacie.target = kris;
        camera.add(lacie);

        susie = new DSSusie(CitroG.WIDTH / 2 + 180, CitroG.HEIGHT / 2, false);
        susie.target = kris;
        camera.add(susie);

        camera.follow(kris, true);
        camera.target = kris;

        dialogueBox = new DSDialogueBox(60, CitroG.HEIGHT - 70);
        dialogueBox.visible = false;
        add(dialogueBox);

        closetDoor = new DSDarkDoor(300, 100);
        camera.add(closetDoor);

        super.create();
    }

    override public function update(delta:Int):Void
    {
        super.update(delta);

        if (inputLockout > 0) {
            inputLockout -= delta / 1000.0;
            return;
        }

        separate(kris, noelle, !noelle.isFollowing);
        separate(kris, susie, !susie.isFollowing);
        separate(noelle, closetDoor, true);
        separate(lacie, noelle, true);
        separate(lacie, kris, true);
        separate(lacie, closetDoor, true);
        separate(susie, noelle, true);
        separate(susie, closetDoor, true);

        var interactPressed = HID.keyPressed(HIDKey.A) || 
                            HID.keyPressed(HIDKey.START) || 
                            HID.keyPressed(HIDKey.R);

        if (HID.keyPressed(HIDKey.START) && !kris.isBusy && CitroG.substate == null) {
           CitroG.substate = new SaveMenuSubState();
           CitroG.substate.create();
           inputLockout = 0.6;
        }

        if (HID.keyPressed(HIDKey.R)) {
           CitroG.switchState(new PlayStateLacie());
           inputLockout = 0.6;
        }

        if (HID.keyPressed(HIDKey.L)) {
           CitroG.switchState(new FreeplayState());
           inputLockout = 0.6;
        }

        if (dialogueStage == 0 && interactPressed && !kris.isBusy && CitroG.overlaps(kris, closetDoor))
        {
            SoundPlayer.playSound('romfs:/assets/sounds/snd_locker.cwav');
            dialogueBox.visible = false;
            kris.isBusy = true;
            
            var transition = new DSDarkWorldTransition(kris, closetDoor, camera, susie.isFollowing ? susie : null);
            transition.onComplete = function() {
                spawnDarkWorldEntities();
            };
            add(transition);
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
        if (!condition || !CitroG.overlaps(obj1, obj2)) return false;

        var overlapX1 = (obj1.x + (obj1.width * obj1.scale.x)) - obj2.x;
        var overlapX2 = (obj2.x + (obj2.width * obj2.scale.x)) - obj1.x;
        var overlapY1 = (obj1.y + (obj1.height * obj1.scale.y)) - obj2.y;
        var overlapY2 = (obj2.y + (obj2.height * obj2.scale.y)) - obj1.y;

        var minOverlapX = overlapX1 < overlapX2 ? overlapX1 : overlapX2;
        var minOverlapY = overlapY1 < overlapY2 ? overlapY1 : overlapY2;

        if (minOverlapX < minOverlapY)
        {
            if (overlapX1 < overlapX2) obj1.x -= overlapX1;
            else obj1.x += overlapX2;
        }
        else
        {
            if (overlapY1 < overlapY2) obj1.y -= overlapY1;
            else obj1.y += overlapY2;
        }
        return true;
    }

    function startBattle(targetEnemy:DSRudinn):Void
    {
        SoundPlayer.playSound('romfs:/assets/sounds/snd_b.cwav');
        kris.isBusy = true;
        CitroG.switchState(new BattleState(targetEnemy));
    }

    function spawnDarkWorldEntities()
    {
        trace('[spawnDarkWorldEntities] Transition done. Unfreezing Kris and transforming party.');
        kris.isBusy = false;
        
        if (noelle.isFollowing) noelle.setDarkWorld(true);
        if (susie.isFollowing) susie.setDarkWorld(true);
    }

    private function handleInputs()
    {
        var interactPressed:Bool = HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START);
        var upPressed:Bool = HID.keyPressed(HIDKey.UP);
        var downPressed:Bool = HID.keyPressed(HIDKey.DOWN);

        if (dialogueBox.isChoosing)
        {
            if (upPressed || downPressed) dialogueBox.navigateChoices(upPressed, downPressed);

            if (interactPressed)
            {
                if (dialogueBox.selectedIndex == 0)
                {
                    noelle.isFollowing = true;
                    dialogueBox.startDialogue(CitroStringUtil.capitalize("* great! let's go!"), "noelle_face", "0", "light", false);
                    dialogueStage = 2;
                }
                else
                {
                    dialogueBox.startDialogue(CitroStringUtil.capitalize("* oh... okay, maybe later!"), "noelle_face", "1", "light", false);
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
            else 
            {
                if (dialogueStage == 1)
                {
                    dialogueBox.visible = false;
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
                else if (dialogueStage == 2)
                {
                    dialogueBox.visible = false;
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
                else if (dialogueStage == 3)
                {
                    susie.isFollowing = true;
                    dialogueBox.visible = false;
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
            }
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingNoelle())
        {
            dialogueStage = 2;
            kris.isBusy = true;
            dialogueBox.startDialogue("* Hi Kris!\n* Want me to come with you?", "noelle_face", "0", "light", true);
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingLacie())
        {
            dialogueStage = 1;
            kris.isBusy = true;
            dialogueBox.startDialogue("* Hi Kris! I'm Lacie!", "", "0", "light", false);
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingSusie())
        {
            dialogueStage = 3;
            kris.isBusy = true;
            
            if (!susie.isFollowing) {
                dialogueBox.startDialogue("* Hey. You need backup, don't you?\n* I'm coming with you.", "", "0", "light", false);
            } else {
                dialogueBox.startDialogue("* Let's go already.", "", "0", "light", false);
            }
        }
    }

    private function isKrisFacingNoelle():Bool { return checkFacing(kris, noelle); }
    private function isKrisFacingLacie():Bool { return checkFacing(kris, lacie); }
    private function isKrisFacingSusie():Bool { return checkFacing(kris, susie); }

    private function checkFacing(player:DSPlayer, target:CitroObject):Bool
    {
        var distance = CitroMath.distanceBetween(player, target);
        if (distance > 35) return false;

        if (player.facingDir == "right" && player.x < target.x) return true;
        if (player.facingDir == "left" && player.x > target.x) return true;
        if (player.facingDir == "up" && player.y > target.y) return true;
        if (player.facingDir == "down" && player.y < target.y) return true;

        return false;
    }
}
#end
