Morph subclass: #OldMediaItemMorph
	instanceVariableNames: 'scratchObj media thumbnailMorph numberMorph nameMorph infoMorph soundSizeMorph playButton stopButton deleteButton highlightMorph topRightInset separator rightMorph highlightPadding numberMorphTopRight minThumbHeight '
	classVariableNames: 'SoundIcon SoundIconOn '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
addPlayButton

	| h |
	playButton _ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn)
		onForm: (ScratchFrameMorph skinAt: #btnPressed).

	playButton
		icon: (ScratchFrameMorph skinAt: #scratchSoundPlay);
		target: self;
		actionSelector: #startPreviewSound;
		toggleMode: false.

	h _ (ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia) height.
	h _ h max: 21.
	playButton extent: (1.3 * h) rounded@h.

	rightMorph addMorphBack: playButton.
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
addStopButton

	| h |
	stopButton _ ResizableToggleButton2 new
		offForm: (ScratchFrameMorph skinAt: #btn)
		onForm: (ScratchFrameMorph skinAt: #btnPressed).

	stopButton
		icon: (ScratchFrameMorph skinAt: #scratchSoundStop);
		target: self;
		actionSelector: #stopPreviewSound;
		toggleMode: false.

	h _ (ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia) height.
	h _ h max: 21.
	stopButton extent: h@h.

	rightMorph addMorphBack: stopButton.
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
buildRightSideMorph
	"Answers the part of MediaItemMorph that includes the label, the edit/copy or record/play buttons, etc. This includes everything but the sprite image, the number, and the horizontal divider."

	| e c bottom |
	rightMorph _ Morph new.
	rightMorph color: (Color transparent).

	nameMorph _ UpdatingStringFieldMorph new
		acceptWhenFocusLost: true;
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		getSelector: #mediaName;
		putSelector: #mediaName:;
		position: (0@0);
		target: self.

	nameMorph width: (5 * nameMorph height) asInteger.
	rightMorph addMorphBack: nameMorph.

	infoMorph _ (StringMorph contents: (media infoString))
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		position: nameMorph left + 2 @ (nameMorph bottom).
	rightMorph addMorph: infoMorph.

	media isSound
		ifTrue: [
			self addPlayButton.
			e _ self getEditButton.
			rightMorph addMorph: e.
			e position: nameMorph left@(infoMorph bottom + 5).
			playButton position: (e topRight + (5@0)).
			self addStopButton.
			stopButton position: playButton topRight + (5@0).
			deleteButton _ self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton left: stopButton right + 5.
			bottom _ stopButton bottom.
		] ifFalse: [
			e _ self getEditButton.
			rightMorph addMorph: e.
			e position: nameMorph left@(infoMorph bottom + 5).
			c _ self getCopyButton.
			rightMorph addMorph: c.
			c position: e topRight + (5@0).
			deleteButton _ self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton position: c right + 5.
			bottom _ c bottom].

	nameMorph extent: (deleteButton right max: nameMorph width)@(nameMorph extent y).
	deleteButton position: (nameMorph right - deleteButton width)@(infoMorph bottom + 6).

	soundSizeMorph _ (StringMorph contents: '')
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		position: nameMorph right @ nameMorph bottom.
	rightMorph addMorph: soundSizeMorph.

	soundSizeMorph
		contents: media mediaSizeInKilobytes asString , ' KB';
		position: ((nameMorph right - soundSizeMorph width) @ nameMorph bottom).

	rightMorph extent: nameMorph width@bottom.
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:18'!
buildSubmorphs

	| thumbHeight |

	numberMorph _ (StringMorph contents: '345')
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		color: Color white;
		position: topRightInset.
	self addMorph: numberMorph.
	numberMorphTopRight _ numberMorph topRight.

	thumbHeight _ minThumbHeight max: (rightMorph height - (2 * highlightPadding y)).
	thumbnailMorph _ TranslucentImageMorph new.
	thumbnailMorph form: (media thumbnailFormExtent: thumbHeight asPoint).
	thumbnailMorph width > thumbHeight ifTrue: [
		highlightPadding _ (highlightPadding x - ((thumbnailMorph width - thumbHeight)/2))@highlightPadding y].
	self addMorph: thumbnailMorph.
	thumbnailMorph position: numberMorph topRight + highlightPadding.

	highlightMorph _ ImageFrameMorph new
		initFromForm: (ScratchFrameMorph skinAt: #costumeSelected).
	highlightMorph extent: thumbnailMorph extent + (highlightPadding * 2).

	self addMorph: rightMorph.
	rightMorph position: thumbnailMorph topRight + ((highlightPadding x + 10)@highlightPadding y negated).
	rightMorph extent: rightMorph extent x@(rightMorph extent y max: highlightMorph extent y).

	separator _ TiledImageMorph new tileForm: (ScratchFrameMorph skinAt: #costumeSeparatorTile).
	self addMorph: separator.
	separator
		position: (numberMorph left)@(rightMorph bottom + 5);
		width: rightMorph right - 14.
	
	self extent: (rightMorph right + 10)@separator bottom
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
configureForDragging
	"Rebuild my submorphs to make a draggable version of me."
	"MediaItemMorph open configureForDragging"

	self removeAllMorphs.

	thumbnailMorph position: self position + highlightPadding.
	self addMorph: thumbnailMorph.

	highlightMorph position: self position.
	self addMorphBack: highlightMorph.

	self color: Color transparent.
	self extent: highlightMorph extent.
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
getCopyButton

	| b |
	b _ ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia.
	b target: self.
	^ b
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 3/22/2016 10:40'!
getDeleteButton

	| b |
	b _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #deleteCircleButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #deleteCircleButton).
	b
		actionSelector: #deleteMedia;
		toggleMode: false.

	media isImage ifTrue: [(scratchObj isKindOf: ScratchStageMorph)
		ifTrue: [b setBalloonText: 'Delete this backdrop' localized]
		ifFalse: [b setBalloonText: 'Delete this costume' localized]].
	media isSound ifTrue: [b setBalloonText: 'Delete this sound' localized].
	b target: self.
	^ b
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
getEditButton

	| b |
	b _ ScratchFrameMorph buttonLabel: 'Edit' localized selector: #editMedia.
	b target: self.
	^ b
! !

!OldMediaItemMorph methodsFor: 'initialization' stamp: 'EMP 10/11/2015 21:18'!
initialize
 
	super initialize.
	topRightInset _ 17@10.
	self extent: 285@81.
	self color: Color transparent.
	"this determines how far in in x and y the thumbnailMorph should be inside of the highlight when selected"
	highlightPadding _ 20@5.
	"this determines the minimum size of the thumbnail. The thumbnail may grow larger with larger font sizes"
	minThumbHeight _ 56.
! !


!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
highlight: aBoolean

	highlightMorph ifNil: [^ self].
	aBoolean
		ifTrue: [
			highlightMorph position: (self topLeft + numberMorphTopRight).
			highlightMorph owner = self ifFalse: [
				self addMorphBack: highlightMorph]]
		ifFalse: [
			highlightMorph owner = self ifTrue: [highlightMorph delete]].
! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
media

	^ media
! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
mediaName

	media ifNotNil: [^ media mediaName]! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
mediaName: name

	| newName sFrame |
	newName _ name.
	newName _ self scratchObj unusedMediaNameFromBaseName: newName forMedia: self media.
	media mediaName: newName.
	nameMorph contents: newName.
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [
		sFrame viewerPane refresh].
! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
scratchObj

	^ scratchObj 
! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
scratchObj: anObject media: aScratchMedia

	media _ aScratchMedia.
	scratchObj _ anObject.
	self buildSubmorphs.
! !

!OldMediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 21:18'!
setNumber: anInteger

	numberMorph contents: anInteger printString.
! !


!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
deleteMedia

	ScratchFrameMorph putInClipboard: self configureForDragging.
	scratchObj deleteMedia: media.
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
duplicateMedia

	scratchObj duplicateMedia: media.
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
editImage

	scratchObj lookLike: media mediaName.
	scratchObj editDrawing.
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
editMedia

	media isSound ifTrue: [self editSound].
	media isImage ifTrue: [self editImage].

! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
editSound

	| sFrame workPane editor |
	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	sFrame ifNil: [^ self].
	workPane _ sFrame workPane.

	editor _ ScratchSoundEditor new client: scratchObj; sound: media sound.
	editor soundName: media mediaName.
	editor position: workPane topLeft + (10@10).
	workPane addMorph: editor.
	workPane world ifNotNil: [workPane world startSteppingSubmorphsOf: editor].
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 3/22/2016 10:40'!
exportMedia

	| result title type |
	media isMovie ifTrue: [^ self].
	(self scratchObj isKindOf: ScratchStageMorph) ifTrue: 
		[type _ #background. title _ 'Export Backdrop'].
	(self scratchObj isKindOf: ScratchSpriteMorph) ifTrue: 
		[type _ #costume. title _ 'Export Costume'].
	media isSound ifTrue: [type _ #sound. title _ 'Export Sound'].
	result _ ScratchFileChooserDialog
		chooseNewFileDefault: media mediaName
		title: title
		type: type.
	result = #cancelled ifTrue: [^ self].
	result size > 0 ifTrue: [media exportFilename: result for: self scratchObj].
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
rightButtonMenu
	"Present the right button menu."

	| menu |
	menu _ CustomMenu new.
	media isImage ifTrue: [
		menu add: 'turn into new sprite' action: #turnIntoNewSprite.
		menu add: 'export this costume' action: #exportMedia].
	media isSound ifTrue: [
		menu add: 'export this sound' action: #exportMedia].
	menu localize; invokeOn: self.
! !

!OldMediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 10/11/2015 21:18'!
turnIntoNewSprite
	"Create a new sprite from this costume and delete the costume from previos sprite."

	| m frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	m _ ScratchSpriteMorph new soleCostume: self media deepCopy.
	frame addAndView: m.
	self deleteMedia.
! !


!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
click: evt
	"In a sound media item, if the thumbnail is clicked on, play the sound."

	| pos |
	pos _ evt cursorPoint.
	(media isSound) ifFalse: [^ self].
	(thumbnailMorph bounds containsPoint: pos) ifTrue: [self startPreviewSound].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
doubleClick: evt

	media isImage ifTrue: [self editMedia].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
handleTool: toolName hand: hand

	toolName = 'CopyTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		^ self duplicateMedia].

	toolName = 'CutTool' ifTrue: [
		Sensor shiftPressed ifFalse: [hand toolType: nil].
		self delete.
		ScratchFrameMorph putInClipboard: self configureForDragging.
		^ self deleteMedia].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
handlesMouseDown: evt

	^ scratchObj notNil
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
mouseDown: evt
	"Handle a mouse click. Left button drags. Right button brings up a menu."

	scratchObj ifNil: [^ self].
	evt hand toolType ifNotNil: [
		^ self handleTool: evt hand toolType hand: evt hand].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			media isImage ifTrue: [scratchObj lookLike: media mediaName].
			evt hand waitForClicksOrDrag: self event: evt].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
mouseHold: evt

	self rightButtonMenu.
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
startDrag: evt

	(self ownerThatIsA: ScratchScriptEditorMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy configureForDragging].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
startPreviewSound

	media sound isPlaying
		ifFalse: [media sound play].! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
step
	
	Sensor anyButtonPressed ifTrue: [^ self].

	media isSound ifTrue: [
		(media sound notNil and: [media sound isPlaying])
			ifTrue: [
				thumbnailMorph form: SoundIconOn.
				infoMorph contents: media sound currentPosition hhmmss.
				infoMorph color: Color white.
				playButton on. 
				stopButton off]
			ifFalse: [
				thumbnailMorph form: SoundIcon.
				infoMorph contents: media infoString.
				infoMorph color: Color black.
				playButton off. 
				stopButton off]].
! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
stepTime

	^ 50! !

!OldMediaItemMorph methodsFor: 'event handling' stamp: 'EMP 10/11/2015 21:18'!
stopPreviewSound

	media sound isPlaying
		ifTrue: [media sound pause].! !


!OldMediaItemMorph methodsFor: 'dropping/grabbing' stamp: 'EMP 10/11/2015 21:18'!
justDroppedInto: aMorph event: evt

	self delete.
	(aMorph ownerThatIsA: ScratchViewerMorph) ifNotNil: [
		"delete myself when dropped on the blocks palette"
		^ self deleteMedia].

	(aMorph ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil: [
		"I have been accepted into a media list; exit this method to prevent myself from being put into the Clipboard again"
		^ self].

	(scratchObj media includes: media) not ifTrue: [
		"I have been dropped outside of the media list; allow myself to be resurrected again".
		^ self deleteMedia]
! !


!OldMediaItemMorph methodsFor: 'printing' stamp: 'EMP 10/11/2015 21:18'!
printOn: aStream

	aStream nextPutAll: self class name, '[', media mediaName, ']'.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

OldMediaItemMorph class
	instanceVariableNames: ''!

!OldMediaItemMorph class methodsFor: 'class initialization' stamp: 'EMP 10/11/2015 21:18'!
initialize
	"self initialize"

	SoundIcon _ (ScratchFrameMorph skinAt: #scratchSound).
	SoundIconOn _ (ScratchFrameMorph skinAt: #scratchSoundOn).
! !


OldMediaItemMorph initialize!
