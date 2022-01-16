package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.io.File;
import sys.FileSystem;
import android.AndroidTools;
import android.Permissions;

class PlayState extends FlxState
{
	var text:FlxText;

	inline static var endl:String = '\n';
	
	static var printText:Bool = true;

	static var gameContent:String = null;

	static var testText = 'lolkekaklsfnjsfhnioeshfnioesnhfioseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' + endl;
	
	override public function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		text = new FlxText(0, 0, FlxG.width, "", 32);
		text.width = FlxG.width;
		text.height = FlxG.height;
		text.setFormat("font/font.ttf", 32, FlxColor.WHITE, RIGHT);
		add(text);
		if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
		    AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
		}
		parse(Main.getStoragePath() + "game.txt");

		super.create();
	}

	public static function getNextThing(content:String):String {
		if (content == null || content.length < 0) {
			trace("game text is not initialised, creating test Text");
			return FlxG.random.int(0, 1000) + testText;
		} else {
			return content; //yes i actually did nothing here now. i did nothing NOW, not at all
		}
	}
	
	public static function parse(path:String) {
		if (FileSystem.exists(path)) {
		    gameContent = File.getContent(path);
		} else {
			trace("file is not existing");
		}
		//parsing game.txt, only template for now
	}

	// str is char not string
	function isitchislo(str:String):Bool
	{
		var num = Std.parseInt(str);
		if (Math.isNaN(num))
			return false;
		else
			return true;
	}

	function vchislo(str:String)
	{
		return Std.parseInt(str);
	}

	function showString(str:String)
	{
		deleteJunk();
		text.text = text.text + str;
	}

	function deleteJunk()
	{
		var strs:Array<String> = text.text.split('\n');
		if (strs.length < 32)
			return;

		strs.reverse();
		strs.resize(32);
		strs.reverse();

		text.text = strs.join('\n');
	}

	override public function update(elapsed:Float)
	{
		showString(getNextThing(gameContent));
		super.update(elapsed);
	}
}
