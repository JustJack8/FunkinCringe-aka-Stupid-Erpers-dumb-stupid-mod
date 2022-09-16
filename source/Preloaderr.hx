package;

import flixel.ui.FlxBar;
import openfl.filters.ShaderFilter;
#if sys
import sys.io.File;
#end
import flixel.text.*;
import openfl.display.BitmapData;
import openfl.utils.AssetCache;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.*;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.Assets;
import openfl.utils.ByteArray;
import flixel.math.FlxMath;
import haxe.io.Bytes;
import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
#if sys
import sys.FileSystem;
#end
#if newgrounds
import io.newgrounds.NG;
#end
import lime.app.Application;
#if cpp
import sys.thread.Thread;
#end
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class Preloaderr extends MusicBeatState {
	public var loadedTxt:FlxText;
	public var loadedImages:Int = 0;
	public var loadBar:FlxBar;
	public var loadBarSpr:FlxSprite;
	var boolOne:Bool = false;
	var boolTwo:Bool = false;
	var iscompleted:Bool = false;
	var fuck:Bool = false;
	var loadFolders:Array<String> = [
		'assets/shared/images/characters' //Example
    ];
	var loadAmt:Int = 0;
	public static var doneOnce:Bool = false;
	
	override function create() {

		//FileSystem.deleteDirectory('assets/shared/images/characters');

		trace('opened Preloading');
		for (i in loadFolders)
			{
				loadAmt += getItemsInFolder(i);
			}
		trace('attempting to load ${loadAmt} items');
		FlxG.save.bind('funkin', 'ninjamuffin99');
		//PlayerSettings.init();

		FlxG.game.focusLostFramerate = 60;
		// FlxG.sound.muteKeys = muteKeys;
		// FlxG.sound.volumeDownKeys = volumeDownKeys;
		// FlxG.sound.volumeUpKeys = volumeUpKeys;
		#if desktop
		FlxG.keys.preventDefaultKeys = [TAB];
		#end

		FlxG.sound.playMusic(Paths.music('anders_preloading_menu_obama'),0);
        FlxG.sound.playMusic(Paths.music('anders_preloading_menu'),0);
        FlxG.sound.music.fadeIn(1, 0, 0.7);
		Conductor.changeBPM(150);

		PlayerSettings.init();
		ClientPrefs.loadPrefs();

		Highscore.load();
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		loadedTxt = new FlxText(10, 720-90, FlxG.width - 600, "preloading", 32);
		loadedTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadedTxt.scrollFactor.set();
		loadedTxt.borderSize = 1.25;
		//loadedTxt.screenCenter();
		add(loadedTxt);

		loadBar = new FlxBar(0,720-15,LEFT_TO_RIGHT,1280,15,this,'loadedImages',0,loadAmt,true);
		// loadBar.createGradientBar([FlxColor.BLACK, FlxColor.GRAY], [FlxColor.ORANGE, FlxColor.YELLOW],1,180,true,FlxColor.BLACK);
		loadBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE, true, FlxColor.BLACK);
		loadBar.antialiasing = true;
		loadBar.screenCenter(X);
		add(loadBar);

		// FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);//genius momento. agree

		loadedTxt.text = "PRELOADING: 0";
		fuck = true;
		#if cpp
		Thread.create(cacheStuff);
		#else
		cacheStuff();
		#end

		new FlxTimer().start(2, function(tmr:FlxTimer) {
			usingOtherText = !usingOtherText;
		}, 0);

		doneOnce = true;
		
		super.create();
	}
	
	var canOnce:Bool = true;
	var usingOtherText:Bool = false;
	var obamaActivated:Bool = false;
	override public function update(h:Float) {

		//leBg.scale.set(mult, mult);
		//leBg.updateHitbox();
		
		super.update(h);
		
		if (iscompleted) { //  && boolOne && boolTwo
            loadedTxt.text = "PRELOADING: DONE\n";
			if (canOnce) {
				FlxG.sound.destroy(true);
                MusicBeatState.switchState(new TitleState());
				trace(loadedImages);
				canOnce = false;
            }
		}
		if (loadedTxt != null && fuck && !iscompleted) {
			loadedTxt.text = "PRELOADING: " + loadedImages;
		}
	}

	function cacheStuff() { 
		#if sys
		for (i in loadFolders)
			{
				loadfolder(i);
			}
		#end
		iscompleted = true;
	}

	function getItemsInFolder(folder:String) {
		var charpaths = [];
		#if sys
		charpaths = FileSystem.readDirectory(Sys.getCwd() + '/' + folder);
		#end
		var leAmt:Int = 0;

		for (path in charpaths)
		{
			var fullpath = '$folder/$path';

			if (path.contains(".png"))
				leAmt++;
		}
		return leAmt;
	}
	function loadfolder(folder:String) {
		var charpaths = [];
		#if sys
		charpaths = FileSystem.readDirectory(Sys.getCwd() + '/' + folder);
		#end

		for (path in charpaths)
		{
			var fullpath = '$folder/$path';
            //trace(fullpath);

			#if sys
			if (!path.contains('.png') || !FileSystem.exists(Sys.getCwd() + '/' + fullpath))
				continue;

			var bitmap = BitmapData.fromFile(Sys.getCwd() + '/' + fullpath);
			FlxG.bitmap.add(bitmap).persist = true;

			Paths.cache.setBitmapData(fullpath, bitmap);
			// Paths.excludeAsset(fullpath); 
			var stupi:FlxGraphic = FlxGraphic.fromBitmapData(bitmap);
			stupi.persist = true;

			Paths.cachedAsses.set(fullpath, stupi);
			Paths.cachedShit.push(fullpath);
			Paths.cache.clear(fullpath);
			if (Paths.cache.hasBitmapData(fullpath))
				Paths.cache.removeBitmapData(fullpath);
			#end

			loadedImages++;
		}
	}
}