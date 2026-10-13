package;

#if (!wiiu || !cafe)

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroCamera;
import citro.object.CitroObject;
import citro.object.CitroGroup;
import citro.math.CitroMath;
import citro.util.CitroStringUtil;
import citro.CitroG;
import citro.backend.CitroColor;
import citro.backend.CitroTween;
import haxe3ds.services.HID;

class PlayState extends CitroState
{
    var rudinn:DSRudinn;
    public var kris:DSPlayer;
    public var noelle:DSNoelle;
    public var lacie:DSLacie;
    public var susie:DSSusie;
    public var dialogueBox:DSDialogueBox;
    var closetDoor:DSDarkDoor;

    var dialogueStage:Int = 0;
    var camera:CitroCamera;
    var inputLockout:Float = 0;
    
    var partyGroup:CitroGroup;

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

        partyGroup = new CitroGroup();

        var centerX = CitroG.WIDTH / 2;
        var centerY = CitroG.HEIGHT / 2;

        kris = new DSPlayer(centerX - 60, centerY, false, playerChar());
        partyGroup.add(kris);
        camera.add(kris);

        noelle = new DSNoelle(centerX - 20, centerY);
        noelle.target = kris;
        partyGroup.add(noelle);
        camera.add(noelle);

        lacie = new DSLacie(centerX + 20, centerY);
        lacie.target = kris;
        partyGroup.add(lacie);
        camera.add(lacie);

        susie = new DSSusie(centerX + 60, centerY, false);
        susie.target = kris;
        partyGroup.add(susie);
        camera.add(susie);

        camera.follow(kris, true);
        camera.target = kris;

        dialogueBox = new DSDialogueBox(60, CitroG.HEIGHT); 
        dialogueBox.visible = false;
        dialogueBox.bottom = true;
        camera.add(dialogueBox);

        closetDoor = new DSDarkDoor(600, 300);
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
        separate(kris, lacie, !lacie.isFollowing);
        separate(kris, closetDoor, true);

        if (noelle.isFollowing) separate(noelle, closetDoor, true);
        if (susie.isFollowing) separate(susie, closetDoor, true);
        if (lacie.isFollowing) separate(lacie, closetDoor, true);

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
            hideDialogueBox();
            kris.isBusy = true;
            
            var transition = new DSDarkWorldTransition(kris, closetDoor, camera, susie.isFollowing ? susie : null);
            transition.onComplete = function() {
                spawnDarkWorldEntities();
            };
            camera.add(transition);
            inputLockout = 0.6;
            return;
        }

        if (rudinn != null && !rudinn.isHit)
        {
            var distanceVal = CitroMath.distanceBetween(kris, rudinn);
            
            if (!kris.isBusy && (CitroG.overlaps(kris, rudinn) || distanceVal < 25))
            {
                rudinn.isHit = true;
                rudinn.play("spr_diamondm_hurt");
                
                kris.isBusy = true;
                startBattle(rudinn);
            }
        }

        handleInputs();
    }

    private function separate(obj1:CitroObject, obj2:CitroObject, condition:Bool = true):Bool
    {
        if (!condition) return false;
        
        var hitboxSize = 20.0; 
        var dx = Math.abs(obj1.x - obj2.x);
        var dy = Math.abs(obj1.y - obj2.y);
        
        if (dx < hitboxSize && dy < hitboxSize) {
            var overlapX = hitboxSize - dx;
            var overlapY = hitboxSize - dy;
            
            if (overlapX < overlapY) {
                if (obj1.x < obj2.x) { obj1.x -= overlapX / 2; obj2.x += overlapX / 2; }
                else { obj1.x += overlapX / 2; obj2.x -= overlapX / 2; }
            } else {
                if (obj1.y < obj2.y) { obj1.y -= overlapY / 2; obj2.y += overlapY / 2; }
                else { obj1.y += overlapY / 2; obj2.y -= overlapY / 2; }
            }
            return true;
        }
        return false;
    }

    function startBattle(targetEnemy:DSRudinn):Void
    {
        SoundPlayer.playSound('romfs:/assets/sounds/snd_b.cwav');
        CitroG.switchState(new BattleState());
    }

    function spawnDarkWorldEntities()
    {
        trace('[spawnDarkWorldEntities] Transition done. Unfreezing Kris and transforming party.');
        kris.isBusy = false;
        
        if (noelle.isFollowing) noelle.setDarkWorld(true);
        if (susie.isFollowing) susie.setDarkWorld(true);
        
        rudinn = new DSRudinn(kris.x + 200, kris.y);
        rudinn.target = kris;
        camera.add(rudinn);
    }

    function showDialogueBox() {
        dialogueBox.visible = true;
        CitroTween.tweenObject(dialogueBox, { y: CitroG.HEIGHT - 70 }, 0.3, { ease: QUAD_OUT });
    }

    function hideDialogueBox() {
        CitroTween.tweenObject(dialogueBox, { y: CitroG.HEIGHT }, 0.3, { 
            ease: QUAD_IN, 
            onComplete: function() { dialogueBox.visible = false; }
        });
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
                    hideDialogueBox();
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
                else if (dialogueStage == 2)
                {
                    hideDialogueBox();
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
                else if (dialogueStage == 3)
                {
                    susie.isFollowing = true; 
                    hideDialogueBox();
                    kris.isBusy = false;
                    dialogueStage = 0;
                }
            }
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingNoelle())
        {
            dialogueStage = 2;
            kris.isBusy = true;
            showDialogueBox();
            dialogueBox.startDialogue("* Hi Kris!\n* Want me to come with you?", "noelle_face", "0", "light", true);
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingLacie())
        {
            dialogueStage = 1;
            kris.isBusy = true;
            showDialogueBox();
            dialogueBox.startDialogue("* Hi Kris! I'm Lacie!", "", "0", "light", false);
        }
        else if (dialogueStage == 0 && interactPressed && isKrisFacingSusie())
        {
            dialogueStage = 3;
            kris.isBusy = true;
            showDialogueBox();
            
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
