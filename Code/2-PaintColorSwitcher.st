Morph subclass: #PaintColorSwitcher
	instanceVariableNames: 'foreground background switcher transparentMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Paint'!

!PaintColorSwitcher methodsFor: 'initialization' stamp: 'EMP 12/18/2015 11:24'!
createForegroundBackground

	foreground _ BorderedMorph new
		width: 24;
		height: 24;
		borderColor: (Color r: 214/255 g: 214/255 b: 214/255);
		cornerStyle: #rounded;
		borderWidth: 2.
	background _ foreground fullCopy.

	self addMorphBack: foreground.
	self addMorphBack: background.

	foreground position: 8@7.
	background position: 18@17.

	self foreground: Color black.
	self background: Color white.! !

!PaintColorSwitcher methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:30'!
createSwitcher

	switcher _ IconicButton new.
	switcher
		labelGraphic: (ScratchFrameMorph skinAt: #paintColorSwitcher) borderWidth: 0;
		actionSelector: #switchColors;
		target: self;
		actWhen: #buttonDown.
! !

!PaintColorSwitcher methodsFor: 'initialization' stamp: 'EMP 12/22/2015 14:32'!
initialize

	super initialize.
	self color: (Color r: 246/255 g: 246/255 b: 246/255).
	transparentMorph _ ImageMorph new form: (ScratchFrameMorph skinAt: #transparentColorSwitchPanel).
	self createSwitcher.
	self extent: 42@42.
	self createForegroundBackground.
! !


!PaintColorSwitcher methodsFor: 'accessing' stamp: 'ee 11/11/2005 21:09'!
background

	^ background color
! !

!PaintColorSwitcher methodsFor: 'accessing' stamp: 'jm 10/6/2006 13:37'!
background: aColor

	| t |
	background color: aColor.
	background removeAllMorphs.
	aColor = Color transparent ifTrue: [
		t _ transparentMorph fullCopy.
		background addMorph:t.
		t position: (background position + (1@1))].
! !

!PaintColorSwitcher methodsFor: 'accessing' stamp: 'ee 11/11/2005 21:09'!
foreground

	^ foreground color
! !

!PaintColorSwitcher methodsFor: 'accessing' stamp: 'jm 10/6/2006 13:38'!
foreground: aColor

	| t |
	foreground color: aColor.
	foreground removeAllMorphs.
	aColor = Color transparent ifTrue: [
		t _ transparentMorph fullCopy.
		foreground addMorph: t.
		t position: (foreground position + (1@1))].

	self owner ifNotNil: [
		(self owner isKindOf: PaintPalette) ifTrue: [self owner updateOptionsPane]].
! !

!PaintColorSwitcher methodsFor: 'accessing' stamp: 'ee 1/1/2006 18:30'!
switchColors

	| storedColor |
	storedColor _ foreground color.
	self owner color1: background color.
	self owner color2: storedColor.
	self owner ifNotNil: [
		(self owner isKindOf: PaintPalette) ifTrue: [self owner updateOptionsPane]].
! !


!PaintColorSwitcher methodsFor: 'event handling' stamp: 'jm 11/20/2005 23:11'!
handlesMouseDown: evt

	^ true
! !

!PaintColorSwitcher methodsFor: 'event handling' stamp: 'jm 11/20/2005 23:11'!
mouseDown: evt

	self switchColors.
! !

!PaintColorSwitcher methodsFor: 'event handling' stamp: 'jm 8/22/2006 08:21'!
mouseLeave: evt

	ScratchToolTipMorph clearToolTips.
! !

!PaintColorSwitcher methodsFor: 'event handling' stamp: 'jm 4/17/2008 12:58'!
showBalloon: msg

	| w worldBounds tooltip |

	w _ self world.
	tooltip _ (ScratchToolTipMorph string: msg for: self).
	w addMorphFront: (tooltip position: self bottomLeft + (0@8)).
	((worldBounds _ w bounds) containsRect: tooltip bounds) ifFalse:
		[tooltip bounds: (tooltip bounds translatedToBeWithin: worldBounds)].! !
