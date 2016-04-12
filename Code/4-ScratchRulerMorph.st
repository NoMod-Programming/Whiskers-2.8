RectangleMorph subclass: #ScratchRulerMorph
	instanceVariableNames: 'max min marks graph sigDigs '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Sound'!

!ScratchRulerMorph methodsFor: 'initialize' stamp: 'LY 7/23/2003 10:30'!
initialize
	
	super initialize.
	min _ 0.0.
	max _ 100.
	marks _ 20.0.
	sigDigs _ 1. 
	graph _ nil. "used specifically to coord with ScratchGraphMorph"

	self borderWidth: 1.
	self extent: 200@20.
	self color: Color white.! !


!ScratchRulerMorph methodsFor: 'accessing' stamp: 'LY 7/23/2003 10:31'!
graph: aScratchGraphMorph

	graph _ aScratchGraphMorph.! !

!ScratchRulerMorph methodsFor: 'accessing' stamp: 'LY 7/23/2003 10:21'!
marks: aNumber
	marks _ aNumber.
	self changed.! !

!ScratchRulerMorph methodsFor: 'accessing' stamp: 'LY 7/23/2003 10:19'!
min: aMin max: aMax

	min _ aMin.
	max _ aMax.
	self changed.! !

!ScratchRulerMorph methodsFor: 'accessing' stamp: 'LY 7/23/2003 10:21'!
sigDigs: aNumber

	sigDigs _ aNumber truncated.
	self changed.! !


!ScratchRulerMorph methodsFor: 'drawing' stamp: 'EMP 10/11/2015 21:44'!
drawOn: aCanvas

	| space bigSpace currVal s ss |
	
	"the amt of space btw each bar.  big Space = the amt of space btw each big bar"
	space _ (self extent x/marks) truncated max: 1.
	bigSpace _ 5* space asFloat.

	graph ifNotNil: [ss _ (graph editor origSamplingRate) asNumberNoError]
		   ifNil: [ss _ 1].

	ss = 0 ifTrue: [ss _ 1].
	currVal _ (min/ss) asFloat roundTo: 0.01.  "the value of where we are in teh rule"

	"aCanvas fillRectangle: (Rectangle origin: (self left)@(self top) corner: (self right)@(self bottom)) color: Color lightGray."
	self removeAllMorphs.

	(self left) to: (self right) by: space do: 
		[:pos |
			(pos - (self left)) \\ bigSpace = 0
				ifTrue: [aCanvas line: (pos truncated)@((self top) truncated) to: (pos truncated)@((self top + 5) truncated) color: Color black.
				s _ StringMorph contents: (currVal asString).
				s center: (pos truncated)@(self top + 12).
				self addMorph: s.]
				ifFalse: [aCanvas line: (pos truncated)@(self top truncated) to: (pos truncated)@((self top + 1) truncated) color: Color black.]. 
			currVal _ currVal + ((max-min)/(marks*ss)) roundTo: 0.01. ].




! !


!ScratchRulerMorph methodsFor: 'stepping' stamp: 'LY 7/31/2003 11:48'!
step
	
	| graphStart graphEnd |
	graph ifNil: [^self].

	self extent x = graph extent x
		ifFalse: [self extent: (graph extent x)@(self extent y).].


	graphStart _ graph startIndex min: graph data size.
	graphEnd _ graphStart + (graph bounds width/graph scale) min: graph data size.
	
	(min = graphStart and:[ max = graphEnd])
		ifFalse: [ min _ graphStart.
				  max _ graphEnd truncated.
				  self changed.].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchRulerMorph class
	instanceVariableNames: ''!

!ScratchRulerMorph class methodsFor: 'instance creation' stamp: 'LY 7/23/2003 10:46'!
graphMorph: aScratchGraphMorph

	^ self new graph: aScratchGraphMorph; extent: (aScratchGraphMorph extent x)@20.

	! !
