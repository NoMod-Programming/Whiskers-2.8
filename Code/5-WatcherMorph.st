AlignmentMorph subclass: #WatcherMorph
	instanceVariableNames: 'titleMorph readout readoutFrame scratchSlider watcher lastTargetName isSpriteSpecific isLarge lastPosition sliderMin sliderMax unused '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Watchers'!
!WatcherMorph commentStamp: 'jm 8/21/2006 13:54' prior: 0!
I am a Scratch variable readout/editor. I can view both variables and reporter values. I support various display modes.
!


!WatcherMorph methodsFor: 'initialization' stamp: 'jm 8/13/2008 15:44'!
buildReadout
	"Build my readout component morphs."

	readout _ UpdatingStringMorph new
		contents: '';
		floatPrecision: 0.1;
		stepTime: 100.
	readout
		font: (ScratchFrameMorph getFont: #Watcher);
		forceUnicodeRendering: true;
		color: Color white;
		kern: 1.
	readoutFrame _ WatcherReadoutFrameMorph new addMorph: readout.
! !

!WatcherMorph methodsFor: 'initialization' stamp: 'jm 8/6/2008 19:30'!
initialize

	super initialize.
	titleMorph _ StringMorph contents: '???'.
	titleMorph font: (ScratchFrameMorph getFont: #Watcher).
	readout _ readoutFrame _ scratchSlider _ nil.
	lastTargetName _ nil.
	isSpriteSpecific _ true.
	isLarge _ false.
	sliderMin _ 0.
	sliderMax _ 100.
	watcher _ AlignmentMorph new
		color: Color transparent;
		borderWidth: 0;
		inset: 0;
		orientation: #horizontal;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		centering: #center.
	self 
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderWidth: 1;
		borderColor: (Color r: (148/255) g: (145/255) b: (145/255));
		orientation: #vertical;
		centering: #center;
		inset: 2;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		buildReadout;
		useRoundedCorners;
		addMorphBack: watcher;
		addMorphBack: (Morph new color: Color transparent; extent: 5@1).
! !

!WatcherMorph methodsFor: 'initialization' stamp: 'jm 9/25/2006 13:05'!
setCategoryColor: aColor

	readoutFrame color: aColor.
! !

!WatcherMorph methodsFor: 'initialization' stamp: 'EMP 11/2/2015 19:17'!
target: anObject selector: selector parameter: parameter
	"Initialize this watcher. If parameter is not nil, then this watcher is used to access user-defined variables or parameterized reporters."

	
	readout
		target: anObject;
		getSelector: selector asSymbol;
		parameter: parameter.
	selector = #timestamp ifTrue: [readout floatPrecision: 0.001].

	isSpriteSpecific _ ScriptableScratchMorph isSpriteSpecificTarget: anObject selector: selector
! !


!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/26/2008 11:35'!
convertFromOldWatcher
	"Convert myself from old watcher structure to the current structure."

	| o p target selector param wasLarge showSlider oldRange c |
	o _ self owner.
	p _ self position.
	target _ readout target.
	selector _ readout getSelector.
	(selector = #getUserVar:) ifTrue: [selector _ #getVar:].  "update selector"
	param _ readout parameter.
	wasLarge _ readoutFrame isLarge.
	showSlider _ scratchSlider notNil.
	oldRange _ self sliderRange.

	self delete; removeAllMorphs; initialize.
	self
		position: p;
		target: target selector: selector parameter: param;
		sliderRange: oldRange.
	self layoutForViewer.

	selector = #getVar:
		ifTrue: [self setCategoryColor: target variableBlockColor]
		ifFalse: [
			c _ ScriptableScratchMorph blockColorDict at: selector ifAbsent: [nil].
			c ifNotNil: [self setCategoryColor: c]].

	o addMorph: self.
	self updateTargetName.
	wasLarge ifTrue: [self showLargeReadout].
	showSlider ifTrue: [self showSlider].
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'DaveF 7/14/2003 16:25'!
evaluate
	"Answer the value of my variable."

	^ readout valueFromTargetOrNil
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 12/1/2007 20:50'!
getAssociatedSprite
	"Return my target."

	^ self target
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'EMP 10/3/2015 17:08'!
getSelector
	^ readout getSelector
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'TIS 7/11/2003 10:11'!
getVariable

	readout parameter notNil
		ifTrue: [^ readout parameter]
		ifFalse: [^ readout getSelector]
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/6/2008 19:44'!
isLarge

	^ isLarge
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 3/17/2003 15:48'!
isReporter

	^ true
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'ee 6/19/2008 16:42'!
languageChanged
	"Force label update after switching languages."

	lastTargetName _ nil.
	self updateTargetName.
	readout target: readout target.  "forces contents to update"
	titleMorph extent: (ScratchTranslator stringExtent: titleMorph contents font: titleMorph font).
	readout extent: (ScratchTranslator stringExtent: readout contents font: readout font).
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/7/2008 16:17'!
layoutStyle
	"Return a symbol indicating my current layout type: small, slider, large."

	scratchSlider notNil ifTrue: [^ #slider].
	^ self isLarge ifTrue: [#large] ifFalse: [#small]
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/7/2008 16:22'!
layoutStyle: aSymbol
	"Set my layout style to one of: #small, #slider, #large."

	self layoutForViewer.
	#slider = aSymbol ifTrue: [^ self showSlider].
	#large = aSymbol ifTrue: [^ self showLargeReadout].
	self showSmallReadout.
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 12/1/2007 21:44'!
parameter

	^ readout parameter
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 11/30/2007 14:09'!
selectorAndArg
	"Answer an array containing my selector and argument (if any)."

	^ Array with: readout getSelector with: readout parameter! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/25/2008 09:56'!
sliderRange
	"Return an array containting the slider max and min."

	^ Array with: sliderMin with: sliderMax
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/25/2008 09:59'!
sliderRange: anArray
	"Set the slider max and min."

	sliderMin _ anArray first.
	sliderMax _ anArray second.
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 8/21/2006 09:50'!
target

	^ readout target
! !

!WatcherMorph methodsFor: 'accessing' stamp: 'jm 12/12/2003 13:46'!
target: anObject

	readout target: anObject.
! !


!WatcherMorph methodsFor: 'dropping/grabbing' stamp: 'jm 12/1/2007 21:04'!
justDroppedInto: aMorph event: evt

	(aMorph isKindOf: ScratchStageMorph) ifTrue: [
		super justDroppedInto: aMorph event: evt.
		self world ifNotNil: [self world startSteppingSubmorphsOf: self].
		^ self].

	"delete me if dropped anywhere but the stage"
	lastPosition ifNil: [lastPosition _ evt hand formerPosition].
	self position: lastPosition.
	^ self delete
! !

!WatcherMorph methodsFor: 'dropping/grabbing' stamp: 'TIS 7/9/2003 10:47'!
rootForGrabOf: aMorph
	"Allow myself to be extracted."

	(owner notNil and: [owner isPartsBin])
		ifTrue: [^ super rootForGrabOf: aMorph]
		ifFalse: [^ self].
! !


!WatcherMorph methodsFor: 'stepping' stamp: 'jm 11/21/2006 12:27'!
step

	self updateTargetName.
	readoutFrame ifNotNil: [readoutFrame fixLayout].
	scratchSlider ifNotNil: [
		(World activeHand hasMouseFocus: scratchSlider) ifFalse: [
			scratchSlider width: self width - 12.
			scratchSlider updateSliderPosition]].
! !

!WatcherMorph methodsFor: 'stepping' stamp: 'jm 8/24/2003 23:34'!
stepTime

	^ 100
! !


!WatcherMorph methodsFor: 'event handling' stamp: 'jm 12/1/2007 20:28'!
click: evt

	evt hand toolType = 'CutTool' ifTrue: [
		evt shiftPressed ifFalse: [evt hand toolType: nil].
		ScratchFrameMorph putInClipboard: self.
		self aboutToBeGrabbedBy: evt hand.
		self delete].
! !

!WatcherMorph methodsFor: 'event handling' stamp: 'jm 8/6/2008 19:31'!
doubleClick: evt
	"Toggle slider/large readout view if I'm in the work pane."

	(self owner isKindOf: ScratchStageMorph) ifFalse: [^ self].  "ignore if not on stage"

	scratchSlider ifNotNil: [^ self showLargeReadout]. "slider -> large readout"
	isLarge ifTrue: [^ self showSmallReadout].  "large readout -> small readout"
	self isVariableWatcher
		ifTrue: [self showSlider]  "small readout -> slider"
		ifFalse: [self showLargeReadout].  "small readout -> large readout"
! !

!WatcherMorph methodsFor: 'event handling' stamp: 'jm 1/2/2006 18:54'!
handlesMouseDown: evt

	^ self world notNil! !

!WatcherMorph methodsFor: 'event handling' stamp: 'jm 11/27/2007 16:05'!
mouseDown: evt

	evt rightButtonPressed ifTrue: [Sensor waitNoButton. ^ self rightButtonMenu].

	evt hand waitForClicksOrDrag: self event: evt.
! !

!WatcherMorph methodsFor: 'event handling' stamp: 'jm 12/1/2007 20:18'!
startDrag: evt

	self world ifNil: [^ self].  "don't pick me up if in presentation mode"
	lastPosition _ self position.
	super startDrag: evt.
! !

!WatcherMorph methodsFor: 'event handling' stamp: 'jm 10/2/2006 15:34'!
wantsKeyboardFocusFor: aSubmorph
	"Don't allow shift-click editing of my label."

	^ false
! !


!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 12/1/2007 21:50'!
delete

	super delete.
	ScratchFrameMorph allInstancesDo: [:frame | frame deletingWatcher].
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 11/21/2006 11:14'!
hideSlider

	scratchSlider ifNotNil: [
		sliderMin _ scratchSlider minVal.
		sliderMax _ scratchSlider maxVal.
		scratchSlider delete.
		scratchSlider _ nil].
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'EMP 2/25/2016 14:22'!
min: min max: max

	sliderMin _ min.
	sliderMax _ max.
	scratchSlider ifNotNil: [
		scratchSlider
			minVal: sliderMin;
			maxVal: sliderMax;
			truncate: (sliderMin isInteger & sliderMax isInteger);
			updateSliderPosition].
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 6/3/2009 17:46'!
rightButtonMenu

	| menu hasSlider |
	(self ownerThatIsA: ScratchStageMorph) ifNil: [^ self].

	menu _ CustomMenu new.
	hasSlider _ self isVariableWatcher and: [scratchSlider notNil].

	hasSlider not & isLarge not
		ifTrue: [menu add: '* ' asUTF8, 'normal readout' localized,' *'	action: #showSmallReadout]
		ifFalse: [menu add: '  ' asUTF8, 'normal readout' localized		action: #showSmallReadout].

	hasSlider not & isLarge
		ifTrue: [menu add: '* ' asUTF8, 'large readout' localized, ' *'		action: #showLargeReadout]
		ifFalse: [menu add: '  ' asUTF8, 'large readout' localized			action: #showLargeReadout].

	self isVariableWatcher ifTrue: [
		scratchSlider
			ifNil: [menu add: '  ' asUTF8, 'slider' localized action: #showSlider]
			ifNotNil: [
				menu add: '* ' asUTF8, 'slider' localized,' *' action: #showSlider.
				menu addLine.
				menu add: '  ' asUTF8, 'set slider min and max' localized action: #setSliderMinAndMax]].

	menu addLine.
	menu add: '  ' asUTF8,  'hide' localized action: #delete.
	menu invokeOn: self.
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 11/21/2006 12:39'!
setSliderMinAndMax

	| newRange |
	newRange _ SliderRangeDialog initialMin: sliderMin max: sliderMax.
	newRange ifNil: [^ self].

	sliderMin _ newRange first.
	sliderMax _ newRange last.
	scratchSlider ifNotNil: [
		scratchSlider
			minVal: sliderMin;
			maxVal: sliderMax;
			truncate: (sliderMin isInteger & sliderMax isInteger);
			updateSliderPosition].
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 8/6/2008 19:37'!
showLargeReadout

	self hideSlider.

	isLarge _ true.
	readout font: (ScratchFrameMorph getFont: #WatcherLarge).
	readoutFrame
		borderColor: (Color gray: 3);
		fixLayout.
	watcher removeAllMorphs; addMorphBack: readoutFrame.
	self
		inset: 0;
		color: Color transparent;
		borderColor: Color transparent;
		cornerStyle: #square.
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 9/25/2007 18:31'!
showSlider

	self hideSlider.
	self showSmallReadout.

	scratchSlider _ WatcherSliderMorph new
		target: readout target;
		actionSelector: #setVar:to:;
		arguments: (Array with: self getVariable);
		truncate: (sliderMin isInteger & sliderMax isInteger);
		minVal: sliderMin;
		maxVal: sliderMax;
		sliderThickness: 0;
		height: 10;
		width: self width - 12.

	self addMorphBack: scratchSlider.
	self world ifNotNil: [self world startSteppingSubmorphsOf: scratchSlider].
	scratchSlider updateSliderPosition.
! !

!WatcherMorph methodsFor: 'right button menu' stamp: 'jm 8/6/2008 19:35'!
showSmallReadout

	self hideSlider.

	isLarge _ false.
	readout font: (ScratchFrameMorph getFont: #Watcher).
	readoutFrame
		borderColor: Color white;
		fixLayout.
	self
		inset: 2;
		color: (Color r: (193/255) g: (196/255) b: (199/255));
		borderColor: (Color r: (148/255) g: (145/255) b: (145/255));
		cornerStyle: #rounded.

	self layoutForViewer.
! !


!WatcherMorph methodsFor: 'copying' stamp: 'jm 2/13/2004 19:12'!
copyRecordingIn: dict
	"Overridden to copy my readout if it is not currently showing. This avoids accidentally sharing the readout morph with the original Watcher that is being copied. If the readout is showing, it is copied by the fullCopy operation, so we don't need to copy it."

	| result |
	result _ super copyRecordingIn: dict.
	readoutFrame owner ifNil: [result readoutFrame: readoutFrame fullCopy].
	^ result
! !

!WatcherMorph methodsFor: 'copying' stamp: 'jm 2/13/2004 19:14'!
mapReceiver: oldObj to: newObj
	"Used in cloning an object to make blocks that refererred to the original object new refer to the new copy."

	readout target == oldObj ifTrue: [readout target: newObj].
! !

!WatcherMorph methodsFor: 'copying' stamp: 'jm 2/13/2004 18:17'!
readoutFrame: readoutFrameMorph
	"Fix up my readout when copying."

	readoutFrame _ readoutFrameMorph.
	readout _ readoutFrameMorph firstSubmorph.
! !


!WatcherMorph methodsFor: 'object i/o' stamp: 'jm 8/6/2008 19:28'!
fieldsVersion

	^ 5
! !

!WatcherMorph methodsFor: 'object i/o' stamp: 'jm 8/6/2008 19:31'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		scratchSlider
		watcher) from: anObjStream.
	watcher ifNotNil: [watcher useRoundedCorners].
	classVersion = 1 ifTrue: [^ self].
	
	"fields added in version 2"
	self initFieldsNamed: #(
		isSpriteSpecific
		unused
	) from: anObjStream.

	"fields added in version 4"
	classVersion < 4 ifTrue: [^ self].
	self initFieldsNamed: #(
		sliderMin
		sliderMax
	) from: anObjStream.

	"fields added in version 5"
	classVersion < 5 ifTrue: [^ self].
	self initFieldsNamed: #(
		isLarge
	) from: anObjStream.
! !

!WatcherMorph methodsFor: 'object i/o' stamp: 'jm 8/6/2008 19:28'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		titleMorph
		readout
		readoutFrame
		scratchSlider
		watcher
		isSpriteSpecific
		unused
		sliderMin
		sliderMax
		isLarge
	) on: anObjStream.
! !


!WatcherMorph methodsFor: 'private' stamp: 'jm 11/15/2006 11:40'!
isVariableWatcher
	"Answer true if I am watching a variable."

	^ readout getSelector = #getVar:
! !

!WatcherMorph methodsFor: 'private' stamp: 'ee 6/19/2008 16:36'!
layoutForViewer

	watcher removeAllMorphs.
	ScratchTranslator isRTL
		ifTrue: [watcher
			addMorphBack: (Morph new color: color; extent: 2);
			addMorphBack: readoutFrame;
			addMorphBack: (AlignmentMorph new color: color; width: 4; hResizing: #rigid);
			addMorphBack: titleMorph;
			addMorphBack: (Morph new color: color; extent: 3)]
		ifFalse: [watcher
			addMorphBack: (Morph new color: color; extent: 3);
			addMorphBack: titleMorph;
			addMorphBack: (AlignmentMorph new color: color; width: 4; hResizing: #rigid);
			addMorphBack: readoutFrame;
			addMorphBack: (Morph new color: color; extent: 2)].
! !

!WatcherMorph methodsFor: 'private' stamp: 'ee 6/23/2009 20:33'!
replace: argStr with: translatedArg in: s
	"Answer a copy of the given string in which the first (only) occurance of argStr is replaced by translatedArg."

	| i |
	i _ s findString: argStr startingAt: 1.
	i = 0 ifTrue: [^ s].
	^ ((s copyFrom: 1 to: i - 1), translatedArg, (s copyFrom: i + argStr size to: s size)) asUTF8
! !

!WatcherMorph methodsFor: 'private' stamp: 'jm 11/30/2007 22:49'!
translatedName
	"Answer the name for this watcher based on my selector and argument. The names of reporters are translated into the current language. The names of variables are left untouched."

	| sel spec result param |
	readout target ifNil: [^ 'xxx'].
	sel _ readout getSelector.
	#getVar: = sel ifTrue: [^ readout parameter].

	spec _ readout target blockSpecForSelector: sel.
	spec ifNil: [^ sel].

	result _ ScratchTranslator translationFor: spec.
	param _ readout parameter.
	param ifNil: [param _ ''].

	#sensor: = sel ifTrue: [
		result _ self replace: '%H' with: (ScratchTranslator translationFor: param) in: result].
	#sensorPressed: = sel ifTrue: [
		result _ self replace: '%h' with: (ScratchTranslator translationFor: param) in: result].

	^ result
! !

!WatcherMorph methodsFor: 'private' stamp: 'EMP 2/24/2016 21:59'!
updateTargetName
	"Check if I should display my target's name."

	| targetName |
	(self ownerThatIsA: HandMorph) ifNotNil: [^ self].  "do nothing when in a HandMorph"
	isLarge ifTrue: [^ self].  "don't show target or var name if large readout showing"

	targetName _ readout target objName asUTF8.
	(lastTargetName = targetName) ifTrue: [^ self].  "no change"

	isSpriteSpecific
		ifTrue: [titleMorph contents: targetName, ': ', self translatedName asUTF8]
		ifFalse: [titleMorph contents: self translatedName].

	lastTargetName _ targetName.
! !
