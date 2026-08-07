package;

import leafy.states.LfState;
import leafy.groups.LfGroup;
import leafy.backend.LeafyDebug;
import leafy.filesystem.LfSystemPaths;
import leafy.objects.LfObject;
import leafy.gamepad.LfGamepad;
import leafy.Leafy;

class WiiUPlayState extends LfState
{
    var rudinn:WiiURudinn;
    public var kris:WiiUPlayer;
    public var noelle:WiiUNoelle;
    public var dialogueBox:WiiUDialogueBox;
    var closetDoor:WiiUDarkDoor;

    var dialogueStage:Int = 0;

    var worldGroup:LfGroup<LfObject>;

    override public function create():Void
    {
        super.create();
        LeafyDebug.log("Initializing PlayState...", INFO);

        worldGroup = new LfGroup<LfObject>();

        kris = new WiiUPlayer(1280 / 2, 720 / 2);
        worldGroup.add(kris);

        noelle = new WiiUNoelle(1280 / 2 + 60, 720 / 2);
        noelle.target = kris;
        worldGroup.add(noelle);

        dialogueBox = new WiiUDialogueBox(20, 720 - 70);
        worldGroup.add(dialogueBox);

        closetDoor = new WiiUDarkDoor(300, 100);
        worldGroup.add(closetDoor);

        worldGroup.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        worldGroup.update(elapsed);

        if (!noelle.isFollowing)
        {
            if (leafy.utils.LfCollision.checkCollision(kris, noelle))
            {
                leafy.utils.LfCollision.separate(kris, noelle);
            }
        }

        if (leafy.utils.LfCollision.checkCollision(kris, closetDoor))
        {
            leafy.utils.LfCollision.separate(kris, closetDoor);
        }

        handleInputs();     
    }

    override public function render():Void
    {
        super.render();
        worldGroup.render();
    }

    function startBattle(targetEnemy:WiiURudinn):Void
    {
        LeafyDebug.log('[startBattle()] Entering startBattle function...', DEBUG);
        kris.isBusy = true;
        
        //Leafy.switchState(new BattleState(kris, targetEnemy));
    }

    private function spawnDarkWorldEntities():Void
    {
        LeafyDebug.log("[spawnDarkWorldEntities] Unfreezing Kris and spawning Rudinn.", DEBUG);
        kris.isBusy = false;
        rudinn = new WiiURudinn(kris.x + 100, kris.y, 150);
        worldGroup.add(rudinn);
        rudinn.create();
    }

    private function handleInputs()
    {
        var interactPressed:Bool = false;
        var upPressed:Bool = false;
        var downPressed:Bool = false;
        var gamepad:LfGamepad = Leafy.wiiuGamepad;
        if (gamepad == null) return;

        interactPressed = gamepad.justPressed(BUTTON_A) || gamepad.justPressed(BUTTON_PLUS);
        upPressed = gamepad.justPressed(BUTTON_UP);
        downPressed = gamepad.justPressed(BUTTON_DOWN);

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
                    dialogueBox.startDialogue("* Great! Let's go!", "noelle_face", "spr_face_n_matome_00000", "light", false);
                    dialogueStage = 2;
                }
                else
                {
                    dialogueBox.startDialogue("* Oh... okay, maybe later!", "noelle_face", "spr_face_n_matome_10000", "light", false);
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
                "spr_face_n_matome_00000", 
                "light",
                true
            );
        }
    }

    private function isKrisFacingNoelle():Bool
    {
        return false;
    }

    override public function destroy():Void
    {
        worldGroup.destroy();
        super.destroy();
    }
}