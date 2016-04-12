ScratchToolTipMorph subclass: #ScratchReporterToolTipMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchReporterToolTipMorph methodsFor: 'accessing' stamp: 'EMP 10/11/2015 19:16'!
message: aString

	| verts |
	super message: aString.
	ScratchTranslator isRTL
		ifFalse: [verts _ (Array
			with: self bottomLeft + (2@6)
			with: self bottomLeft + (5@0)
			with: self bottomLeft + (10@0))]
		ifTrue: [verts _ (Array
			with: self bottomRight - (2@0) + (0@6)
			with: self bottomRight - (5@0)
			with: self bottomRight - (10@0))].
	self addMorph: (PolygonMorph
		vertices: verts
		color: (Color r: 0.9 g: 0.9 b: 0.9)
		borderWidth: 1
		borderColor: Color black).
! !

!ScratchReporterToolTipMorph methodsFor: 'accessing' stamp: 'jm 5/7/2009 11:40'!
messageFont

	^ ScratchFrameMorph getFont: #ReporterToolTip
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchReporterToolTipMorph class
	instanceVariableNames: ''!

!ScratchReporterToolTipMorph class methodsFor: 'instance creation' stamp: 'EMP 10/11/2015 19:13'!
string: str for: morph

	^ self new
		message: str;
		target: morph;
		color: (Color r: 0.9 g: 0.9 b: 0.9);
		useRoundedCorners;
		borderWidth: 1.
! !
