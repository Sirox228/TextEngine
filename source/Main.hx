package;

import flixel.FlxGame;
import openfl.display.Sprite;
import android.os.Environment;
import android.os.Build.VERSION;
import android.Permissions;
import lime.app.Application;
import sys.FileSystem;

class Main extends Sprite
{
	private static var storagePath:String = null;
	
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
	}
	
	static public function getStoragePath():String {
		if (storagePath != null && storagePath.length > 0) {
			trace(storagePath);
			return storagePath;
		} else {
			if (VERSION.SDK_INT > 23 || VERSION.SDK_INT == 23) {
			    var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions();
			    if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
				    Application.current.window.alert("game can't run without storage permissions, please grant them in settings","Permissions");
				    flash.system.System.exit(0);
			    }
			}
			var strangePath:String = Environment.getExternalStorageDirectory();
			trace(strangePath);
			if (!FileSystem.exists(strangePath + "/TextEngine")) {
				FileSystem.createDirectory(strangePath + "/TextEngine");
			}
			storagePath = strangePath + "/TextEngine/";
			return storagePath;
		}
	}
}
