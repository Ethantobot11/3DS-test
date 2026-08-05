package;

import haxe3ds.services.RomFS;
import haxe3ds.services.GFX;
import citro.CitroGame;

class Main
{
    public static function main():Void
    {
        CitroGame.start(new PlayState());
    }
}