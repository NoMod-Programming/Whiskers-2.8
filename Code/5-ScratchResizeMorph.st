AlignmentMorph subclass: #ScratchResizeMorph
	instanceVariableNames: 'type '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchResizeMorph methodsFor: 'initialization' stamp: 'ee 5/14/2008 17:49'!
initialize

	super initialize.
	self
		color: Color transparent;
		orientation: #vertical;
		centering: #center;
		hResizing: #rigid;
		vResizing: #rigid;
		inset: 0;
		borderWidth: 0.
	self
		addMorph: ImageMorph new.
! !


!ScratchResizeMorph methodsFor: 'event handling' stamp: 'ee 5/14/2008 17:04'!
handlesMouseOver: evt

	^ true
! !

!ScratchResizeMorph methodsFor: 'event handling' stamp: 'ee 5/14/2008 17:31'!
mouseEnter: evt

	(type = #edge)
		ifTrue: [World activeHand showTemporaryCursor: Cursor resizeHorizontally]
		ifFalse: [World activeHand showTemporaryCursor: Cursor resizeCorner].
! !

!ScratchResizeMorph methodsFor: 'event handling' stamp: 'ee 5/14/2008 17:04'!
mouseLeave: evt

	World activeHand showTemporaryCursor: nil.
! !

!ScratchResizeMorph methodsFor: 'event handling' stamp: 'EMP 1/7/2016 14:45'!
type: aSymbol

	type _ aSymbol.
	(type = #edge) ifTrue: [
		self addMorphBack: (AlignmentMorph newSpacer: Color transparent).
		self addMorphFront: (AlignmentMorph newSpacer: Color transparent)] ifFalse: [self addMorphFront: (AlignmentMorph newSpacer: Color transparent)]
! !


!ScratchResizeMorph methodsFor: 'accessing' stamp: 'ee 5/14/2008 17:35'!
form: aForm

	(self submorphs at: 1) form: aForm.
	self extent: (self submorphs at: 1) extent.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchResizeMorph class
	instanceVariableNames: ''!

!ScratchResizeMorph class methodsFor: 'instance creation' stamp: 'ee 5/14/2008 17:48'!
ofType: aSymbol
	"#edge #corner"
	
	(aSymbol = #edge)
		ifTrue: [^ self new form: (ScratchFrameMorph skinAt: #resizeIconEdge); type: aSymbol]
		ifFalse: [^ self new form: (ScratchFrameMorph skinAt: #resizeIconCorner); type: aSymbol].
! !
