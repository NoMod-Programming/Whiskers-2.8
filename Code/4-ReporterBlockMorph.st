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


!ReporterBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/20/2016 14:35'!
drawBooleanOn: aCanvas 

	| right topY bottomY xInset c majorPointsLeft majorPointsRight |

	self computeHighlightColors.

	right _ self width.
	topY _ bottomY _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	xInset _ 0.
	[topY >= 0] whileTrue: [
		c _ color.
		self drawHLineFrom: xInset to: right - xInset y: topY color: c on: aCanvas.
		(topY > 1) & (xInset > 0) ifTrue: [
			self drawPoint: xInset@topY color: c on: aCanvas.
			self drawPoint: (right - xInset - 1)@topY color: c on: aCanvas].

		self drawHLineFrom: xInset to: right - xInset y: bottomY color: c on: aCanvas.
		xInset > 0 ifTrue: [
			self drawPoint: xInset@bottomY color: c on: aCanvas.
			self drawPoint: (right - xInset - 1)@bottomY color: c on: aCanvas].

		xInset _ xInset + 1.	
		bottomY _ bottomY + 1.
		topY _ topY - 1].
	
	"Now add the bevel; the steps are:
	1. draw the top and bottom lines with varying levels of shades, using a list of major points and going from there.
	2. draw the left side's bevels and fix the area where the two colors meet.
	3. draw the right side's bevels and fix the area where the two colors meet.

	"

	"----------------------------BEGIN STEP 1--------------------------------"
	majorPointsLeft _ {(((self height // 2)) @ (0)). ((self height // 2) @ ((self height))). (0 @ ((self height // 2)))}.
	majorPointsRight _ {(self width - ((self height // 2))) @ (0). ((self width - ((self height // 2))) @ (self height)). ((self width) @ ((self height // 2)))}.
	self drawHLineFrom: (majorPointsLeft first x) to: (majorPointsRight first x) y: 0 color: (Color white mixed: 0.3 with: color) on: aCanvas.
	self drawHLineFrom: (majorPointsLeft first x) to: (majorPointsRight first x) y: 1 color: (Color white mixed: 0.15 with: color) on: aCanvas.
	self drawHLineFrom: (majorPointsLeft first x) to: (majorPointsRight first x) y: 2 color: (Color white mixed: 0.07 with: color) on: aCanvas.
	self drawHLineFrom: (majorPointsLeft second x) to: (majorPointsRight second x) y: (self height) color: (Color black mixed: 0.3 with:  color) on: aCanvas.
	self drawHLineFrom: (majorPointsLeft second x) to: (majorPointsRight second x) y: (self height - 1) color: (Color black mixed: 0.15 with:  color) on: aCanvas.
	self drawHLineFrom: (majorPointsLeft second x) to: (majorPointsRight second x) y: (self height - 2) color: (Color black mixed: 0.07 with: color) on: aCanvas.
	"----------------------------END STEP 1----------------------------------"

	"----------------------------BEGIN STEP 2-------------------------------"
	aCanvas line: (majorPointsLeft first + (self topLeft)) to: (majorPointsLeft third + (self topLeft)) width: 1 color: (Color white mixed: 0.3 with: color).
	aCanvas line: (majorPointsLeft second + (self topLeft)) to: (majorPointsLeft third + (self topLeft)) width: 1 color: (Color white mixed: 0.20 with: color).
	aCanvas line: (majorPointsLeft first + (self topLeft + (0@1))) to: (majorPointsLeft third + (self topLeft + (1@0))) width: 1 color: (Color white mixed: 0.15 with: color).
	aCanvas line: (majorPointsLeft second + (self topLeft - (0@1))) to: (majorPointsLeft third + (self topLeft + (1@0))) width: 1 color: (Color white mixed: 0.10 with: color).
	aCanvas line: (majorPointsLeft first + (self topLeft + (0@2))) to: (majorPointsLeft third + (self topLeft + (2@0))) width: 1 color: (Color white mixed: 0.07 with: color).
	aCanvas line: (majorPointsLeft second + (self topLeft - (0@2))) to: (majorPointsLeft third + (self topLeft + (2@0))) width: 1 color: (Color white mixed: 0.05 with: color).
	self drawPoint: (majorPointsLeft second + (0@-1)) color: ((Color white mixed: 0.3 with: color) mixed: 0.5 with: (Color black mixed: 0.3 with: color)) on: aCanvas.
	self drawPoint: (majorPointsLeft second + (1@-2)) color: ((Color white mixed: 0.15 with: color) mixed: 0.5 with: (Color black mixed: 0.15 with: color)) on: aCanvas.
	self drawPoint: (majorPointsLeft second + (1@-1)) color: ((Color white mixed: 0.3 with: color) mixed: 0.4 with: (Color black mixed: 0.15 with: color)) on: aCanvas.
	self drawPoint: (majorPointsLeft second + (2@-2)) color: ((Color white mixed: 0.15 with: color) mixed: 0.4 with: (Color black mixed: 0.07 with: color)) on: aCanvas.
	"-------------------------END STEP 2-----------------------------------"

	"-------------------------BEGIN STEP 3---------------------------------"
		aCanvas line: (majorPointsRight second + (self topLeft - (1@0))) to: (majorPointsRight third + (self topLeft)) width: 1 color: (Color black mixed: 0.3 with: color).
		aCanvas line: (majorPointsRight first + (self topLeft)) to: (majorPointsRight third + (self topLeft)) width: 1 color: (Color black mixed: 0.15 with: color).
		aCanvas line: (majorPointsRight second + (self topLeft - (1@1))) to: (majorPointsRight third + (self topLeft - (1@0))) width: 1 color: (Color black mixed: 0.15 with: color).
		aCanvas line: (majorPointsRight first + (self topLeft + (0@1))) to: (majorPointsRight third + (self topLeft - (1@0))) width: 1 color: (Color black mixed: 0.07 with: color).
		aCanvas line: (majorPointsRight second + (self topLeft - (1@2))) to: (majorPointsRight third + (self topLeft - (2@0))) width: 1 color: (Color black mixed: 0.07 with: color).
		aCanvas line: (majorPointsRight first + (self topLeft + (-1@1))) to: (majorPointsRight third + (self topLeft - (2@0))) width: 1 color: (Color black mixed: 0.04 with: color).
	self drawPoint: (majorPointsLeft first - (2@-2)) color: ((Color white mixed: 0.15 with: color) mixed: 0.4 with: (Color black mixed: 0.04 with: color)) on: aCanvas.
	"---------------------------END STEP 3-----------------------------------"! !

!ReporterBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/19/2016 16:44'!
drawNumericOn: aCanvas 

	| right topY bottomY radius xInset c points |

	self computeHighlightColors.
	points _ OrderedCollection new.
	right _ self width.
	topY _ bottomY _ radius _ self height // 2.
	self height even ifTrue: [topY _ bottomY - 1].
	[topY >= 0] whileTrue: [
		xInset _ radius - (radius squared - (radius - topY - 1) squared) sqrt rounded.

		topY = 0 ifTrue: [c _ highlightColor1].
		topY = 1 ifTrue: [c _ highlightColor2].
		topY > 1 ifTrue: [c _ color].
		points add: (xInset @ topY).
		points add: (right - xInset @ topY).
		self drawHLineFrom: xInset to: right - xInset y: topY color: c on: aCanvas.
		(xInset > 0) & (topY > 1) ifTrue: [
			self drawPoint: xInset@topY color: highlightColor1 on: aCanvas.
			self drawPoint: (right - xInset - 1)@topY color: highlightColor1 on: aCanvas].

		c _ bottomY = (self height - 1) ifTrue: [shadowColor] ifFalse: [color].
		points add: (xInset @ bottomY).
		points add: (right - xInset @ bottomY).
		self drawHLineFrom: xInset to: right - xInset y: bottomY color: c on: aCanvas.
		xInset > 0 ifTrue: [
			self drawPoint: xInset@bottomY color: shadowColor on: aCanvas.
			self drawPoint: (right - xInset - 1)@bottomY color: shadowColor on: aCanvas].

		bottomY _ bottomY + 1.
		topY _ topY - 1].


		self drawHLineFrom: xInset to: right - xInset y: bottomY color: (Color black mixed: 0.3 with: color) on: aCanvas.
		self drawHLineFrom: xInset to: right - xInset y: (bottomY - 1) color: (Color black mixed: 0.15 with: color) on: aCanvas.
		self drawHLineFrom: xInset to: right - xInset y: (bottomY - 2) color: (Color black mixed: 0.07 with: color) on: aCanvas.

		self drawHLineFrom: xInset to: right- xInset y: topY color: (Color white mixed: 0.3 with: color) on: aCanvas.
		self drawHLineFrom: xInset to: right- xInset y: topY color: (Color white mixed: 0.15 with: color) on: aCanvas.
		self drawHLineFrom: xInset to: right- xInset y: topY color: (Color white mixed: 0.07 with: color) on: aCanvas.
		points do: [:point |
		(((point y > (((self height // 8) + 2))) and: [point x < (self width - xInset)]) and: [point y > 0]) ifTrue: [
		self drawPoint: point color: (Color white mixed: 0.3 with: color) on: aCanvas.
		self drawPoint: (point + (1@0)) color: (Color white mixed: 0.15 with: color) on: aCanvas.
		self drawPoint: (point+ (2@0)) color: (Color white mixed: 0.07 with: color) on: aCanvas].
		(point y > (self height - (self height // 8))) ifTrue: [
		self drawPoint: point color: (Color black mixed: 0.3 with: color) on: aCanvas.
		].


		(((point y > (((self height // 8) + 2))) and: [point x > (self width - xInset)]) and: [point y > 0]) ifTrue: [self drawPoint: point color: (Color black mixed: 0.3 with: color) on: aCanvas].

		(((point y < (((self height // 8) + 3))) and: [point x > (self width - xInset)]) and: [point y > 0]) ifTrue: [self drawPoint: point color: ((Color gray: (((self height // 8 + 3)) / (point y)) / 5) mixed: 0.3 with: color) on: aCanvas].
		].
		(self height -((self height // 8) rounded + 2)) to: (self height - ((self height // 8) - 1 rounded)) do: [:y |
			(points select: [:point |
				point y = y]) do: [:point |
					self drawPoint: point color: ((Color gray: (
				1 - ((y - (self height - ((self height // 8) rounded + 2)) + 1) / 4)
			)) mixed: 0.3 with: color) on: aCanvas
			]].
! !

!ReporterBlockMorph methodsFor: 'drawing' stamp: 'EMP 4/18/2016 13:08'!
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

!ReporterBlockMorph methodsFor: 'object i/o' stamp: 'EMP 4/26/2016 16:57'!
showValue

	| gotError msg tooltip w tmp |
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
	tooltip popUpForHand: (w activeHand).
	self setProperty: #toolTip toValue: tooltip.
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

!ReporterBlockMorph methodsFor: 'other' stamp: 'EMP 4/20/2016 14:36'!
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
	h _ (maxH + 4) max: 20.

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

!ReporterBlockMorph methodsFor: 'other' stamp: 'EMP 4/27/2016 12:08'!
toggleProcess
	
	| tooltip |
	(tooltip _ self valueOfProperty: #toolTip)
		ifNil: [self showValue]
		ifNotNil: [ 
			tooltip delete.
			self setProperty: #toolTip toValue: nil]
! !


!ReporterBlockMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/27/2016 14:59'!
evaluateIn: aStackFrame
	super evaluateIn: aStackFrame.
	^ false! !
