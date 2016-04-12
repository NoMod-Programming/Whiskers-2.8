ImageFrameMorph subclass: #DividedImageFrameMorph
	instanceVariableNames: 'topSectionHeight middleBarForm leftJointForm rightJointForm leftMargin rightMargin '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!DividedImageFrameMorph methodsFor: 'initialize' stamp: 'EMP 12/9/2015 11:56'!
initFromForm: aForm topSectionHeight: aNumber

	| w h |
	super initFromForm: aForm.

	topSectionHeight _ aNumber.
	leftMargin _ 0.
	rightMargin _ 0.
	middleBarForm _ ScratchFrameMorph skinAt: #dividedImageFrameBar.

	w _ (middleBarForm width // 2) + 2.
	h _ middleBarForm height.
	leftJointForm _ middleBarForm copy: (0@0 extent: w@h).
	rightJointForm _ middleBarForm copy: ((middleBarForm width - w) @ 0 extent: w@h).
! !

!DividedImageFrameMorph methodsFor: 'initialize' stamp: 'jm 12/9/2008 12:54'!
initFrontFromForm: aForm topSectionHeight: aNumber

	| w h |
	super initFrontFromForm: aForm.

	topSectionHeight _ aNumber.
	leftMargin _ 0.
	rightMargin _ 0.
	middleBarForm _ ScratchFrameMorph skinAt: #dividedImageFrameBar.

	w _ (middleBarForm width // 2) + 2.
	h _ middleBarForm height.
	leftJointForm _ middleBarForm copy: (0@0 extent: w@h).
	rightJointForm _ middleBarForm copy: ((middleBarForm width - w) @ 0 extent: w@h).
! !


!DividedImageFrameMorph methodsFor: 'accessing' stamp: 'ee 10/30/2008 13:37'!
middleBarLeftMargin: aNumber rightMargin: aNumber2

	leftMargin _ aNumber.
	rightMargin _ aNumber2.! !


!DividedImageFrameMorph methodsFor: 'drawing' stamp: 'ee 1/28/2009 16:11'!
drawDividerOn: aCanvas
	"Draw my divider edge."

	| w r f slice |
	w _ self width - (leftJointForm width + rightJointForm width) - leftMargin - rightMargin.
	r _ ((self left + leftJointForm width + leftMargin) @ (self top + topSectionHeight - 4))
		extent: (w @ middleBarForm height).

	f _ edgeCache at: 5.
	(f isNil or: [f extent ~= r extent]) ifTrue: [
		f _ Form extent: r extent depth: 32.
		slice _ middleBarForm copy: (((middleBarForm width // 2) @ 0) extent: (1 @ r height)).
		0 to: r width by: slice width do: [:x | slice displayOn: f at: x@0 rule: Form blend].
		edgeCache at: 5 put: f].

	aCanvas translucentImage: f at: r topLeft.
! !

!DividedImageFrameMorph methodsFor: 'drawing' stamp: 'EMP 12/9/2015 12:20'!
drawFrameOn: aCanvas

	super drawFrameOn: aCanvas.
	(self isKindOf: ScratchScriptEditorMorph) ifFalse: [self drawDividerOn: aCanvas.

	"draw middle bar left and right joints"
	aCanvas
		translucentImage: leftJointForm
		at: self topLeft + (leftMargin@(topSectionHeight-4)).
	aCanvas
		translucentImage: rightJointForm
		at: (self right - rightJointForm width - rightMargin) @ (self top + topSectionHeight - 4)]
! !
