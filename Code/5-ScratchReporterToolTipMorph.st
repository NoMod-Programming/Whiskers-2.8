ScratchToolTipMorph subclass: #ScratchReporterToolTipMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchReporterToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/29/2016 14:14'!
message: aString

	| verts |
	super message: aString.
	ScratchTranslator isRTL
		ifFalse: [verts _ (Array
			with: self bottomLeft + (2@5)
			with: self bottomLeft + (5@-1)
			with: self bottomLeft + (15@-1))]
		ifTrue: [verts _ (Array
			with: self bottomRight - (2@-5)
			with: self bottomRight - (5@1)
			with: self bottomRight - (15@1))].
	self addMorphBack: (PolygonMorph
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

!ScratchReporterToolTipMorph class methodsFor: 'instance creation' stamp: 'EMP 4/29/2016 14:15'!
string: str for: morph

	^ self new
		message: ((str size > 0) ifTrue: [str] ifFalse: [' ', str, ' ']);
		target: morph;
		color: (Color r: 0.9 g: 0.9 b: 0.9);
		useRoundedCorners;
		borderWidth: 1.
! !
