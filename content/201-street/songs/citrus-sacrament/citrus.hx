import funkin.FunkinAssets;
import funkin.utils.CoolUtil;
import flixel.text.FlxText;

var lines:Array<String> = [];
var lyric_text:FlxText;
var curLine:Int = 0;

/*
	the line event makes it go up +1 in the lyrics.txt file it is really unstable and will crack
 */
function onLoad()
{
	lines = CoolUtil.coolTextFile(Paths.getPath('songs/citrus-sacrament/lyrics.txt', null, null, true));
	lines.insert(0, '');
}

function onCreatePost()
{
	lyric_text = new FlxText(0, 500, 1280, '', 32);
	lyric_text.setFormat(Paths.font("ATTFShinGoProBold.ttf"), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	lyric_text.cameras = [camOther];
	add(lyric_text);
	loadNewLine();
}

function onEvent(evName, v1, v2)
{
	switch (evName)
	{
		case 'Monster Events':
			switch (v1)
			{
				case 'line':
					if (ClientPrefs.subtitles){
						curLine += 1;
						loadNewLine(); 
					}
				case 'bye line':
					if (ClientPrefs.subtitles){
						FlxTween.tween(lyric_text, {alpha: 0}, 2);
					}
			}
	}
}

function loadNewLine()
{
	var EMPTYLINE:Bool = lines[curLine] == '';
	// trace(lines[curLine]);
	if (lines[curLine - 1] == '') fadeThisMfOut(false);
	else
	{
		FlxTween.tween(lyric_text, {alpha: 0, y: (EMPTYLINE ? 500 : 480)}, EMPTYLINE ? 1 : 0.2,
			{
				ease: FlxEase.sineIn,
				onComplete: function() {
					fadeThisMfOut(true);
				}
			});
	}
}

function fadeThisMfOut(moveY = true)
{
	lyric_text.alpha = 0;
	if (moveY)
	{
		lyric_text.y = 520;
	}
	lyric_text.text = lines[curLine];
	FlxTween.tween(lyric_text, {alpha: 1, y: 500}, 0.2, {ease: FlxEase.sineOut});
}
