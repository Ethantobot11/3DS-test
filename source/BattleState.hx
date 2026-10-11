package;

#if (!wiiu || !cafe)

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.object.CitroAnimate;
import citro.object.CitroGroup;
import citro.backend.CitroColor;
import citro.backend.CitroTimer;
import citro.backend.CitroTween;
import citro.CitroG;
import haxe3ds.services.HID;

enum BattlePhase {
    MENU;
    TARGET_SELECT;
    PLAYER_ATTACK;
    ENEMY_TURN;
    VICTORY;
}

class BattleState extends CitroState
{
    var currentPhase:BattlePhase = MENU;
    
    var selectedOption:Int = 0;
    var menuOptions:Array<String> = ["FIGHT", "ACT", "ITEM", "MERCY", "DEFEND"];
    var menuTextGroup:Array<CitroText> = [];
    var infoText:CitroText;

    var arenaX:Float;
    var arenaY:Float;
    var arenaW:Float = 160;
    var arenaH:Float = 100;

    var soul:CitroSprite;
    
    var krisBattle:CitroAnimate;
    var susieBattle:CitroAnimate;
    var rudinn:CitroAnimate;
    
    var bulletGroup:CitroGroup;

    public function new()
    {
        super();

        arenaX = (CitroG.WIDTH - arenaW) / 2;
        arenaY = (CitroG.HEIGHT - arenaH) / 2;

        rudinn = new CitroAnimate("romfs:/assets/images/chars/Rudinn.cea", "spr_diamondm_idle");
        rudinn.x = (CitroG.WIDTH / 2) - (rudinn.width / 2);
        rudinn.y = 40;
        add(rudinn);

        krisBattle = new CitroAnimate("romfs:/assets/images/chars/battle/kris_battle.cea", "spr_krisb_idle");
        krisBattle.x = 40;
        krisBattle.y = 140;
        add(krisBattle);

        susieBattle = new CitroAnimate("romfs:/assets/images/chars/battle/susie_battle.cea", "spr_susieb_idle");
        susieBattle.x = 100;
        susieBattle.y = 140;
        add(susieBattle);

        infoText = new CitroText(30, CitroG.HEIGHT - 110, "* Rudinn blocks the way!");
        infoText.color = CitroColor.WHITE;
        add(infoText);

        var startX:Float = 30;
        var spacingX:Float = 110;
        for (i in 0...menuOptions.length) {
            var optionText = new CitroText(startX + (i * spacingX), CitroG.HEIGHT - 50, menuOptions[i]);
            optionText.color = CitroColor.WHITE;
            menuTextGroup.push(optionText);
            add(optionText);
        }

        soul = new CitroSprite(arenaX + 76, arenaY + 46);
        soul.makeGraphic(8, 8, CitroColor.RED);
        soul.visible = false;
        add(soul);

        bulletGroup = new CitroGroup(50);
        add(bulletGroup);

        updateMenuText();
        
        CitroTween.tweenObject(krisBattle, { y: 140 }, 0.4, { ease: BOUNCE_OUT });
        CitroTween.tweenObject(susieBattle, { y: 140 }, 0.5, { ease: BOUNCE_OUT });
    }

    override public function update(delta:Int):Void
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;

        switch (currentPhase) {
            case MENU:
                handleMenuInput();

            case TARGET_SELECT:
                infoText.text = "* Select target: Rudinn";
                if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START)) {
                    currentPhase = PLAYER_ATTACK;
                } else if (HID.keyPressed(HIDKey.B) || HID.keyPressed(HIDKey.SELECT)) {
                    currentPhase = MENU;
                    infoText.text = "* Choose an action.";
                    setMenuVisible(true);
                }

            case PLAYER_ATTACK:
                infoText.text = "* You attacked Rudinn!";
                rudinn.play("spr_diamondm_idle");
                
                CitroTimer.start(1.0, function() {
                    startEnemyTurn();
                }, 1);

            case ENEMY_TURN:
                handleSoulMovement();
                bulletGroup.update();

            case VICTORY:
                if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START)) {
                    CitroG.switchState(new PlayState());
                }
        }

        super.update(delta);
    }

    function handleMenuInput():Void
    {
        var leftPressed = HID.keyPressed(HIDKey.LEFT) || HID.keyPressed(HIDKey.DLEFT);
        var rightPressed = HID.keyPressed(HIDKey.RIGHT) || HID.keyPressed(HIDKey.DRIGHT);
        var confirmPressed = HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START);

        if (leftPressed) {
            selectedOption = (selectedOption - 1 + menuOptions.length) % menuOptions.length;
            updateMenuText();
        } else if (rightPressed) {
            selectedOption = (selectedOption + 1) % menuOptions.length;
            updateMenuText();
        }

        if (confirmPressed) {
            executeMenuOption(menuOptions[selectedOption]);
        }
    }

    function executeMenuOption(option:String):Void
    {
        switch (option) {
            case "FIGHT":
                setMenuVisible(false);
                currentPhase = TARGET_SELECT;
            case "ACT":
                infoText.text = "* Rudinn seems docile.";
            case "ITEM":
                infoText.text = "* You don't have any items.";
            case "MERCY":
                setMenuVisible(false);
                infoText.text = "* You spared Rudinn!";
                currentPhase = VICTORY;
            case "DEFEND":
                setMenuVisible(false);
                infoText.text = "* You took a defensive stance.";
                startEnemyTurn();
        }
    }

    function updateMenuText():Void
    {
        for (i in 0...menuTextGroup.length) {
            var textObj = menuTextGroup[i];
            if (i == selectedOption) {
                textObj.color = CitroColor.YELLOW;
                textObj.text = "> " + menuOptions[i];
            } else {
                textObj.color = CitroColor.WHITE;
                textObj.text = menuOptions[i];
            }
        }
    }

    function setMenuVisible(isVisible:Bool):Void
    {
        for (textObj in menuTextGroup) {
            textObj.visible = isVisible;
        }
    }

    function startEnemyTurn():Void
    {
        setMenuVisible(false);
        currentPhase = ENEMY_TURN;
        infoText.text = "* Rudinn attacks!";
        soul.visible = true;
        rudinn.play("idle");
        
         bulletGroup.recycle();
    }

    function handleSoulMovement():Void
    {
        var speed:Float = 140;
        var vx:Float = 0;
        var vy:Float = 0;

        if (HID.keyHeld(HIDKey.UP)) vy = -speed;
        if (HID.keyHeld(HIDKey.DOWN)) vy = speed;
        if (HID.keyHeld(HIDKey.LEFT)) vx = -speed;
        if (HID.keyHeld(HIDKey.RIGHT)) vx = speed;

        var elapsed:Float = CitroG.deltaTime / 1000.0;
        soul.x += vx * elapsed;
        soul.y += vy * elapsed;

        if (soul.x < arenaX + 2) soul.x = arenaX + 2;
        if (soul.x > arenaX + arenaW - 12) soul.x = arenaX + arenaW - 12;
        if (soul.y < arenaY + 2) soul.y = arenaY + 2;
        if (soul.y > arenaY + arenaH - 12) soul.y = arenaY + arenaH - 12;
    }

    override public function destroy()
    {
        if (infoText != null) infoText.destroy();
        for (textObj in menuTextGroup) textObj.destroy();
        if (soul != null) soul.destroy();
        if (krisBattle != null) krisBattle.destroy();
        if (susieBattle != null) susieBattle.destroy();
        if (rudinn != null) rudinn.destroy();
        if (bulletGroup != null) bulletGroup.destroy();
        super.destroy();
    }
}
#end
