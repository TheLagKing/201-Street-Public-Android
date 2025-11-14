import funkin.backend.FunkinShader.FunkinRuntimeShader;

var shader:FunkinRuntimeShader;

// [lighter_color, darker_color]
// THANK YOU BASIL FOR THE DARKER SHADES
// THERE'S DEFINITELY AN EASIER WAY TO DO THIS

var possibleColors:Array<Dynamic> = [
	[[226, 226, 224], [152, 130, 148]], // white boy color
	[[255, 105, 105], [152, 53, 62]], // tomongus
	[[255, 0, 60], [152, 0, 35]], // ito color
	[[255, 3, 241], [152, 3, 141]], // hot pink
	[[98, 0, 113], [57, 0, 64]], // jammy purple
	[[25, 0, 254], [15, 0, 148]], // ugly blue
	[[0, 255, 247], [0, 130, 141]], // orbyy color
	[[166, 255, 239], [100, 130, 139]], // connie from dandys world color
	[[0, 255, 14], [0, 129, 10]], // lime green
	[[48, 107, 48], [29, 55, 29]], // shelby color
	[[255, 255, 84], [152, 130, 49]], // i love memes color
	[[255, 134, 0], [152, 68, 0]], // orang color
	[[212, 163, 73], [126, 83, 42]] // ugly ass tan
];

function randomColor()
{
	var pCol = possibleColors[FlxG.random.int(0, possibleColors.length - 1)];
	shader.setFloatArray("r", [pCol[0][0] / 255, pCol[0][1] / 255, pCol[0][2] / 255]);
	shader.setFloatArray("g", [1, 1, 1]);
	shader.setFloatArray("b", [pCol[1][0] / 255, pCol[1][1] / 255, pCol[1][2] / 255]);
}

function onLoad()
{
	shader = newShader('among_us_rgb');
	shader.setFloat('mult', 1);
	global.set('repo', shader);
}

function onCreatePost()
{
	boyfriend.shader = shader;
	randomColor();
}
