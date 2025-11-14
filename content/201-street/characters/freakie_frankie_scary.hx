function opponentNoteHitPre(note){
	if(opponentStrums.owner == gf && note.isSustainNote == false){
		var randomNote:Int = FlxG.random.int(0, 2);
		switch(randomNote){
			case 1:
				note.noteType = 'Alt Animation';
			case 2:
				note.noteType = 'Other Alt Animation';
		}
	}
	else if(note.isSustainNote){
		note.noteType = 'No Animation';
	}
}

var noteArray:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
function opponentNoteHit(note){
	if(opponentStrums.owner == gf && note.noteType == 'Other Alt Animation'){
		opponentStrums.owner.playAnim('sing' + noteArray[note.noteData] + '-alt2');		
	}
}