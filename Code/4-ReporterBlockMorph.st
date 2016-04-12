CommandBlockMorph subclass: #ReporterBlockMorph
	instanceVariableNames: 'isBoolean '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!

!ReporterBlockMorph methodsFor: 'initialization' stamp: 'jm 3/31/2005 19:39'!
initialize

	super initialize.
	isBoolean _ false.
	self extent: 80@20.
! !


!ReporterBlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 09:37'!
drawBooleanOn: aCanvas 

	| right topY bottomY xInset c |
	self computeHighlightColors.

	right _ self width.
	topY _ bottomY _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	xInset _ 0.
	[topY >= 0] whileTrue: [
		topY = 0 ifTrue: [c _ highlightColor1].
		topY = 1 ifTrue: [c _ highlightColor2].
		topY > 1 ifTrue: [c _ color].
		self drawHLineFrom: xInset to: right - xInset y: topY color: c on: aCanvas.
		(topY > 1) & (xInset > 0) ifTrue: [
			self drawPoint: xInset@topY color: highlightColor1 on: aCanvas.
			self drawPoint: (right - xInset - 1)@topY color: shadowColor on: aCanvas].

		c _ bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		self drawHLineFrom: xInset to: right - xInset y: bottomY color: c on: aCanvas.
		xInset > 0 ifTrue: [
			self drawPoint: xInset@bottomY color: shadowColor on: aCanvas.
			self drawPoint: (right - xInset - 1)@bottomY color: shadowColor on: aCanvas].

		xInset _ xInset + 1.	
		bottomY _ bottomY + 1.
		topY _ topY - 1].

! !

!ReporterBlockMorph methodsFor: 'drawing' stamp: 'jm 3/30/2005 08:15'!
drawNumericOn: aCanvas 

	| right topY bottomY radius xInset c |
	self computeHighlightColors.

	right _ self width.
	topY _ bottomY _ radius _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset _ radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		topY = 0 ifTrue: [c _ highlightColor1].
		topY = 1 ifTrue: [c _ highlightColor2].
		topY > 1 ifTrue: [c _ color].
		self drawHLineFrom: xInset to: right - xInset y: topY color: c on: aCanvas.
		(xInset > 0) & (topY > 1) ifTrue: [
			self drawPoint: xInset@topY color: highlightColor1 on: aCanvas.
			self drawPoint: (right - xInset - 1)@topY color: highlightColor1 on: aCanvas].

		c _ bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		self drawHLineFrom: xInset to: right - xInset y: bottomY color: c on: aCanvas.
		xInset > 0 ifTrue: [
			self drawPoint: xInset@bottomY color: shadowColor on: aCanvas.
			self drawPoint: (right - xInset - 1)@bottomY color: shadowColor on: aCanvas].

		bottomY _ bottomY + 1.
		topY _ topY - 1].
! !

!ReporterBlockMorph methodsFor: 'drawing' stamp: 'jm 3/28/2005 13:16'!
drawOn: aCanvas 

	self computeHighlightColors.
	isBoolean
		ifTrue: [self drawBooleanOn: aCanvas]
		ifFalse: [self drawNumericOn: aCanvas].
! !


!ReporterBlockMorph methodsFor: 'watcher' stamp: 'EMP 10/3/2015 16:55'!
createWatcher
	"Return a new watcher for me."

	| newWatcher |
	newWatcher _ WatcherMorph new setCategoryColor: self color.
	self argumentCount = 1
		ifTrue: [newWatcher target: receiver selector: selector parameter: self args first]
		ifFalse: [newWatcher target: receiver selector: selector parameter: nil].

	^ newWatcher
! !

!ReporterBlockMorph methodsFor: 'watcher' stamp: 'jm 12/1/2007 20:49'!
getAssociatedSprite
	"Return my receiver."

	^ receiver
! !

!ReporterBlockMorph methodsFor: 'watcher' stamp: 'jm 12/1/2007 20:58'!
toggleWatcher
	"Toggle between hiding and showing a watcher for this block."

	| frame w palette |
	(frame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	(w _ frame watcherForBlock: self)
		ifNil: [frame showWatcher: self createWatcher]
		ifNotNil: [w delete].
			
	palette _ self ownerThatIsA: ScratchBlockPaletteMorph.
	palette ifNotNil: [palette updateWatcherButtonsForFrame: frame].
! !


!ReporterBlockMorph methodsFor: 'object i/o' stamp: 'jm 5/15/2005 10:27'!
fieldsVersion

	^ 2
! !

!ReporterBlockMorph methodsFor: 'object i/o' stamp: 'jm 5/15/2005 10:27'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	classVersion = 1 ifTrue: [^ self].

	"fields added in version 2"
	self initFieldsNamed: #(
		isBoolean
	) from: anObjStream.

! !

!ReporterBlockMorph methodsFor: 'object i/o' stamp: 'EMP 1/12/2016 15:26'!
showValue

	| gotError msg tooltip w worldBounds tmp |
	gotError _ false.
	(self isSpecialForm) ifTrue: [self start.
	tmp _ scratchProc.
	[tmp isRunning] whileTrue: [World doOneCycleNow].
	msg _ tmp answer asString] ifFalse: [
	ScratchFrameMorph useErrorCatcher ifTrue: [
	[msg _ self evaluate asString] ifError: [
		gotError _ true.
		msg _ 'Error!!']] ifFalse: [msg _ self evaluate asString]].

	(self isBooleanReporter or: [msg = 'Error!!']) ifTrue: [
		msg _ msg localized].
	tooltip _ (ScratchReporterToolTipMorph string: msg for: self)
		left: self right;
		bottom: self top.
	ScratchTranslator isRTL ifTrue: [tooltip right: self left].
	gotError ifTrue: [tooltip messageColor: Color red darker].

	w _ self world.
	w addMorphFront: tooltip.
	((worldBounds _ w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].
	self setProperty: #toolTip toValue: tooltip.
	tooltip initialCursorPoint: Sensor cursorPoint.
	tooltip startStepping.! !

!ReporterBlockMorph methodsFor: 'object i/o' stamp: 'jm 5/11/2005 10:50'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		isBoolean
	) on: anObjStream.
! !


!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/28/2005 19:22'!
acceptsTypeOf: aBlockMorph
	"Answer true if I can accept a dropped reporter of the given type. Answer false by default."

	aBlockMorph isReporter ifFalse: [^ false].
	^ aBlockMorph isBooleanReporter = self isBooleanReporter
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/30/2005 09:21'!
computeHighlightColors

	| h s v |
	h _ color hue.
	s _ color saturation.
	v _ color brightness.
	highlightColor1 _ Color h: h s: (s - 0.13) v: (v + 0.17).
	highlightColor2 _ Color h: h s: s v: (v + 0.06).
	shadowColor _ color mixed: 0.8 with: Color black.
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'ee 3/8/2008 17:08'!
fixBlockLayout
	"Update the positions of my submorphs."

	| mList maxH h x y |
	blockLayoutNeeded ifFalse: [^ self].
	cachedForm _ nil.
	cachedFeedbackForm _ nil.

	mList _ self nonControlFlowSubmorphs.
	maxH _ 0.
	mList do: [:m |
		(m isKindOf: ArgMorph) ifTrue: [m fixArgLayout].
		(m isKindOf: BlockMorph) ifTrue: [m fixBlockLayout].
		maxH _ maxH max: m height].
	h _ (maxH + 4) max: 17.

	x _ isBoolean ifTrue: [8] ifFalse: [4].
	(mList size > 0 and: [mList first isKindOf: StringMorph]) ifTrue: [x _ x + 2].

	mList do: [:m |
		(m isKindOf: StringMorph) ifTrue: [m color: self labelColor].
		y _ (h - m height) // 2.
		m position: self position + (x@y).
		x _ x + m width + 3].
	x _ x + (isBoolean ifTrue: [1] ifFalse: [-3]).

	self extent: (x + 4) @ h.
	(self ownerThatIsA: ScratchBlockPaletteMorph) ifNotNil: [
		(self ownerThatIsA: ScratchBlockPaletteMorph) fixLayout].
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/28/2005 12:59'!
isBoolean: aBoolean

	isBoolean _ aBoolean.
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/28/2005 19:14'!
isBooleanReporter

	^ isBoolean
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/31/2005 19:38'!
isReporter
	"Answer true if this block reports a value."

	^ true
! !

!ReporterBlockMorph methodsFor: 'other' stamp: 'jm 3/20/2009 19:54'!
toggleProcess

	| toolTip |
	toolTip _ self valueOfProperty: #toolTip.
	toolTip ifNotNil: [
		toolTip delete.
		self setProperty: #toolTip toValue: nil.
		^ self].

	self showValue.
! !
