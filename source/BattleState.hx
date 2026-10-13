package;

#if (!wiiu || !cafe)

import citro.state.CitroState;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.object.CitroAnimate;
import citro.object.CitroGroup;
import citro.object.CitroObject;
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
    var menuOptions:Array<String> = [];
    var menuTextGroup:Array<CitroText> = [];
    var infoText:CitroText;

    var arenaX:Float;
    var arenaY:Float;
    var arenaW:Float = 160;
    var arenaH:Float = 100;

    var soul:CitroSprite;
    
    var krisBattle:CitroAnimate;
    var susieBattle:CitroAnimate;
    
    var bulletGroup:CitroGroup;
    
    var isSusieTurn:Bool = false;
    var enemyAttackTimer:Float = 0;
    var soulHit:Bool = false;

    public function new()
    {
        super();

        arenaX = (CitroG.WIDTH - arenaW) / 2;
        arenaY = (CitroG.HEIGHT - arenaH) / 2;

        try {
            krisBattle = new CitroAnimate("romfs:/assets/images/chars/battle/kris_battle.cea", "spr_krisb_idle");
            krisBattle.x = 40;
            krisBattle.y = 140;
            add(krisBattle);
        } catch (e:Dynamic) {
            trace("ERROR: Failed to load kris_battle.cea: " + e);
            krisBattle = null;
        }
    
        try {
            susieBattle = new CitroAnimate("romfs:/assets/images/chars/battle/susie_battle.cea", "spr_susieb_idle");
            susieBattle.x = 100;
            susieBattle.y = 140;
            add(susieBattle);
        } catch (e:Dynamic) {
            trace("ERROR: Failed to load susie_battle.cea: " + e);
            susieBattle = null;
        }

        updateMenuOptions();

        infoText = new CitroText(30, CitroG.HEIGHT - 110, "* Rudinn blocks the way!");
        infoText.color = CitroColor.WHITE;
        add(infoText);

        for (i in 0...menuOptions.length) {
            var optionText = new CitroText(30 + (i * 110), CitroG.HEIGHT - 50, menuOptions[i]);
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
    }

    function updateMenuOptions() {
        menuOptions = isSusieTurn ? ["FIGHT", "SPELL", "ITEM", "MERCY"] : ["FIGHT", "ACT", "ITEM", "MERCY"];
        
        for (i in 0...menuOptions.length) {
            if (i < menuTextGroup.length) {
                menuTextGroup[i].text = menuOptions[i];
                menuTextGroup[i].visible = true;
            } else {
                var optionText = new CitroText(30 + (i * 110), CitroG.HEIGHT - 50, menuOptions[i]);
                optionText.color = CitroColor.WHITE;
                menuTextGroup.push(optionText);
                add(optionText);
            }
        }
        for (i in menuOptions.length...menuTextGroup.length) {
            menuTextGroup[i].visible = false;
        }
        updateMenuText();
    }

    override public function update(delta:Int):Void
    {
        super.update(delta);

        var elapsed:Float = delta / 1000.0;

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
                if (isSusieTurn && selectedOption == 1) {
                    infoText.text = "* Susie used Rude Buster!";
                    susieBattle.play("spr_susie_rudebuster");
                } else {
                    infoText.text = "* You attacked Rudinn!";
                    if (Math.random() > 0.5) {
                        krisBattle.play("spr_krisb_hurt");
                    } else {
                        susieBattle.play("spr_susieb_hurt");
                    }
                }
                
                CitroTimer.start(1.0, function() {
                    startEnemyTurn();
                }, 1);

            case ENEMY_TURN:
                handleEnemyTurn(elapsed);

            case VICTORY:
                if (HID.keyPressed(HIDKey.A) || HID.keyPressed(HIDKey.START)) {
                    CitroG.switchState(new PlayState());
                }
        }
    }

    function handleEnemyTurn(elapsed:Float) {
        enemyAttackTimer += elapsed;
        
        if (Std.int(enemyAttackTimer * 2) % 2 == 0 && Std.int(enemyAttackTimer * 10) % 5 == 0) {
            var bullet = cast bulletGroup.recycle(CitroSprite);
            bullet.makeGraphic(8, 8, CitroColor.WHITE);
            bullet.x = arenaX + (Math.random() * arenaW);
            bullet.y = arenaY;
            bullet.visible = true;
        }
        
        bulletGroup.forEach(function(b:CitroObject) {
            if (b.visible) {
                b.y += 120 * elapsed;
                
                if (CitroG.overlaps(b, soul) && !soulHit) {
                    soulHit = true;
                    
                    soul.visible = true;
                    
                    if (Math.random() > 0.5) {
                        krisBattle.play("spr_krisb_hurt");
                    } else {
                        susieBattle.play("spr_susieb_hurt");
                    }
                    
                    CitroTimer.start(0.5, function() {
                        soulHit = false;
                    }, 1);
                }
                
                if (b.y > arenaY + arenaH) {
                    b.visible = false;
                }
            }
        });

        if (enemyAttackTimer >= 4.0) {
            endEnemyTurn();
        }
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
            case "ACT", "SPELL":
                setMenuVisible(false);
                currentPhase = PLAYER_ATTACK;
            case "ITEM":
                infoText.text = "* You don't have any items.";
            case "MERCY":
                setMenuVisible(false);
                infoText.text = "* You spared Rudinn!";
                currentPhase = VICTORY;
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
        enemyAttackTimer = 0;
        infoText.text = "* Rudinn attacks!";
        soul.visible = true;
        soulHit = false;
    }

    function endEnemyTurn():Void
    {
        soul.visible = false;
        currentPhase = MENU;
        setMenuVisible(true);
        infoText.text = "* What will you do?";
        updateMenuText();
    }

    override public function destroy()
    {
        if (infoText != null) infoText.destroy();
        for (textObj in menuTextGroup) textObj.destroy();
        if (soul != null) soul.destroy();
        if (krisBattle != null) krisBattle.destroy();
        if (susieBattle != null) susieBattle.destroy();
        if (bulletGroup != null) bulletGroup.destroy();
        super.destroy();
    }
}
#end
