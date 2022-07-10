package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.io.File;
import sys.FileSystem;
import android.os.Environment;
import android.os.Build.VERSION;
import android.Permissions;
import android.PermissionsList;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxButton;
import flixel.input.keyboard.FlxKey;

using StringTools;

class PlayState extends FlxState
{
	var text:FlxText;
	
    //var inputText:FlxUIInputText;
    
    static var nextStatesArray:Array<String> = [];

    inline static var endl:String = '\n';
    
    static var writtenText:String = '';
    
    static var allowedKeys:Array<String> = ["BACKSPACE", "SPACE", "ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
    
    static var km:Bool = false;
    
    static var knownChoices:Array<String> = [];
	
	static var printText:Bool = true;
	
	static var allowInput:Bool = false;
	
	static var requestedPerms:Bool = false;
	
	static var parseGameTxt:Bool = false;
	
	static var nextState:String = "1";

	static var gameContent:Array<String> = [];

	static var testText = 'TEST TEXT (PLACEHOLDER)' + endl;
	
	override public function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;
		text = new FlxText(0, 0, FlxG.width, "", 32);
		text.setFormat("font/font.ttf", 32, FlxColor.WHITE, LEFT);
		text.width = FlxG.width - 200;
		text.x = 100;
		text.y = 100;
		text.textField.width = FlxG.width - 200;
		/*inputText = new FlxUIInputText(140, 110, 1000, '', 32, FlxColor.WHITE);
		inputText.background = false;
		inputText.resize(1000, 500);
		inputText.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		add(inputText);*/
		add(text);
		if (VERSION.SDK_INT > 23 || VERSION.SDK_INT == 23) {
		    Permissions.requestPermissions([PermissionsList.READ_EXTERNAL_STORAGE, PermissionsList.WRITE_EXTERNAL_STORAGE]);
		    requestedPerms = true;
		    parseGameTxt = true;
		} else {
			requestedPerms = true;
		    parseGameTxt = true;
		}

		super.create();
	}

	public static function getNextThing(content:Array<String>, state:String):String {
		knownChoices = [];
		nextStatesArray = [];
		var THESHIT:String = "";
		if (content == null || content.length < 0 || state == "" || state.length < 0) {
			trace("game text is not initialised or state changing have an error, creating test Text");
			THESHIT = FlxG.random.int(0, 1000) + testText;
		} else {
			trace(content);
			var lineContent = content[Std.parseInt(state)].split('|');
			trace(lineContent);
			var statePrefs = lineContent[0].split('=');
			trace(statePrefs);
			var textContent = statePrefs[1];
			trace(textContent);
			var finalText:String = textContent;
			trace(finalText);
			var choicePrefs = lineContent[1].split(',');
			trace(choicePrefs);
			var choiceStates = lineContent[2].split(',');
			for (id in choiceStates) {
				if (!id.contains('&')) {
				    nextStatesArray.push(id);
				}
			}
			var shit:String = finalText;
			if (!choicePrefs[0].startsWith('&')) {
			    var choicesText:Array<String> = [];
			    for (choice in choicePrefs) {
			        var choiceSplitted = choice.split('-');
					trace(choiceSplitted);
			        choicesText.push(choiceSplitted[1]);
			        knownChoices.push(choiceSplitted[0]);
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
			THESHIT = shit + endl;
		}
		return THESHIT; //stupid text getting ;-;
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
	
	function parseKey(key:String) 
    {
		if (key == "BACKSPACE") {
			writtenText = "";
		} else if (key == "ZERO") {
			writtenText += "0";
		} else if (key == "ONE") {
			writtenText += "1";
		} else if (key == "TWO") {
			writtenText += "2";
		} else if (key == "THREE") {
			writtenText += "3";
		} else if (key == "FOUR") {
			writtenText += "4";
		} else if (key == "FIVE") {
			writtenText += "5";
		} else if (key == "SIX") {
			writtenText += "6";
		} else if (key == "SEVEN") {
			writtenText += "7";
		} else if (key == "EIGHT") {
			writtenText += "8";
		} else if (key == "NINE") {
			writtenText += "9";
		}
	}

	override public function update(elapsed:Float)
	{
		if (requestedPerms && parseGameTxt) {
			gameContent = parse("game.txt");
			parseGameTxt = false;
		}
		if (printText && requestedPerms) {
		    showString(getNextThing(gameContent, nextState));
		}
		#if android
		if (FlxG.android.justReleased.BACK) {
			FlxG.stage.window.textInputEnabled = false;
			km = false;
			if (!text.text.endsWith(endl)) {
				text.text += endl;
			}
			text.text += writtenText + endl;
			nextState = writtenText;
			writtenText = "";
		}
		#end
		if (allowInput && requestedPerms) {
			if (km && FlxG.keys.firstJustPressed() != FlxKey.NONE) {
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if (allowedKeys.contains(keyName)) {
					parseKey(keyName);
				}
			}
			for (touch in FlxG.touches.list) {
				var hold:Bool = false;
				var c:Int = 0;
				while (touch.pressed) {
					hold = true;
					c++;
					if (c > 120) {
						km = true;
						if (nextState != "") {
							nextState = "";
						}
						FlxG.stage.window.textInputEnabled = true;
					}
				}
				if (touch.justPressed && !hold && !km) {
					if (knownChoices.contains(nextState)) {
					    allowInput = false;
					    var ns:Int = Std.parseInt(nextState);
					    nextState = Std.string(nextStatesArray[ns]);
					    printText = true;
					} else {
						deleteJunk();
		                clearMess();
						if (!text.text.endsWith(endl) && text.text != "") {
				            text.text += endl;
			            }
						text.text += "ERROR: no such choice, please check text you write for mistakes or check game.txt";
					}
				}
			}
		}

		super.update(elapsed);
	}
}
