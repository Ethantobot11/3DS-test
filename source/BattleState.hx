package;

import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.backend.CitroColor;
import citro.backend.CitroTimer;
import citro.CitroG;
import citro.c2d.CitroObjectDraw;
import haxe3ds.services.HID;
import citro.state.CitroState;

enum BattlePhase
{
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
    var enemy:DSRudinn;
    var enemyTurnTimer:Float = 0;
    var attackTimerStarted:Bool = false;

    public function new(enemy:DSRudinn)
    {
        super();
        this.enemy = enemy;

        arenaX = (CitroG.WIDTH - arenaW) / 2;
        arenaY = (CitroG.HEIGHT - arenaH) / 2;

        infoText = new CitroText(30, CitroG.HEIGHT - 110, "* Rudinn drew near!");
        infoText.color = CitroColor.WHITE;

        var startX:Float = 30;
        var spacingX:Float = 110;
        for (i in 0...menuOptions.length)
        {
            var optionText = new CitroText(startX + (i * spacingX), CitroG.HEIGHT - 50, menuOptions[i]);
            optionText.color = CitroColor.WHITE;
            menuTextGroup.push(optionText);
        }

        soul = new CitroSprite(arenaX + 76, arenaY + 46);
        soul.makeGraphic(8, 8, CitroColor.RED);
        soul.visible = false;

        updateMenuText();
    }

    override public function update(delta:Int):Void
    {
        var elapsed:Float = CitroG.deltaTime / 1000.0;

        switch (currentPhase)
        {
            case MENU:
                handleMenuInput();

            case TARGET_SELECT:
                infoText.text = "* Select target: Rudinn";
                
                if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START) || CitroG.isTouching(soul) || HID.keyPressed(HIDKey.TOUCH))
                {
                    currentPhase = PLAYER_ATTACK;
                    attackTimerStarted = false;
                }
                else if (HID.keyPressed(HIDKey.B) || HID.keyPressed(HIDKey.SELECT))
                {
                    currentPhase = MENU;
                    infoText.text = "* Choose an action.";
                    setMenuVisible(true);
                }

            case PLAYER_ATTACK:
                infoText.text = "* You attacked Rudinn!";
                if (!attackTimerStarted)
                {
                    attackTimerStarted = true;
                    CitroTimer.start(1.0, function() {
                        startEnemyTurn();
                    }, 1);
                }

            case ENEMY_TURN:
                handleSoulMovement();
                enemyTurnTimer += elapsed;

                if (enemyTurnTimer >= 4.0)
                {
                    endEnemyTurn();
                }

            case VICTORY:
                if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START) || HID.keyPressed(HIDKey.TOUCH))
                {
                    destroy();
                }
        }

        CitroObjectDraw.drawRect(arenaX, arenaY, arenaW, arenaH, [CitroColor.WHITE], false);
        CitroObjectDraw.drawRect(arenaX + 3, arenaY + 3, arenaW - 6, arenaH - 6, [CitroColor.BLACK], false);

        infoText.update();
        for (opt in menuTextGroup) {
            if (opt.visible) opt.update();
        }

        if (soul.visible)
        {
            soul.update();
        }

        super.update(delta);
    }

    function handleMenuInput():Void
    {
        var leftPressed = HID.keyPressed(HIDKey.LEFT) || HID.keyPressed(HIDKey.DLEFT);
        var rightPressed = HID.keyPressed(HIDKey.RIGHT) || HID.keyPressed(HIDKey.DRIGHT);
        var confirmPressed = HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START);

        if (leftPressed)
        {
            selectedOption = (selectedOption - 1 + menuOptions.length) % menuOptions.length;
            updateMenuText();
        }
        else if (rightPressed)
        {
            selectedOption = (selectedOption + 1) % menuOptions.length;
            updateMenuText();
        }

        if (HID.keyHeld(HIDKey.TOUCH))
        {
            final t = HID.touch;
            for (i in 0...menuTextGroup.length)
            {
                var btn = menuTextGroup[i];
                if (t.px >= btn.x && t.px <= btn.x + btn.width &&
                    t.py >= btn.y && t.py <= btn.y + btn.height)
                {
                    if (selectedOption != i)
                    {
                        selectedOption = i;
                        updateMenuText();
                    }
                    if (HID.keyPressed(HIDKey.TOUCH))
                    {
                        confirmPressed = true;
                    }
                }
            }
        }

        if (confirmPressed)
        {
            executeMenuOption(menuOptions[selectedOption]);
        }
    }

    function executeMenuOption(option:String):Void
    {
        switch (option)
        {
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
        for (i in 0...menuTextGroup.length)
        {
            var textObj = menuTextGroup[i];
            if (i == selectedOption)
            {
                textObj.color = CitroColor.YELLOW;
                textObj.text = "> " + menuOptions[i];
            }
            else
            {
                textObj.color = CitroColor.WHITE;
                textObj.text = menuOptions[i];
            }
        }
    }

    function setMenuVisible(isVisible:Bool):Void
    {
        for (textObj in menuTextGroup)
        {
            textObj.visible = isVisible;
        }
    }

    function startEnemyTurn():Void
    {
        setMenuVisible(false);
        currentPhase = ENEMY_TURN;
        enemyTurnTimer = 0;
        infoText.text = "* Rudinn attacks!";
        soul.visible = true;
    }

    function endEnemyTurn():Void
    {
        soul.visible = false;
        currentPhase = MENU;
        setMenuVisible(true);
        infoText.text = "* What will you do?";
        updateMenuText();
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

        if (HID.keyHeld(HIDKey.TOUCH))
        {
            final t = HID.touch;
            soul.x = t.px - (soul.width / 2);
            soul.y = t.py - (soul.height / 2);
        }

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
        super.destroy();
    }
}