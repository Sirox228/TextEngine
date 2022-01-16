package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.io.File;
import sys.FileSystem;
import android.AndroidTools;
import android.Permissions;
import flixel.addons.ui.FlxUIInputText;

using StringTools;

class PlayState extends FlxState
{
	var text:FlxText;

	inline static var endl:String = '\n';
	
	static var printText:Bool = true;
	
	static var allowInput:Bool = false;
	
	static var nextState:Int = 0;

	static var gameContent:Array<String> = [];

	static var testText = 'lolkekaklsfnjsfhnioeshfnioesnhfioseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee' + endl;
	
	override public function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		text = new FlxText(0, 0, FlxG.width, "", 32);
		text.setFormat("font/font.ttf", 32, FlxColor.WHITE, LEFT);
		text.width = FlxG.width - 200;
		text.x = 100;
		text.y = 100;
		text.textField.width = FlxG.width - 200;
		add(text);
		if (AndroidTools.getSDKversion() > 23 || AndroidTools.getSDKversion() == 23) {
		    AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
		}
		gameContent = parse("game.txt");

		super.create();
	}

	public static function getNextThing(content:Array<String>):String {
		if (content == null || content.length < 0) {
			trace("game text is not initialised, creating test Text");
			return FlxG.random.int(0, 1000) + testText;
		} else {
			trace(content);
			var lineContent = content[nextState].split('|');
			trace(lineContent);
			var statePrefs = lineContent[0].split('=');
			trace(statePrefs);
			var textContent = statePrefs[1];
			trace(textContent);
			var finalText:String = textContent;
			trace(finalText);
			var choicePrefs = lineContent[1].split(',');
			trace(choicePrefs);
			var shit:String = finalText;
			if (!choicePrefs[0].startsWith('&')) {
			    var choicesText:Array<String> = [];
			    for (choice in choicePrefs) {
			        var choiceSplitted = choice.split('-');
					trace(choiceSplitted);
			        choicesText.push(choiceSplitted[1]);
			    }
				trace(choicesText);
			    for (i in 0...choicesText.length) {
				    shit += ' ' + choicesText[i];
			    }
				trace(shit);
			} else {
				shit = finalText;
			}
			allowInput = true;
			return shit + endl; //stupid text getting ;-;
		}
	}

	public static function parse(path:String):Array<String>
	{
		var daList:Array<String> = [];
		
		if(FileSystem.exists(Main.getStoragePath() + path)) daList = File.getContent(Main.getStoragePath() + path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}
		trace(daList);
		trace(Main.getStoragePath() + path);

		return daList;
	}

	// str is char not string
	function isNum(str:String):Bool
	{
		var num = Std.parseInt(str);
		if (Math.isNaN(num))
			return false;
		else
			return true;
	}

	function toNum(str:String)
	{
		return Std.parseInt(str);
	}
	
	function clearMess() {
		var textArray = text.text.split("\n");
		var g:Int = 0;
		for (i in 0...textArray.length) {
			g++;
		}
		if (g > 18) {
		    text.text = '';
		}
	}

	function showString(str:String)
	{
		deleteJunk();
		clearMess();
		text.text = text.text + str;
		printText = false;
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
		if (printText) {
		    showString(getNextThing(gameContent));
		}
		if (allowInput) {
			for (touch in FlxG.touches.list) {
				if (touch.justPressed) {
					allowInput = false;
					nextState++;
					printText = true;
				}
			}
		}

		super.update(elapsed);
	}
}
