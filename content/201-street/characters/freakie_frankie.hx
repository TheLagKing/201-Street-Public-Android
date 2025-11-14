import flixel.text.FlxText;
import funkin.FunkinAssets;
import funkin.objects.stageobjects.ABotVis;
import sys.FileSystem;

//adding abot visualiser for the sake of reading from it
var vis_data:ABotVis;
var microphone_vocals:FlxSound;
function onCreatePost()
{
	mouth = new FlxSprite(152, 513);
	mouth.frames = Paths.getSparrowAtlas('backgrounds/music/Frankie_Mouth');
	mouth.animation.addByPrefix('talk', 'Jaw', 24, false);
	mouth.animation.play('talk');
	mouth.animation.curAnim.curFrame = 0;
	dadGroup.add(mouth);

	eyes = new FlxSprite(120, 420);
	eyes.frames = Paths.getSparrowAtlas('backgrounds/music/Frankie_Eyes');
	eyes.animation.addByIndices('idle', 'Eyes', [0], '', 24, false);
	eyes.animation.addByIndices('left', 'Eyes', [1], '', 24, false);
	eyes.animation.addByIndices('down', 'Eyes', [2], '', 24, false);
	eyes.animation.addByIndices('right', 'Eyes', [3], '', 24, false);
	eyes.animation.addByIndices('up', 'Eyes', [4], '', 24, false);
	eyes.animation.addByIndices('gays', 'Eyes', [5], '', 24, false);
	eyes.animation.addByIndices('red', 'Eyes', [6], '', 24, false);
	eyes.animation.play('idle');

	eyebrows = new FlxSprite(eyes.x + 10, eyes.y - 30);
	eyebrows.frames = Paths.getSparrowAtlas('backgrounds/music/Frankie_Eyebrows');
	eyebrows.animation.addByIndices('idle', 'Eyebrows', [0], '', 24, false);
	eyebrows.animation.addByIndices('stern', 'Eyebrows', [1], '', 24, false);
	eyebrows.animation.addByIndices('angry', 'Eyebrows', [2], '', 24, false);
	eyebrows.animation.addByIndices('shocked', 'Eyebrows', [3], '', 24, false);
	eyebrows.animation.addByIndices('sad', 'Eyebrows', [4], '', 24, false);
	eyebrows.animation.play('idle');
	dadGroup.add(eyes);
	dadGroup.add(eyebrows);

	left_arm = new FlxSprite(-71, 404);
	left_arm.frames = Paths.getSparrowAtlas('backgrounds/music/Frankie_Arm');
	left_arm.animation.addByIndices('idle', 'Arms', [0], '', 24, false);
	left_arm.animation.addByIndices('fist', 'Arms', [1], '', 24, false);
	left_arm.animation.addByIndices('handout', 'Arms', [2], '', 24, false);
	left_arm.animation.addByIndices('point', 'Arms', [3], '', 24, false);
	left_arm.animation.addByIndices('close', 'Arms', [4], '', 24, false);
	left_arm.animation.addByIndices('dance', 'Arms', [5], '', 24, false);
	left_arm.animation.addByIndices('wave', 'Arms', [6], '', 24, false);
	left_arm.animation.addByIndices('droop', 'Arms', [7], '', 24, false);
	left_arm.animation.addByIndices('stretch', 'Arms', [8], '', 24, false);
	left_arm.animation.addByIndices('side', 'Arms', [9], '', 24, false);
	left_arm.animation.addByIndices('cringe', 'Arms', [10], '', 24, false);
	left_arm.animation.play('idle');
	left_arm.origin.set(left_arm.width / 2 + 100, left_arm.height / 2 + 5);

	right_arm = new FlxSprite(left_arm.x + 268, left_arm.y + 4);
	right_arm.frames = Paths.getSparrowAtlas('backgrounds/music/Frankie_Arm');
	right_arm.animation.addByIndices('idle', 'Arms', [0], '', 24, false);
	right_arm.animation.addByIndices('fist', 'Arms', [1], '', 24, false);
	right_arm.animation.addByIndices('handout', 'Arms', [2], '', 24, false);
	right_arm.animation.addByIndices('point', 'Arms', [3], '', 24, false);
	right_arm.animation.addByIndices('close', 'Arms', [4], '', 24, false);
	right_arm.animation.addByIndices('dance', 'Arms', [5], '', 24, false);
	right_arm.animation.addByIndices('wave', 'Arms', [6], '', 24, false);
	right_arm.animation.addByIndices('droop', 'Arms', [7], '', 24, false);
	right_arm.animation.addByIndices('stretch', 'Arms', [8], '', 24, false);
	right_arm.animation.addByIndices('side', 'Arms', [9], '', 24, false);
	right_arm.animation.addByIndices('cringe', 'Arms', [10], '', 24, false);
	right_arm.animation.play('idle');
	right_arm.flipX = true;
	right_arm.origin.set(67, right_arm.height / 2);
	dadGroup.add(left_arm);
	dadGroup.add(right_arm);
	
	var vocal_path = Paths.voices(PlayState.SONG.song, 'opp-raw');
	if(FileSystem.exists("content/201-street/songs/" + Paths.formatToSongPath(PlayState.SONG.song) + '/Voices-opp-raw.ogg') == false){
		vocal_path = Paths.voices(PlayState.SONG.song, 'opp');
	}

	microphone_vocals = new FlxSound().loadEmbedded(vocal_path, false, true);
	microphone_vocals.persist = false;        
	microphone_vocals.volume = 0;
	microphone_vocals.play();
	FlxG.sound.list.add(microphone_vocals);

	ABotVis.BAR_COUNT = 1;
	vis_data = new ABotVis(microphone_vocals, false);
	vis_data.x -= 5000;
	vis_data.y += 100;
	add(vis_data);
}

function onSongStart()
{
	vis_data.snd = microphone_vocals;
	vis_data.initAnalyzer();
}

var arm_anim_array:String = ['idle', 'fist', 'handout', 'point', 'close', 'dance', 'wave'];
var eye_anim_array:String = ['idle', 'left', 'up', 'down', 'right'];
var brow_anim_array:String = ['idle', 'stern', 'shocked', 'sad', 'angry'];
var animPos:Int = 0;

function onUpdatePost(elapsed){
	mouth.animation.play('talk', true, false, 5 - vis_data.group.members[0].animation.curAnim.curFrame);

	if(microphone_vocals.time != Conductor.songPosition){
		microphone_vocals.time = Conductor.songPosition;
	}
}

function onEvent(eventName, value1, value2){
	switch(eventName){
		case 'Freakie Frankie Animations':
			var piece:FlxSprite;

			switch(value1){
				case 'eyes':
					piece = eyes;
				case 'eyebrows':
					piece = eyebrows;
				case 'left_arm':
					piece = left_arm;
				case 'right_arm':
					piece = right_arm;
			}

			piece.animation.play(value2);

			if(piece == left_arm || piece == right_arm){
				switch(piece){
					case left_arm:
						piece.angle -= 3;

					case right_arm:
						piece.angle += 3;
					}

				FlxTween.tween(piece, {angle: 0}, 0.4, {ease: FlxEase.quadOut});
			}
	}
}
