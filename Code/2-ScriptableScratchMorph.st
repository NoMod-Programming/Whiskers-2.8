Morph subclass: #ScriptableScratchMorph
	instanceVariableNames: 'objName blocksBin vars lists isClone media costume costumeChangeMSecs filterPack visibility volume tempoBPM sceneStates '
	classVariableNames: 'BlockColorDict BlockSpecDict DefaultBackgroundForm DefaultSpriteForm DoubleSize Experimental ListBlockColor MeowSound OldMeowPrefixReversed PopSound RandomGen Recorder ScratchOrigin TimerStartMSecs '
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScriptableScratchMorph commentStamp: '<historical>' prior: 0!
I am the superclass of all scriptable Scratch morphs.

Scriptable morphs:
  1. allow the user to add user-defined scripts
  2. allow the user to add user-defined variables
  3. when they are copied, their scripts and variables are copied;
     thereafter, script changes to the original and the copy are entirely independent
  4. can be exported and imported into another Scratch project.
!


!ScriptableScratchMorph methodsFor: 'initialization' stamp: 'EMP 11/5/2015 14:13'!
initialize

	super initialize.
	borderWidth _ 0.
	objName _ self nextInstanceName.
	vars _ Dictionary new.
	lists _ Dictionary new.
	blocksBin _ ScratchScriptsMorph new.
	isClone _ false.
	costume _ self defaultImageMedia.
	media _ OrderedCollection new.
	costumeChangeMSecs _ 0.
	visibility _ 100.
	volume _ 100.
	tempoBPM _ 60.
	sceneStates _ Dictionary new.
! !


!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:25'!
backdropChangedScriptsFor: t1 
	^ (self scripts
		select: [:t2 | t2 isBackdropEventHatMorph])
		select: [:t2 | (t2 respondsToBackdropName: t1)
				& t2 nextBlock notNil]! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 8/2/2004 20:42'!
costume

	^ costume
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 11/30/2004 16:52'!
costumeChangeMSecs
	"Answer the time of the last costume change. Whenever a costume change (or a filter change) occurs, this value is updated from the current millisecond clock. This value is used to optimize redrawing of thumbnails--if costumeChangeMSecs hasn't changed since the last time the thumbnail was updated we don't need to compute a new thumbnail."

	^ costumeChangeMSecs
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 12/9/2005 16:33'!
costumeForm
	"Answer my current costume form, without filtering, rotation or scaling. If my costume is a movie or animation, answer the appropriate frame."

	^ costume compositeForm
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 10/31/2006 12:28'!
filteredForm

	filterPack ifNil: [^ self rotatedForm].

	filterPack filtersActive ifTrue: [  "filter parameters have changed; apply filters"
		ScratchFrameMorph useErrorCatcher
			ifTrue: [[filterPack applyFiltersTo: self rotatedForm]
						ifError: [filterPack _ nil. ^ self rotatedForm]]
			ifFalse: [filterPack applyFiltersTo: self rotatedForm]].
	^ filterPack resultForm
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 1/12/2016 16:18'!
findAnySpec: specString
	
	(blocksBin submorphs select: [:submorph | submorph isKindOf: ProcedureHatBlockMorph]) do: [:hatBlock | ((CommandBlockMorph parseCommandSpec: specString asString) = (CommandBlockMorph parseCommandSpec: hatBlock procedure)) ifTrue: [^ true]].
	^ false! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/3/2004 14:00'!
form
	"Answer my current costume form, without filtering, rotation, or scaling."

	^ self costumeForm
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 11/30/2004 16:33'!
form: aForm

	costume _ (ImageMedia new form: aForm).
	costume mediaName: (self unusedMediaNameFromBaseName: 'costume').
	media addLast: costume.
	self costumeChanged.
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 10/6/2015 14:57'!
getUserName
	^ ''! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 10/6/2015 14:42'!
hideList: t1
	| t3 t4 t5 t2 |
	t2 _ false.
	t4 _ self ownerThatIsA: ScratchStageMorph.
	(self listVarNames includes: t1)
		ifTrue: [t3 _ lists at: t1]
		ifFalse: 
			[t4 ifNil: [^ self].
			(t4 listVarNames includes: t1)
				ifTrue: [t3 _ t4 lists at: t1]
				ifFalse: [^ self]].
	t2
		ifTrue: [t4 addMorph: t3]
		ifFalse: [t3 delete].
	(t5 _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	t5 viewerPane categoryChanged: 'variables'! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 1/8/2006 18:38'!
imageForm
	"Answer a Form showing myself for the purpose of generating a thumbnail."

	^ self filteredForm copy offset: 0@0
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/6/2009 17:39'!
inPresentationMode

	^ (self ownerThatIsA: OffscreenWorldMorph) notNil
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 6/9/2004 09:29'!
isClone

	^ false
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/10/2004 19:46'!
isClone: aBoolean
	"Ignored here. Overridden by my subclasses."! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 4/30/2004 19:05'!
isColorable

	^ false
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 3/2/2003 12:14'!
isScriptable
	"I am a scriptable Scratch object."

	^ true
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 15:14'!
isSprite

	^ false
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 6/2/2009 11:43'!
isVisible

	^ self isHidden not and: [visibility > 0]
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/8/2005 11:44'!
media

	^ media
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 3/15/2003 19:27'!
objName

	^ objName
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/11/2009 11:06'!
objName: aString

	"don't allow renaming a sprite to use a name already in use"
	(self spriteNameInUse: aString) ifTrue: [^ self].
	objName _ aString.
	objName size = 0 ifTrue: [objName _ self nextInstanceName].
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 11/16/2015 16:32'!
procedure: t1

	^ self scripts detect: [:t4 | (t4 isKindOf: ProcedureHatBlockMorph)
					& t4 procedure = t1]
				ifNone: [nil].! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 4/5/2016 15:53'!
procedure: t1 withArgs: t2 
	| t3 |
	t3 _ self scripts detect: [:t4 | (t4 isKindOf: ProcedureHatBlockMorph)
					& t4 procedure = t1]
				ifNone: [^ #()].
	^ (t3 fullCopy startForEvent: t1 args: t2)! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 11/23/2015 14:14'!
removeAllSounds
	media _ media select: [:item | item isSound not]! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'md 11/8/2004 16:39'!
renewFilterPack

	filterPack _ FilterPack new.! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 1/8/2006 18:41'!
rotatedForm
	"By default, just return my costume form. Sprites override this method to do rotation."

	^ self costumeForm

! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'jm 5/9/2005 09:05'!
rotationCenter: aPoint
	"Set my costume's rotation center."

	costume rotationCenter: aPoint.
	self costumeChanged.
! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 10/6/2015 14:42'!
showList: t1
	| t3 t4 t5 t2 |
	t2 _ true.
	t4 _ self ownerThatIsA: ScratchStageMorph.
	(self listVarNames includes: t1)
		ifTrue: [t3 _ lists at: t1]
		ifFalse: 
			[t4 ifNil: [^ self].
			(t4 listVarNames includes: t1)
				ifTrue: [t3 _ t4 lists at: t1]
				ifFalse: [^ self]].
	t2
		ifTrue: [t4 addMorph: t3]
		ifFalse: [t3 delete].
	(t5 _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	t5 viewerPane categoryChanged: 'variables'! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 4/26/2016 16:46'!
whenClonedScripts
	^ self scripts
		select: [:t1 | t1 isWhenCloneHat & t1 nextBlock notNil]! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 10/3/2015 19:10'!
whenTrueGet: anAttribute numberTesting: number
	anAttribute asString = 'timer' ifTrue: [^ self timer].
	anAttribute asString = 'loudness' ifTrue: [^ self soundLevel].
	^ number asNumberNoError - 1! !

!ScriptableScratchMorph methodsFor: 'accessing' stamp: 'EMP 4/29/2016 13:48'!
wordsFrom: aString
	| string |
	string _ 'obsolete '.
	aString do: [:char | char = $: ifTrue: [string _ string, '%n ']].
	^ string! !


!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'EMP 2/24/2016 18:43'!
changeBackdropTo: costumeNameOrIndex
	"Change to the costume indicated by the given name, index, or boolean. Noop if there is no costume of the given name in my library."
	"Note: Costumes can have names that look like numbers, but those numbers have nothing to do with the index of the costume. So, we first try interpreting the argument as a name. If that fails, we try interpreting it as a costume index number."

	| p newCostume i |
	p _ self referencePosition.
	costume suspendPlaying.

	newCostume _ nil.
	(costumeNameOrIndex isKindOf: String) ifTrue: [
		"try interpreting the argument as a costume name"
		newCostume _ self costumeFromName: costumeNameOrIndex.

		"try interpreting the string as a number"
		newCostume ifNil: [
			i _ self interpretStringAsNumberIfPossible: costumeNameOrIndex.
			i isNumber ifTrue: [
				newCostume _ self costumeFromName: (self costumeNameFromNumber: i)]
				ifFalse: [^ self]]].  "string does not match a costume and cannot be coverted to a number"

	"treat other types (number, boolean) as a costume index"
	newCostume ifNil: [
		i _ costumeNameOrIndex asNumberNoError.
		newCostume _ self costumeFromName: (self costumeNameFromNumber: i)].

	newCostume ifNil: [^ self].  "should not happen..."

	costume _ newCostume.
	costume resumePlaying.
	self costumeChanged.
	self referencePosition: p.
	World displayWorldSafely.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 7/10/2004 09:55'!
changeCostumeIndexBy: aNumber
	"Change my costume index by the given amount."

	self costumeIndex: self costumeIndex + aNumber.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 1/13/2006 09:41'!
changeGraphicEffect: effect by: aNumber
	"Change the given graphic effect by the given value."

	filterPack ifNil: [filterPack _ FilterPack new].

	'blur' = effect ifTrue: [filterPack blur: filterPack blur + aNumber].
	'brightness' = effect ifTrue: [filterPack brightnessShift: filterPack brightnessShift + aNumber].
	'fisheye' = effect ifTrue: [filterPack fisheye: filterPack fisheye + aNumber].
	'color' = effect ifTrue: [filterPack hueShift: filterPack hueShift + aNumber].
	'mosaic' = effect ifTrue: [filterPack mosaicCount: filterPack mosaicCount + aNumber].
	'pixelate' = effect ifTrue: [filterPack pixelateCount: filterPack pixelateCount + aNumber].
	'pointillize' = effect ifTrue: [filterPack pointillizeSize: filterPack pointillizeSize + aNumber].
	'saturation' = effect ifTrue: [filterPack saturationShift: filterPack saturationShift + aNumber].
	('transparency' = effect) | ('ghost' = effect) ifTrue: [
		self transparency: self transparency + aNumber].
	'water ripple' = effect ifTrue: [filterPack waterRippleRate: filterPack waterRippleRate + aNumber].
	'whirl' = effect ifTrue: [filterPack whirl: filterPack whirl + aNumber].

	costumeChangeMSecs _ Time millisecondClockValue.
	self changed.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 2/18/2008 11:23'!
changeVisibilityBy: delta
	"Obsolete. Do nothing."
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 6/8/2009 10:26'!
costumeFromName: aString
	"If there is a costume by the given name, return it. Otherwise, return nil."

	| cameraCostume |
	((aString = '*** camera ***') and:
	 [CameraPlugin cameraIsAvailable]) ifTrue: [
		cameraCostume _ CameraMedia new.
		(self class = ScratchStageMorph) ifTrue: [cameraCostume frameExtent: self extent].
		^ cameraCostume].

	^ media
		detect: [:el | el isSound not and: [el mediaName = aString]]
		ifNone: [nil]
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 7/10/2004 09:49'!
costumeIndex
	"Answer the index of my current costume."

	^ (media reject: [:m | m isSound])
		indexOf: costume ifAbsent: [1]
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 7/10/2004 09:59'!
costumeIndex: aNumber
	"Set my costume to the costume at the given index modulo my total number of costumes. Costumes are numbered starting at 1."

	| cList i newC |
	cList _ media reject: [:m | m isSound].
	cList size = 0 ifTrue: [^ self].  "should never happen..."
	i _ ((aNumber rounded - 1) \\ cList size) + 1.
	newC _ cList at: i.
	costume == newC ifFalse: [self lookLike: newC mediaName].
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'EMP 10/2/2015 19:59'!
costumeNameFromNumber: aNumber
	"Return a costume name for the given number--rounded and modulo the number of costumes."

	| costumeList i |
	aNumber isNumber ifFalse: [^ aNumber].
	costumeList _ media reject: [:m | m isSound].
	costumeList size = 0 ifTrue: [^ 'costume'].

	i _ ((aNumber rounded - 1) \\ costumeList size) + 1.
	^ (costumeList at: i) mediaName
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 5/22/2005 22:54'!
filterReset

	filterPack _ nil.
	self transparency: 0.
	self costumeChanged.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 9/25/2007 11:48'!
graphicEffectNames
	"Answer a collection of graphic effect names."

	^ #(
		'color'
		'fisheye'
		'whirl'
		'pixelate'
		'mosaic'
		'brightness'
		'ghost')
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 8/10/2008 13:12'!
lookLike: costumeNameOrIndex
	"Change to the costume indicated by the given name, index, or boolean. Noop if there is no costume of the given name in my library."
	"Note: Costumes can have names that look like numbers, but those numbers have nothing to do with the index of the costume. So, we first try interpreting the argument as a name. If that fails, we try interpreting it as a costume index number."

	| p newCostume i |
	p _ self referencePosition.
	costume suspendPlaying.

	newCostume _ nil.
	(costumeNameOrIndex isKindOf: String) ifTrue: [
		"try interpreting the argument as a costume name"
		newCostume _ self costumeFromName: costumeNameOrIndex.

		"try interpreting the string as a number"
		newCostume ifNil: [
			i _ self interpretStringAsNumberIfPossible: costumeNameOrIndex.
			i isNumber ifTrue: [
				newCostume _ self costumeFromName: (self costumeNameFromNumber: i)]
				ifFalse: [^ self]]].  "string does not match a costume and cannot be coverted to a number"

	"treat other types (number, boolean) as a costume index"
	newCostume ifNil: [
		i _ costumeNameOrIndex asNumberNoError.
		newCostume _ self costumeFromName: (self costumeNameFromNumber: i)].

	newCostume ifNil: [^ self].  "should not happen..."

	costume _ newCostume.
	costume resumePlaying.
	self costumeChanged.
	self referencePosition: p.
	World displayWorldSafely.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'EMP 11/20/2015 16:09'!
lookLikeIndex: costumeNameOrIndex
	"Change to the costume indicated by the given name, index, or boolean. Noop if there is no costume of the given name in my library."
	"Note: Costumes can have names that look like numbers, but those numbers have nothing to do with the index of the costume. So, we first try interpreting the argument as a name. If that fails, we try interpreting it as a costume index number."
	"EDIT: Because I am doing this from Scratch 2.0, I wil interperet this ALWAYS as a number"

	| p newCostume i |
	p _ self referencePosition.
	costume suspendPlaying.

	"treat other types (number, boolean) as a costume index"
		i _ costumeNameOrIndex asNumberNoError.
		newCostume _ self costumeFromName: (self costumeNameFromNumber: i).

	newCostume ifNil: [^ self].  "should not happen..."

	costume _ newCostume.
	costume resumePlaying.
	self costumeChanged.
	self referencePosition: p.
	World displayWorldSafely.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 11/28/2006 13:39'!
nextCostume
	"Show the next costume in my costumes list."

	self costumeIndex: self costumeIndex + 1.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 4/4/2005 13:14'!
penDown
	"Overriden by sprites."

	^ false
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 5/19/2009 12:56'!
sayNothing
	"Default behavior does nothing. Overridden in ScratchSpriteMorph."
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'nb 1/7/2008 12:02'!
sceneNames

	^ (self ownerThatIsA: ScratchStageMorph) sceneNames
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 1/13/2006 09:41'!
setGraphicEffect: effect to: aNumber
	"Set the given graphic effect to the given value."

	filterPack ifNil: [filterPack _ FilterPack new].

	'blur' = effect ifTrue: [filterPack blur: aNumber].
	'brightness' = effect ifTrue: [filterPack brightnessShift: aNumber].
	'fisheye' = effect ifTrue: [filterPack fisheye: aNumber].
	'color' = effect ifTrue: [filterPack hueShift: aNumber].
	'mosaic' = effect ifTrue: [filterPack mosaicCount: aNumber].
	'pixelate' = effect ifTrue: [filterPack pixelateCount: aNumber].
	'pointillize' = effect ifTrue: [filterPack pointillizeSize: aNumber].
	'saturation' = effect ifTrue: [filterPack saturationShift: aNumber].
	('transparency' = effect) | ('ghost' = effect) ifTrue: [self transparency: aNumber].
	'water ripple' = effect ifTrue: [filterPack waterRippleRate: aNumber].
	'whirl' = effect ifTrue: [filterPack whirl: aNumber].

	costumeChangeMSecs _ Time millisecondClockValue.
	self changed.
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 2/18/2008 11:23'!
setVisibilityTo: percent
	"Obsolete. Do nothing."
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 5/22/2005 22:46'!
transparency
	"Answer my transparency. 0 is opaque; 100 is transparent."

	^ 100 - self visibility
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 5/23/2005 08:54'!
transparency: aNumber
	"Set my transparency. 0 is opaque; 100 is transparent."

	self visibility: (100 - aNumber abs).
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 8/2/2006 18:10'!
visibility
	"Answer my visibility. 0 is invisible. 100 is fully opaque."

	^ visibility
! !

!ScriptableScratchMorph methodsFor: 'looks ops' stamp: 'jm 2/18/2008 11:19'!
visibility: aNumber
	"Set my visibility. 0 is invisible. 100 is fully opaque."

	visibility _ (aNumber max: 0) min: 100.
	self changed.
! !


!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 12/2/2007 22:13'!
changeTempoBy: aNumber

	self setTempoTo: self tempo + aNumber.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 9/24/2007 17:05'!
changeVolumeBy: aNumber

	self setVolumeTo: volume + aNumber.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/3/2008 09:18'!
drum: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer

	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the drum"
		(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ ScratchNotePlayer new].
		(player _ stage notePlayerFor: self) ifNil: [^ ScratchNotePlayer new].
		^ player copy drumOn: midiKey].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer drumOff].
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 6/3/2009 18:47'!
midiDrumMenu
	"Provides a drop-down menu for setting the drum number."

	| menu |
	menu _ CustomMenu new.
	#(	('Acoustic Bass Drum' 35)
		('Bass Drum 1' 36)
		('Side Stick' 37)
		('Acoustic Snare' 38)
		('Hand Clap' 39)
		('Electric Snare' 40)
		('Low Floor Tom' 41)
		('Closed Hi-Hat' 42)
		('High Floor Tom' 43)
		('Pedal Hi-Hat' 44)
		('Low Tom' 45)
		('Open Hi-Hat' 46)
		('Low-Mid Tom' 47)
		('Hi-Mid Tom' 48)
		('Crash Cymbal 1' 49)
		('High Tom' 50)
		('Ride Cymbal 1' 51)
		('Chinese Cymbal' 52)
		('Ride Bell' 53)
		('Tambourine' 54)
		('Splash Cymbal' 55)
		('Cowbell' 56)
		('Crash Cymbal 2' 57)
		('Vibraslap' 58)
		('Ride Cymbal 2' 59)
		('Hi Bongo' 60)
		('Low Bongo' 61)
		('Mute Hi Conga' 62)
		('Open Hi Conga' 63)
		('Low Conga' 64)
		('High Timbale' 65)
		('Low Timbale' 66)
		('High Agogo' 67)
		('Low Agogo' 68)
		('Cabasa' 69)
		('Maracas' 70)
		('Short Whistle' 71)
		('Long Whistle' 72)
		('Short Guiro' 73)
		('Long Guiro' 74)
		('Claves' 75)
		('Hi Wood Block' 76)
		('Low Wood Block' 77)
		('Mute Cuica' 78)
		('Open Cuica' 79)
		('Mute Triangle' 80)
		('Open Triangle' 81)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), (pair first localizedMIDI)
			action: pair second].
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 3/2/2009 13:02'!
midiInstrument: aNumber
	"Old 'set instrument to _' block. Set the MIDI instrument used for note sounds."

	| stage player |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	(player _ stage notePlayerFor: self) ifNotNil: [
		player instrument: aNumber].
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 6/3/2009 18:34'!
midiInstrumentMenu
	"Provides a drop-down menu for setting the instrument number."

	| menu |
	menu _ CustomMenu new.
	#(	('Acoustic Grand' 1)
		('Bright Acoustic' 2)
		('Electric Grand' 3)
		('Honky-Tonk' 4)
		('Electric Piano 1' 5)
		('Electric Piano 2' 6)
		('Harpsichord' 7)
		('Clavinet' 8)
		('Celesta' 9)
		('Glockenspiel' 10)
		('Music Box' 11)
		('Vibraphone' 12)
		('Marimba' 13)
		('Xylophone' 14)
		('Tubular Bells' 15)
		('Dulcimer' 16)
		('Drawbar Organ' 17)
		('Percussive Organ' 18)
		('Rock Organ' 19)
		('Church Organ' 20)
		('Reed Organ' 21)
		('Accordion' 22)
		('Harmonica' 23)
		('Tango Accordion' 24)
		('Nylon String Guitar' 25)
		('Steel String Guitar' 26)
		('Electric Jazz Guitar' 27)
		('Electric Clean Guitar' 28)
		('Electric Muted Guitar' 29)
		('Overdriven Guitar' 30)
		('Distortion Guitar' 31)
		('Guitar Harmonics' 32)
		('Acoustic Bass' 33)
		('Electric Bass (finger)' 34)
		('Electric Bass (pick)' 35)
		('Fretless Bass' 36)
		('Slap Bass 1' 37)
		('Slap Bass 2' 38)
		('Synth Bass 1' 39)
		('Synth Bass 2' 40)
		('Violin' 41)
		('Viola' 42)
		('Cello' 43)
		('Contrabass' 44)
		('Tremolo Strings' 45)
		('Pizzicato Strings' 46)
		('Orchestral Strings' 47)
		('Timpani' 48)
		('String Ensemble 1' 49)
		('String Ensemble 2' 50)
		('SynthStrings 1' 51)
		('SynthStrings 2' 52)
		('Choir Aahs' 53)
		('Voice Oohs' 54)
		('Synth Voice' 55)
		('Orchestra Hit' 56)
		('Trumpet' 57)
		('Trombone' 58)
		('Tuba' 59)
		('Muted Trumpet' 60)
		('French Horn' 61)
		('Brass Section' 62)
		('SynthBrass 1' 63)
		('SynthBrass 2' 64)
		('Soprano Sax' 65)
		('Alto Sax' 66)
		('Tenor Sax' 67)
		('Baritone Sax' 68)
		('Oboe' 69)
		('English Horn' 70)
		('Bassoon' 71)
		('Clarinet' 72)
		('Piccolo' 73)
		('Flute' 74)
		('Recorder' 75)
		('Pan Flute' 76)
		('Blown Bottle' 77)
		('Shakuhachi' 78)
		('Whistle' 79)
		('Ocarina' 80)
		('Lead 1 (square)' 81)
		('Lead 2 (sawtooth)' 82)
		('Lead 3 (calliope)' 83)
		('Lead 4 (chiff)' 84)
		('Lead 5 (charang)' 85)
		('Lead 6 (voice)' 86)
		('Lead 7 (fifths)' 87)
		('Lead 8 (bass+lead)' 88)
		('Pad 1 (new age)' 89)
		('Pad 2 (warm)' 90)
		('Pad 3 (polysynth)' 91)
		('Pad 4 (choir)' 92)
		('Pad 5 (bowed)' 93)
		('Pad 6 (metallic)' 94)
		('Pad 7 (halo)' 95)
		('Pad 8 (sweep)' 96)
		('FX 1 (rain)' 97)
		('FX 2 (soundtrack)' 98)
		('FX 3 (crystal)' 99)
		('FX 4 (atmosphere)' 100)
		('FX 5 (brightness)' 101)
		('FX 6 (goblins)' 102)
		('FX 7 (echoes)' 103)
		('FX 8 (sci-fi)' 104)
		('Sitar' 105)
		('Banjo' 106)
		('Shamisen' 107)
		('Koto' 108)
		('Kalimba' 109)
		('Bagpipe' 110)
		('Fiddle' 111)
		('Shanai' 112)
		('Tinkle Bell' 113)
		('Agogo' 114)
		('Steel Drums' 115)
		('Woodblock' 116)
		('Taiko Drum' 117)
		('Melodic Tom' 118)
		('Synth Drum' 119)
		('Reverse Cymbal' 120)
		('Guitar Fret Noise' 121)
		('Breath Noise' 122)
		('Seashore' 123)
		('Bird Tweet' 124)
		('Telephone Ring' 125)
		('Helicopter' 126)
		('Applause' 127)
		('Gunshot' 128)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), pair first localizedMIDI
			action: pair second].
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 12/31/2005 12:48'!
midiNoteMenu
	"Provides a drop-down menu for setting the note number."

	| menu midiKey noteName |
	menu _ CustomMenu new.
	midiKey _ 48.
	#(low middle) do: [:oct |
		#(C 'C#' D 'Eb' E F 'F#' G 'Ab' A 'Bb' B) do: [:n |
			n = #C
				ifTrue: [noteName _ oct, ' ', n]
				ifFalse: [noteName _ n].
			menu
				add: '(', midiKey printString, ') ', noteName
				action: midiKey.
			midiKey _ midiKey + 1]].
		menu add: '(72) high C' action: 72.
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/3/2008 09:17'!
noteOn: midiKey duration: beats elapsed: elapsedMSecs from: aNotePlayer

	| stage player |
	aNotePlayer ifNil: [  "first call, start playing the note"
		(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ ScratchNotePlayer new].
		(player _ stage notePlayerFor: self) ifNil: [^ ScratchNotePlayer new].
		^ player copy noteOn: midiKey].

	elapsedMSecs >= ((60000 * beats) // self tempo) ifTrue: [aNotePlayer noteOff].
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/3/2008 09:19'!
noteSelector
	"Returns an instance of a ScratchNoteSelector for selecting notes. This object behaves like a CustomMenu."

	| stageMorph notePlayer |
	stageMorph _ (self ownerThatIsA: ScratchStageMorph).
	stageMorph ifNil: [^ self midiNoteMenu].
	notePlayer _ stageMorph notePlayerFor: self.
	notePlayer ifNil: [^ self midiNoteMenu].

	^ ScratchNoteSelector new setNotePlayer: notePlayer
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 6/3/2009 18:45'!
numberInParens: aNumber

	^ (UTF32 with: 16r200E) asUTF8, '(' asUTF8, aNumber printString, ') '
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/20/2006 12:37'!
playMidi: fileName
	"Play the midi file with the given name."

	| fname score player |
	fname _ fileName, '.mid'.
	(FileDirectory default fileExists: fname) ifFalse: [^ self].
	score _ (MIDIFileReader scoreFromFileNamed: fname).
	player _ ScorePlayer onScore: score.
	player openMIDIPort: 0.
	player play.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/5/2007 16:49'!
playSound: soundName

	| snd |
	snd _ self soundNamed: soundName ifAbsent: [^ self].
	snd playFromStart.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 12/4/2007 17:45'!
rest: duration elapsed: elapsed from: ignored
	"Do nothing; just wait for the time interval to elapse."

	^ nil
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 5/5/2007 16:50'!
rewindSound: soundName
	"Rewind the given sound."

	| snd |
	snd _ self soundNamed: soundName ifAbsent: [^ self].
	snd rewindSound.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 3/19/2009 14:22'!
setInstrument: aNumber
	"New 'set instrument to _' block. Set the instrument used for note sounds. Testing in beta but reverted."

	| stage map n player |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	map _ #(1 30 25 35).
	n _ aNumber asNumberNoError asInteger.
	(n between: 1 and: map size)
		ifTrue: [n _ map at: n]
		ifFalse: [n _ 1].
	(player _ stage notePlayerFor: self) ifNotNil: [
		player instrument: n].
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 6/3/2009 18:47'!
setInstrumentMenu
	"Provides a drop-down menu for setting the instrument number."

	| menu |
	menu _ CustomMenu new.
	#(	('Piano' 1)
		('Electric Guitar' 2)
		('Acoustic Guiar' 3)
		('Bass' 4)
	) do: [:pair |
		menu
			add: (self numberInParens: pair second), (pair first localizedMIDI)
			action: pair second].
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 11/28/2007 12:56'!
setTempoTo: aNumber

	| stage |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	stage setTempoTo: aNumber.
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 10/19/2007 12:09'!
setVolumeTo: aNumber

	| stage player |
	volume _ aNumber within: 0 and: 100.
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		(player _ stage notePlayerFor: self) ifNotNil: [
			player volume: volume]].

	media do: [:snd |
		snd isSound ifTrue: [snd volume: volume]].
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 8/10/2008 12:14'!
soundFromIndex: aNumber
	"Return a sound for the given number--rounded and modulo the number of costumes. Return nil if there are not sounds."

	| soundList i |
	soundList _ media select: [:m | m isSound].
	soundList size = 0 ifTrue: [^ nil].

	i _ ((aNumber rounded - 1) \\ soundList size) + 1.
	^ soundList at: i
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 8/10/2008 12:25'!
soundNamed: soundNameOrIndex ifAbsent: absentBlock
	"Return a SoundMedia with the given name (ignoring case differences) or index. If there is none, return the result of evaluating the given block."

	| snd i |
	snd _ nil.
	(soundNameOrIndex isKindOf: String) ifTrue: [ "first, try using the argument as a sound name"
		snd _ media
			detect: [:el | el isSound and: [el mediaName caseInsensitiveEqual: soundNameOrIndex]]
			ifNone: [nil].

		snd ifNil: [
			i _ self interpretStringAsNumberIfPossible: soundNameOrIndex.
			i isNumber ifTrue: [
				snd _ self soundFromIndex: i]].

		snd ifNil: [^ absentBlock value]].

	snd ifNil: [snd _ self soundFromIndex: soundNameOrIndex asNumberNoError].

	snd
		ifNil: [^ absentBlock value]
		ifNotNil: [^ snd]

! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 11/27/2007 11:28'!
tempo

	| stage |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ 60].
	^ stage tempo
! !

!ScriptableScratchMorph methodsFor: 'sound ops' stamp: 'jm 9/24/2007 17:14'!
volume

	^ volume
! !


!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 2/11/2009 09:48'!
answer

	^ ScratchPrompterMorph lastAnswer
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 10/25/2007 20:33'!
asciiFor: keyName

	| localizedKey |
	keyName size = 1 ifTrue: [^ keyName first asciiValue].

	localizedKey _ keyName localized.
	'space' localized = localizedKey ifTrue: [^ Character space asciiValue].
	'enter' localized = localizedKey ifTrue: [^ Character cr asciiValue].
	'up arrow' localized = localizedKey ifTrue: [^ 30].
	'down arrow' localized = localizedKey ifTrue: [^ 31].
	'right arrow' localized = localizedKey ifTrue: [^ 29].
	'left arrow' localized = localizedKey ifTrue: [^ 28].

	"needed to support old projects:"
	'up' = keyName ifTrue: [^ 30].
	'down' = keyName ifTrue: [^ 31].
	'right' = keyName ifTrue: [^ 29].
	'left' = keyName ifTrue: [^ 28].

	^ -1  "no match; should never happen"
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 10/2/2007 17:48'!
attributeNames

	^ vars keys
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 6/8/2009 10:36'!
coerceSpriteArg: anObject
	"Coerce the given object to a sprite reference if necessary. If it is a Symbol (e.g. #mouse), just return it. If it is a String, try to find a Sprite with that name. If it is a Number, coerce it to a string and look for a Sprite with a matching name."

	| s targetName |
	(anObject isKindOf: ScriptableScratchMorph) ifTrue: [^ anObject].
	(anObject isKindOf: Symbol) ifTrue: [^ anObject].

	targetName _ anObject isNumber ifTrue: [anObject printString] ifFalse: [anObject].

	(s _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ nil].
	s submorphsDo: [:m |
		((m isKindOf: ScriptableScratchMorph) and:
		 [targetName = m objName])
			ifTrue: [^ m]].

	^ nil

! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 10/2/2007 17:47'!
getAttribute: attr
	"Answer the value of my variable or built-in attribute with the given name. Answer zero if I have no attribute or variable with the given name."

	(vars includesKey: attr) ifTrue: [^ vars at: attr].
	^ 0
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 4/1/2009 10:38'!
getAttribute: attr of: anObject
	"Answer the variable or built-in attribute value for the given sprite. Answer zero if the given sprite does not have a built-in attribute or variable of the given name."

	| aSpriteOrStage |
	aSpriteOrStage _ self coerceSpriteArg: anObject.

	(aSpriteOrStage isKindOf: ScriptableScratchMorph) ifFalse: [^ 0].
	^ aSpriteOrStage getAttribute: attr asString
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'EMP 10/11/2015 19:09'!
getDateOrTime: wanted
	| date time |
	date _ Date today.
	time _ Time now.
	'time' = wanted ifTrue: [^ time asString].
	'hour' = wanted ifTrue: [^ time hours].
	'minute' = wanted ifTrue: [^ time minutes].
	'second' = wanted ifTrue: [^ time seconds].
	'date' = wanted ifTrue: [^ date asString].
	'year' = wanted ifTrue: [^ date year].
	'month' = wanted ifTrue: [^ date monthIndex].
	'day of week' = wanted ifTrue: [^ date weekdayIndexForScratchTwo].
	^ -1! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'ee 11/10/2007 19:20'!
hookupBooleanSensorNames

	^ #(
		'button pressed'
		'connected'
	)
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'ee 6/2/2009 16:29'!
hookupSensorNames

	| sensorNames stage virtualSensors |
	sensorNames _ #(
		'slider'
		'light'
		'sound'
		'resistance'
	).

	sensorNames _ sensorNames, #('-' 'tilt' 'distance'). "WeDo sensors"

	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		stage scratchServer ifNotNil: [
			virtualSensors _ stage scratchServer sensorNames.
			virtualSensors size > 0 ifTrue: [
				^ sensorNames, {'-'}, stage scratchServer sensorNames]]].

	^ sensorNames
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 11/20/2006 12:15'!
hookupSensorNumber
	"Backwards compatibility for old blocks."

	^ (1 to: 8) collect: [:n | n printString]
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 4/11/2007 10:50'!
indexForSensorName: sensorName
	"Answer the index for the given sensor name."

	sensorName startsWithDigit ifTrue: [^ sensorName asNumberNoError].

	'slider' = sensorName		ifTrue: [^ 1].
	'light' = sensorName			ifTrue: [^ 2].
	'sound' = sensorName		ifTrue: [^ 3].
	(sensorName includesSubString: 'button') ifTrue: [^ 4].
	(sensorName includes: $A)	ifTrue: [^ 5].
	(sensorName includes: $B)	ifTrue: [^ 6].
	(sensorName includes: $C)	ifTrue: [^ 7].
	(sensorName includes: $D)	ifTrue: [^ 8].

	^ 1
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 5/12/2006 09:28'!
isLoud

	^ self class soundRecorder meterLevel > 30
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'ee 4/8/2008 12:27'!
keyNames
	"Key names for 'key pressed' block menu. Must keep this list in sync with asciiFor:."

	^ #('up arrow' 'down arrow' 'right arrow' 'left arrow' 'space'),
	   ($a to: $z), ($0 to: $9)
		 collect: [:ch | ch asString]
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 10/19/2006 07:57'!
keyPressed: keyName

	| ch |
	ch _ self asciiFor: keyName.
	(Sensor keyPressed: ch) ifTrue: [^ true].

	"if key is a letter, check the opposite case"
	(ch between: $a asciiValue and: $z asciiValue) ifTrue: [
		^ Sensor keyPressed: ch - 32].
	(ch between: $A asciiValue and: $Z asciiValue) ifTrue: [
		^ Sensor keyPressed: ch + 32].

	^ false
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 8/23/2003 12:22'!
mousePressed

	^ Sensor redButtonPressed
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 5/6/2009 17:45'!
mouseX

	| s centerX |
	DoubleSize ifTrue: [^ (Sensor cursorPoint x - ScratchOrigin x) // 2].

	self inPresentationMode ifFalse: [
		s _ self ownerThatIsA: ScratchStageMorph.
		(s notNil and: [s isQuarterSize]) ifTrue: [
			centerX _ s left + (s width // 4).
			^ 2 * (Sensor cursorPoint x - centerX)]].

	^ Sensor cursorPoint x - ScratchOrigin x
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 5/6/2009 17:45'!
mouseY

	| s centerY |
	DoubleSize ifTrue: [^ (Sensor cursorPoint y - ScratchOrigin y) negated // 2].

	self inPresentationMode ifFalse: [
		s _ self ownerThatIsA: ScratchStageMorph.
		(s notNil and: [s isQuarterSize]) ifTrue: [
			centerY _ s top + (s height // 4).
			^ -2 * (Sensor cursorPoint y - centerY)]].

	^ (Sensor cursorPoint y - ScratchOrigin y) negated
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 6/2/2009 11:27'!
promptForInput: questionString

	| s prompter |
	(s _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	prompter _ ScratchPrompterMorph new.
	((self isKindOf: ScratchStageMorph) | (self isHidden))
		ifTrue: [
			prompter question: questionString]
		ifFalse: [
			self showQuestion: questionString.
			prompter sprite: self].

	prompter left: s center x - (prompter width // 2).
	prompter bottom: s bottom - 5.
	prompter isSticky: true.
	s addMorphFront: prompter.
	prompter grabKeyboardFocus.
	^ prompter

	! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 3/24/2009 16:55'!
promptInProgress

	| s |
	(s _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ false].
	s submorphsDo: [:m |
		(m isKindOf: ScratchPrompterMorph) ifTrue: [^ true]].
	^ false
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 3/23/2009 15:28'!
sensor: sensorName
	"Answer the value of the given sensor, or zero if the sensorboard is not available."

	| stage v sb |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ 0].
	stage scratchServer ifNotNil: [
		v _ stage scratchServer sensorValueFor: sensorName.
		v ifNotNil: [^ v]].

	'tilt' = sensorName ifTrue: [^ WeDoPlugin tilt].
	'distance' = sensorName ifTrue: [^ WeDoPlugin distance].

	sb _ stage sensorBoard.
	sb tryToOpenPort ifFalse: [^ 0].  "could not open"
	^ sb sensor: (self indexForSensorName: sensorName)
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 11/20/2006 12:11'!
sensorPressed: sensorName
	"Answer true if a button connected to the given input of the sensor board is pressed. That is, if the sensor value is less than 10. Answer false if the sensor board cannot be opened."

	| stage sb |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ false].
	sb _ stage sensorBoard.
	sb tryToOpenPort ifFalse: [^ false].  "could not open"
	^ (sb sensor: (self indexForSensorName: sensorName)) < 10
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 5/10/2006 11:12'!
soundLevel

	^ self class soundRecorder meterLevel
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'jm 10/19/2003 09:26'!
timer

	| now |
	now _ Time millisecondClockValue.
	TimerStartMSecs ifNil: [TimerStartMSecs _ now].
	TimerStartMSecs > now ifTrue: [TimerStartMSecs _ now].
	^ (now - TimerStartMSecs) asFloat / 1000.0
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'EMP 1/7/2016 12:42'!
timerReset

	TimerStartMSecs _ Time millisecondClockValue.
	WhenTrueHatBlockMorph allInstancesDo: [:m | m reset]
! !

!ScriptableScratchMorph methodsFor: 'sensing ops' stamp: 'EMP 11/2/2015 19:24'!
timestamp
	| d tempSeconds |
	d _ (((367 * (Date today year) - (((7 * ((Date today year) + (((Date today monthIndex + 9) / 12) floor))) / 4) floor) + (((((275 * (Date today monthIndex)) / 9) floor) + (Date today weekdayIndexForScratchTwo)) - 730530)))).
	tempSeconds _ (((((Time now hours) * 60) + (Time now minutes)) * 60) + (Time now seconds)).
	^ d + (tempSeconds / (24 * 60 * 60))! !


!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 10/3/2015 19:22'!
addGlobalList

	| sFrame listName |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self beep].

	listName _ StringDialog ask: 'List name?'.
	listName size = 0 ifTrue: [^ self].
	sFrame workPane createListNamed: listName.
	sFrame viewerPane categoryChanged: 'data'.
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 10/3/2015 19:22'!
addList

	| sFrame result listName |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self beep].

	result _ NewVariableDialog ask: 'List name?'.
	result = #cancelled ifTrue: [^ self].
	listName _ result first.
	result second
		ifTrue: [self createListNamed: listName]
		ifFalse: [sFrame workPane createListNamed: listName].
	sFrame viewerPane categoryChanged: 'data'.
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 6/3/2008 18:09'!
append: anObject toList: listName

	| list |
	list _ self listNamed: listName ifNone: [^ 0].
	list insertLine: (self asListElement: anObject) at: (list lineCount + 1).

! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 8/13/2008 17:04'!
asListElement: anObject
	"Answer the given object converted to an object suitable for storing in a list."

	(anObject isKindOf: String) ifTrue: [^ anObject].
	anObject isUnicode ifTrue: [^ anObject].
	(anObject isKindOf: Boolean) ifTrue: [
		^ anObject ifTrue: ['1'] ifFalse: ['0']].
	^ anObject printString
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 10:51'!
contentsOfList: listName

	| list |
	list _ self listNamed: listName ifNone: [^ ''].
	^ list concatenatedLines
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'ee 8/7/2008 21:12'!
createListNamed: listName

	| list stage n |
	(self variableNameInUse: listName) ifTrue: [
		self beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	lists at: listName put: (list _ ScratchListMorph new listName: listName target: self).
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		n _ (stage submorphs select: [:m | m isKindOf: ScratchListMorph]) size.
		stage addMorph: (list position: stage topRight - ((list width + 10)@0) + (0@(10+(20*n)))).
		list startStepping].
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 4/28/2016 11:54'!
customBlockFromTuple: tuple receiver: scriptOwner
	"Answer a new block for the given tuple."

	| spec blockColor block argCount arg argBlock |

	(tuple first = #getParam) ifTrue: [spec _ {tuple second. tuple third. tuple second}. blockColor _ (Color r: 89/255 g: 71/255 b: 177/255).] ifFalse: [spec _ {tuple second. (tuple first = #callReporter) ifTrue: [#rs] ifFalse: [#s]. tuple first}. blockColor _ (Color r: 99/255 g: 45/255 b: 153/255).].

	block _ scriptOwner customBlockFromSpec: spec color: blockColor.
	(block isKindOf: CommandBlockMorph) ifTrue: [
		argCount _ block argumentCount min: tuple size - 2.
		(1 to: argCount) do: [:i |
			((#(+ - / * =) includes: block selector) and: [ScratchTranslator isRTLMath]) "RTLMath operators are RTL"
				ifTrue: [arg _ tuple at: ((argCount + 1) - (i - 2))]
				ifFalse: [arg _ tuple at: i + 2].
			(arg isKindOf: Array)
				ifTrue: [  "argument is a block"
					((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
					argBlock _ self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: (block argumentAt: i) by: argBlock]
				ifFalse: [  "argument is a value"
					(block argumentAt: i) defaultValue: arg]].

		(block isKindOf: CBlockMorph) ifTrue: [
			(tuple last isKindOf: Array) ifTrue: [
				block firstBlockList: (self stackFromTupleList: tuple last receiver: scriptOwner)]].

		(block isKindOf: IfElseBlockMorph) ifTrue: [
			arg _ tuple at: tuple size - 1.
			(arg isKindOf: Array) ifTrue: [
				block trueBlock: (self stackFromTupleList: arg receiver: scriptOwner)].
			arg _ tuple at: tuple size.
			(arg isKindOf: Array) ifTrue: [
				block falseBlock: (self stackFromTupleList: arg receiver: scriptOwner)]].

		(block isKindOf: ReporterBlockMorph) ifTrue: [
			((spec at: 2) includes: $b) ifTrue: [block isBoolean: true]]].

	^ block
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 11/24/2015 12:37'!
customBlockFromTupleTwo: tuple receiver: scriptOwner
	"Answer a new block for the given tuple."

	| spec blockColor block argCount arg argBlock |

	(tuple first = #getParam) ifTrue: [spec _ {tuple second. tuple third. tuple second}] ifFalse: [spec _ {tuple second. #s. tuple first}].

	blockColor _ (Color r: 99/255 g: 45/255 b: 153/255).
	block _ scriptOwner customBlockFromSpec: spec color: blockColor.
	(block isKindOf: CommandBlockMorph) ifTrue: [
		argCount _ block argumentCount min: tuple size - 2.
		(1 to: argCount) do: [:i |
			((#(+ - / * =) includes: block selector) and: [ScratchTranslator isRTLMath]) "RTLMath operators are RTL"
				ifTrue: [arg _ tuple at: ((argCount + 1) - (i - 2))]
				ifFalse: [arg _ tuple at: i + 2].
			(arg isKindOf: Array)
				ifTrue: [  "argument is a block"
					((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
					argBlock _ self blockFromTupleTwo: arg receiver: scriptOwner.
					block replaceArgMorph: (block argumentAt: i) by: argBlock]
				ifFalse: [  "argument is a value"
					(block argumentAt: i) defaultValue: arg]].

		(block isKindOf: CBlockMorph) ifTrue: [
			(tuple last isKindOf: Array) ifTrue: [
				block firstBlockList: (self stackFromTupleListTwo: tuple last receiver: scriptOwner)]].

		(block isKindOf: IfElseBlockMorph) ifTrue: [
			arg _ tuple at: tuple size - 1.
			(arg isKindOf: Array) ifTrue: [
				block trueBlock: (self stackFromTupleListTwo: arg receiver: scriptOwner)].
			arg _ tuple at: tuple size.
			(arg isKindOf: Array) ifTrue: [
				block falseBlock: (self stackFromTupleListTwo: arg receiver: scriptOwner)]].

		(block isKindOf: ReporterBlockMorph) ifTrue: [
			((spec at: 2) includes: $b) ifTrue: [block isBoolean: true]]].

	^ block
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 11:38'!
defaultListName

	| stage |
	lists size > 0 ifTrue: [^ lists keys asArray sort first].

	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		stage lists size > 0 ifTrue: [^ stage lists keys asArray sort first]].

	^ ''
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 6/20/2008 11:14'!
deleteLine: lineNum ofList: listName

	| list |
	list _ self listNamed: listName ifNone: [^ self].
	lineNum = 'all' ifTrue: [list clear. ^ self].
	list deleteLineAt: (self lineNum: lineNum forList: list)
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 10/3/2015 19:23'!
deleteList
	"Ask the user which list variable to delete, then remove it."

	| sFrame stage menu choice |
	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	sFrame ifNil: [^ self].

	stage _ sFrame workPane.
	(stage listVarNames isEmpty) & (self listVarNames isEmpty)
		ifTrue: [^ self inform: 'No lists.' localized].

	menu _ CustomMenu new.
	stage listVarNames do: [:v | menu add: v action: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage listVarNames isEmpty ifFalse: [menu addLine].
		self listVarNames do: [:v | menu add: v action: (Array with: v with: #local)]].
	choice _ menu startUp.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage deleteList: choice first]
		ifFalse: [self deleteList: choice first].

	sFrame viewerPane categoryChanged: 'data'.
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jens 9/22/2008 11:31'!
deleteList: listName
	"Delete the list variable with the given name. Do nothing if the variable doesn't exist."

	| stage |
	stage _ self ownerThatIsA: ScratchStageMorph.
	lists removeKey: listName asString ifAbsent: [].
	stage submorphs do: [:m |
		((m isKindOf: ScratchListMorph) and: 
		[(m listName = listName) and: 
		[m target = self]])
			ifTrue: [m delete]].
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/6/2008 20:36'!
getLine: lineNum ofList: listName

	| list |
	list _ self listNamed: listName ifNone: [^ ''].
	^ list lineAt: (self lineNum: lineNum forList: list)
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 6/3/2008 18:09'!
insert: anObject at: lineNum ofList: listName

	| list i |
	list _ self listNamed: listName ifNone: [^ self].
	i _ self lineNum: lineNum forList: list.
	#last = lineNum ifTrue: [i _ list lineCount + 1].
	list insertLine: (self asListElement: anObject) at: i.

! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 11:18'!
lineCountOfList: listName

	| list |
	list _ self listNamed: listName ifNone: [^ 0].
	^ list lineCount
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 7/30/2008 16:26'!
lineNum: lineNum forList: list

	| s |
	lineNum isNumber ifTrue: [^ lineNum asInteger].

	s _ lineNum.
	s isUnicode ifTrue: [s _ String withAll: lineNum].
	(s isKindOf: String) ifTrue: [
		#first = s ifTrue: [^ 1].
		#last = s ifTrue: [^ list lineCount].
		#any = s ifTrue: [
			list lineCount = 0 ifTrue: [^ 1].
			^ (1 to: list lineCount) atRandom].
		^ s asNumberNoError].
	^ 0
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 1/28/2009 10:20'!
list: listName contains: anObject

	| list |
	list _ self listNamed: listName ifNone: [^ false].
	^ list contains: anObject
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 8/10/2008 14:33'!
listIndexForDeleteMenu

	| menu |
	menu _ CustomMenu new.
	#('1' last) do: [:s | menu add: s action: s].
	menu addLine.
	menu add: #all action: #all.
	menu localize.
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 8/10/2008 14:31'!
listIndexMenu

	| menu |
	menu _ CustomMenu new.
	#('1' last any) do: [:s | menu add: s action: s].
	menu localize.
	^ menu
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 10:23'!
listNamed: aString ifNone: aBlock
	"Answer a list with the given name. First check the local list variables, otherwise check the global list variables. If there is no list variable with the given name, return the result of evaluating the given block."

	| result stage |
	(result _ lists at: aString ifAbsent: [nil]) ifNotNil: [^ result].

	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		(result _ stage lists at: aString ifAbsent: [nil]) ifNotNil: [^ result]].

	^ aBlock value
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 7/30/2008 19:38'!
listVarMenu
	"Answer a menu for selecting a list variables."

	| result stage |
	result _ #().
	((stage _ self ownerThatIsA: ScratchStageMorph) notNil & (stage ~= self)) ifTrue: [
		result _ stage listVarNames].

	lists size > 0 ifTrue: [
		result size > 0 ifTrue: [result _ result copyWith: '-'].
		result _ result, self listVarNames].

	^ result
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 14:48'!
listVarNames
	"Answer a list of list variable names."

	^ lists keys asArray sort
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 5/1/2008 10:23'!
lists

	^ lists
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'jm 6/3/2008 18:10'!
setLine: lineNum ofList: listName to: anObject

	| list |
	list _ self listNamed: listName ifNone: [^ ''].
	^ list setLineAt: (self lineNum: lineNum forList: list) to: (self asListElement: anObject)
! !

!ScriptableScratchMorph methodsFor: 'list ops' stamp: 'EMP 10/12/2015 14:33'!
soundsPage: xOffset
	"Answer a morph containing thumbnails of my sounds."

	| bin m y sounds n recBut impBut maxHeight yMargin xMargin separator editor |
	xMargin _ 15.
	yMargin _ 15.

	bin _ ScratchBlockPaletteMorph new color: (Color r: (149/255) g: (154/255) b: (159/255)).

	m _ StringMorph
		contents: 'New sound:' localized
		font: (ScratchFrameMorph getFont: #SoundsPage).
	m color: (Color black).
	bin addMorph: m.

	recBut _ ScratchFrameMorph buttonLabel: 'Record' localized selector: #recordSound.
	recBut target: self.
	bin addMorph: recBut.

	impBut _ ((ScratchFrameMorph buttonLabel: 'Import' localized selector: #importSound) target: self).

	bin addMorph: impBut.

	maxHeight _ (m height max: (impBut height max: recBut height)).
	ScratchTranslator isRTL
		ifTrue: [impBut position: xMargin@(yMargin + ((maxHeight - impBut height) / 2)).
			recBut position: (impBut right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			m position: (recBut right + 4)@(yMargin + ((maxHeight - m height) / 2))]
		ifFalse: [m position: xMargin@(yMargin + ((maxHeight - m height) / 2)).
			recBut position: (m right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			impBut position: (recBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2))].

	separator _ TiledImageMorph new tileForm: (ScratchFrameMorph skinAt: #costumeSeparatorTile).
	bin addMorph: (separator position: (xOffset + 17)@(yMargin + maxHeight + 5)).

	n _ 0.
	y _ yMargin + maxHeight + 9.
	sounds _ media select: [:item | item isSound].
	sounds size > 0 ifTrue: [editor _ ScratchSoundEditorMorph new client: self; sound: (sounds first sound); color: (Color transparent).
	bin addMorph: (editor position: separator topRight)].
	sounds do: [:item |
		m _ MediaItemMorph new.
		m scratchObj: self media: item; position: xOffset@y; editor: editor.
		m setNumber: (n _ n + 1).
		bin addMorph: m.
		y _ y + m height - 1].

	bin submorphs size > 0
		ifTrue: [separator width: (137)"bin firstSubmorph width - 14"]
		ifFalse: [separator width: 240].
	editor ifNotNil: [editor position: separator topRight].
	^ bin
! !


!ScriptableScratchMorph methodsFor: 'string ops' stamp: 'jm 6/22/2009 12:38'!
concatenate: arg1 with: arg2
	"Concatenate two strings. Arguments are converted to strings."

	^ arg1 asString asUTF8, arg2 asString asUTF8
! !

!ScriptableScratchMorph methodsFor: 'string ops' stamp: 'jm 2/26/2009 20:52'!
letter: index of: anObject
	"Answer the ith letter of the given string. Answer the empty string if the index is out of bounds."

	| s i |
	s _ anObject.
	anObject isUnicode
		ifTrue: [s _ anObject asUTF32]
		ifFalse: [s _ anObject asString asUTF32].
	i _ self letterNum: index of: s.
	((i < 1) | (i > s size)) ifTrue: [^ ''].
	^ (UTF32 with: (s at: i)) asUTF8
! !

!ScriptableScratchMorph methodsFor: 'string ops' stamp: 'jm 2/26/2009 20:40'!
letterNum: letterNum of: aString
	"Answer the ith letter of the given string. Answer the empty string if the index is out of bounds."

	| s |
	letterNum isNumber ifTrue: [^ letterNum asInteger].

	s _ letterNum.
	s isUnicode ifTrue: [s _ String withAll: letterNum].
	(s isKindOf: String) ifTrue: [
		#first = s ifTrue: [^ 1].
		#last = s ifTrue: [^ aString size].
		#any = s ifTrue: [
			aString size = 0 ifTrue: [^ 1].
			^ (1 to: aString size lineCount) atRandom].
		^ s asNumberNoError].
	^ 0
! !

!ScriptableScratchMorph methodsFor: 'string ops' stamp: 'jm 4/1/2009 10:21'!
stringLength: anObject

	anObject isUnicode
		ifTrue: [^ anObject asUTF32 size]
		ifFalse: [^ anObject asString asUTF32 size].
! !


!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/8/2009 14:40'!
allMotorsOff
	"Turn all motors off."

	self motorOff: ' '.
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/14/2009 11:11'!
allMotorsOn
	"Turn all motors off."

	self motorOn: ' '.
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/21/2009 21:06'!
motor: motorName direction: directionName
	"Set the direction of the given motor."

	| dir |
	dir _ 0.
	(directionName includesSubString: 'reverse') ifTrue: [dir _ 0].
	(directionName includesSubString: 'this way') ifTrue: [dir _ 1].
	(directionName includesSubString: 'that way') ifTrue: [dir _ -1].

	'A' = motorName ifTrue: [WeDoPlugin motorADirection: dir].
	'B' = motorName ifTrue: [WeDoPlugin motorBDirection: dir].
	' ' = motorName ifTrue: [
		WeDoPlugin motorADirection: dir.
		WeDoPlugin motorBDirection: dir].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 3/26/2009 22:13'!
motor: motorName power: power
	"Set the power level of the given motor (0-100)."

	'A' = motorName ifTrue: [WeDoPlugin motorAPower: power].
	'B' = motorName ifTrue: [WeDoPlugin motorBPower: power].
	' ' = motorName ifTrue: [
		WeDoPlugin motorAPower: power.
		WeDoPlugin motorBPower: power].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'ee 6/2/2009 14:34'!
motorDirection

	^ {
		'this way'.
		'that way'.
		'reverse'
	}
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 3/26/2009 22:10'!
motorNames

	^ #(' ' A B)
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/8/2009 15:59'!
motorOff: motorName
	"Turn the given motor off."

	'A' = motorName ifTrue: [WeDoPlugin motorAOn: false].
	'B' = motorName ifTrue: [WeDoPlugin motorBOn: false].
	' ' = motorName ifTrue: [
		WeDoPlugin motorAOn: false.
		WeDoPlugin motorBOn: false].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 3/26/2009 22:13'!
motorOn: motorName
	"Turn the given motor on."

	'A' = motorName ifTrue: [WeDoPlugin motorAOn: true].
	'B' = motorName ifTrue: [WeDoPlugin motorBOn: true].
	' ' = motorName ifTrue: [
		WeDoPlugin motorAOn: true.
		WeDoPlugin motorBOn: true].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 3/20/2009 17:34'!
motorOn: motorName duration: secs elapsed: elapsedMSecs from: motorID
	"Turn the given motor on for the given number of seconds."

	motorID ifNil: [  "first call, start motor"
		self motorOn: motorName.
		^ motorName].

	elapsedMSecs >= (1000 * secs) ifTrue: [self motorOff: motorID].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/8/2009 15:59'!
motorOnFor: secs elapsed: elapsedMSecs from: motorID
	"Turn all motors on for the given number of seconds."

	motorID ifNil: [  "first call, start motor"
		self motorOn: ' '.
		^ #' '].

	elapsedMSecs >= (1000 * secs) ifTrue: [self motorOff: motorID].
! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/14/2009 11:13'!
setMotorDirection: directionName

	self motor: ' ' direction: directionName.

! !

!ScriptableScratchMorph methodsFor: 'motor ops' stamp: 'jm 4/8/2009 15:59'!
startMotorPower: power

	self motor: ' ' power: power.
	self motorOn: ' '.
! !


!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 6/23/2004 10:05'!
broadcast: name
	"Broadcast the given event name with zero as its argument."

	self broadcast: name withArgument: 0.
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 5/15/2008 13:49'!
broadcast: name withArgument: arg
	"Broadcast the given event with the given argument."

	| stage |
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		stage broadcastEventNamed: name asString with: arg].
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 10/6/2015 14:39'!
computeFunction: functionName of: aNumber
	"Return the result of computing the given mathematical function on the given number."

	'abs' = functionName ifTrue: [^ aNumber abs].
	'floor' = functionName ifTrue: [^ aNumber floor].
	'ceiling' = functionName ifTrue: [^ aNumber ceiling].
	'sqrt' = functionName ifTrue: [^ aNumber sqrt].
	'sin' = functionName ifTrue: [^ aNumber degreesToRadians sin].
	'cos' = functionName ifTrue: [^ aNumber degreesToRadians cos].
	'tan' = functionName ifTrue: [^ aNumber degreesToRadians tan].
	'asin' = functionName ifTrue: [^ (aNumber within: -1.0 and: 1.0) arcSin radiansToDegrees].
	'acos' = functionName ifTrue: [^ (aNumber within: -1.0 and: 1.0) arcCos radiansToDegrees].
	'atan' = functionName ifTrue: [^ aNumber arcTan radiansToDegrees].
	
	'ln' = functionName ifTrue: [^ aNumber ln].
	'log' = functionName ifTrue: [^ aNumber log].
	'e ^' = functionName ifTrue: [^ aNumber exp].
	'10 ^' = functionName ifTrue: [^ 10.0 raisedTo: aNumber].

	^ 0
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 4/26/2016 16:31'!
eventReceived: t1 
	| t2 t3 |
	t2 := t1 extractTargetScriptsFrom: self.
	t3 := t2 asArray
				collect: [:t4 | t4 startForEvent: t1].
	^ t3
		select: [:t4 | t4 notNil]! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 4/26/2016 16:31'!
keypressEventScriptsFor: t1 
	^ self scripts
		select: [:t2 | (t2 respondsToKeyEvent: t1)
				& t2 nextBlock notNil]! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 10/6/2015 14:38'!
mathFunctionNames
	"Answer a collection of math function names."

	^ #(
		'abs'
		'floor'
		'ceiling'
		'sqrt'
		'sin'
		'cos'
		'tan'
		'asin'
		'acos'
		'atan'
		'ln'
		'log'
		'e ^'
		'10 ^')
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 4/26/2016 16:37'!
mouseClickEventScripts
	self isVisible
		ifTrue: [^ self scripts
				select: [:t1 | t1 isMouseClickEventHatMorph & t1 nextBlock notNil]].
	^ #()! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 5/18/2006 07:43'!
mwait: duration elapsed: elapsed from: ignored
	"Do nothing; just wait for the time interval to elapse."

	^ nil
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 4/26/2016 16:31'!
namedEventScriptsFor: t1 
	^ self scripts
		select: [:t2 | (t2 eventNameMatches: t1)
				& t2 nextBlock notNil]! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 10/4/2007 15:23'!
randomFrom: start to: stop
	"Answer a random number within the given range. If both min and max are integers, the result is rounded to the nearest integer."

	| min max result |
	min _ start min: stop.
	max _ start max: stop.
	result _ (RandomGen next * (max - min)) + min.
	min isInteger & max isInteger
		ifTrue: [result _ (RandomGen next * ((max + 1) - min)) truncated + min]
		ifFalse: [result _ (RandomGen next * (max - min)) + min].
	^ result
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'EMP 4/26/2016 16:31'!
startClickEventScripts
	^ self scripts
		select: [:t1 | (t1 eventNameMatches: 'Scratch-StartClicked')
				& t1 nextBlock notNil]! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 8/8/2005 12:21'!
stopAll
	"Stop everything!!"

	| stage |
	stage _ self ownerThatIsA: ScratchStageMorph.
	stage ifNotNil: [stage stopAll].
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 12/1/2006 19:03'!
stopAllSounds
	"Stop all sounds and MIDI notes/drums."

	| stage |
	stage _ self ownerThatIsA: ScratchStageMorph.
	stage ifNotNil: [stage stopAllSounds].
! !

!ScriptableScratchMorph methodsFor: 'other ops' stamp: 'jm 8/22/2003 19:29'!
wait: duration elapsed: elapsed from: ignored
	"Do nothing; just wait for the time interval to elapse."

	^ nil
! !


!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 10/3/2015 19:23'!
addGlobalVariable
	"Ask the user for a variable name, then add a background (global) variable of that name."

	| sFrame varName |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self beep].

	varName _ StringDialog ask: 'Variable name?'.
	varName size = 0 ifTrue: [^ self].
	varName _ varName asUTF8.
	(sFrame workPane variableNameInUse: varName) ifTrue: [
		self beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	sFrame workPane addVariable: varName.
	sFrame viewerPane categoryChanged: 'data'.
	self addWatcherForNewVariable: varName withScope: sFrame workPane.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 10/3/2015 19:23'!
addVariable
	"Ask the user for a variable name, then add a user variable of that name. This version is for sprites and supports the option of making the variable specific to the sprite (i.e. local)."

	| sFrame result varName varOwner |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self beep].

	result _ NewVariableDialog ask: 'Variable name?'.
	result = #cancelled ifTrue: [^ self].
	varName _ result first asUTF8.
	varOwner _ result second ifTrue: [self] ifFalse: [sFrame workPane].
	(varOwner variableNameInUse: varName) ifTrue: [
		self beep.
		DialogBoxMorph warn: 'That variable name is already in use'.
		^ self].

	varOwner addVariable: varName.
	sFrame viewerPane categoryChanged: 'data'.
	self addWatcherForNewVariable: varName withScope: varOwner.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 8/21/2006 11:59'!
addVariable: varName
	"Add a new user variable with the given name to this object. Do nothing if the variable already exists or is built in."

	(vars includesKey: varName asString) ifFalse: [
		vars at: varName asString put: 0].
	self isClone: false.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 6/3/2009 16:43'!
addVariable: varName value: anObject
	"Add a new user variable with the given name to this object. Do nothing if the variable already exists or is built in."

	(vars includesKey: varName asString) ifFalse: [
		vars at: varName asString put: anObject].
	self isClone: false.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 12/1/2007 22:10'!
addWatcherForNewVariable: varName withScope: spriteOrStage
	"Add a watcher on the stage once a variable has been created."

	| sFrame |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	sFrame viewerPane pageViewer submorphs do: [:s | 
		(s isKindOf: ScratchBlockPaletteMorph) ifTrue: [
			s submorphs do: [:block | 
				(block isKindOf: VariableBlockMorph) ifTrue: [
					(block receiver = spriteOrStage) &
					(block commandSpec = varName) ifTrue: [
						(sFrame watcherForBlock: block) ifNil: [
							block toggleWatcher]]]]]].
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/30/2008 18:52'!
allVarNames
	"Answer a set of all variable and list variable names."

	| allNames |
	allNames _ vars keys.
	allNames addAll: lists keys.
	^ allNames

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 12/12/2015 12:25'!
bindVar: oldVarName to: newVarName fromBlock: varBlock

	| blocksToBind sFrame oldPos w newW |
	vars at: newVarName put: (vars at: oldVarName ifAbsent: [^ self]).
	vars removeKey: oldVarName ifAbsent: [^ self].

	sFrame _ (self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	(w _ sFrame watcherForBlock: varBlock) ifNotNil: [oldPos _ w position].

	blocksToBind _ (((CommandBlockMorph allInstances copyWithArray: (SetterBlockMorph allInstances)) copyWithArray: (VariableBlockMorph allInstances)) select: [:block | 
	(block isKindOf: VariableBlockMorph) ifTrue: [(block commandSpec asUTF8) = (oldVarName asUTF8)] ifFalse: [(block isKindOf: SetterBlockMorph) ifTrue: [(block variable asUTF8) = (oldVarName asUTF8)] ifFalse: [(block isKindOf: CommandBlockMorph) ifTrue: [(#(#showVariable: #hideVariable:) includes: (block selector)) ifTrue: [(block args first asUTF8) = (oldVarName asUTF8)] ifFalse: [false]] ifFalse: [false]]]]). "Yes this is messy"

	blocksToBind do: [:block | (block isKindOf: SetterBlockMorph) ifTrue: [block variable: newVarName] ifFalse: [(block isKindOf: VariableBlockMorph) ifTrue: [block commandSpec: newVarName] ifFalse: ["Block must be a CommandBlockMorph" block argMorphs first choice: newVarName]]].

	w ifNotNil: [w delete. newW _ varBlock createWatcher. sFrame showWatcher: newW pos: oldPos].
	sFrame viewerPane categoryChanged: 'data'.

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/7/2008 10:56'!
changeVar: varName by: increment
	"Change the value of the given variable of this object by the given amount."

	| stage n |
	(vars includesKey: varName asString) ifFalse: [
		stage _ self ownerThatIsA: ScratchStageMorph.
		(stage notNil and: [stage ~= self]) ifTrue: [
			stage changeVar: varName by: increment].
		^ self].

	n _ vars at: varName asString ifAbsent: [^ self].
	self setVar: varName to: n asNumberNoError + increment asNumberNoError.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 10/3/2015 19:23'!
deleteVariable
	"Ask the user which user variable to delete, then remove it."

	| sFrame stage menu choice |
	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	sFrame ifNil: [^ self].

	stage _ sFrame workPane.
	(stage varNames isEmpty) & (self varNames isEmpty)
		ifTrue: [^ self inform: 'No variables.' localized].

	menu _ CustomMenu new.
	stage varNames do: [:v | menu add: v action: (Array with: v with: #global)].
	self = stage ifFalse: [
		stage varNames isEmpty ifFalse: [menu addLine].
		self varNames do: [:v | menu add: v action: (Array with: v with: #local)]].
	choice _ menu startUp.
	choice ifNil: [^ self].

	choice second = #global
		ifTrue: [stage deleteVariable: choice first]
		ifFalse: [self deleteVariable: choice first].

	sFrame viewerPane categoryChanged: 'data'.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 12/1/2007 23:55'!
deleteVariable: varName
	"Delete the variable with the given name. Do nothing if the variable doesn't exist."

	| frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNotNil: [frame deleteWatchersForVar: varName ofSprite: self].
	vars removeKey: varName asString ifAbsent: [^ self].
	self isClone: false.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 12/12/2015 11:39'!
deleteVariableOwned: varName
	"Delete the variable with the given name. Do nothing if the variable doesn't exist."

	| frame ss |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNotNil: [frame deleteWatchersForVar: varName ofSprite: self].
	vars removeKey: varName asString ifAbsent: [(ss _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [ss deleteVariable: varName]].
	self isClone: false.
	frame ifNotNil: [frame viewerPane categoryChanged: 'data']
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 8/6/2008 22:10'!
ensureListExists: listName
	"If a list with the given name is not visible to this object, make one."

	| stage |
	(lists includesKey: listName) ifTrue: [^ self].
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		(stage listVarNames includes: listName) ifTrue: [^ self]].

	"list not found; create it"
	lists at: listName put: (ScratchListMorph new listName: listName target: self).

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 8/6/2008 21:05'!
ensureVariableExists: varName
	"Make sure that the variable with the given name is visible to this object. Do nothing if the variable already exists."

	| stage |
	(vars includesKey: varName) ifTrue: [^ self].
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		(stage varNames includes: varName) ifTrue: [^ self]].

	"variable not found; create it"
	vars at: varName asString put: 0.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 11/15/2006 11:32'!
getVar: varName
	"Answer the value of the given user variable of this object, or 0 if the variable has been deleted."

	^ vars at: varName asString ifAbsent: [0]
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/7/2008 10:28'!
hideVariable: varName
	"Hide the watcher(s) for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, hide both. Do nothing if the variable does not exist or is already hidden."

	| stage |
	self showOrHideVariable: varName show: false.

	stage _ self ownerThatIsA: ScratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideVariable: varName show: false].

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 2/24/2016 19:48'!
setListDict: aDictionary
	lists _ aDictionary! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 4/9/2016 16:08'!
setVar: varName to: newValue
	"Set the value of the given variable of this object to the given value."

	| vName stage |
	vName _ varName asString. "convert Symbol to String if needed"
	(vars includesKey: vName) ifFalse: [
		stage _ self ownerThatIsA: ScratchStageMorph.
		(stage notNil and: [stage ~= self]) ifTrue: [
			stage setVar: varName to: newValue.
		^ self]].

	vars at: vName put: newValue.
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'EMP 2/24/2016 19:17'!
setVarDict: aDictionary
	vars _ aDictionary! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 8/3/2008 12:44'!
showOrHideVariable: varName show: showFlag
	"Show the watcher for the given variable. Do nothing if the variable does not exist or is already showing."

	| frame w b palette |
	(self varNames includes: varName) ifFalse: [^ self].
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [
		(w _ self ownerThatIsA: OffscreenWorldMorph) ifNil: [^ self].
		frame _ w frame].

	b _ VariableBlockMorph new commandSpec: varName; receiver: self blockReceiver.
	w _ frame watcherForBlock: b.
	showFlag
		ifTrue: [w ifNil: [frame showWatcher: b createWatcher]]
		ifFalse: [w ifNotNil: [w delete]].

	palette _ frame viewerPane pageViewer contents.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/7/2008 10:17'!
showVariable: varName
	"Show the watcher(s) for the given variable. If the receiver is a sprite and both it and and the stage have the given variable, show both. Do nothing if the variable does not exist or is already showing."

	| stage |
	self showOrHideVariable: varName show: true.

	stage _ self ownerThatIsA: ScratchStageMorph.
	stage ~= self ifTrue: [stage showOrHideVariable: varName show: true].

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 11/15/2006 11:22'!
varNames
	"Answer a list of variable names."

	^ vars keys asArray sort
! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/30/2008 18:41'!
varNamesMenu
	"Answer a list of variable names."

	| varList stage |
	varList _ #().
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [varList _ stage varNames].
	self == stage ifFalse: [
		varList size > 0 ifTrue: [varList _ varList copyWith: #-].
		varList _ varList, self varNames].

	^ varList! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/30/2008 18:36'!
variableBlockColor

	^ Color h: 25 s: 0.88 v: 0.95

! !

!ScriptableScratchMorph methodsFor: 'variables' stamp: 'jm 7/30/2008 18:53'!
variableNameInUse: varName
	"Answer true if the given variable name in the receiver would conflict with an existing variable or list. For example, if the receiver is the Stage and the given variable name is used by any sprite."

	| stage |
	(self allVarNames includes: varName) ifTrue: [^ true].

	self isSprite
		ifTrue: [
			(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ false].
			^ stage allVarNames includes: varName]
		ifFalse: [
			submorphs do: [:m |
				(m isKindOf: ScratchSpriteMorph) ifTrue: [
					(m allVarNames includes: varName) ifTrue: [^ true]]]].

	^ false
! !


!ScriptableScratchMorph methodsFor: 'scripts' stamp: 'ee 5/14/2008 13:00'!
addComment: aScratchCommentMorph
	"Aligns the newly added script below the lowest script in the pane."

	| y bottom |
	y _ 10.
	blocksBin submorphsDo: [:m |
		bottom _  (m fullBounds bottom) - (blocksBin position y).
		(bottom > y) ifTrue: 
			[y _ bottom]].
	aScratchCommentMorph position: blocksBin position + (20@(y+10)).

	blocksBin addMorph: aScratchCommentMorph.
! !

!ScriptableScratchMorph methodsFor: 'scripts' stamp: 'jm 6/26/2006 09:57'!
addStack: aBlockStack
	"Aligns the newly added script below the lowest script in the pane."

	| y bottom |
	y _ 10.
	blocksBin submorphsDo: [:m |
		bottom _  (m fullBounds bottom) - (blocksBin position y).
		(bottom > y) ifTrue: 
			[y _ bottom]].
	aBlockStack position: blocksBin position + (20@(y+10)).

	aBlockStack newScriptOwner: self.
	blocksBin addMorph: aBlockStack.
! !

!ScriptableScratchMorph methodsFor: 'scripts' stamp: 'jm 5/7/2009 15:05'!
duplicate

	| newSprite s |
	newSprite _ self duplicateNoAttach.
	self world activeHand attachMorph: newSprite.

	((s _ self ownerThatIsA: ScratchStageMorph) notNil and:
	 [s isQuarterSize]) ifTrue: [
		self world activeHand drawHalfSize: true].

	^ newSprite
! !

!ScriptableScratchMorph methodsFor: 'scripts' stamp: 'jm 8/10/2007 10:14'!
scripts
	"Answer my scripts, a collection of HatBlockMorphs."

	(blocksBin isKindOf: Morph) ifFalse: [^ blocksBin].
	^ blocksBin submorphs select: [:m | m isKindOf: HatBlockMorph]
! !


!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 10/16/2007 15:32'!
addEventNamesTo: aSet
	"Add the names of all events implemented by this morph, excluding keyboard events. Suppress duplicates (ignoring case differences)."

	(blocksBin isKindOf: Morph) ifFalse: [^ self].
	blocksBin allMorphsDo: [:m |
		(m class = EventTitleMorph) ifTrue: [
			(aSet anySatisfy: [:el | el caseInsensitiveEqual: m eventName]) ifFalse: [
				aSet add: m eventName]]].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/6/2016 14:35'!
addGenericListBlocksTo: page y: startY
	"Add the generic list blocks to the given page starting at the given y offset."

	| addButton deleteButton x y hasLists stage |
	addButton _ ScratchFrameMorph
		buttonLabel: 'Make a list' localized
		selector: #addList.
	(self isKindOf: ScratchStageMorph) ifTrue: [addButton actionSelector: #addGlobalList].

	deleteButton _ ScratchFrameMorph
		buttonLabel: 'Delete a list' localized
		selector: #deleteList.

	x _ 12.
	y _ startY + 2.
	page addMorph: (addButton target: self; position: x@y).
	y _ addButton bottom + 3.
	hasLists _ self listVarNames size > 0.
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		stage listVarNames size > 0 ifTrue: [hasLists _ true]].
	hasLists ifFalse: [^ self].

	page addMorph: (deleteButton target: self; position: x@y).
	y _ deleteButton bottom + 10.

	y _ (self addListReportersTo: page x: x y: y) + 10.

	(self blocksFor: 'list') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y _ y + 17].	"insert a full space"
				(blockOrSym = #~) ifTrue: [y _ y + 7]]	"insert a half space"
			ifFalse: [
				y _ self createBlock: blockOrSym atPosition: x@y onPage: page.
				page submorphs last color: ScriptableScratchMorph listBlockColor]].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 7/30/2008 19:07'!
addGenericVariableBlocksTo: page x: x y: startY
	"Add the generic variable blocks to the given page starting at the given y offset. Answer the new y."

	| y vName stage block varBlocks |
	y _ startY.

	"pick a default variable name"
	vName _ nil.
	stage _ self ownerThatIsA: ScratchStageMorph.
	(stage notNil and: [stage varNames size > 0])
		ifTrue: [
			vName _ stage varNames first]
		ifFalse: [
			self varNames size = 0 ifTrue: [^ y].
			vName _ self varNames first].

	varBlocks _ OrderedCollection new.
	block _ SetterBlockMorph new
		initSetterForVar: vName;
		receiver: self blockReceiver.
	block expressionArg stringExpression: '0'.
	varBlocks add: block.

	block _ SetterBlockMorph new
		initChangerForVar: vName;
		receiver: self blockReceiver.
	block expressionArg numExpression: '1'.
	varBlocks add: block.

	(self blocksFor: 'variables') do: [:b |
		b defaultArgs: (Array with: vName).
		varBlocks add: b].

	varBlocks do: [:b |
		b color: self variableBlockColor.
		page addMorph: (b position: x@y).
		y _ b bottom + 3].

	^ y

! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'ee 8/11/2008 19:52'!
addListReportersTo: page x: x y: startY
	"Add the list block reporters to the given page starting at the given y offset. Answer the new y."

	| y stage b watcherButton yOffset line line2 |
	y _ startY.
	stage _ self ownerThatIsA: ScratchStageMorph.
	(stage notNil and: [stage ~= self]) ifTrue: [
		stage listVarNames do: [:listVarName |
			b _ ListContentsBlockMorph new
				color: ScriptableScratchMorph listBlockColor;
				receiver: stage blockReceiver;
				commandSpec: listVarName;
				selector: #contentsOfList:.
			watcherButton _ self createToggleButtonFor: b.
			yOffset _ (b fullBounds height - watcherButton height) // 2.
			page addMorph: (watcherButton position: x @ (y + yOffset)).
			page addMorph: (b position: (x + watcherButton width + 4)@y).
			y _ y + b height + 3].
		(self listVarNames size > 0) ifTrue: [
			line _ Morph new.
			line
				extent: 90@1;
				color: Color gray darker darker;
				position: x@(y+2).
			line2 _ Morph new.
			line2
				extent: 90@1;
				color: Color gray lighter;
				position: x@(y+3).
			page
				addMorph: line;
				addMorph: line2.
			y _ y + 9]].

	self listVarNames do: [:listVarName |
		b _ ListContentsBlockMorph new
			color: ScriptableScratchMorph listBlockColor;
			receiver: self blockReceiver;
			commandSpec: listVarName;
			selector: #contentsOfList:.
		watcherButton _ self createToggleButtonFor: b.
		yOffset _ (b fullBounds height - watcherButton height) // 2.
		page addMorph: (watcherButton position: x @ (y + yOffset)).
		page addMorph: (b position: (x + watcherButton width + 4)@y).
		y _ y + b height + 3].

	^ y
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'ee 8/11/2008 19:52'!
addVariableReportersTo: page x: x y: startY
	"Add the list block reporters to the given page starting at the given y offset. Answer the new y."

	| y stage b watcherButton yOffset line line2 |
	y _ startY.

	stage _ self ownerThatIsA: ScratchStageMorph.
	(stage notNil and: [stage ~= self]) ifTrue: [
		stage varNames do: [:vName |
			b _ VariableBlockMorph new
				commandSpec: vName;
				receiver: stage blockReceiver.

			watcherButton _ self createToggleButtonFor: b.
			yOffset _ (b fullBounds height - watcherButton height) // 2.
			page addMorph: (watcherButton position: x @ (y + yOffset)).
			page addMorph: (b position: (x + watcherButton width + 4)@y).
			y _ y + b height + 3].
		(self varNames size > 0) ifTrue: [
			line _ Morph new.
			line
				extent: 90@1;
				color: Color gray darker darker;
				position: x@(y+2).
			line2 _ Morph new.
			line2
				extent: 90@1;
				color: Color gray lighter;
				position: x@(y+3).
			page
				addMorph: line;
				addMorph: line2.
			y _ y + 9]].

	self varNames do: [:vName |
		b _ VariableBlockMorph new
			commandSpec: vName;
			receiver: self blockReceiver.

		watcherButton _ self createToggleButtonFor: b.
		yOffset _ (b fullBounds height - watcherButton height) // 2.
		page addMorph: (watcherButton position: x @ (y + yOffset)).
		page addMorph: (b position: (x + watcherButton width + 4)@y).
		y _ y + b height + 3].

	^ y
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 7/7/2008 10:34'!
blockCategories
	"Answer a list of block categories."

	^ (self class blockSpecs select: [:el |
		(el isKindOf: String) and: [el ~= '-' and: [el ~= '~']]]) asArray
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/29/2016 13:33'!
blockFromSpec: spec color: blockColor
	"Create a block from the given block specification. Answer nil if I don't implement the block spec selector."

	| blockLabelSpec blockType selector defaultArgs block rcvr argPermutation newBlockColor |
	blockLabelSpec _ ScratchTranslator translationFor: (spec at: 1).
	argPermutation _ CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	blockType _ spec at: 2.
	selector _ (spec at: 3) asSymbol.
	defaultArgs _ self defaultArgsFor: spec.

	(#(call getParam) includes: (spec third)) ifTrue: [^ self procBlockFromSpec: spec color: blockColor].

	(#(E K M S W B H C Z) includes: blockType) ifTrue: [
		block _ (self hatBlockType: blockType color: blockColor).
		^ block].

	"basic block type: normal or C-shaped"
	(blockType includes: $c)
		ifTrue:	[
			selector = #doIfElse
				ifTrue: [block _ IfElseBlockMorph new isSpecialForm: true]
				ifFalse: [block _ CBlockMorph new isSpecialForm: true]]
		ifFalse:	[
			(blockType includes: $r) | (blockType includes: $b)
				ifTrue: [block _ ReporterBlockMorph new]
				ifFalse: [block _ CommandBlockMorph new]].

	(blockType includes: $b) ifTrue: [block isBoolean: true].
	(blockType includes: $s) ifTrue: [block isSpecialForm: true].
	(blockType includes: $t) ifTrue: [block isTimed: true].

	(ScriptableScratchMorph isSpriteSpecificTarget: self selector: selector)
		ifTrue: [rcvr _ self]
		ifFalse: [rcvr _ self ownerThatIsA: ScratchStageMorph].
	newBlockColor _ blockColor.
	"under this comment is a kind of messy way to check it a block has been implemented in the code yet"
	^ block
		argPermutation: argPermutation;
		color: newBlockColor;
		selector: selector;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/29/2016 13:49'!
blockFromTuple: tuple receiver: scriptOwner
	"Answer a new block for the given tuple."

	| k spec blockColor block argCount arg argBlock |
	k _ tuple first.

	#doForeverIf = k ifTrue: [
		^ self fixForeverIfScript: tuple receiver: scriptOwner].


	(#(call callReporter getParam) includes: k) ifTrue: [
		^ self customBlockFromTuple: tuple receiver: scriptOwner].

	(#(readVariable changeVariable) includes: k) ifTrue: [
		^ self variableBlockFromTuple: tuple receiver: scriptOwner].

	#contentsOfList: = k ifTrue: [
		^ ListContentsBlockMorph new
			color: ScriptableScratchMorph listBlockColor;
			receiver: scriptOwner;
			commandSpec: tuple second;
			selector: #contentsOfList:].

	(#(EventHatMorph KeyEventHatMorph MouseClickEventHatMorph WhenHatBlockMorph whenSceneStarts whenCloned whenSensorGreaterThan procDef) includes: k) ifTrue: [
		block _ self hatBlockFromTuple: tuple receiver: scriptOwner.
		^ block].

	#scratchComment = k ifTrue: [
		block _ ScratchCommentMorph new.
		tuple size > 1 ifTrue: [block commentMorph contents: (tuple at: 2)].
		tuple size > 2 ifTrue: [(tuple at: 3) ifFalse: [block toggleShowing]].
		tuple size > 3 ifTrue: [block width: (tuple at: 4)].
		tuple size > 4 ifTrue: [block anchor: (self blockWithID: (tuple at: 5))].
		^ block].

	#comment: = k ifTrue: [
		block _ CommentBlockMorph new.
		tuple size > 1 ifTrue: [block comment: (tuple at: 2)].
		tuple size > 2 ifTrue: [(tuple at: 3) ifFalse: [block toggleShowing]].
		block color: (Color r: 0.8 g: 0 b: 0).  "obsolete"
		^ block].

	spec _ BlockSpecDict at: k ifAbsent: [nil].
	spec ifNil: [
		^ scriptOwner
			blockFromSpec: {(self wordsFrom: k asString). #-. k}
			color: Color red].

	blockColor _ BlockColorDict at: k ifAbsent: [Color red].
	block _ scriptOwner blockFromSpec: spec color: blockColor.
	(block isKindOf: CommandBlockMorph) ifTrue: [
		argCount _ block argumentCount min: tuple size - 1.
		1 to: argCount do: [:i |
			((#(+ - / * =) includes: block selector) and: [ScratchTranslator isRTLMath]) "RTLMath operators are RTL"
				ifTrue: [arg _ tuple at: ((argCount + 1) - (i - 1))]
				ifFalse: [arg _ tuple at: i + 1].
			(arg isKindOf: Array)
				ifTrue: [  "argument is a block"
					((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
					argBlock _ self blockFromTuple: arg receiver: scriptOwner.
					block replaceArgMorph: (block argumentAt: i) by: argBlock]
				ifFalse: [  "argument is a value"
					(block argumentAt: i) defaultValue: arg]].

		(block isKindOf: CBlockMorph) ifTrue: [
			(tuple last isKindOf: Array) ifTrue: [
				block firstBlockList: (self stackFromTupleList: tuple last receiver: scriptOwner)]].

		(block isKindOf: IfElseBlockMorph) ifTrue: [
			arg _ tuple at: tuple size - 1.
			(arg isKindOf: Array) ifTrue: [
				block trueBlock: (self stackFromTupleList: arg receiver: scriptOwner)].
			arg _ tuple at: tuple size.
			(arg isKindOf: Array) ifTrue: [
				block falseBlock: (self stackFromTupleList: arg receiver: scriptOwner)]].

		(block isKindOf: ReporterBlockMorph) ifTrue: [
			((spec at: 2) includes: $b) ifTrue: [block isBoolean: true]]].

	^ block
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/28/2016 11:54'!
blockFromTupleTwo: oldTuple receiver: scriptOwner
	"Answer a new block for the given tuple."

	| k spec blockColor block argCount arg argBlock tuple interval |
	tuple _ Array new: oldTuple size.
	tuple at: 1 put: ((oldTuple at: 1) asSymbol).
	interval _ 1.
	oldTuple allButFirst do: [:m | interval _ interval + 1. tuple at: interval put: m].
	k _ tuple first asSymbol.

	#doForeverIf = k ifTrue: [
		^ self fixForeverIfScript: oldTuple receiver: scriptOwner].

	(#(call callReporter getParam) includes: k) ifTrue: [
		^ self customBlockFromTupleTwo: tuple receiver: scriptOwner].

	(#(readVariable changeVariable changeVar:by: setVar:to:) includes: k) ifTrue: [
		^ self variableBlockFromTupleTwo: tuple receiver: scriptOwner].

	#contentsOfList: = k ifTrue: [
		^ ListContentsBlockMorph new
			color: ScriptableScratchMorph listBlockColor;
			receiver: scriptOwner;
			commandSpec: tuple second;
			selector: #contentsOfList:].

	(#(EventHatMorph KeyEventHatMorph MouseClickEventHatMorph WhenHatBlockMorph whenSceneStarts whenCloned whenSensorGreaterThan procDef whenGreenFlag whenKeyPressed  whenClicked whenIReceive) includes: k) ifTrue: [
		block _ self hatBlockFromTuple: tuple receiver: scriptOwner.
		^ block].

	#scratchComment = k ifTrue: [
		block _ ScratchCommentMorph new.
		tuple size > 1 ifTrue: [block commentMorph contents: (tuple at: 2)].
		tuple size > 2 ifTrue: [(tuple at: 3) ifFalse: [block toggleShowing]].
		tuple size > 3 ifTrue: [block width: (tuple at: 4)].
		tuple size > 4 ifTrue: [block anchor: (self blockWithID: (tuple at: 5))].
		^ block].

	#comment: = k ifTrue: [
		block _ CommentBlockMorph new.
		tuple size > 1 ifTrue: [block comment: (tuple at: 2)].
		tuple size > 2 ifTrue: [(tuple at: 3) ifFalse: [block toggleShowing]].
		block color: (Color r: 0.8 g: 0 b: 0).  "obsolete"
		^ block].

	spec _ BlockSpecDict at: k ifAbsent: [nil].
	spec ifNil: [
		^ scriptOwner
			blockFromSpec: #('obsolete!!' - yourself)
			color: Color red].

	blockColor _ BlockColorDict at: k ifAbsent: [Color red].
	Transcript show: k asString.
	block _ scriptOwner blockFromSpec: spec color: blockColor.
	Transcript show: block asString.
	(block isKindOf: CommandBlockMorph) ifTrue: [
		argCount _ block argumentCount min: tuple size - 1.
		1 to: argCount do: [:i |
			((#(+ - / * =) includes: block selector) and: [ScratchTranslator isRTLMath]) "RTLMath operators are RTL"
				ifTrue: [arg _ tuple at: ((argCount + 1) - (i - 1))]
				ifFalse: [arg _ tuple at: i + 1].
			(arg isKindOf: Array)
				ifTrue: [  "argument is a block"
					((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
					argBlock _ self blockFromTupleTwo: arg receiver: scriptOwner.
					block replaceArgMorph: (block argumentAt: i) by: argBlock]
				ifFalse: [  "argument is a value"
					(block argumentAt: i) defaultValue: arg]].

		(block isKindOf: CBlockMorph) ifTrue: [
			(tuple last isKindOf: Array) ifTrue: [
				block firstBlockList: (self stackFromTupleListTwo: tuple last receiver: scriptOwner)]].

		(block isKindOf: IfElseBlockMorph) ifTrue: [
			arg _ tuple at: tuple size - 1.
			(arg isKindOf: Array) ifTrue: [
				block trueBlock: (self stackFromTupleListTwo: arg receiver: scriptOwner)].
			arg _ tuple at: tuple size.
			(arg isKindOf: Array) ifTrue: [
				block falseBlock: (self stackFromTupleListTwo: arg receiver: scriptOwner)]].

		(block isKindOf: ReporterBlockMorph) ifTrue: [
			((spec at: 2) includes: $b) ifTrue: [block isBoolean: true]]].

	^ block! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 12/10/2003 18:06'!
blockReceiver
	"Answer the object that is the receiver of my blocks. By default that is myself, but subclasses may re-direct block operations to another object."

	^ self
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 11/30/2007 09:25'!
blockSpecForSelector: aSymbol
	"Answer a block specification string (in English) for the give selector or nil if there is no spec that has the given selector."

	self class blockSpecs do: [:spec |
		((spec isKindOf: Array) and: [(spec at: 3) = aSymbol])
			ifTrue: [^ spec first]].

	^ nil
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jens 3/4/2009 10:52'!
blockWithID: id

	| topBlockList blockList|

	topBlockList _ (blocksBin submorphs select: [:m | (m isKindOf: BlockMorph) ]) reversed.
	blockList _ OrderedCollection new.
	topBlockList do: [:top | (top allMorphs select: [:b| b isKindOf: BlockMorph ]) do: [:m |
		blockList add: m ]].

	^ blockList at: id
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 9/25/2003 12:45'!
blocksBin

	^ blocksBin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/22/2015 18:15'!
blocksBin: aMorph

	blocksBin _ aMorph
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/27/2016 16:00'!
blocksFor: aCategory
	"Answer a collection of blocks for the given category. Mixed with the blocks are dash and tilde symbols (#- and #~) indicating where full and half spaces should be inserted when laying out the blocks."

	| blockColor blocksList category b |
	blockColor _ self class blockColorFor: aCategory.
	blocksList _ OrderedCollection new.
	category _ nil.
	self class blockSpecs do: [:spec |
		((spec isKindOf: String) and: [spec ~= #- and: [spec ~= #~]])
			ifTrue: [category _ spec]
			ifFalse: [
				category = aCategory ifTrue: [
					(spec = #-) | (spec = #~)
						ifTrue: [blocksList addLast: spec]
						ifFalse: [
							(b _ self blockFromSpec: spec color: blockColor) ifNotNil: [
								blocksList addLast: b]]]]].
	aCategory = 'more blocks' ifTrue: [
	(blocksBin submorphs select: [:submorph | submorph isKindOf: ProcedureHatBlockMorph]) do: [:hatBlock | b _ self procBlockFromSpec: {hatBlock procedure asString. #s. #call} color: (Color r: 99/255 g: 45/255 b: 153/255). blocksList addLast: b. 

	Experimental ifTrue: [b _ self procBlockFromSpec: {hatBlock procedure asString. #rs. #callReporter} color: (Color r: 99/255 g: 45/255 b: 153/255). 
	blocksList addLast: b]
]].
	^ blocksList asArray
! !

!ScriptableScratchMorph methodsFor: 'blocks'!
blocksForNoOther: aCategory
	"Answer a collection of blocks for the given category."

	| blockColor blocksList category b |
	blockColor _ self class blockColorFor: aCategory.
	blocksList _ OrderedCollection new.
	category _ nil.
	self class blockSpecs do: [:spec |
		((spec isKindOf: String) and: [spec ~= #- and: [spec ~= #~]])
			ifTrue: [category _ spec]
			ifFalse: [
				category = aCategory ifTrue: [
					(spec = #-) | (spec = #~)
						ifTrue: [nil]
						ifFalse: [
							(b _ self blockFromSpec: spec color: blockColor) ifNotNil: [
								blocksList addLast: b]]]]].
	^ blocksList asArray
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/27/2016 16:06'!
convertStacksToTuples
	"Convert my blocks bin from a morph containing block stack into a collection of (<point>, <tuple>) pairs the represent the same stacks in compact, language-independent form."

	| stacks blocks comments |
	(blocksBin isKindOf: Array) ifTrue: [^ self].  "already converted"

	stacks _ (blocksBin submorphs select: [:m | m respondsTo: #tupleSequence]).
	blocks _ stacks select: [:m | m isBlockMorph].
	comments _ stacks select: [:m | m isKindOf: ScratchCommentMorph].

	blocks _ blocks collect: [:blockM |
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	comments _ comments collect: [:blockM |
		Array
			with: blockM position - blocksBin position
			with: blockM tupleSequence].

	blocksBin _ blocks, comments.
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 10/10/2015 17:13'!
convertStacksToTuplesWithScale: aScale
	"Convert my blocks bin from a morph containing block stack into a collection of (<point>, <tuple>) pairs the represent the same stacks in compact, language-independent form."

	| stacks blocks comments |
	(blocksBin isKindOf: Array) ifTrue: [^ self].  "already converted"

	stacks _ (blocksBin submorphs select: [:m | m respondsTo: #tupleSequence]).
	blocks _ stacks select: [:m | m isKindOf: BlockMorph].
	comments _ stacks select: [:m | m isKindOf: ScratchCommentMorph].

	blocks _ blocks collect: [:blockM |
		Array
			with: ((blockM position - blocksBin position) * (ScratchFrameMorph getScale))
			with: blockM tupleSequence].

	comments _ comments collect: [:blockM |
		Array
			with: ((blockM position - blocksBin position) * (ScratchFrameMorph getScale))
			with: blockM tupleSequence].

	blocksBin _ blocks, comments.
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/3/2015 13:51'!
convertTuplesToStacks
	"Convert my blocks bin from a collection of (<point>, <tuple>) pairs into a morph containing a number of block stacks."
	| tuplesList stack |
	(blocksBin isKindOf: Array) ifFalse: [^ self].  "already converted"
	tuplesList _ blocksBin.
	blocksBin _ ScratchScriptsMorph new.
	tuplesList do: [:pair |
		stack _ self stackFromTupleList: pair second receiver: self.
		stack position: pair first.
		blocksBin addMorph: stack].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/23/2015 10:19'!
convertTuplesToStacksTwo
	"Convert my blocks bin from a collection of (<point>, <tuple>) pairs into a morph containing a number of block stacks."
	| tuplesList stack |
	(blocksBin isKindOf: Array) ifFalse: [^ self].  "already converted"
	tuplesList _ blocksBin.
	blocksBin _ ScratchScriptsMorph new.
	tuplesList do: [:pair |
		stack _ self stackFromTupleListTwo: pair third receiver: self.
		stack position: ((pair first) @ (pair second)).
		blocksBin addMorph: stack].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 10/10/2015 17:11'!
convertTuplesToStacksWithScale: aScale
	"Convert my blocks bin from a collection of (<point>, <tuple>) pairs into a morph containing a number of block stacks."
	| tuplesList stack |
	(blocksBin isKindOf: Array) ifFalse: [^ self].  "already converted"
	tuplesList _ blocksBin.
	blocksBin _ ScratchScriptsMorph new.
	tuplesList do: [:pair |
		stack _ self stackFromTupleList: pair second receiver: self.
		stack position: (pair first * (ScratchFrameMorph getScale)).
		blocksBin addMorph: stack].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/13/2015 10:46'!
costumesPage: xOffset
	"Answer a morph containing thumbnails of my costumes."

	| bin label m y images n recBut impBut photoBut maxHeight xMargin yMargin separator |
	xMargin _ 15.
	yMargin _ 15.

	bin _ ScratchBlockPaletteMorph new color: (Color r: (149/255) g: (154/255) b: (159/255)).

	(self isKindOf: ScratchStageMorph)
		ifTrue: [label _ 'New backdrop:' localized]
		ifFalse: [label _ 'New costume:' localized].
	m _ StringMorph
		contents: label
		font: (ScratchFrameMorph getFont: #CostumesPage).
	m color: Color black.
	bin addMorph: m.

	recBut _ ScratchFrameMorph buttonLabel: 'Paint' localized selector: #drawNewCostume.
	recBut target: self.
	bin addMorph: recBut.

	impBut _ ScratchFrameMorph buttonLabel: 'Import' localized selector: #importImage.
	impBut target: self.
	bin addMorph: impBut.

	photoBut _ ScratchFrameMorph buttonLabel: 'Camera' localized selector: #takePhoto.
	photoBut target: self.
	CameraPlugin cameraIsAvailable ifTrue: [
	bin addMorph: photoBut].

	maxHeight _ (m height max: (impBut height max: (recBut height max: photoBut height))).
	ScratchTranslator isRTL
		ifTrue: [
			photoBut position: xMargin@(yMargin + ((maxHeight - photoBut height) / 2)).
			impBut position: (photoBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2)).
			recBut position: (impBut right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			m position: (recBut right + 4)@(yMargin + ((maxHeight - m height) / 2))]
		ifFalse: [
			m position: xMargin@(yMargin + ((maxHeight - m height) / 2)).
			recBut position: (m right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			impBut position: (recBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2)).
			photoBut position: (impBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2))].

	separator _ TiledImageMorph new tileForm: (ScratchFrameMorph skinAt: #costumeSeparatorTile).
	bin addMorph: (separator position: (xOffset + 17)@(yMargin + maxHeight + 5)).

	y _ yMargin + maxHeight + 9.
	n _ 0.
	images _ media select: [:item | item isImage].
	images do: [:item |
		m _ MediaItemMorph new.
		m scratchObj: self media: item; position: xOffset@y.
		m setNumber: (n _ n + 1).
		item = costume ifTrue: [m highlight: true].
		bin addMorph: m.
		y _ y + m height - 1.].

	bin submorphs size > 0
		ifTrue: [separator width: bin firstSubmorph width - 14]
		ifFalse: [separator width: 240].

	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/14/2015 12:24'!
costumesPage: xOffset for: aScriptEditorMorph
	"Answer a morph containing thumbnails of my costumes."

	| bin label m y images n maxHeight yMargin buttonSpecs buttons button panel x |
	yMargin _ 7.

	bin _ ScratchBlockPaletteMorph new color: (Color r: (149/255) g: (154/255) b: (159/255)).

	(self isKindOf: ScratchStageMorph)
		ifTrue: [label _ 'New backdrop:' localized]
		ifFalse: [label _ 'New costume:' localized].
	m _ StringMorph
		contents: label
		font: (ScratchFrameMorph getFont: #CostumesPage).
	m color: Color black.
	bin addMorph: m.
	m position: bin topLeft + (7@yMargin).
	buttonSpecs _ #(
	"	icon name			selector			tooltip"
	(newSpriteSurprise	chooseFromLibrary	'Choose costume from library')
	(newSpritePaint		drawNewCostume	'Paint new costume')
	(newSpriteLibrary	importImage			'Import costume from file')
	).

	buttons _ buttonSpecs collect: [:spec |
		button _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: (spec at: 1))
			offForm: (ScratchFrameMorph skinAt: (spec at: 1)).
		button 
			target: aScriptEditorMorph;
			actionSelector: (spec at: 2);
			setProperty: #balloonText toValue: (spec at: 3) localized.
		button].
	panel _ AlignmentMorph new color: Color transparent.
	bin addMorph: panel.
	panel position: (m bottomLeft + (0@3)).
	x _ 7.
	buttons do: [:b | panel addMorph: b. b left: x. x _ x + b width - 10].
	"recBut _ ScratchFrameMorph buttonLabel: 'Paint' localized selector: #drawNewCostume.
	recBut target: self.
	bin addMorph: recBut.

	impBut _ ScratchFrameMorph buttonLabel: 'Import' localized selector: #importImage.
	impBut target: self.
	bin addMorph: impBut."

	maxHeight _ buttons last height + m height.
	y _ yMargin + maxHeight + 9.
	n _ 0.
	images _ media select: [:item | item isImage].
	images do: [:item |
		m _ MediaItemMorph new.
		m scratchObj: self media: item; position: 7@y; editor: aScriptEditorMorph.
		m setNumber: (n _ n + 1).
		item = costume ifTrue: [m highlight: true].
		bin addMorph: m.
		y _ y + m height - 1.].

	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/10/2015 14:39'!
createBlock: block atPosition: pos onPage: page
	"Creates a block on the given page. If the block is one that can become a watcher, then a toggle button is created as well."

	| x y changingX toggleButton yOffset frame |
	x _ pos x.
	y _ pos y.
	changingX _ x.
	block canBecomeWatcher ifTrue: [
		toggleButton _ self createToggleButtonFor: block.
		yOffset _ (block fullBounds height - toggleButton fullBounds height) // 2.
		page addMorphBack: (toggleButton position: x@(y+yOffset)).
		changingX _ x + toggleButton fullBounds width + 4].

	block fixBlockLayout; position: changingX@y.
	page addMorphBack: block.
	block canBecomeWatcher ifTrue: [
		frame _ self ownerThatIsA: ScratchFrameMorph.
		page updateWatcherButtonsForFrame: frame].

	^ y + block height + 4.5
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/10/2015 14:40'!
createCallBlock: block atPosition: pos onPage: page
	"Creates a block on the given page. If the block is one that can become a watcher, then a toggle button is created as well."

	| x y changingX toggleButton yOffset frame |
	x _ pos x.
	y _ pos y.
	changingX _ x.
	block canBecomeWatcher ifTrue: [
		toggleButton _ self createToggleButtonFor: block.
		yOffset _ (block fullBounds height - toggleButton fullBounds height) // 2.
		page addMorphBack: (toggleButton position: x@(y+yOffset)).
		changingX _ x + toggleButton fullBounds width + 4].

	block fixBlockLayout; position: changingX@y.
	page addMorphBack: block.
	block canBecomeWatcher ifTrue: [
		frame _ self ownerThatIsA: ScratchFrameMorph.
		page updateWatcherButtonsForFrame: frame].

	^ y + block height + 4.5
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 3/21/2008 14:04'!
createToggleButtonFor: block
	"Create the toggle button for each variable that could be viewed on the stage."

	| toggleButton |
	toggleButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #watcherButton).

	toggleButton
		target: block;
		actionSelector: #toggleWatcher;
		borderWidth: 0;
		setProperty: #balloonText toValue: 'View on stage' localized.

	^ toggleButton
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/28/2016 12:36'!
customBlockFromSpec: spec color: blockColor
	"Create a block from the given block specification. Answer nil if I don't implement the block spec selector."

	| blockLabelSpec blockType selector defaultArgs block rcvr argPermutation |
	blockLabelSpec _ ScratchTranslator translationFor: (spec at: 1).
	argPermutation _ CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	blockType _ spec at: 2.
	selector _ (spec at: 3) asSymbol.
	defaultArgs _ self defaultArgsFor: spec.

	(#(E K M S W Z) includes: blockType) ifTrue: [
		^ (self hatBlockType: blockType) color: blockColor].

	"basic block type: normal or C-shaped"
	(blockType includes: $c)
		ifTrue:	[
			selector = #doIfElse
				ifTrue: [block _ IfElseBlockMorph new isSpecialForm: true]
				ifFalse: [block _ CBlockMorph new isSpecialForm: true]]
		ifFalse:	[
			(blockType includes: $r) | (blockType includes: $b)
				ifTrue: [block _ (selector = #callReporter) ifTrue: [ProcReporterCallBlockMorph new] ifFalse: [CustomReporterMorph new]]
				ifFalse: [block _ ProcCallBlockMorph new]].
	"DialogBoxMorph inform: blockType asString."
	(blockType includes: $b) ifTrue: [block isBoolean: true].
	(blockType includes: $s) ifTrue: [block isSpecialForm: true].
	(blockType includes: $t) ifTrue: [block isTimed: true].

	rcvr _ self.

	^ block
		argPermutation: argPermutation;
		color: blockColor;
		selector: selector;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/6/2016 14:32'!
defaultArgsFor: blockSpec
	"Answer the default argument for the given block specification."

	| defaultArgs stage sel currentSize list |
	defaultArgs _ blockSpec copyFrom: 4 to: blockSpec size.  "may be empty"
	stage _ self ownerThatIsA: ScratchStageMorph.

	sel _ (blockSpec at: 3) asSymbol.
	#gotoX:y: = sel ifTrue: [
		defaultArgs _ Array
			with: self referencePosition x rounded
			with: self referencePosition y rounded].

	#gotoSpriteOrMouse: = sel ifTrue: [
		defaultArgs _ Array with: #mouse].

	#glideSecs:toX:y:elapsed:from: = sel ifTrue: [
		defaultArgs _ Array
			with: 1
			with: self referencePosition x rounded
			with: self referencePosition y rounded].

	#motor:direction: = self ifTrue: [
		defaultArgs _ Array with: 'reverse' localized with: 'this way' localized with: 'that way'].

	#setSizeTo: = sel ifTrue: [
		currentSize _ (100.0 * (self scalePoint x max: self scalePoint y)) rounded.
		defaultArgs _ Array with: currentSize].

	#getAttribute:of: = sel ifTrue: [
		(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
			list _ stage submorphs select: [:m | m isKindOf: ScratchSpriteMorph].
			list sort: [:s1 :s2 | s1 objName asLowercase < s2 objName asLowercase].
			list size > 0
				ifTrue: [defaultArgs _ Array with: 'x position' with: list first]
				ifFalse: [defaultArgs _ Array with: 'backdrop #' with: stage]]
		ifNil:[defaultArgs _ Array with: 'x position' with: self]].

	#concatenate:with: = sel ifTrue: [
		defaultArgs _ Array with: 'hello ' localized with: 'world' localized].

	#doAsk = sel ifTrue: [
		defaultArgs _ Array with: 'What''s your name?' localized].

	#letter:of: = sel ifTrue: [
		defaultArgs _ Array with: 1 with: 'world' localized].

	#stringLength: = sel ifTrue: [
		defaultArgs _ Array with: 'world' localized].

	#say:duration:elapsed:from: = sel ifTrue: [
		defaultArgs _ Array with: 'Hello!!' localized with: 2].

	#say: = sel ifTrue: [
		defaultArgs _ Array with: 'Hello!!' localized].

	#think:duration:elapsed:from: = sel ifTrue: [
		defaultArgs _ Array with: 'Hmm...' localized with: 2].

	#think: = sel ifTrue: [
		defaultArgs _ Array with: 'Hmm...' localized].

	(#(lookLike: showBackground: startSceneAndWait) includes: sel) ifTrue: [
		defaultArgs _ Array with: (((self costumeNames) size > 0) ifTrue: [self costumeNames last] ifFalse: [''])].

	(#(playSound: doPlaySoundAndWait) includes: sel) ifTrue: [
		list _ self soundNames.
		defaultArgs _ list size <= 2
			ifTrue: [Array with: '']
			ifFalse: [Array with: (list at: (list size - 2))]].

	(#(broadcast: doBroadcastAndWait) includes: sel) ifTrue: [
		stage ifNotNil: [defaultArgs _ Array with: stage defaultEventName]].

	(#(append:toList: deleteLine:ofList: insert:at:ofList:) includes: sel) ifTrue: [
		defaultArgs size >= 1 ifTrue: [
			defaultArgs at: 1 put: (defaultArgs at: 1) localized]].

	(#(append:toList: deleteLine:ofList: getLine:ofList: insert:at:ofList: lineCountOfList: showList: hideList:)
		includes: sel) ifTrue: [
			defaultArgs _ defaultArgs copyWith: self defaultListName].

	#setLine:ofList:to: = sel ifTrue: [
		defaultArgs size >= 3 ifTrue: [
			defaultArgs at: 2 put: self defaultListName.
			defaultArgs at: 3 put: (defaultArgs at: 3) localized]].

	#appendLettersOf:toList: = sel ifTrue: [
		defaultArgs size >= 2 ifTrue: [
			defaultArgs at: 1 put: (defaultArgs at: 1) localized.
			defaultArgs at: 2 put: self defaultListName]].

	#list:contains: = sel ifTrue: [
		defaultArgs size >= 2 ifTrue: [
			defaultArgs at: 1 put: self defaultListName.
			defaultArgs at: 2 put: (defaultArgs at: 2) localized]].

	^ defaultArgs
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/6/2016 15:34'!
fixForeverIfScript: tuple receiver: scriptOwner
	| blockColor block arg argBlock |
	blockColor _ BlockColorDict at: #doForever ifAbsent: [Color red].
	block _ scriptOwner blockFromSpec: #('if %b' #c doIf) color: blockColor.
	((arg _ tuple second) isKindOf: Array) ifTrue: [
		((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
		argBlock _ self blockFromTupleTwo: arg receiver: scriptOwner.
		block replaceArgMorph: (block argumentAt: 1) by: argBlock].
	tuple third ifNotNil: [
	block firstBlockList: (self stackFromTupleList: tuple third receiver: scriptOwner)].
	^ (scriptOwner blockFromSpec: #('forever' #c #doForever) color: blockColor) firstBlockList: block; yourself.! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/6/2016 15:39'!
hatBlockFromTuple: tuple receiver: scriptOwner
	"Answer a new block for the given hat block reference tuple."

	| blockClass block eventName arg |
	((tuple first) == #whenSceneStarts) ifTrue: [blockClass _ Smalltalk at: #BackdropHatBlockMorph] ifFalse: [((tuple first) == #whenCloned) ifTrue: [blockClass _ Smalltalk at: #WhenCloneHatBlock] ifFalse: [((tuple first) == #whenSensorGreaterThan) ifTrue: [blockClass _ Smalltalk at: #WhenTrueHatBlockMorph] ifFalse: [((tuple first) == #procDef) ifTrue: [blockClass _ Smalltalk at: #ProcedureHatBlockMorph] ifFalse: [((tuple first) == #whenGreenFlag) ifTrue: [blockClass _ Smalltalk at: #EventHatMorph] ifFalse: [((tuple first) == #whenKeyPressed) ifTrue: [blockClass _ Smalltalk at: #KeyEventHatMorph] ifFalse: [((tuple first) == #whenClicked) ifTrue: [blockClass _ Smalltalk at: #MouseClickEventHatMorph] ifFalse: [((tuple first) == #whenIReceive) ifTrue: [blockClass _ Smalltalk at: #EventHatMorph] ifFalse: [blockClass _ Smalltalk at: tuple first]]]]]]]].

	block _ blockClass new scriptOwner: scriptOwner.
	blockClass = EventHatMorph ifTrue: [
		(tuple size > 1) ifTrue: [
		eventName _ tuple at: 2.
		eventName = 'Scratch-StartClicked'
			ifTrue: [block forStartEvent; scriptOwner: scriptOwner]
			ifFalse: [block eventName: eventName]] ifFalse: [block forStartEvent; scriptOwner: scriptOwner]].

	blockClass = KeyEventHatMorph ifTrue: [
		block choice: (tuple at: 2)].

	blockClass = BackdropHatBlockMorph ifTrue: [
		block choice: (tuple at: 2)].

	blockClass = WhenHatBlockMorph ifTrue: [
		((tuple at: 2) isKindOf: Array) ifTrue: [
			arg _ self blockFromTuple: (tuple at: 2) receiver: scriptOwner.
			block replaceArgMorph: block argMorph by: arg].
		].

	blockClass = WhenCloneHatBlock ifTrue: [
		eventName _ 'Scratch-StartedAsClone'.
		block forStartEvent; scriptOwner: scriptOwner].

	blockClass = WhenTrueHatBlockMorph ifTrue: [
		((tuple at: 3) isKindOf: Array) ifTrue: [
			arg _ self blockFromTuple: (tuple at: 3) receiver: scriptOwner.
			block replaceArgMorph: block argMorph by: arg]
		ifFalse: [block argMorph numExpression: (tuple at: 3)].
		block choice: (tuple at: 2)].
	
	blockClass = ProcedureHatBlockMorph ifTrue: [
		block _ (ProcedureHatBlockMorph fromSpec: (tuple at: 2) params: (tuple at: 3) isAtomic: (tuple at: 5)) scriptOwner: self ].

	^ block! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 10/5/2015 11:59'!
hatBlockType: blockType

"old; obsolete version of code"
	| stage evtName |
	'E' = blockType ifTrue: [
		evtName _ ''.
		(stage _ self ownerThatIsA: ScratchStageMorph)
			ifNotNil: [evtName _ stage defaultEventName].
		^ EventHatMorph new scriptOwner: self; eventName: evtName].

	'K' = blockType ifTrue: [^ KeyEventHatMorph new scriptOwner: self].
	'M' = blockType ifTrue: [^ MouseClickEventHatMorph new scriptOwner: self].
	'S' = blockType ifTrue: [^ EventHatMorph new forStartEvent scriptOwner: self].
	'W' = blockType ifTrue: [^ WhenHatBlockMorph new scriptOwner: self].
	'B' = blockType ifTrue: [^ BackdropHatBlockMorph new scriptOwner: self].
	'C' = blockType ifTrue: [^ WhenCloneHatBlock new scriptOwner: self; forStartEvent].
	'H' = blockType ifTrue: [^ WhenTrueHatBlockMorph new scriptOwner: self].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 1/6/2016 15:41'!
hatBlockType: blockType color: aColor

	| stage evtName |
	'E' = blockType ifTrue: [
		evtName _ ''.
		(stage _ self ownerThatIsA: ScratchStageMorph)
			ifNotNil: [evtName _ stage defaultEventName].
		^ EventHatMorph new scriptOwner: self; eventName: evtName].

	'K' = blockType ifTrue: [^ KeyEventHatMorph new scriptOwner: self; color: aColor].
	'M' = blockType ifTrue: [^ MouseClickEventHatMorph new scriptOwner: self; color: aColor].
	'S' = blockType ifTrue: [^ EventHatMorph new forStartEvent scriptOwner: self; color: aColor].
	'W' = blockType ifTrue: [^ WhenHatBlockMorph new scriptOwner: self; color: aColor].
	'B' = blockType ifTrue: [^ BackdropHatBlockMorph new scriptOwner: self; color: aColor].
	'C' = blockType ifTrue: [^ WhenCloneHatBlock new scriptOwner: self; forStartEvent; color: aColor].
	'H' = blockType ifTrue: [^ WhenTrueHatBlockMorph new scriptOwner: self; color: aColor].
	'Z' = blockType ifTrue: [^ ProcedureHatBlockMorph new scriptOwner: self; color: aColor].! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 1/12/2016 14:19'!
procBlockFromSpec: spec color: blockColor
	"Create a block from the given block specification. Answer nil if I don't implement the block spec selector."

	| blockLabelSpec blockType selector defaultArgs block rcvr argPermutation |
	blockLabelSpec _ ScratchTranslator translationFor: (spec at: 1).
	argPermutation _ CommandBlockMorph argPermutationForSpec: (spec at: 1) withTranslation: blockLabelSpec.
	blockType _ spec at: 2.
	selector _ (spec at: 3) asSymbol.
	defaultArgs _ self defaultArgsFor: spec.


	"basic block type: normal or C-shaped"
	(blockType includes: $c)
		ifTrue:	[
			selector = #doIfElse
				ifTrue: [block _ IfElseBlockMorph new isSpecialForm: true]
				ifFalse: [block _ CBlockMorph new isSpecialForm: true]]
		ifFalse:	[
			(blockType includes: $r) | (blockType includes: $b)
				ifTrue: [block _ ProcReporterCallBlockMorph new]
				ifFalse: [block _ ProcCallBlockMorph new]].

	(blockType includes: $b) ifTrue: [block isBoolean: true].
	(blockType includes: $s) ifTrue: [block isSpecialForm: true].
	(blockType includes: $t) ifTrue: [block isTimed: true].

	(ScriptableScratchMorph isSpriteSpecificTarget: self selector: selector)
		ifTrue: [rcvr _ self]
		ifFalse: [rcvr _ self ownerThatIsA: ScratchStageMorph].

	^ block
		argPermutation: argPermutation;
		color: blockColor;
		selector: #call;
		commandSpec: blockLabelSpec;
		defaultArgs: defaultArgs;
		receiver: rcvr
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jm 8/9/2007 17:31'!
scriptsAsTuples: tuples

	blocksBin _ tuples asArray.
	self convertTuplesToStacks.
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/14/2015 15:27'!
soundsPage: xOffset for: aScriptEditorMorph
	"Answer a morph containing thumbnails of my sounds."

	| bin m y sounds n recBut impBut maxHeight yMargin xMargin editor |
	yMargin _ 7.
	xMargin _ 7.

	bin _ ScratchBlockPaletteMorph new color: (Color r: (149/255) g: (154/255) b: (159/255)).

	m _ StringMorph
		contents: 'New sound:' localized
		font: (ScratchFrameMorph getFont: #SoundsPage).
	m color: (Color black).
	bin addMorph: m.
	m position: bin topLeft + (7@ yMargin).

	recBut _ ScratchFrameMorph buttonLabel: 'Record' localized selector: #recordSound.
	recBut target: self.
	bin addMorph: recBut.

	impBut _ ((ScratchFrameMorph buttonLabel: 'Import' localized selector: #importSound) target: self).

	bin addMorph: impBut.

	maxHeight _ (m height max: (impBut height max: recBut height)).
	ScratchTranslator isRTL
		ifTrue: [impBut position: xMargin@(yMargin + ((maxHeight - impBut height) / 2)).
			recBut position: (impBut right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			m position: (recBut right + 4)@(yMargin + ((maxHeight - m height) / 2))]
		ifFalse: [m position: xMargin@(yMargin + ((maxHeight - m height) / 2)).
			recBut position: (m right + 4)@(yMargin + ((maxHeight - recBut height) / 2)).
			impBut position: (recBut right + 4)@(yMargin + ((maxHeight - impBut height) / 2))].



	n _ 0.
	y _ yMargin + maxHeight + 9.
	sounds _ media select: [:item | item isSound].
	sounds do: [:item |
		m _ MediaItemMorph new.
		m scratchObj: self media: item; position: 7@y.
		m setNumber: (n _ n + 1).
		n = 1 ifTrue: [m highlight: true. editor _ ScratchSoundEditorMorph new client: self; sound: (sounds first sound); soundName: item mediaName.
	bin addMorph: (editor position: m topRight)].
		m editor: editor.
		bin addMorph: m.
		y _ y + m height - 1].
	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jens 3/4/2009 00:53'!
stackFromTupleList: tupleList receiver: scriptOwner
	"Answer a new block stack from the given sequence of tuples."
	"self stackFromTupleList: #() receiver: nil"

	| stackTop previousBlock block |
	stackTop _ previousBlock _ nil.
	tupleList do: [:tuple |
		block _ self blockFromTuple: tuple receiver: scriptOwner.
		previousBlock
			ifNil: [stackTop _ block]
			ifNotNil: [previousBlock nextBlock: block].
		previousBlock _ block].

	^ stackTop
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/23/2015 10:19'!
stackFromTupleListTwo: tupleList receiver: scriptOwner
	"Answer a new block stack from the given sequence of tuples."
	"self stackFromTupleList: #() receiver: nil"

	| stackTop previousBlock block |
	stackTop _ previousBlock _ nil.
	tupleList do: [:tuple |
		block _ self blockFromTupleTwo: tuple receiver: scriptOwner.
		previousBlock
			ifNil: [stackTop _ block]
			ifNotNil: [previousBlock nextBlock: block].
		previousBlock _ block].

	^ stackTop
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'jens 3/6/2009 00:29'!
variableBlockFromTuple: tuple receiver: scriptOwner
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock |
	varName _ tuple at: 2.
	rcvr _ scriptOwner.
	(scriptOwner varNames includes: varName) ifFalse: [
		bg _ scriptOwner ownerThatIsA: ScratchStageMorph.
		bg
			ifNil: [scriptOwner addVariable: varName]
			ifNotNil: [
				bg addVariable: varName.
				rcvr _ bg]].

	tuple first = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			receiver: rcvr].

	tuple first = #changeVariable ifTrue: [
		selector _ tuple at: 3.
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector _ #setVar:to:].
		block _ SetterBlockMorph new receiver: rcvr.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		arg _ tuple at: 4.
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
				argBlock _ self blockFromTuple: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/1/2015 15:18'!
variableBlockFromTupleTwo: oldTuple receiver: scriptOwner
	"Answer a new block for the given variable reference tuple."

	| varName rcvr bg selector block arg argBlock tuple |
	tuple _ Array new: oldTuple size.
	tuple at: 1 put: (oldTuple at: 1) asSymbol.
	(2 to: (oldTuple size)) do: [:i | tuple at: i put: (oldTuple at: i)].
	varName _ tuple at: 2.
	rcvr _ scriptOwner.
	(scriptOwner varNames includes: varName) ifFalse: [
		bg _ scriptOwner ownerThatIsA: ScratchStageMorph.
		bg
			ifNil: [scriptOwner addVariable: varName]
			ifNotNil: [
				bg addVariable: varName.
				rcvr _ bg]].

	tuple first = #readVariable ifTrue: [
		^ VariableBlockMorph new
			commandSpec: varName;
			receiver: rcvr].

	((tuple first = #changeVariable) | (tuple first = #setVar:to:) | (tuple first = #changeVar:by:)) ifTrue: [
		selector _ tuple at: 3.
		(tuple at: 1) = #changeVar:by: ifTrue: [selector _ tuple first].
		(tuple at: 1) = #setVar:to: ifTrue: [selector _ tuple first].
		"update selector if necessary (backward compatibility):"
		(selector = #set:to:) ifTrue: [selector _ #setVar:to:].
		block _ SetterBlockMorph new receiver: rcvr.
		selector = #setVar:to:
			ifTrue: [block initSetterForVar: varName]
			ifFalse: [block initChangerForVar: varName].

		arg _ tuple at: 4 ifAbsent: [tuple at: 3].
		(arg isKindOf: Array)
			ifTrue: [  "argument is a block"
				((arg size = 1) and: [arg first isKindOf: Array]) ifTrue: [arg _ arg first].
				argBlock _ self blockFromTupleTwo: arg receiver: scriptOwner.
				block replaceArgMorph: block expressionArg by: argBlock]
			ifFalse: [ "argument is a value"
				block expressionArg defaultValue: arg].

		^ block].

	self error: 'unknown variable spec'
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 4/6/2016 14:35'!
variablesPage
	"Answer a morph containing my variables."

	| page addButton deleteButton hasVars stage x y maxX |
	page _ ScratchBlockPaletteMorph new
		color: (Color r: 0.8 g: 0.8 b: 1.0);
		borderWidth: 0.

	addButton _ ScratchFrameMorph
		buttonLabel: 'Make a variable' localized
		selector: #addGlobalVariable.
	(self isKindOf: ScratchSpriteMorph) ifTrue: [addButton actionSelector: #addVariable].

	deleteButton _ ScratchFrameMorph
		buttonLabel: 'Delete a variable' localized
		selector: #deleteVariable.

	x _ 12.
	page addMorph: (addButton target: self; position: x@7).
	y _ addButton bottom + 3.

	hasVars _ self varNames size > 0.
	(stage _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		stage varNames size > 0 ifTrue: [hasVars _ true]].

	hasVars ifTrue: [
		page addMorph: (deleteButton target: self; position: x@y).
		y _ deleteButton bottom + 10.

		y _ self addVariableReportersTo: page x: x y: y.
		y _ y + 12.
		y _ self addGenericVariableBlocksTo: page x: x y: y].

	self addGenericListBlocksTo: page y: y.
	page updateWatcherButtonsForFrame: (self ownerThatIsA: ScratchFrameMorph).
	maxX _ page submorphs inject: 0 into: [:t :m | t max: m right].
	page extent: (maxX + 10) @ y.
	^ page
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/23/2015 15:35'!
viewBlocksAndScripts

	| sFrame editor viewer tabs |
	self isClone ifTrue: [^ self].
	self convertTuplesToStacks.
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	editor _ sFrame scriptsPane.
	viewer _ sFrame viewerPane.
	tabs _ sFrame scriptsPane tabPane.
	sFrame view: self tab: tabs currentTab category: viewer currentCategory.

	self world ifNotNil: [
		self createRectFor: self bounds.
		"self zoomRectFrom: self bounds to: editor bounds"].
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 11/2/2015 14:45'!
viewerPageForCategory: aCategoryName
	"Answer a morph containing blocks for the given category for use in the given ScratchViewer."

	| bin x y |
	aCategoryName = 'data' ifTrue: [^ self variablesPage].
	aCategoryName = 'motion' ifTrue: [^ self viewerPageForMotion].
	aCategoryName = 'sensing' ifTrue: [^ self viewerPageForSensing].
	aCategoryName = 'more blocks' ifTrue: [^ self viewerPageForMore].

	bin _ ScratchBlockPaletteMorph new.
	x _ 12.
	y _ 10.
	(self blocksFor: aCategoryName) do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y _ y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y _ y + 5]]  "insert a half space"
			ifFalse: [
				y _ self createBlock: blockOrSym atPosition: x@y onPage: bin]].

	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'EMP 12/4/2015 15:39'!
viewerPageForMore
	| bin x y addButton |
	"Answer a morph containing control blocks for the given category for use in the given ScratchViewer."

	bin _ ScratchBlockPaletteMorph new.
	x _ 12.
	y _ 10.
	
		addButton _ ScratchFrameMorph
		buttonLabel: 'Make a block' localized
		selector: #addCustom.
	bin addMorph: (addButton target: self; position: x@7).
	y _ y + (addButton height) + 10.
	"add custom blocks"
	(self blocksFor: 'more blocks') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y _ y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y _ y + 5]]  "insert a half space"
			ifFalse: [
				y _ self createCallBlock: blockOrSym atPosition: x@y onPage: bin]].
	
	"add param reporters. Used in old version of whiskers. Parameters are now drag-out"

	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks'!
viewerPageForMotion
	"Answer a morph containing mtion blocks for the given category for use in the given ScratchViewer."

	| bin isStage addMotorBlocks s font x y m |
	bin _ ScratchBlockPaletteMorph new.

	(self isKindOf: ScratchStageMorph)
		ifTrue: [
			isStage _ true.
			addMotorBlocks _ self showMotorBlocks]
		ifFalse: [
			isStage _ false.
			s _ self ownerThatIsA: ScratchStageMorph.
			addMotorBlocks _ s notNil and: [s showMotorBlocks]].

	(isStage & addMotorBlocks not) ifTrue: [
		font _ (ScratchFrameMorph getFont: #ViewerPage).
		x _ 20.
		y _ 12.
		m _ StringMorph contents: 'Stage selected:' localized font: font.
		bin addMorph: (m color: Color black; position: x@y).
		m _ StringMorph contents: 'No motion blocks' localized font: font.
		bin addMorph: (m color: Color black; position: x@(y + 17)).
		^ bin].

	x _ 12.
	y _ 10.
	(self blocksFor: 'motion') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y _ y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y _ y + 5]]  "insert a half space"
			ifFalse: [
				y _ self createBlock: blockOrSym atPosition: x@y onPage: bin]].

	addMotorBlocks ifFalse: [^ bin].

	isStage ifFalse: [
		y _ y + 7.
		bin addMorph: ((ImageMorph new form: (ScratchFrameMorph skinAt: #connector)) position: x@y).
		y _ y + 20].

	(self blocksFor: 'motor') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue: [y _ y + 15].  "insert a full space"
				(blockOrSym = #~) ifTrue: [y _ y + 5]]  "insert a half space"
			ifFalse: [
				y _ self createBlock: blockOrSym atPosition: x@y onPage: bin]].

	^ bin
! !

!ScriptableScratchMorph methodsFor: 'blocks' stamp: 'ee 4/30/2009 14:26'!
viewerPageForSensing
	"Answer a morph containing mtion blocks for the given category for use in the given ScratchViewer."

	| bin x y |
	bin _ ScratchBlockPaletteMorph new.
	x _ 12.
	y _ 10.
	(self blocksFor: 'sensing') do: [:blockOrSym |
		(blockOrSym = #-) | (blockOrSym = #~)
			ifTrue: [
				(blockOrSym = #-) ifTrue:[y _ y + 15]. "insert a full space"
				(blockOrSym = #~) ifTrue: [
					y _ y + 7.
					bin addMorph: ((ImageMorph new form: (ScratchFrameMorph skinAt: #connector)) position: x@y).
					y _ y + 20]]
			ifFalse: [
				y _ self createBlock: blockOrSym atPosition: x@y onPage: bin]].

	^ bin
! !


!ScriptableScratchMorph methodsFor: 'dropping/grabbing' stamp: 'jm 12/30/2008 18:37'!
justDroppedInto: newOwner event: evt
	"If I'm dropped into any submorph of a ScratchFrameMorph, reject the drop unless it is onto the work pane. For developers, accept drops into other morphs (e.g. the World). Otherwise, reject the drop."

	| sFrame |
	(sFrame _ newOwner ownerThatIsA: ScratchFrameMorph) ifNotNil: [
		newOwner = sFrame viewerPane pageViewer contents ifTrue: [
			self undoableDeleteSprite.
			sFrame libraryPane step.
			^ self].

		newOwner = sFrame workPane ifTrue: [^ self]. "allow drops onto the work pane"
		^ self rejectDropEvent: evt].

	Preferences noviceMode ifTrue: [^ self rejectDropEvent: evt].
! !

!ScriptableScratchMorph methodsFor: 'dropping/grabbing' stamp: 'jm 8/3/2003 13:21'!
rejectDropEvent: evt
	"Reject being dropped by the given event."

	evt hand rejectDropMorph: self event: evt.
! !


!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'EMP 4/26/2016 16:36'!
click: evt
	"Start or stop all my clickable scripts."

	| h |
	h _ World activeHand.
	h toolType ifNotNil: [^ self handleTool: h toolType hand: h].

	self eventReceived: ScratchMouseClickEvent new! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'jm 10/7/2005 15:56'!
doubleClick: evt
	"Show my viewer and script editor."
	
	| hand |
	hand _ self world activeHand.
	hand toolType ifNotNil: [
		^ self handleTool: hand toolType hand: hand].

	self viewBlocksAndScripts.
! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'tis 12/10/2006 23:50'!
handleTool: toolName hand: hand

	| scaleFactor |
	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self isKindOf: ScratchStageMorph) ifFalse: [
			^ self duplicate]].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		(self isKindOf: ScratchStageMorph) ifFalse: [
			^ self undoableDeleteSprite]].

	"exit now if I am not scalable"
	(self respondsTo: #multiplySizeBy:) ifFalse: [
		self beep.
		hand toolType: nil.
		^ self].

	scaleFactor _ hand lastEvent shiftPressed ifTrue: [1.2] ifFalse: [1.03].
	toolName = 'ZoomInTool' ifTrue: [^ self multiplySizeBy: scaleFactor].
	toolName = 'ZoomOutTool' ifTrue: [^ self multiplySizeBy: 1.0 / scaleFactor].
! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'jm 6/2/2009 11:44'!
handlesMouseDown: evt

	^ self isVisible
! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:04'!
mouseDown: evt
	"Handle a mouse click. Left button either drags or performs click action. Right button brings up a menu."

	evt hand newKeyboardFocus: nil.

	evt hand toolType ifNotNil: [
		self handleTool: evt hand toolType hand: evt hand.
		^ self].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[evt hand waitForClicksOrDrag: self event: evt].
! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'jm 12/19/2008 17:19'!
mouseHold: evt

	self rightButtonMenu.
! !

!ScriptableScratchMorph methodsFor: 'event handling' stamp: 'jm 8/3/2003 23:42'!
startDrag: evt
	"This is a drag gesture; pick me up."

	| rootForGrab |
	rootForGrab _ owner rootForGrabOf: self.
	rootForGrab ifNil: [^ self].
	rootForGrab position: evt hand position + (self topLeft - evt cursorPoint).
	evt hand grabMorph: rootForGrab.
! !


!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'EMP 10/5/2015 11:58'!
duplicateNoAttach
	"Duplicate this sprite, but do not attach to the hand."

	| newSprite frame |
	newSprite _ self fullCopy.
	newSprite position: (newSprite position + 20).
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [(frame _ ((self ownerThatIsA: OffscreenWorldMorph) frame))].
	frame ifNotNil: [
		frame workPane addMorphFront: newSprite.
		frame workPane sprites addLast: newSprite].
	^ newSprite
! !

!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'jm 8/2/2004 21:43'!
editDrawing
	"Edit my current form with the paint editor."

	self editDrawingOldCostumeName: nil deleteOnCancel: false.
! !

!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'jm 3/3/2008 11:42'!
editDrawingOldCostumeName: oldCostumeName deleteOnCancel: aBoolean
	"Edit my original form with the paint editor."

	| sFrame paintEditor |
	costume isMovie ifTrue: [^ self beep].
	(sFrame _ self ownerThatIsA: ScratchFrameMorph)
		ifNotNil: [
			sFrame paintingInProgress ifTrue: [^ self beep].
			sFrame stopAll.
			sFrame paintingInProgress: true].

	paintEditor _ PaintFrame new.
	paintEditor
		withStartingObject: self;
		scratchFrame: sFrame;
		oldCostumeName: oldCostumeName deleteOnCancel: aBoolean.

	oldCostumeName ifNotNil: [
		"When an oldCostumeName is supplied, it means I'm making a new drawing. Clear the initial rotation center."
		paintEditor clearRotationCenter].

	(paintEditor isKindOf: DialogBoxMorph)
		ifTrue: [paintEditor getUserResponse]
		ifFalse: [
			World addMorphFront: paintEditor.
			World startSteppingSubmorphsOf: paintEditor].
! !

!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'EMP 10/1/2015 16:31'!
exportObject

	| fName dir f objToExport |
	fName _ ScratchFileChooserDialog
		chooseNewFileDefault: objName
		title: 'Export Sprite'
		type: #sprite.
	fName = #cancelled ifTrue: [^ self].
	fName size = 0 ifTrue: [^ self].
	(fName endsWith: '.sprite') ifFalse: [fName _ fName, '.sprite'].
	fName _ FileDirectory localNameFor: fName.  "ignore path, if any; save in default directory"

	dir _ ScratchFileChooserDialog getLastFolderForType: #sprite.
	(dir fileExists: fName) ifTrue: [
		(DialogBoxMorph ask: 'Overwrite existing ', fName, '?') ifFalse: [^ self].
		dir deleteFileNamed: fName].

	f _ nil.
	[	f _ (dir newFileNamed: fName) binary.
		objToExport _ self copyForExport.
		objToExport objName: fName.
		ObjStream new storeObj: objToExport on: f showProgress: true.
		f close.
		dir setMacFileNamed: fName type: 'STsb' creator: 'MITS'.
	] ifError: [
		f ifNotNil: [f close].
		self inform: 'Could not write file' withDetails: 'Export failed' localized].
! !

!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'jm 7/4/2008 19:48'!
makeVisible
	"Make sure that I am entirely on the screen and visible."

	self isHidden ifTrue: [self isHidden: false].
	visibility < 30 ifTrue: [self visibility: 100].
	self scale < 10 ifTrue: [self setSizeTo: 100].
	(owner notNil and: [owner bounds containsPoint: self center]) ifFalse: [
		self referencePosition: 0@0].
	self comeToFront.
	World displayWorldSafely.

	self viewBlocksAndScripts.
! !

!ScriptableScratchMorph methodsFor: 'right button menu' stamp: 'jm 5/25/2004 14:18'!
rightButtonMenu
	"This default implementation does nothing."
! !


!ScriptableScratchMorph methodsFor: 'media' stamp: 'tis 8/20/2006 22:45'!
addMediaItem: aScratchMedia
	"Add the given media item to my media."

	aScratchMedia mediaName: (self unusedMediaNameFromBaseName: aScratchMedia mediaName).
	media addLast: aScratchMedia.
	aScratchMedia isSound ifFalse: [self lookLike: aScratchMedia mediaName].
	self updateMediaCategory.! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 11/20/2015 15:29'!
addMediaItem: aScratchMedia withName: mediaName
	"Add the given media item to my media. This allows setting the costumes seperately and naming each seperately, due to the scratch 2 file format"

	aScratchMedia mediaName: mediaName.
	media addLast: aScratchMedia.
	self updateMediaCategory.! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 6/8/2009 10:23'!
costumeNames
	"Answer a list of my costume (costume = non-sound media object) names."

	| result nm |
	result _ OrderedCollection new.
	media do: [:el |
		el isSound ifFalse: [
			nm _ el mediaName.
			(result includes: nm) ifFalse: [result add: nm]]].

	result _ result asArray.
	CameraPlugin cameraIsAvailable ifTrue: [
		result _ result copyWith: '*** camera ***'].
	^ result
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 2/10/2016 14:29'!
costumesSize
	"Answer a list of my costume (costume = non-sound media object) names."

	| result nm |
	result _ OrderedCollection new.
	media do: [:el |
		el isSound ifFalse: [
			nm _ el mediaName.
			(result includes: nm) ifFalse: [result add: nm]]].
	^ result size
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 8/7/2008 13:16'!
defaultImageMedia
	"Placeholder image media."

	^ ImageMedia new
		form: (Form extent: 8@8 depth: 8) fillWhite;
		mediaName: ('costume' localized, '1')
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 6/29/2009 17:14'!
deleteMedia: itemToDelete
	"Delete the given media item."

	| oldIndex costumesBefore costumesAfter newCostume |
	oldIndex _ media indexOf: itemToDelete.
	media remove: itemToDelete ifAbsent: [].
	itemToDelete isSound ifTrue: [itemToDelete sound pause].

	itemToDelete == costume ifTrue: [
		"select the costume just before or after the costume being deleted"
		costumesBefore _ (media copyFrom: 1 to: oldIndex - 1) select: [:item | item isSound not].
		costumesAfter _ (media copyFrom: oldIndex to: media size) select: [:item | item isSound not].
		costumesBefore size > 0
			ifTrue: [newCostume _ costumesBefore last]
			ifFalse: [
				costumesAfter size > 0
					ifTrue: [newCostume _ costumesAfter first]
					ifFalse: [media addLast: (newCostume _ itemToDelete)]].
		self lookLike: newCostume mediaName].

	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 10/2/2006 16:25'!
drawNewCostume

	| oldCostumeName newName newImage |
	oldCostumeName _ costume mediaName.
	newImage _ ImageMedia new form: (Form extent: 4@4 depth: 8).
	newName _ (self unusedMediaNameFromBaseName: self defaultImageMedia mediaName).
 	newImage mediaName: newName.
	media addLast: newImage.
	self lookLike: newImage mediaName.
	self updateMediaCategory.
	self editDrawingOldCostumeName: oldCostumeName deleteOnCancel: false.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 6/22/2004 17:37'!
duplicateMedia: itemToDuplicate
	"Duplicate the given media item."

	| dup |
	itemToDuplicate isSound ifTrue: [itemToDuplicate pausePlaying].
	dup _ itemToDuplicate copy.
	dup mediaName: (self unusedMediaNameFromBaseName: itemToDuplicate mediaName).
	media addLast: dup.
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 1/4/2006 12:56'!
editedForm: aForm textBox: aMultilineTextMorph

	| newImage |
	(costume isKindOf: ImageMedia) ifFalse: [
		newImage _ ImageMedia new
			form: aForm;
			mediaName: (self unusedMediaNameFromBaseName: costume mediaName).
		media addLast: newImage.
		self lookLike: newImage mediaName].

	costume form: aForm.  "replace the current costume"
	costume textBox: aMultilineTextMorph.
	self lookLike: costume mediaName.
	self viewBlocksAndScripts.
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 3/22/2016 10:48'!
importImage
	"Import a new image from a file and add it to my media (concatenating the name if it is greater than 16 characters long). If the file is an animated gif, import all frames of the gif as separate costumes."

	| title result el ext fList isFirst newName type |
	(self isKindOf: ScratchStageMorph)
		ifTrue: [type _ #background. title _ 'Import Backdrop']
		ifFalse: [type _ #costume. title _ 'Import Costume'].
	result _ ScratchFileChooserDialog
		chooseImageFileType: type
		title: title.
	result = #cancelled ifTrue: [^ self].

	fList _ OrderedCollection new.
	ext _ FileDirectory extensionFor: result asLowercase.
	ext = 'gif'
		ifTrue: [[fList _ (GIFReadWriter new on: (FileStream readOnlyFileNamed: result)) nextImageSet] ifError: [^ self]]
		ifFalse: [[fList addLast: (Form fromFileNamed: result)] ifError: [^ self]].

	isFirst _ true.
	fList do: [:f |
		el _ ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f).
		newName _ self mediaNameFromFileName: result default: 'costume'.
		el mediaName: (self unusedMediaNameFromBaseName: (UTF8 withAll: newName)).
		media addLast: el.
		isFirst ifTrue: [isFirst _ false. self lookLike: el mediaName.]].

	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 10/5/2006 08:32'!
importMedia: fileName
	"Import a new image from a file and add it to my media."

	| extension elList baseName fList isFirst |
	extension _ FileDirectory extensionFor: fileName asLowercase.

	elList _ OrderedCollection new.

	(#(aif aiff wav mp3) includes: extension) ifTrue: [
		baseName _ self mediaNameFromFileName: fileName default: 'sound'.
		[elList addLast: (SoundMedia new loadFile: fileName)] ifError: [^ self]].

	(#(jpg jpeg gif bmp png) includes: extension) ifTrue: [
		baseName _ self
			mediaNameFromFileName: fileName
			default: self defaultImageMedia mediaName.
		fList _ OrderedCollection new.
		extension = 'gif' 
			ifTrue: 
				[[fList _ (GIFReadWriter new on: (FileStream oldFileNamed: fileName)) nextImageSet] ifError: [^ self]]
			ifFalse: 
				[[fList addLast: (Form fromFileNamed: fileName)] ifError: [^ self]].
		fList do: [:f | 
			elList addLast: (ImageMedia new form: (ScratchFrameMorph scaledFormForPaintEditor: f))]].

	elList isEmpty ifTrue: [^ self].  "unknown file type; ignore"

	isFirst _ true.
	elList do: [:el | 
		el mediaName: (self unusedMediaNameFromBaseName: baseName).
		media addLast: el.
		isFirst ifTrue: [
			isFirst _ false. 
			el isSound ifFalse: [self lookLike: el mediaName]]].
	
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 8/2/2008 22:55'!
importSound
	"Import a new sound from a file and add it to my media."

	| result el newName |
	result _ ScratchFileChooserDialog
		chooseExistingFileType: #sound
		extensions: #(aif aiff au wav mp3)
		title: 'Import Sound'.

	result = #cancelled ifTrue: [^ self].

	el _ [SoundMedia new loadFile: result]
		ifError: [:err :rcvr |
			DialogBoxMorph warn: err.
			nil].
	el ifNil: [^ self].

	newName _ self mediaNameFromFileName: result default: 'sound'.
	el mediaName: (UTF8 withAll: (self unusedMediaNameFromBaseName: newName)).
	media addLast: el.
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 4/3/2005 10:38'!
insertMedia: aScratchMedia before: targetOrNil
	"Shuffle my media list so that the given media item comes immediately before the target media item, or at the end of the list if targetScratchMedia is nil. Do nothing if the given item is the same as the target item."

	| mediaItem |
	aScratchMedia == targetOrNil ifTrue: [^ self].

	mediaItem _ aScratchMedia.
	(media includes: aScratchMedia) ifFalse: [
		"dropping an undeleted media item"
		mediaItem _ mediaItem copy.
		mediaItem mediaName: (self unusedMediaNameFromBaseName: mediaItem mediaName).
		media addLast: mediaItem].

	media remove: mediaItem.
	targetOrNil
		ifNil: [media addLast: mediaItem]
		ifNotNil: [media add: mediaItem before: targetOrNil].
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 9/7/2006 17:23'!
mediaNameFromFileName: fileName default: defaultName
	"Answer a name for the given media item. If the existing name is '$$squeak$$' then the media was copied via windows drag-and-drop; use the given default name instead."

	| result |
	result _ (FileDirectory baseNameFor: (FileDirectory localNameFor: fileName)).
	(result beginsWith: '$$squeak$$') ifTrue: [result _ defaultName].
	result size > 16 ifTrue: [result _ result copyFrom: 1 to: 16].
	^ result
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 12/1/2005 20:04'!
onlyCostume: aForm
	"Remove all my costumes, then make a new costume using the given Form."

	| el |
	media _ media select: [:m | m isSound].

	el _ ImageMedia new form: aForm.
	el mediaName: 'costume'.
	media addLast: el.
	self lookLike: el mediaName.
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 8/3/2007 08:00'!
recordSound

	| frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self beep].
	frame stopAll.
	World submorphs do: [:m |
		(m isKindOf: ScratchSoundRecorderDialogMorph) ifTrue: [m delete]].

	ScratchSoundRecorderDialogMorph forClient: self.

! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 8/2/2004 20:38'!
revertToCostume: oldCostumeName
	"Sent by the paint editor if editing of a newly-created costume is cancelled. Delete the new costume and revert to the old costume with the given name."

	| newlyCreatedCostume |
	newlyCreatedCostume _ costume.
	self lookLike: oldCostumeName.
	media remove: newlyCreatedCostume ifAbsent: [].
	self updateMediaCategory.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 12/15/2015 07:00'!
saveNewSound: aSampledSound name: baseName

	| sndItem |
	sndItem _ SoundMedia new.
	sndItem mediaName: (self unusedMediaNameFromBaseName: baseName).
	media addLast: sndItem.

	sndItem sound: aSampledSound.
	self updateMediaCategory."


	((self media select: [:m | m isSound]) select: [:m | m mediaName asUTF8 = baseName asUTF8]) first sound: aSampledSound.
	self updateMediaCategory"
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 6/22/2009 15:45'!
savePhoto: aForm

	| n |
	n _ self unusedMediaNameFromBaseName: 'costume' localized, '1'.
	self addMediaItem: (ImageMedia new mediaName: n; form: aForm).

! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 12/14/2015 15:37'!
saveSound: aSampledSound name: baseName

	"| sndItem |
	We need to overwrite the old sound, so get rid of this code...
	sndItem _ SoundMedia new.
	sndItem mediaName: (self unusedMediaNameFromBaseName: baseName).
	media addLast: sndItem.

	sndItem sound: aSampledSound.
	self updateMediaCategory."


	((self media select: [:m | m isSound]) select: [:m | m mediaName asUTF8 = baseName asUTF8]) first sound: aSampledSound.
	self updateMediaCategory
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 5/12/2004 19:52'!
setMedia: mediaCollection
	"Set my media to the given collection when copying."

	media _ mediaCollection.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 12/18/2006 10:38'!
soleCostume: imageMedia
	"Make the given image my only costume."

	media _ media select: [:item | item isImage not].
	self addMediaItem: imageMedia.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 4/25/2008 15:58'!
soundNames
	"Answer a list of my sound names. Suppress duplicates (ignoring case differences)."

	| result nm |
	result _ OrderedCollection new.
	media do: [:el |
		el isSound ifTrue: [
			nm _ el mediaName.
			(result anySatisfy: [:s | s caseInsensitiveEqual: nm])
				ifFalse: [result add: nm]]].
	result addLast: '-'.
	result addLast: 'record' localized, ScratchTranslator ellipsesSuffix.
	^ result asArray
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'EMP 10/2/2015 19:34'!
stageCostumeNames
	"Answer a list of my costume (costume = non-sound media object) names."

	^ ((self ownerThatIsA: ScratchStageMorph) costumeNames)
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 4/30/2009 22:53'!
takePhoto
	"Take a photo."

	ScratchCameraDialog new
		client: self;
		openInWorld;
		openCamera.
! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'tis 8/20/2006 22:47'!
unusedMediaNameFromBaseName: baseName
	"Answer an unused name for a new media item with the given base name. Strip off the file extension, if any."

	^ self unusedMediaNameFromBaseName: baseName forMedia: nil! !

!ScriptableScratchMorph methodsFor: 'media' stamp: 'jm 6/22/2009 16:06'!
unusedMediaNameFromBaseName: baseName forMedia: aMedia
	"Answer an unused name for a new media item with the given base name. Strip off the file extension, if any.  med is the sound or costume media which is currently being renamed."

	| nm i existingNames greatestNum |
	nm _ baseName.
	i _ nm indexOf: $..
	i > 1 ifTrue: [nm _ nm copyFrom: 1 to: i - 1].

	nm size = 0 ifTrue: [
		aMedia
			ifNil: [nm _ 'new' localized asUTF8, '1']
			ifNotNil: [
				aMedia isImage
					ifTrue: [nm _ self defaultImageMedia mediaName]
					ifFalse: [nm _ 'sound' localized asUTF8, '1']]].

	existingNames _ Set new.
	media do: [:m | m = aMedia ifFalse: [existingNames add: (UTF8 withAll: m mediaName)]].

	(nm size > 0 and: [nm last isDigit]) ifFalse: [
		(existingNames includes: (UTF8 withAll: nm)) ifFalse: [^ nm]].

	"remove trailing digits, if any"
	i _ nm size.
	[i > 1 and: [(nm at: i) isDigit]] whileTrue: [i _ i - 1].
	[i > 1 and: [(nm at: i) = Character space]] whileTrue: [i _ i - 1].
	nm _ nm copyFrom: 1 to: i.

	greatestNum _ 0.
	existingNames do: [:n |
		i _ n size.
		[i > 1 and: [(n at: i) isDigit]] whileTrue: [i _ i - 1].
		(n copyFrom: 1 to: i) = nm ifTrue: [
			greatestNum _ ((n copyFrom: i+1 to: n size) asNumber) max: greatestNum]].

	^ nm, (greatestNum+1) printString
! !


!ScriptableScratchMorph methodsFor: 'stepping' stamp: 'jm 1/8/2006 18:06'!
step

	costume mediaStep ifTrue: [self costumeChanged].
! !

!ScriptableScratchMorph methodsFor: 'stepping' stamp: 'jm 5/14/2004 12:22'!
stepTime

	^ 0
! !


!ScriptableScratchMorph methodsFor: 'object i/o' stamp: 'jm 6/1/2004 20:19'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		objName
		vars
		blocksBin
		isClone
		media
		costume
	) from: anObjStream.
! !

!ScriptableScratchMorph methodsFor: 'object i/o' stamp: 'jm 3/23/2005 20:17'!
storeFieldsOn: anObjStream

	| oldBlockBinOwner |
	super storeFieldsOn: anObjStream.
	(blocksBin isKindOf: Morph) ifTrue: [
		oldBlockBinOwner _ blocksBin owner.
		blocksBin delete].

	self storeFieldsNamed: #(
		objName
		vars
		blocksBin
		isClone
		media
		costume
	) on: anObjStream.

	oldBlockBinOwner ifNotNil: [oldBlockBinOwner addMorph: blocksBin].
! !


!ScriptableScratchMorph methodsFor: 'private' stamp: 'EMP 3/22/2016 10:39'!
addCustom

	| array spec params isAtomic f sf b |
	array _ BlockCreationDialog new getUserResponse. "The result is an array: [[blockSpec, variable names], isAtomic]"
	array = false ifTrue: [^ self].
	spec _ array first first.
	spec withoutLeadingBlanks withoutTrailingBlanks = '' ifTrue: [^ self].
	params _ array first second.
	isAtomic _ array second.
	b _ (self blocksBin submorphs select: [:m | m isKindOf: BlockMorph]).
	(self findAnySpec: spec) ifTrue: [^ DialogBoxMorph warn: 'A block with that name already exists'].
	(b isEmptyOrNil) ifFalse: [
	blocksBin addMorphBack: ((ProcedureHatBlockMorph fromSpec: spec params: params isAtomic: isAtomic) scriptOwner: self; position: (b last fullBounds bottomLeft + (0 @ 10)))] ifTrue: [blocksBin addMorphBack: ((ProcedureHatBlockMorph fromSpec: spec params: params isAtomic: isAtomic) scriptOwner: self; position: (self blocksBin topLeft + (20@20)))].
	blocksBin changed.
	self changed.
	(f _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [(sf _ f viewerPane) ifNotNil: [sf categoryChanged: (sf currentCategory)]].! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 12/15/2006 11:48'!
clearMediaAndCostume
	"Private!! Used when exporting an empty stage."

	media _ OrderedCollection new.
	costume _ nil.
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 1/5/2006 12:40'!
copyForExport
	"Answer a copy of me for exporting."

	| objToExport |
	objToExport _ self fullCopy.
	objToExport objName: objName.
	objToExport blocksBin allMorphsDo: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m stop].
		(m isKindOf: SpriteArgMorph) ifTrue: [m clearMorphReference]].
	objToExport convertStacksToTuples.
	^ objToExport
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 6/4/2008 19:45'!
copyListsFor: aSprite
	"Answer a deep copy of my list variables dictionary."

	| result oldList copiedList |
	result _ lists species new.
	lists associationsDo: [:assoc |
		oldList _ assoc value.
		copiedList _ ScratchListMorph new
			listName: oldList listName target: aSprite;
			newContents: oldList listContents.
		result at: assoc key put: copiedList].
	^ result

! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 6/4/2008 19:45'!
copyRecordingIn: dict
	"Copy my fields and scripts."

	| newCopy newBlocksBin |
	(self respondsTo: #sayNothing) ifTrue: [self sayNothing].  "remove talk bubble before copying"
	newCopy _ super copyRecordingIn: dict.
	newCopy renewFilterPack.
	newBlocksBin _ blocksBin fullCopy.
	newBlocksBin allMorphsDo: [:m |
		(m isKindOf: HatBlockMorph) ifTrue: [m scriptOwner: newCopy].
		(m isKindOf: CommandBlockMorph) ifTrue: [m mapReceiver: self to: newCopy]].
	newCopy vars: vars copy lists: (self copyListsFor: newCopy) blocksBin: newBlocksBin.
	newCopy objName: self nextInstanceName.
	newCopy setMedia: (media collect: [:el | el copy]).
	newCopy lookLike: costume mediaName.
	^ newCopy
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 11/22/2004 13:43'!
costumeChanged

	costumeChangeMSecs _ Time millisecondClockValue.
	filterPack ifNotNil: [filterPack clearFilterCaches].
	self layoutChanged.
	self keepOnScreen.
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'EMP 11/5/2015 07:54'!
createRectFor: aBounds
	| feedbackMorph |
	Initializing == false ifTrue: [
	self class == ScratchStageMorph ifFalse: [
	Display forceDisplayUpdate.
	feedbackMorph _ BorderedMorph new borderWidth: 3; bounds: (aBounds expandBy: 5); openInWorld; useRoundedCorners; color: (Color r: 128/255 g: 128/255 b: 128/255); borderColor: (Color r: 23/255 g: 159/255 b: 215/255); changed.
	0 to: 10 do: [:i |
	feedbackMorph delete.
	feedbackMorph _ BorderedMorph new borderWidth: 3; bounds: (aBounds expandBy: 5); useRoundedCorners; color: (Color r: 128/255 g: 128/255 b: 128/255 alpha: ((100 - (i * 10)) / 100)); borderColor: (Color r: 23/255 g: 159/255 b: 215/255 alpha: ((100 - (i * 10)) / 100)); changed.
	self addMorphFront: feedbackMorph.
	World doOneCycle.
	Display forceDisplayUpdate].
	feedbackMorph delete]]! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'ee 4/23/2008 22:01'!
deleteSprite
	"Delete the sprite and all watchers that are associated with it."

	| frame sprites i |
	frame _ self ownerThatIsA: ScratchFrameMorph. 
	frame ifNil: [^ self delete].

	frame deleteWatchersForSprite: self.

	frame workPane updateSpritesList.
	sprites _ frame workPane sprites.
	i _ sprites indexOf: self.  "remember my index"
	sprites remove: self ifAbsent: [].

	self delete.

	frame libraryPane fixLayout.

	"delete my thumbnail, and re-focus on the thumbnail right after me or the stage if there are no sprites"
	i > sprites size ifTrue: [i _ i - 1].
	i < 1 
		ifTrue: [frame view: frame workPane tab: 'Scripts' category: 'motion'] 
		ifFalse: [frame view: (sprites at: i) tab: 'Scripts' category: 'motion'].	
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 3/14/2009 17:22'!
interpretStringAsNumberIfPossible: anObject
	"If the argument is a string that can be interpreted as a number, such as '123', then return it's value as a number. Otherwise, return the original object."

	| s digits hasDigit |
	(anObject isKindOf: String) ifFalse: [^ anObject].
	anObject size = 0 ifTrue: [^ anObject].

	(anObject first isKindOf: Character)
		ifTrue: [s _ ReadStream on: anObject asByteArray]
		ifFalse: [s _ ReadStream on: anObject].

	"see if the string can be parsed as a Scratch number:"
	digits _ '0123456789' asByteArray.
	hasDigit _ false.
	(s atEnd not and: [s peek = $- asciiValue]) ifTrue: [s next].
	[s atEnd not and: [digits includes: s peek]] whileTrue: [hasDigit _ true. s next].
	(s atEnd not and: [s peek = $. asciiValue]) ifTrue: [s next].
	[s atEnd not and: [digits includes: s peek]] whileTrue: [hasDigit _ true. s next].

	(s atEnd and: [hasDigit])
		ifTrue: [^ anObject asNumberNoError]
		ifFalse: [^ anObject].

! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 6/21/2009 11:53'!
nextInstanceName
	"Answer a name for a new instance. For sprites, an attempt is made to create a unique name of the form 'spriteN'."

	| stage lastN digits |
	self = ScratchStageMorph ifTrue: [^ 'Stage' localized].

	(stage _ self ownerThatIsA: ScratchStageMorph) ifNil: [^ 'Sprite' localized asUTF8, 1 printString].
	lastN _ 0.
	stage sprites ifNotNil: [
		stage sprites do: [:m |
			(m isKindOf: ScratchSpriteMorph) ifTrue: [
				digits _ m objName trailingDigits.
				((digits size > 0) and: [m objName beginsWith: ('Sprite' localized)])
					ifTrue: [lastN _ lastN max: digits asNumber]]]].

	^ 'Sprite' localized asUTF8, (lastN + 1) printString
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 5/12/2006 14:02'!
printSummaryOn: aStream

	| costumes snds stacks hats otherStacks |
	aStream nextPutAll: 'Sprite: ', self objName; crlf.

	costumes _ media select: [:item | item isImage].
	aStream nextPutAll: '  Costumes (', costumes size printString, '):'; crlf.
	costumes do: [:item |
		aStream nextPutAll: '    ', item mediaName, ' (', item infoString, ')'; crlf].

	snds _ media select: [:item | item isSound].
	aStream nextPutAll: '  Sounds (', snds size printString, '):'; crlf.
	snds do: [:item |
		aStream nextPutAll: '    ', item mediaName, ' (', item infoString, ')'; crlf].

	stacks _ blocksBin submorphs select: [:m | m isKindOf: BlockMorph].
	stacks size = 0 ifTrue: [
		aStream nextPutAll: '  No stacks.'; crlf; crlf.
		^ self].
	aStream nextPutAll: '  Stacks (', stacks size printString, '):'; crlf.

	hats _ stacks select: [:m | m isKindOf: HatBlockMorph].
	otherStacks _ stacks select: [:m | (m isKindOf: HatBlockMorph) not].

	hats, otherStacks do: [:item |
		item printCodeOn: aStream indent: 1.
		(item isKindOf: ReporterBlockMorph) ifTrue: [aStream crlf].
		aStream crlf].

! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 11/13/2003 20:44'!
projectDirectory
	"Answer the directory containing this Scratch project or the default directory."

	| frame |
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ FileDirectory default].
	^ frame projectDirectory
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 9/15/2008 10:36'!
serialized
	"Answer a ByteArray containing this Scratch object in serialized form."

	| s objToExport |
	s _ WriteStream on: (ByteArray new: 100000).
	objToExport _ self copyForExport.
	ObjStream new storeObj: objToExport on: s showProgress: false.
	^ s contents
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 5/11/2009 11:08'!
spriteNameInUse: aString

	| s |
	(s _ self ownerThatIsA: ScratchStageMorph) ifNotNil: [
		s submorphs do: [:m |
			m == self ifFalse: [
				((m isKindOf: ScriptableScratchMorph) and:
				 [m objName caseInsensitiveEqual: aString]) ifTrue: [
					^ true]]]].

	^ false
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 5/28/2008 16:05'!
stopPlaying
	"Stop playing all movies and sounds."

	| firstCostume |
	costume stopPlaying.
	self filterReset.
	self setVolumeTo: 100.  "reset volume"

	"exit camera mode"
	(costume isKindOf: CameraMedia) ifTrue: [
		firstCostume _ media detect: [:el | el isImage] ifNone: [^ self].
		self lookLike: firstCostume mediaName].
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'tis 11/8/2006 14:20'!
undoableDeleteSprite
	"Delete the sprite and store it in the clipboard in case of an undo."

	ScratchFrameMorph putInClipboard: self.
	self deleteSprite.
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 1/28/2009 10:42'!
updateMediaCategory
	"Update the media category in the viewer, if it is showing."

	| sFrame |
	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	sFrame ifNotNil: [
		sFrame projectModified.
		sFrame updateMediaCategoryFor: self.
		sFrame viewerPane refresh].

! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 11/17/2006 17:39'!
vars: varsDict blocksBin: aBlocksBin
	"Private!! Set my variables and blocks bin. Used by copyRecordingIn:."

	vars _ varsDict.
	blocksBin _ aBlocksBin.
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'jm 6/4/2008 19:34'!
vars: varsDict lists: listsDict blocksBin: aBlocksBin
	"Private!! Set my variables and blocks bin. Used by copyRecordingIn:."

	vars _ varsDict.
	lists _ listsDict.
	blocksBin _ aBlocksBin.
! !

!ScriptableScratchMorph methodsFor: 'private' stamp: 'EMP 10/3/2015 19:51'!
zoomRectFrom: startRect to: finalRect

	| steps r p1 p2 |
	self class == ScratchStageMorph ifFalse: [
	steps _ 8.
	r _ startRect.
	Display border: r width: 2 rule: Form reverse fillColor: Color gray.
	Display forceDisplayUpdate.
	0 to: steps do: [:i |
		Delay waitMSecs: 20.
		Display border: r width: 2 rule: Form reverse fillColor: Color gray.
		Display forceDisplayUpdate.
		p1 _ startRect origin + ((i * (finalRect origin - startRect origin)) // steps).
		p2 _ startRect corner + ((i * (finalRect corner - startRect corner)) // steps).
		r _ p1 corner: p2.
		Display border: r width: 2 rule: Form reverse fillColor: Color gray.
		Display forceDisplayUpdate].
	Delay waitMSecs: 20.
	Display border: r width: 2 rule: Form reverse fillColor: Color gray].
	Display forceDisplayUpdate.
! !


!ScriptableScratchMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:51'!
bindCustom: oldSpec to: newSpec
	(((ProcCallBlockMorph allInstances), (ProcReporterCallBlockMorph allInstances)) select: [:m | m commandSpec asUTF8 = oldSpec asUTF8]) do: [:block | block commandSpec: newSpec].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScriptableScratchMorph class
	instanceVariableNames: ''!

!ScriptableScratchMorph class methodsFor: 'class initialization' stamp: 'EMP 1/6/2016 14:43'!
initialize
	"self initialize"

	Experimental _ false.
	ScratchOrigin _ 0@0.
	RandomGen _ Random new.
	TimerStartMSecs _ Time millisecondClockValue.
	ListBlockColor _ Color r: 204/255 g: 91/255 b: 32/255! !


!ScriptableScratchMorph class methodsFor: 'license'!
license
	^ '
Scratch 1.4 
Copyright (C) 2011 Massachusetts Institute of Technology

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

Contact Linux@scratch.mit.edu for more information.
'! !


!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'jm 8/23/2006 12:58'!
blockColorDict

	^ BlockColorDict
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 4/19/2016 12:15'!
blockColorFor: aCategory
	"Answer the block color for the given category."

	'events' = aCategory ifTrue: [^ (Color r: 200/255 g: 131/255 b: 48/255)].
	'control' = aCategory ifTrue: [^ (Color r: 225/255 g: 169/255 b: 26/255)].
	'motion' = aCategory ifTrue: [^ (Color h: 225 s: 0.65 v: 0.83)].
	'motor' = aCategory ifTrue: [^ (Color h: 220 s: 0.85 v: 0.725)].
	'looks' = aCategory ifTrue: [^ (Color h: 264 s: 0.62 v: 0.89)].
	'pen' = aCategory ifTrue: [^ (Color r: 14/255 g: 154/255 b: 108/255)].
	'operators' = aCategory ifTrue: [^ (Color r: 92/255 g: 183/255 b: 22/255)].
	'sound' = aCategory ifTrue: [^ (Color h: 296 s: 0.66 v: 0.85)].
	'sensing' = aCategory ifTrue: [^ (Color h: 200 s: 0.98 v: 0.86)].
	'variables' = aCategory ifTrue: [^ (Color r: 238/255 g: 125/255 b: 22/255)].
	'list' = aCategory ifTrue: [^ ListBlockColor].

	^ (Color r: 212/255 g: 40/255 b: 40/255)  "a shade of red"
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 10/26/2015 15:59'!
blockSpecDict
	"Answer my block specification dictionary."

	BlockSpecDict ifNil: [self buildBlockSpecDictionary].
	^ BlockSpecDict

! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 4/12/2016 13:56'!
blockSpecs
	"Answer a collection of block specifications for the blocks that are common to all objects. Block specificatons (Arrays) are interspersed with category names (Strings). A block specification is an Array of the form: (<block spec string> <block type> <selector> [optional initial argument values]).

	Explanation of flags:
		-	no flags
		b	boolean reporter
		c	c-shaped block containing a sequence of commands (always special form)
		r	reporter
		s	special form command with its own evaluation rule
		t	timed command, like wait or glide
		E	message event hat
		K	key event hat
		M	mouse-click event hat
		S	start event hat
		W	when <condition> hat (obsolete)
		B	when backdrop switches to..."

	| blocks |
	blocks _ #(
		'events'
			('when @greenFlag clicked'		S	-)
			('when %m.key key pressed'			K	-)
			('when this sprite clicked'				M	-)
			('when backdrop switches to %m.backdrop'	B	-)
			-
			('when [loudness v] > %n'		H	-)
			-
			('when I receive %m.broadcast'			E	-)
			('broadcast %m.broadcast'					-	broadcast:)
			('broadcast %m.broadcast and wait'			s	doBroadcastAndWait)
		'operators'
			('%n + %n'						r	+ - -)
			('%n - %n'						r	- - -)
			('%n * %n'						r	* - -)
			('%n / %n'						r	/ - -)
			-
			('pick random %n to %n'		r	randomFrom:to: 1 10)
			-
			('%s < %s'						b	< '' '')
			('%s = %s'						b	= '' '')
			('%s > %s'						b	> '' '')
			-
			('%b and %b'					b	&)
			('%b or %b'						b	|)
			('not %b'						b	not)
			-
			('join %s %s'					r	concatenate:with: 'hello ' 'world')
			('letter %n of %s'				r	letter:of: 1 'world')
			('length of %s'					r	stringLength: 'world')
			-
			('%n mod %n'					r	\\ - -)
			('round %n'						r	rounded -)
			-
			('%m.mathOp of %n'						r	computeFunction:of: 'sqrt' 10)
		'sound'
			('play sound %m.sound'				-	playSound:)
			('play sound %m.sound until done'		s	doPlaySoundAndWait)
			('stop all sounds'				-	stopAllSounds)
			-
			('play drum %d.drum for %n beats'	t 	drum:duration:elapsed:from: 1 0.25)
			('rest for %n beats'				t 	rest:elapsed:from: 0.25)
			-
			('play note %d.note for %n beats'	t	noteOn:duration:elapsed:from: 60 0.5)
			('set instrument to %d.instrument'			- 	midiInstrument: 1)
			-
			('change volume by %n'		- 	changeVolumeBy: -10)
			('set volume to %n %'			- 	setVolumeTo: 100)
			('volume'						r 	volume)
			-
			('change tempo by %n'			- 	changeTempoBy: 20)
			('set tempo to %n bpm'			- 	setTempoTo: 60)
			('tempo'							r 	tempo)
		'motor'
			('motor on for %n secs'			t	motorOnFor:elapsed:from: 1)
			('motor on'						-	allMotorsOn)
			('motor off'						-	allMotorsOff)
			('motor power %n'				-	startMotorPower: 100)
			('motor direction %m.motorDirection'			-	setMotorDirection: 'this way')
		'variables'
			('show variable %m.var'				-	showVariable:)
			('hide variable %m.var'				-	hideVariable:)
		'list'
			('add %s to %m.list'					-	append:toList: 'thing')
			-
			('delete %d.listDeleteItem of %m.list'				-	deleteLine:ofList: 1)
			('insert %s at %d.listItem of %m.list'			-	insert:at:ofList: 'thing' 1)
			('replace item %d.listItem of %m.list with %s'		-	setLine:ofList:to: 1 'list' 'thing')
			-
			('item %d.listItem of %m.list'					r	getLine:ofList: 1)
			('length of %m.list'					r	lineCountOfList:)
			('%m.list contains %s'				b	list:contains: 'list' 'thing')
			-
			('show list %m.list'					-	showList:)
			('hide list %m.list'					-	hideList:)
	).

	^ blocks, self obsoleteBlockSpecs, self moreBlocks
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'jm 4/1/2005 07:25'!
buildBlockSpecDictionary
	"self buildBlockSpecDictionary"

	| blockColor sel |
	BlockSpecDict _ IdentityDictionary new: 250.
	BlockColorDict _ IdentityDictionary new: 250.

	self withAllSubclassesDo: [:cl |
		blockColor _ Color blue.
		cl blockSpecs do: [:spec |
			((spec isKindOf: String) and: [spec size > 1]) ifTrue: [
				"set color  for this category"
				blockColor _ self blockColorFor: spec].
			(spec isMemberOf: Array) ifTrue: [
				sel _ spec at: 3.
				BlockSpecDict at: sel put: spec.
				BlockColorDict at: sel put: blockColor]]].
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'jm 5/14/2008 18:49'!
listBlockColor

	^ ListBlockColor
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 4/12/2016 14:27'!
moreBlocks
	^ #('sensing'
			-
			-
			('%m.sensor sensor value'				r	sensor: 'slider')
			('sensor %m.booleanSensor ?'			b	sensorPressed: 'button pressed')
		'other blocks' "Create the base for the custom blox"
		), (Experimental ifTrue: [#('control' ('return %s' s report))] ifFalse: [false ifTrue: [#(
		'more blocks'
			('When <>'								W	-)
)] ifFalse: [#()]]).! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 4/12/2016 14:00'!
obsoleteBlockSpecs
	"Answer a list of specifications for the graphic filter blocks."

	^ #(
	'obsolete'
		('abs %n'							r	abs -)
		('sqrt %n'							r	sqrt -)

		('rewind sound %m.sound'					-	rewindSound:)

		('point away from edge'				-	turnAwayFromEdge)
		('glide x:%n y:%n in %n secs'		t	gotoX:y:duration:elapsed:from: 50 50 1)

		('change costume by %n'			-	changeCostumeIndexBy: 1)
		('change background by %n' 		-	changeBackgroundIndexBy: 1)
		-
		('change stretch by %n'				-	changeStretchBy:)
		('set stretch to %n %'					-	setStretchTo: 100)
		-
		('say nothing'						-	sayNothing)
		-
		('change visibility by %n'			-	changeVisibilityBy: -10)
		('set visibility to %n %'				-	setVisibilityTo: 100)

		('change color-effect by %n'		-	changeHueShiftBy: 25)
		('set color-effect to %n'				-	setHueShiftTo: 0)
		-
		('change fisheye by %n'			-	changeFisheyeBy: 10)
		('set fisheye to %n'					-	setFisheyeTo: 0)
		~
		('change whirl by %n'				-	changeWhirlBy: 30)
		('set whirl to %n'					-	setWhirlTo: 0)
		-
		('change pixelate by %n'			- 	changePixelateCountBy: 1)
		('set pixelate to %n'					- 	setPixelateCountTo: 1)
		~
		('change mosaic by %n'				- 	changeMosaicCountBy: 1)
		('set mosaic to %n'					- 	setMosaicCountTo: 1)
		-
		('change brightness-shift by %n'	-	changeBrightnessShiftBy: 10)
		('set brightness-shift to %n'			-	setBrightnessShiftTo: 0)
		~
		('change saturation-shift by %n'	-	changeSaturationShiftBy: 10)
		('set saturation-shift to %n'			-	setSaturationShiftTo: 0)
		-
		('change pointillize drop by %n'		-	changePointillizeSizeBy: 5)
		('set pointillize drop to %n'			-	setPointillizeSizeTo: 0)
		~
		('change water ripple by %n'		-	changeWaterRippleBy: 5)
		('set water ripple to %n'				-	setWaterRippleTo: 0)
		-
		('change blur by %n'				-	changeBlurBy: 1)
		('set blur to %n'						-	setBlurTo: 0)
	)
! !

!ScriptableScratchMorph class methodsFor: 'block specs' stamp: 'EMP 10/26/2015 15:55'!
oldBlockSpecs
	"Answer a collection of block specifications for the blocks that are common to all objects. Block specificatons (Arrays) are interspersed with category names (Strings). A block specification is an Array of the form: (<block spec string> <block type> <selector> [optional initial argument values]).

	Explanation of flags:
		-	no flags
		b	boolean reporter
		c	c-shaped block containing a sequence of commands (always special form)
		r	reporter
		s	special form command with its own evaluation rule
		t	timed command, like wait or glide
		E	message event hat
		K	key event hat
		M	mouse-click event hat
		S	start event hat
		W	when <condition> hat (obsolete)
		B	when backdrop switches to..."

	| blocks |
	blocks _ #(
		'events'
			('when %m clicked'				S	-)
			('when %k key pressed'			K	-)
			('when %m clicked'				M	-)
			('when backdrop switches to %l'	B	-)
			-
			('when [loudness v] > %n'		H	-)
			-
			('when I receive %e'			E	-)
			('broadcast %e'					-	broadcast:)
			('broadcast %e and wait'			s	doBroadcastAndWait)
		'operators'
			('%n + %n'						r	+ - -)
			('%n - %n'						r	- - -)
			('%n * %n'						r	* - -)
			('%n / %n'						r	/ - -)
			-
			('pick random %n to %n'		r	randomFrom:to: 1 10)
			-
			('%s < %s'						b	< '' '')
			('%s = %s'						b	= '' '')
			('%s > %s'						b	> '' '')
			-
			('%b and %b'					b	&)
			('%b or %b'						b	|)
			('not %b'						b	not)
			-
			('join %s %s'					r	concatenate:with: 'hello ' 'world')
			('letter %n of %s'				r	letter:of: 1 'world')
			('length of %s'					r	stringLength: 'world')
			-
			('%n mod %n'					r	\\ - -)
			('round %n'						r	rounded -)
			-
			('%f of %n'						r	computeFunction:of: 'sqrt' 10)
		'sound'
			('play sound %S'				-	playSound:)
			('play sound %S until done'		s	doPlaySoundAndWait)
			('stop all sounds'				-	stopAllSounds)
			-
			('play drum %D for %n beats'	t 	drum:duration:elapsed:from: 1 0.25)
			('rest for %n beats'				t 	rest:elapsed:from: 0.25)
			-
			('play note %N for %n beats'	t	noteOn:duration:elapsed:from: 60 0.5)
			('set instrument to %I'			- 	midiInstrument: 1)
			-
			('change volume by %n'		- 	changeVolumeBy: -10)
			('set volume to %n%'			- 	setVolumeTo: 100)
			('volume'						r 	volume)
			-
			('change tempo by %n'			- 	changeTempoBy: 20)
			('set tempo to %n bpm'			- 	setTempoTo: 60)
			('tempo'							r 	tempo)
		'motor'
			('motor on for %n secs'			t	motorOnFor:elapsed:from: 1)
			('motor on'						-	allMotorsOn)
			('motor off'						-	allMotorsOff)
			('motor power %n'				-	startMotorPower: 100)
			('motor direction %W'			-	setMotorDirection: 'this way')
		'variables'
			('show variable %v'				-	showVariable:)
			('hide variable %v'				-	hideVariable:)
		'list'
			('add %s to %L'					-	append:toList: 'thing')
			-
			('delete %y of %L'				-	deleteLine:ofList: 1)
			('insert %s at %i of %L'			-	insert:at:ofList: 'thing' 1)
			('replace item %i of %L with %s'		-	setLine:ofList:to: 1 'list' 'thing')
			-
			('item %i of %L'					r	getLine:ofList: 1)
			('length of %L'					r	lineCountOfList:)
			('%L contains %s'				b	list:contains: 'list' 'thing')
			-
			('show list %L'					-	showList:)
			('hide list %L'					-	hideList:)
	).

	^ blocks, self obsoleteBlockSpecs, self moreBlocks
! !


!ScriptableScratchMorph class methodsFor: 'forms/sounds/icons' stamp: 'jm 11/4/2005 12:36'!
defaultBackgroundForm

	(DefaultBackgroundForm isNil or:
	 [DefaultBackgroundForm extent ~= ScratchFrameMorph workpaneExtent]) ifTrue: [
		DefaultBackgroundForm _ (Form extent: ScratchFrameMorph workpaneExtent depth: 1).
		DefaultBackgroundForm fillWhite].

	^ DefaultBackgroundForm
! !

!ScriptableScratchMorph class methodsFor: 'forms/sounds/icons' stamp: 'jm 5/5/2007 12:57'!
meowSound
	"MeowSound _ SampledSound fromFileNamed: ((FileDirectory default directoryNamed: 'ScratchSkin') fullNameFor: 'kitten.wav')"

	^ MeowSound
! !

!ScriptableScratchMorph class methodsFor: 'forms/sounds/icons' stamp: 'jm 5/8/2007 11:03'!
oldMeowPrefixReversed

	^ OldMeowPrefixReversed
! !

!ScriptableScratchMorph class methodsFor: 'forms/sounds/icons' stamp: 'jm 12/12/2004 11:54'!
popSound

	^ PopSound
! !


!ScriptableScratchMorph class methodsFor: 'translation support' stamp: 'ee 10/24/2007 09:31'!
blockSpecsArrayForTranslation
	"Answer an array that lists all the blocks and categories to be used as a guide to block translation."
	"self blockSpecDictForTranslation"

	| blocks all obsolete currentSpecs |
	currentSpecs _ Set new.
	ScratchSpriteMorph new blockCategories sort collect: [:cat |
		blocks _  (ScratchSpriteMorph new blocksFor: cat)
			select: [:b | b isKindOf: CommandBlockMorph].
		all _ blocks collect: [:b | b commandSpec].
		obsolete _ ScriptableScratchMorph obsoleteBlockSpecs collect: [:o | o first].
		all _  all select: [:p | (obsolete indexOf: p) = 0].
		(cat beginsWith: 'obsolete') ifFalse:[currentSpecs add: cat].
		currentSpecs addAll: all].
	currentSpecs _ currentSpecs asArray sort.
	^ currentSpecs
! !

!ScriptableScratchMorph class methodsFor: 'translation support' stamp: 'jm 11/29/2007 13:20'!
blockSpecsForTranslation
	"Answer a collection blocks for translation. Obsolete blocks are removed."

	| allSpecs |
	allSpecs _ Set new.
	(ScriptableScratchMorph blockSpecs,
	 ScratchSpriteMorph blockSpecs,
	 ScratchStageMorph blockSpecs) do: [:el |
		(el isKindOf: Array)
			ifTrue: [allSpecs add: el first]
			ifFalse: [((el beginsWith: 'obsolete') or:[#('-' '~') includes: el])
				ifFalse:[allSpecs add: el]]].
	ScriptableScratchMorph obsoleteBlockSpecs do: [:el |
		(el isKindOf: Array) ifTrue: [allSpecs remove: el first ifAbsent: []]].
	allSpecs
		add: 'else';
		add: 'variables';
		add: 'set %v to %n';
		add: 'change %v by %n'.
	^ allSpecs asArray sort
! !

!ScriptableScratchMorph class methodsFor: 'translation support' stamp: 'ee 10/23/2007 13:49'!
blockSpecsStringForTranslation
	"Answer a String that lists all the blocks and categories to be used as a guide to block translation."

	| out blocks pairs key |
	out _ WriteStream on: (String new: 10000).
	ScratchSpriteMorph new blockCategories sort collect: [:cat |
		out nextPutAll: '-	', cat; cr.
		blocks _  (ScratchSpriteMorph new blocksFor: cat)
			select: [:b | b isKindOf: CommandBlockMorph].
		pairs _ blocks collect: [:b |
			key _ b selector collect: [:ch | ch = $: ifTrue: [$_] ifFalse: [ch]].
			Array with: key with: b commandSpec].
		pairs sort: [:p1 :p2 | p1 first < p2 first].
		pairs do: [:p | out nextPutAll: p first; tab; nextPutAll: p last; cr]].
	^ out contents
! !


!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 10/21/2005 11:20'!
doubleSize: aBoolean

	DoubleSize _ aBoolean.
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 8/13/2003 17:07'!
fromUser
	"Go into a mode asking the user to select an instance of me, displaying a crossHair cursor while in this mode. The mode ends with the next mouse click. If the click is over an instance of me, return it. Otherwise, return nil. Keep running the world while waiting for the mouse click."

	| result p m mList |
	World ifNil: [^ self].  "not in morphic"
	result _ nil.
	Cursor crossHair showWhile: [
		[Sensor anyButtonPressed] whileFalse: [World doOneCycleNoInput].
		p _ Sensor cursorPoint.
		m _ (World rootMorphsAt: p) first.
		(m isKindOf: ScratchFrameMorph) ifTrue: [
			mList _ m workPane rootMorphsAt: p.
			mList size > 0 ifTrue: [
				m _ (m workPane rootMorphsAt: p) first]].
		(m isKindOf: self) ifTrue: [result _ m].
		Sensor waitNoButton].
	^ result
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'EMP 12/5/2015 11:19'!
isSpriteSpecificTarget: anObject selector: selector
	"I determine whether the given selector is specific to a particular Sprite. ."

	| i |
	selector = #COUNT ifTrue: [^ false].
	(anObject isKindOf: ScratchSpriteMorph) ifFalse: [^ false].
	selector = #stopScripts ifTrue: [^ true].
	i _ selector asString
		findAnySubStr: #('answer' 'key' 'Loud' 'mouse' 'sensor' 'soundLevel' 'tempo' 'timer')
		startingAt: 1.
	^ i > selector asString size
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 10/23/2007 12:48'!
randomInit

	RandomGen initialize.
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'tis 7/31/2006 16:04'!
resetTimer

	TimerStartMSecs _ Time millisecondClockValue.
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'EMP 4/27/2016 13:09'!
scratch2blocks
	^ #(#COUNT #'INCR_COUNT' #'CLR_COUNT' #warpSpeed #doWhile #doForLoop #isLoud #costumeName #startSceneAndWait)! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 10/21/2005 11:21'!
scratchOrigin: aPoint
	"Set the origin for the Scratch coordinate system."

	ScratchOrigin _ aPoint.
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 5/10/2006 11:22'!
soundRecorder
	"Return the shared Scratch SoundRecorder. Create and start it, if necessary."

	Recorder ifNil: [
		Recorder _ SoundRecorder new.
		Recorder startRecording].
	Recorder isActive ifFalse: [Recorder startRecording].
	^ Recorder
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'jm 5/12/2006 10:58'!
stopSoundRecorder
	"Stop the shared sound recorder."
	"self stopSoundRecorder"

	Recorder ifNotNil: [Recorder stopRecording; clearRecordedSound].

! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'EMP 10/3/2015 18:05'!
timer

	| now |
	now _ Time millisecondClockValue.
	TimerStartMSecs ifNil: [TimerStartMSecs _ now].
	TimerStartMSecs > now ifTrue: [TimerStartMSecs _ now].
	^ (now - TimerStartMSecs) asFloat / 1000.0
! !

!ScriptableScratchMorph class methodsFor: 'other' stamp: 'EMP 4/6/2016 13:31'!
tryExtractColorFrom: aColorAsNumber
	| base result alpha red green blue |
	"Try answering a color from a Scratch 2.0 color value, or nil if none can be deciphered
	-EMP 11/9/15"
	base _ (aColorAsNumber) asString withoutLeadingBlanks withoutTrailingBlanks.
	"First, try to see if the input got converted to a string"
	(base beginsWith: '(Color') ifTrue: [[result _ (Compiler evaluate: base for: self logged: false)] ifError: [result _ nil "reset the result in case of an error AFTER storing the value"]].

	"Next, try to see if it a scratch 2.0 format color: ARGB"
	(base asNumberNoError = 0) ifFalse: [
	alpha _ ((base asNumberNoError / 16777216) floor) asInteger.
	red _ ((base asNumberNoError - ((alpha * 16777216)) / 65536) floor) asInteger.
	green _ ((base asNumberNoError - ((alpha * 16777216) + (red * 65536)) / 256) floor) asInteger.
	blue _ ((base asNumberNoError - ((alpha * 16777216) + (red * 65536) + (green * 256))) floor) asInteger.
	result _ (Color r: red/255 g: green/255 b: blue/255 alpha: (1 - (alpha / 255))) "I am trying to implement color alpha. About halfway through"].

	(base asNumberNoError = 0) ifTrue: [^ (Color r:0 g:0 b:0) "in case a user wants zero"].
	
	result ifNil: [^ nil] ifNotNil: [^ result]! !


ScriptableScratchMorph initialize!
