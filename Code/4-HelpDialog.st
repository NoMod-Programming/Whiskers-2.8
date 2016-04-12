DialogBoxMorph subclass: #HelpDialog
	instanceVariableNames: 'imageMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!HelpDialog commentStamp: 'jm 5/14/2005 16:44' prior: 0!
Shows a help Form in a dialog box with an ok button.
!


!HelpDialog methodsFor: 'initialization' stamp: 'ee 6/26/2008 17:13'!
initialize

	super initialize.

	"position morphs"
	imageMorph _ ImageMorph new form: (Form extent: 32@32 depth: 1).
	imageMorph position: 36@55.

	mainColumn addMorph: imageMorph.
! !


!HelpDialog methodsFor: 'other' stamp: 'jm 11/28/2007 19:30'!
helpForm: anImage

	| f |
	f _ anImage.
	(f isKindOf: ColorForm) ifTrue: [
		f _ f copy.
		f colors: (f colors collect: [:c | c isTransparent ifTrue: [Color black] ifFalse: [c]])].

	imageMorph form: f.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

HelpDialog class
	instanceVariableNames: ''!

!HelpDialog class methodsFor: 'instance creation' stamp: 'EMP 11/9/2015 12:08'!
showForm: aForm
	"HelpDialogMorph showForm: (Form fromFileNamed: 'move.gif')"

	| dialog |
	aForm ifNil: [^ self].
	self allInstancesDo: [:t1 | t1 delete].
	dialog _ super new
		withButtonsForYes: false no: false okay: true cancel: false;
		title: 'help';
		helpForm: aForm;
		extent: (aForm extent + (80@145)).
	^ dialog getUserResponse
! !
