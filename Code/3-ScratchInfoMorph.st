BorderedMorph subclass: #ScratchInfoMorph
	instanceVariableNames: 'target readoutMorphs lockButton nameMorph deleteButton rotationButtons penReadout thumbnailMorph thumbnailMorphHolder showButton rotationMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!
!ScratchInfoMorph commentStamp: '<historical>' prior: 0!
This is a BorderedMorph subclass that is used to represent a Scratch 2.0-like info page. While this can be run for a ScratchStageMorph (The code worke perfectly with one), that is disabled because stagemorphs cannot do so in Scratch 2.0!


!ScratchInfoMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 15:12'!
target
	^ nameMorph target! !

!ScratchInfoMorph methodsFor: 'accessing' stamp: 'EMP 9/30/2015 16:24'!
target: aMorph
	| nameSel |
	target _ aMorph.
	thumbnailMorph target: aMorph; showDirection: false.
	nameMorph target: aMorph.
	self showOrHideReadouts.
	nameSel _ (target isKindOf: ScratchStageMorph)
		ifTrue: [nil]
		ifFalse: [#objName:].
	nameMorph
		target: aMorph;
		getSelector: #objName;
		putSelector: nameSel.! !


!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/29/2015 14:57'!
addDeleteButton
	"Add button to delete infoMorph."

	self deleteDeleteButton.

	deleteButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #deleteSprite)
		offForm: (ScratchFrameMorph skinAt: #deleteSprite)
		overForm: (ScratchFrameMorph skinAt: #deleteSprite).

	deleteButton
		target: self;
		actionSelector: #deleteSprite;
		setBalloonText: 'Close' localized;
		actWhen: #buttonUp;
		isMomentary: true.

	self addMorph: deleteButton.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 14:59'!
addLockButton
	"Add button to set sprite locked status."
	| button text |
	self deleteLockButton.

	button _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #watcherButton).

	button
		target: self;
		actionSelector: #toggleSpriteDraggable;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - button height) / 2)).
	text _ StringMorph new contents: ('draggable on website?   ' localized); font: (ScratchFrameMorph getFont: #XYReadoutBold).
	lockButton _ Morph new color: (Color transparent); addMorph: text; addMorph: (button position: text topRight).
	self addMorph: lockButton.
	self updateLockButton.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 10/3/2015 19:46'!
addReadouts
	"Add readouts for my target's position and direction."

	| x y label readout s |
	self deleteReadouts.
	readoutMorphs _ OrderedCollection new.

	x _ nameMorph left.
	y _ nameMorph bottom + 5.

	#(('x' xpos) ('y' ypos)('direction' heading)) do: [:spec |

		(ScratchTranslator isRTL and: [(spec at: 1) = 'x' or: [(spec at: 1) = 'y']])
			ifTrue: [s _ (':', spec first) asUTF8]
			ifFalse: [s _ (spec first localized, ScratchTranslator colonSuffix)].

		label _ StringMorph new
			contents: s;
			font: (ScratchFrameMorph getFont: #XYReadout);
			position: x@y.

		readout _ (UpdatingStringMorph on: target selector: spec second)
			font: (ScratchFrameMorph getFont: #XYReadoutBold);
			forceUnicodeRendering: true;
			color: (Color gray: 0.2);
			contents: '-000'; 
			growable: false;
			stepTime: 0;
			position: (label right + 4)@y.

		ScratchTranslator isRTL ifTrue:[
			readout rightJustify: true].

		self addMorph: label; addMorph: readout.
		readoutMorphs add: label; add: readout.

		readout startStepping.
		x _ readout right + 2].

	ScratchTranslator isRTL ifTrue: [
		readoutMorphs reversed do: [: m |
			readoutMorphs remove: m.
			readoutMorphs add: m]].

	penReadout _ Morph new extent: 15@5.
	penReadout position: (lockButton right + 4)@(nameMorph top + ((nameMorph height - penReadout height) / 2));
		color: Color transparent.
	self addMorph: penReadout.
	readoutMorphs add: penReadout.
	penReadout startStepping.

	readoutMorphs _ readoutMorphs asArray.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 15:39'!
addRotationButtons
	"Add buttons to set the rotation style."

	| specs x y style button |
	self deleteRotationButtons.
	(self target respondsTo: #rotationStyle:) ifFalse: [^ self].

	specs _ #(
		(Smooth		'can rotate')
		(Flip		'only face left-right')
		(None		'don''t rotate')).

	x _ self left + 13.
	y _ self top + 12.
	specs do: [:pair |
		style _ pair first.
		button _ ToggleButton
			onForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'On'))
			offForm: (ScratchFrameMorph skinAt: ('rotStyle', style))
			overForm: (ScratchFrameMorph skinAt: ('rotStyle', style, 'Over')).
		button
			target: self;
			arguments: (Array with: style);
			actionSelector: #setRotationStyle:;
			setBalloonText: pair second localized;
			actWhen: #buttonDown;
			position: x@y.
		self addMorph: button.
		rotationButtons _ rotationButtons copyWith: button.
		x _ x + button width + 10].

	self updateRotationButtonHighlight.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 16:21'!
addRotationMorph
	rotationMorph _ ScratchRotationSetterMorph new.
	rotationMorph target: (self target);
	form: (ScratchFrameMorph skinAt: #rotationSetterMorph).
	self addMorph: rotationMorph.! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 15:50'!
addShowButton
	"Add button to set sprite locked status."
	| button text |
	self deleteShowButton.

	button _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #watcherButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #watcherButton).

	button
		target: self;
		actionSelector: #toggleSpriteShowing;
		actWhen: #buttonUp;
		isMomentary: true;
		position: (nameMorph right + 4)@(nameMorph top + ((nameMorph height - button height) / 2)).
	text _ StringMorph new contents: ('showing?   ' localized); font: (ScratchFrameMorph getFont: #XYReadoutBold).
	showButton _ Morph new color: (Color transparent); addMorph: text; addMorph: (button position: text topRight).
	self addMorph: showButton.
	self updateShowButton.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:16'!
deleteDeleteButton
	"Delete my delete button."

	deleteButton ifNotNil: [
		deleteButton delete.
		deleteButton _ nil].
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:16'!
deleteLockButton
	"Delete my lock button."

	lockButton ifNotNil: [
		lockButton delete.
		lockButton _ nil].
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:16'!
deleteReadouts
	"Delete the position/rotation readouts."

	readoutMorphs do: [:m | m delete].
	readoutMorphs _ #().
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 16:13'!
deleteRotationButton
	"Delete my lock button."

	rotationMorph ifNotNil: [
		rotationMorph delete.
		rotationMorph _ nil].
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:16'!
deleteRotationButtons
	"Delete the rotation style buttons."

	rotationButtons do: [:m | m delete].
	rotationButtons _ #().
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 15:45'!
deleteShowButton
	"Delete my show button."

	showButton ifNotNil: [
		deleteButton delete.
		deleteButton _ nil].
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/28/2015 16:36'!
extent: anExtent
	super extent: anExtent.
	self fixLayout.! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 9/30/2015 16:14'!
showOrHideReadouts
	"If this is a sprite, show the position and direction readouts and the rotation style buttons. Otherwise, hide them."

	self deleteRotationButtons; deleteLockButton; deleteReadouts; deleteDeleteButton; deleteShowButton; deleteRotationButton.
	nameMorph
		font: nameMorph font;
		width: nameMorph height * 4;
		rightJustify: ScratchTranslator isRTL.

	(target isKindOf: ScratchSpriteMorph) ifTrue: [
		self addRotationButtons; addLockButton; addReadouts; addShowButton; addRotationMorph.
		World ifNotNil: [World startSteppingSubmorphsOf: self]].
	self addDeleteButton.
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 10/7/2015 14:24'!
updateLockButton
	lockButton ifNil: [^ self].
	self target draggable not
		ifTrue: [lockButton submorphs first off]
		ifFalse: [lockButton submorphs first on]! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 10/3/2015 19:39'!
updateRotationButtonHighlight
	"Highlight the appropriate rotation style button. Do nothing if my target is not a sprite."

	| style sym |
	(self target isKindOf: ScratchSpriteMorph) ifFalse: [^ self].

	style _ self target rotationStyle asSymbol.
	style = #normal ifTrue: [sym _ #Smooth].
	style = #leftRight ifTrue: [sym _ #Flip].
	style = #none ifTrue: [sym _ #None].

	rotationButtons do: [:m |
		sym = m arguments first ifTrue: [m on] ifFalse: [m off]].
! !

!ScratchInfoMorph methodsFor: 'private' stamp: 'EMP 10/7/2015 14:22'!
updateShowButton

	showButton ifNil: [^ self].
	self target isHidden
		ifTrue: [showButton submorphs first off]
		ifFalse: [showButton submorphs first on].
! !


!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 9/30/2015 15:14'!
addNameBox

	nameMorph _ UpdatingStringFieldMorph new
		font: (ScratchFrameMorph getFont: #UpdatingStringField);
		rightJustify: ScratchTranslator isRTL;
		acceptWhenFocusLost: true;
		position: self topLeft;
		useInfoFrame;
		textColor: Color black.

	self addMorphBack: nameMorph.
! !

!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 9/29/2015 14:53'!
deleteSprite
	^ (self ownerThatIsA: ScratchLibraryMorph) toggleInfo: (self target).! !

!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 9/30/2015 16:12'!
fixLayout

	| y x |
	"layout readout morphs vertically"
	deleteButton ifNotNil: [deleteButton left: (self left + 7); top: (self top + 3)].
	thumbnailMorphHolder top: (self top + 5); left: (deleteButton right + 5).
	nameMorph position: (thumbnailMorphHolder topRight + (10@10));
		extent: ((self width - (thumbnailMorphHolder width + deleteButton width + 40)) @ (nameMorph height)).
	y _ nameMorph bottom + 5.
	readoutMorphs do: [:m |
		m position: m left@y].
	readoutMorphs do: [:m |
		m startStepping].
	"layout readout and name morphs horizontally"
	x _ nameMorph left.
	readoutMorphs do: [:m |
		m position: x@m top.
		x _ m right + 5].
	readoutMorphs size > 0 ifTrue: [
	y _ readoutMorphs last bottom + 10.
	rotationMorph position: ((readoutMorphs last right + 10) @ (readoutMorphs last top))].
	x _ nameMorph left.
	rotationButtons do: [:button |
		button position: (x@y).
		x _ x + button width + 10].
	rotationButtons size > 0 ifTrue: [
	y _ rotationButtons last height + y + 10].
	
	"layout lock and pen morphs"
	lockButton ifNotNil: [
		lockButton position: (nameMorph left + 4)@y.
		y _ (lockButton submorphs first bottom) + 10.
		showButton position: (nameMorph left + 4)@y.
		penReadout position: (lockButton left + 4)@y].! !

!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 11/17/2015 18:23'!
initialize

	super initialize.
	self addNameBox.
	borderWidth _ 1.
	borderColor _ (Color r: 208/255 g: 209/255 b: 210/255).
	self color: "(Color r:230/255 g:232/255 b:232/255)" Color white.
	thumbnailMorph _ ScratchThumbnailMorph new.
	thumbnailMorphHolder _ Morph new
		extent: 102@102;
		position: (self topLeft + (20@20));
		color: Color transparent.
	self addMorph: thumbnailMorphHolder.
	thumbnailMorphHolder addMorph: (thumbnailMorph position: (thumbnailMorphHolder position + (1@1))).
	rotationButtons _ #().
	readoutMorphs _ #().
	self target: nil.
	self extent: 300@400! !

!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 10/3/2015 19:44'!
step
	self submorphs do: [:m | (m respondsTo: #step) ifTrue: [m step]].
	self updateRotationButtonHighlight! !

!ScratchInfoMorph methodsFor: 'initialization' stamp: 'EMP 9/30/2015 15:37'!
stepTime
	^ 50! !


!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 9/30/2015 15:18'!
animateRotationStyle

	| style thumbForm wasFlipped currentRotation pen center rotatedForm doFlip |
	style _ self target rotationStyle.

	thumbnailMorph updateThumbnail.
	thumbForm _ thumbnailMorph form deepCopy.
	currentRotation _ self target rotationDegrees rounded.
	wasFlipped _ ((currentRotation \\ 360) >= 90) & ((currentRotation \\ 360) <= 270).

	thumbnailMorph showDirection: false.

	pen _ (Pen newOnForm: thumbnailMorph form) color: Color white.
	center _ thumbnailMorph form center.
	currentRotation to: currentRotation + 360 by: 12 do: [:i |
		rotatedForm _ thumbForm.  "no rotation by default"
		style = #normal ifTrue: [rotatedForm _ thumbForm rotateBy: i].
		style = #leftRight ifTrue: [
			doFlip _ ((i \\ 360) >= 90) & ((i \\ 360) <= 270).
			wasFlipped ifTrue: [doFlip _ doFlip not].
			doFlip ifTrue: [rotatedForm _ thumbForm flipBy: #horizontal centerAt: 0@0]].

		thumbnailMorph form fill: thumbnailMorph form boundingBox fillColor: Color transparent.
		rotatedForm
			displayOn: thumbnailMorph form
			at: (thumbnailMorph extent - rotatedForm extent) // 2
			rule: Form paint.
		pen place: center.
		pen goto: center + (Point r: 22 degrees: i).
		thumbnailMorph changed.

		World displayWorldSafely.
		Delay waitMSecs: 20].

	thumbnailMorph showDirection: true.
	thumbnailMorph updateThumbnail.
! !

!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/16/2015 11:06'!
handlesMouseDown: evt
	^ true! !

!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 12/16/2015 11:06'!
mouseDown: evt
	evt hand newKeyboardFocus: nil.! !

!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 9/30/2015 15:18'!
setRotationStyle: aSymbol

	aSymbol == #Smooth ifTrue: [self target rotationStyle: #normal].
	aSymbol == #Flip ifTrue: [self target rotationStyle: #leftRight].
	aSymbol == #None ifTrue: [self target rotationStyle: #none].
	self updateRotationButtonHighlight.

	(self target respondsTo: #rotationDegrees:) ifFalse: [^ self].
	self animateRotationStyle.

! !

!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 9/30/2015 15:17'!
toggleSpriteDraggable
	"Add buttons to set the rotation style."

	target draggable: target draggable not.
	self updateLockButton.
! !

!ScratchInfoMorph methodsFor: 'as yet unclassified' stamp: 'EMP 9/30/2015 15:51'!
toggleSpriteShowing
	"Add buttons to set the rotation style."

	target toggleShowing.
	self updateShowButton.
! !
