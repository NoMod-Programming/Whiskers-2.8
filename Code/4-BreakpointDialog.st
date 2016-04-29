DialogBoxMorph subclass: #BreakpointDialog
	instanceVariableNames: 'imageMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!

!BreakpointDialog methodsFor: 'initialization' stamp: 'EMP 4/16/2016 19:01'!
initialize

	super initialize.

	"position morphs"
	imageMorph _ ImageMorph new form: (Form extent: 32@32 depth: 1).
	imageMorph position: 36@55.

	mainColumn addMorph: imageMorph.
! !


!BreakpointDialog methodsFor: 'other' stamp: 'EMP 4/16/2016 19:01'!
helpForm: anImage

	| f |
	f _ anImage.
	(f isKindOf: ColorForm) ifTrue: [
		f _ f copy.
		f colors: (f colors collect: [:c | c isTransparent ifTrue: [Color black] ifFalse: [c]])].

	imageMorph form: f.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

BreakpointDialog class
	instanceVariableNames: ''!

!BreakpointDialog class methodsFor: 'instance creation' stamp: 'EMP 4/16/2016 19:02'!
showForm: aForm
	"HelpDialogMorph showForm: (Form fromFileNamed: 'move.gif')"

	| dialog |
	aForm ifNil: [^ self].
	dialog _ super new
		withButtonsForYes: true no: true okay: false cancel: false;
		title: 'Breakpoint; Continue?';
		helpForm: aForm;
		extent: (aForm extent + (80@145)).
	^ dialog getUserResponse
! !
