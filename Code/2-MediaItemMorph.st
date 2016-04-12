Morph subclass: #MediaItemMorph
	instanceVariableNames: 'scratchObj media thumbnailMorph numberMorph nameMorph infoMorph soundSizeMorph playButton stopButton deleteButton highlightMorph topRightInset separator rightMorph highlightPadding numberMorphTopRight minThumbHeight editor '
	classVariableNames: 'SoundIcon SoundIconOn '
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!MediaItemMorph commentStamp: '<historical>' prior: 0!
I represent an image in a Scratch object's media closet.
!


!MediaItemMorph methodsFor: 'initialization' stamp: 'jm 4/24/2008 15:48'!
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

!MediaItemMorph methodsFor: 'initialization' stamp: 'jm 4/24/2008 15:47'!
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

!MediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:18'!
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
			"self addPlayButton.
			e _ self getEditButton.
			rightMorph addMorph: e.
			e position: nameMorph left@(infoMorph bottom + 5).
			playButton position: (e topRight + (5@0)).
			self addStopButton.
			stopButton position: playButton topRight + (5@0)."
			nameMorph delete.
			self extent: 20@81.
			infoMorph position: 0@0.
			deleteButton _ self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton left: self left + 5.
			bottom _ deleteButton bottom.
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

	rightMorph extent: (media isSound ifTrue: [50@20] ifFalse: [nameMorph width@bottom]).
! !

!MediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:18'!
buildRightSideMorphStuff
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
			"self addPlayButton.
			e _ self getEditButton.
			rightMorph addMorph: e.
			e position: nameMorph left@(infoMorph bottom + 5).
			playButton position: (e topRight + (5@0)).
			self addStopButton.
			stopButton position: playButton topRight + (5@0)."
			nameMorph delete.
			self extent: 20@81.
			infoMorph position: 0@0.
			deleteButton _ self getDeleteButton.
			rightMorph addMorph: deleteButton.
			deleteButton left: self left + 5.
			bottom _ deleteButton bottom.
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

	rightMorph extent: (media isSound ifTrue: [50@20] ifFalse: [nameMorph width@bottom]).
! !

!MediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:26'!
buildSubmorphs

	| thumbHeight |

	numberMorph _ (StringMorph contents: '345')
		font: (ScratchFrameMorph getFont: #MediaItemInfo);
		color: Color white;
		position: topRightInset.
	self addMorph: numberMorph.
	numberMorphTopLeft _ numberMorph topLeft. "I don't know why this is here, but apparently the code breaks without it"

	thumbHeight _ minThumbHeight.
	thumbnailMorph _ TranslucentImageMorph new.
	thumbnailMorph form: (media thumbnailFormExtent: thumbHeight asPoint).
	thumbnailMorph width > thumbHeight ifTrue: [
		highlightPadding _ (highlightPadding x - ((thumbnailMorph width - thumbHeight)/2))@highlightPadding y].
	self addMorph: thumbnailMorph.
	thumbnailMorph position: numberMorph topLeft + highlightPadding.

	highlightMorph _ ImageFrameMorph new
		initFromForm: (ScratchFrameMorph skinAt: #costumeSelected).
	highlightMorph extent: thumbnailMorph extent + (highlightPadding * 2).
	
	deleteButton _ self getDeleteButton.
	self addMorph: deleteButton.
	deleteButton position: self topRight - (deleteButton width @ 0).
! !

!MediaItemMorph methodsFor: 'initialization' stamp: 'nb 3/25/2008 18:11'!
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

!MediaItemMorph methodsFor: 'initialization' stamp: 'jm 4/23/2008 15:23'!
getCopyButton

	| b |
	b _ ScratchFrameMorph buttonLabel: 'Copy' localized selector: #duplicateMedia.
	b target: self.
	^ b
! !

!MediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:23'!
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

!MediaItemMorph methodsFor: 'initialization' stamp: 'jm 4/23/2008 15:24'!
getEditButton

	| b |
	b _ ScratchFrameMorph buttonLabel: 'Edit' localized selector: #editMedia.
	b target: self.
	^ b
! !

!MediaItemMorph methodsFor: 'initialization' stamp: 'EMP 12/13/2015 11:24'!
initialize
 
	super initialize.
	topRightInset _ 0@0.
	self extent: 70@66.
	self color: Color transparent.
	"this determines how far in in x and y the thumbnailMorph should be inside of the highlight when selected"
	highlightPadding _ 5@5.
	"this determines the minimum size of the thumbnail. The thumbnail may grow larger with larger font sizes"
	minThumbHeight _ 56.
! !


!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 10/12/2015 11:32'!
editor: anEditorMorph
	editor _ anEditorMorph! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 12/13/2015 10:45'!
extent: anExtent
	super extent: anExtent.! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 12/13/2015 11:11'!
highlight: aBoolean

	highlightMorph ifNil: [^ self].
	aBoolean
		ifTrue: [
			highlightMorph position: (self topLeft + (numberMorphTopLeft)).
			highlightMorph owner = self ifFalse: [
				self addMorphBack: highlightMorph]]
		ifFalse: [
			highlightMorph owner = self ifTrue: [highlightMorph delete]].
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 12/15/2015 12:20'!
isHighlighted

	highlightMorph ifNil: [^false].
	^ highlightMorph owner = self
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'jm 2/27/2005 09:47'!
media

	^ media
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'tis 8/14/2006 23:37'!
mediaName

	media ifNotNil: [^ media mediaName]! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 12/13/2015 11:16'!
mediaName: name

	| newName sFrame |
	newName _ name.
	newName _ self scratchObj unusedMediaNameFromBaseName: newName forMedia: self media.
	media mediaName: newName.
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNotNil: [
		sFrame viewerPane refresh].
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'jm 2/27/2005 09:47'!
scratchObj

	^ scratchObj 
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'EMP 9/28/2015 16:05'!
scratchObj: anObject media: aScratchMedia

	media _ aScratchMedia.
	scratchObj _ anObject.
	self buildSubmorphs.
! !

!MediaItemMorph methodsFor: 'accessing' stamp: 'jm 9/27/2007 13:22'!
setNumber: anInteger

	numberMorph contents: anInteger printString.
! !


!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'jm 1/5/2006 21:44'!
deleteMedia

	ScratchFrameMorph putInClipboard: self configureForDragging.
	scratchObj deleteMedia: media.
! !

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'jm 2/27/2005 09:47'!
duplicateMedia

	scratchObj duplicateMedia: media.
! !

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 1/14/2016 11:55'!
editImage

	true ifTrue: [^ self beep].
	scratchObj lookLike: media mediaName.
	scratchObj editDrawing.
! !

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'jm 2/27/2005 15:20'!
editMedia

	media isSound ifTrue: [self editSound].
	media isImage ifTrue: [self editImage].

! !

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'jm 7/2/2008 15:27'!
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

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 3/22/2016 10:40'!
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

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'EMP 12/14/2015 12:16'!
rightButtonMenu
	"Present the right button menu."

	| menu |
	menu _ CustomMenu new.
	media isImage ifTrue: [
		menu add: 'turn into new sprite' action: #turnIntoNewSprite.
		menu add: 'save to local file' action: #exportMedia].
	media isSound ifTrue: [
		menu add: 'duplicate' action: #duplicateMedia.
		menu add: 'delete' action: #deleteMedia.
		menu addLine.
		menu add: 'save to local file' action: #exportMedia].
	menu localize; invokeOn: self.
! !

!MediaItemMorph methodsFor: 'menu/button ops' stamp: 'ee 4/8/2008 12:55'!
turnIntoNewSprite
	"Create a new sprite from this costume and delete the costume from previos sprite."

	| m frame |
	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].
	m _ ScratchSpriteMorph new soleCostume: self media deepCopy.
	frame addAndView: m.
	self deleteMedia.
! !


!MediaItemMorph methodsFor: 'event handling' stamp: 'EMP 12/14/2015 15:39'!
click: evt
	"Change the editor to focus on this morph's sound"

	media isSound ifTrue: [editor sound: self media sound; soundName: self media mediaName].! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'jm 3/27/2005 18:36'!
doubleClick: evt

	media isImage ifTrue: [self editMedia].
! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'jm 10/6/2006 18:54'!
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

!MediaItemMorph methodsFor: 'event handling' stamp: 'jm 2/27/2005 09:47'!
handlesMouseDown: evt

	^ scratchObj notNil
! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'EMP 12/15/2015 13:37'!
mouseDown: evt
	| m |
	"Handle a mouse click. Left button drags. Right button brings up a menu."

	scratchObj ifNil: [^ self].
	evt hand toolType ifNotNil: [
		^ self handleTool: evt hand toolType hand: evt hand].

	evt rightButtonPressed
		ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu]
		ifFalse:	[
			media isImage ifTrue: [scratchObj lookLike: media mediaName].
			media isSound ifTrue: [(m _ self ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil: [(m submorphs select: [:mediaitemmorph | (mediaitemmorph isKindOf: MediaItemMorph) ifTrue: [(mediaitemmorph media isSound)] ifFalse: [false]]) do: [:soundmedia | soundmedia highlight: false]. self highlight: true].
editor sound: self media sound; soundName: self media mediaName].
			evt hand waitForClicksOrDrag: self event: evt].! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'jm 12/19/2008 17:29'!
mouseHold: evt

	self rightButtonMenu.
! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'jm 1/21/2007 15:24'!
startDrag: evt

	(self ownerThatIsA: ScratchScriptEditorMorph)
		ifNil: [evt hand grabMorph: self]
		ifNotNil: [evt hand attachMorph: self fullCopy configureForDragging].
! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'ee 1/2/2006 13:53'!
startPreviewSound

	media sound isPlaying
		ifFalse: [media sound play].! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'EMP 12/13/2015 11:16'!
step
	
	Sensor anyButtonPressed ifTrue: [^ self].

	media isSound ifTrue: [
		(media sound notNil and: [media sound isPlaying])
			ifTrue: [
				thumbnailMorph form: SoundIconOn.
				"playButton on. 
				stopButton off"]
			ifFalse: [
				thumbnailMorph form: SoundIcon.
				"playButton off. 
				stopButton off"]].
! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'ee 1/2/2006 13:51'!
stepTime

	^ 50! !

!MediaItemMorph methodsFor: 'event handling' stamp: 'ee 1/2/2006 13:53'!
stopPreviewSound

	media sound isPlaying
		ifTrue: [media sound pause].! !


!MediaItemMorph methodsFor: 'dropping/grabbing' stamp: 'jens 8/22/2008 13:21'!
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


!MediaItemMorph methodsFor: 'printing' stamp: 'jm 4/18/2008 14:37'!
printOn: aStream

	aStream nextPutAll: self class name, '[', media mediaName, ']'.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MediaItemMorph class
	instanceVariableNames: ''!

!MediaItemMorph class methodsFor: 'class initialization' stamp: 'jm 3/21/2008 13:59'!
initialize
	"self initialize"

	SoundIcon _ (ScratchFrameMorph skinAt: #scratchSound).
	SoundIconOn _ (ScratchFrameMorph skinAt: #scratchSoundOn).
! !


MediaItemMorph initialize!
