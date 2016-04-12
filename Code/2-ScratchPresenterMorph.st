Morph subclass: #ScratchPresenterMorph
	instanceVariableNames: 'frame stage buttons flagButton offscreenWorld doubleSize mouseFocus mouseDownPoint dragOffset clickWasHandled mouseMoved lastStepTime topPane '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchPresenterMorph commentStamp: '<historical>' prior: 0!
I present the Scratch stage all by itself on the screen in presentation mode.
!


!ScratchPresenterMorph methodsFor: 'initialization' stamp: 'jm 10/21/2005 11:45'!
beDoubleSize

	doubleSize _ true.
	ScriptableScratchMorph doubleSize: true.
! !

!ScratchPresenterMorph methodsFor: 'initialization' stamp: 'jm 12/2/2005 18:51'!
buttons

	^ buttons
! !

!ScratchPresenterMorph methodsFor: 'initialization'!
frame: aScratchFrameMorph

	frame _ aScratchFrameMorph.
	stage _ aScratchFrameMorph workPane.

	"insert stage in an OffscreenWorldMorph to detect damage"
	offscreenWorld _ OffscreenWorldMorph new on: stage.
	offscreenWorld frame: aScratchFrameMorph.
! !

!ScratchPresenterMorph methodsFor: 'initialization' stamp: 'EMP 11/17/2015 19:03'!
initialize

	| button |
	super initialize.
	self color: (Color white).
	doubleSize _ false.
	lastStepTime  _ IdentityDictionary new.

	buttons _ #(
		(presentationExit	exitPresentation		'Exit presentation')
		(go					shoutGo				'Start green flag scripts')
		(stop				stopAll				'Stop everything')
	) collect: [:spec |
		button _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: (spec first, 'ButtonBlackPressed'))
			offForm: (ScratchFrameMorph skinAt: (spec first, 'ButtonBlack'))
			overForm: ((spec first = #stop) ifTrue: [(ScratchFrameMorph skinAt: (spec first, 'ButtonBlack') asSymbol)] ifFalse: [(ScratchFrameMorph skinAt: (spec first, 'ButtonBlackPressed') asSymbol)]).
		button
			target: self;
			actionSelector: spec second;
			isMomentary: true;
			actWhen: #buttonUp;
			setProperty: #balloonText toValue: spec third localized;
			drawToolTipAbove: true;
			off.
		#shoutGo = spec second ifTrue: [flagButton _ button].
		button].
	topPane _ ImageFrameMorph new initFromForm: (ScratchFrameMorph skinAt: 'libraryTop').
	buttons do: [:b | topPane addMorph: b].
	self addMorph: topPane.
! !


!ScratchPresenterMorph methodsFor: 'button actions' stamp: 'ee 12/30/2008 13:11'!
exitPresentation

	self delete.
	frame exitPresentationMode.
! !

!ScratchPresenterMorph methodsFor: 'button actions' stamp: 'jm 8/3/2008 14:11'!
shoutGo

	frame ifNotNil: [frame shoutGo].
	flagButton on.
	World displayWorldSafely.  "force button flash"
	Delay waitMSecs: 20.
! !

!ScratchPresenterMorph methodsFor: 'button actions' stamp: 'jm 8/3/2008 14:15'!
stopAll

	frame ifNotNil: [frame stopAll].

! !


!ScratchPresenterMorph methodsFor: 'geometry' stamp: 'jm 8/3/2005 11:45'!
extent: aPoint

	super extent: aPoint.
	self fixLayout.
! !

!ScratchPresenterMorph methodsFor: 'geometry' stamp: 'EMP 11/18/2015 12:07'!
fixLayout

	| stageExtent stageBox y totalW x |
	stageExtent _ doubleSize ifTrue: [2 * stage extent] ifFalse: [stage extent].
	stageBox _ Rectangle center: self center extent: stageExtent.
	stage owner center: self center + (0@5).
	y _ stageBox top - 24.
	buttons first position: 20@2.  "exit presentation button"

	topPane width: stageBox width.
	topPane height: (buttons first height + 10).
	topPane position: (stageBox left) @ y.

	"other buttons"
	totalW _ (buttons collect: [:b | b width] from: 2 to: buttons size) sum.
	x _ stageBox right - totalW - (2 * (buttons size - 2)) - 5.
	buttons allButFirst do: [:b |
		b position: x@2.
		x _ x + b width + 2].

	offscreenWorld redrawAll.
! !


!ScratchPresenterMorph methodsFor: 'drawing' stamp: 'EMP 11/17/2015 19:02'!
drawOn: aCanvas

	| stageRect |
	stageRect _ Rectangle
		center: stage center
		extent: (doubleSize ifTrue: [2 * stage extent] ifFalse: [stage extent]).

	(self bounds areasOutside: stageRect) do: [:r |
		aCanvas fillRectangle: r color: color].

	(aCanvas clipRect intersects: stageRect) ifTrue: [
		offscreenWorld invalidRect: aCanvas clipRect.
		offscreenWorld incrRedrawDouble: doubleSize].
! !


!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'jm 10/22/2005 14:00'!
handlesMouseDown: evt

	^ true
! !

!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'jm 6/2/2009 11:43'!
mouseDown: evt
	"There are three possible cases: drag a sprite, and adjust a slider, and do nothing. To drag a sprite, set mouseFocus to the sprite and dragOffset to the cursor offset the sprite's position. To adjust a slider, set the mouseFocus to the slider and dragOffset to nil. To do nothing, set both to nil."

	| p adjustedEvt rootM |
	mouseFocus _ nil.
	dragOffset _ nil.
	clickWasHandled _ false.
	mouseMoved _ false.
	evt hand toolType: nil.

	p _ mouseDownPoint _ stage adjustedCursorPoint.
	adjustedEvt _ evt copy setCursorPoint: p.

	rootM _ stage submorphs
		detect: [:m | (m containsPoint: p) & m isVisible]
		ifNone: [
			(stage containsPoint: p) ifTrue: [stage click: adjustedEvt].
			clickWasHandled _ true.
			^ self].

	(rootM isKindOf: ScratchSpriteMorph) ifTrue: [
		rootM draggable
			ifTrue: [
				rootM comeToFront.
				mouseFocus _ rootM.
				dragOffset _ rootM position - p]
			ifFalse: [
				rootM click: adjustedEvt.
				clickWasHandled _ true].
		^ self].

	(rootM unlockedMorphsAt: p) do: [:m |
		(m handlesMouseDown: adjustedEvt) ifTrue: [
			mouseFocus _ m.
			dragOffset _ nil.
			mouseFocus mouseDown: adjustedEvt.
			^ self]].


! !

!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'jm 11/28/2007 15:32'!
mouseMove: evt

	| p |
	p _ stage adjustedCursorPoint.
	p = mouseDownPoint ifFalse: [mouseMoved _ true].
	mouseFocus ifNotNil: [
		dragOffset
			ifNil: [mouseMoved ifTrue: [mouseFocus mouseMove: (evt copy setCursorPoint: p)]]
			ifNotNil: [mouseFocus position: p + dragOffset]].

! !

!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'jm 11/28/2007 15:37'!
mouseUp: evt

	| p |
	self mouseMove: evt.
	clickWasHandled ifTrue: [^ self].

	p _ stage adjustedCursorPoint.
	mouseFocus ifNotNil: [
		mouseMoved ifFalse: [mouseFocus click: (MorphicEvent new setCursorPoint: p)]].

	mouseFocus _ nil.
	dragOffset _ nil.

! !

!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'jm 3/2/2009 15:39'!
processKeyboardEvents

	| prompter evt ch |
	prompter _ stage submorphs detect: [:m | m isKindOf: ScratchPrompterMorph] ifNone: [nil].
	World hands do: [:h |
		[(evt _ h nextUnclaimedKeystrokeOrNil) notNil] whileTrue: [
			ch _ evt keyValue.
			ch = 27 ifTrue: [^ self exitPresentation].  "escape"
			prompter
				ifNotNil: [
					prompter dispatchKeyStroke: evt]
				ifNil: [
					(ch = 3) | (ch = 13) ifTrue: [^ self shoutGo].
					stage broadcastEventNamed: 'Scratch-KeyPressedEvent' with: evt]]].
! !

!ScratchPresenterMorph methodsFor: 'event handling' stamp: 'EMP 4/12/2016 13:47'!
processWhenConditions
	"Trigger any 'when <condition>' hats."

	| objList |
	"true ifTrue: [^ self].  enabled"
	objList _ stage submorphs select: [:m | m isKindOf: ScriptableScratchMorph].
	objList _ objList copyWith: stage.
	objList do: [:obj |
		obj scripts do: [:hat |
			(hat isMemberOf: WhenTrueHatBlockMorph) ifTrue: [
				(hat hasRunningProcess not and: [hat evaluateCondition]) ifTrue: [
					hat start; layoutChanged]].
			(hat isMemberOf: WhenHatBlockMorph) ifTrue: [
				(hat hasRunningProcess not and: [hat evaluateCondition]) ifTrue: [
					hat start; layoutChanged]]]].
! !


!ScratchPresenterMorph methodsFor: 'stepping' stamp: 'EMP 1/7/2016 12:21'!
step
	"Run each process until it gives up control, then filter out any processes that have terminated."

	| screenExtent |
	screenExtent _ DisplayScreen actualScreenSize.
	((self position = (0@0)) and: [self extent = screenExtent]) ifFalse: [
		self position: 0@0.
		^ self extent: screenExtent].

	ScriptableScratchMorph scratchOrigin: stage center.

	stage scratchServer ifNotNil: [stage scratchServer stepServer].
	self processKeyboardEvents.
	stage stepProcesses.
	stage step.
	self stepSubmorphs.
	offscreenWorld incrRedrawDouble: doubleSize.

	stage processesToRun size > 0
		ifTrue: [flagButton on]
		ifFalse: [flagButton off].
! !

!ScratchPresenterMorph methodsFor: 'stepping' stamp: 'EMP 1/7/2016 12:21'!
stepAt: millisecondClockValue
	millisecondClockValue // 50 = 0 ifTrue: [self processWhenConditions.].
self step.! !

!ScratchPresenterMorph methodsFor: 'stepping' stamp: 'jm 3/24/2009 17:30'!
stepSubmorphs
	"Run my submorph 'step' methods if their time has come."

	| now lastTime |
	now _ Time millisecondClockValue.
	stage submorphsDo: [:topM |
		topM allMorphsDo: [:m |
			lastTime _ lastStepTime at: m ifAbsent: [-1000000].
			((now - lastTime) > m stepTime) ifTrue: [
				m step.
				lastStepTime at: m put: now]]].
! !

!ScratchPresenterMorph methodsFor: 'stepping' stamp: 'jm 8/3/2005 11:26'!
stepTime
	"Every screen update cycle."

	^ 0
! !
