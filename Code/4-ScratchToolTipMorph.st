RectangleMorph subclass: #ScratchToolTipMorph
	instanceVariableNames: 'target message initialCursorPoint '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 3/14/2009 10:11'!
initialCursorPoint: aPoint

	initialCursorPoint _ aPoint.
! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:20'!
message: t1 
	message := StringMorph contents: t1 font: self messageFont.
	self addMorph: message.
	self extent: message extent + (12 @ 3).
	message position: 6 @ 1! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:21'!
messageColor: t1 
	message color: t1! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:21'!
messageFont
	^ ScratchFrameMorph getFont: #ToolTip! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:21'!
popUpFor: t1 hand: t2 
	^ self popUpForHand: t2! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:24'!
popUpForHand: t1 
	| |
	self lock.
	t1 world addMorphFront: self.
	(World right < self right) ifTrue: [self right: (World right)].
	self initialCursorPoint: (Sensor cursorPoint)! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:25'!
setTarget: t1 
	target := t1.
	target
		ifNotNil: [self position: t1 bottomLeft + (0 @ 8)]! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'EMP 4/27/2016 09:25'!
setTarget: t1 above: t2 
	target := t1.
	target
		ifNotNil: [self
				position: (t2
						ifTrue: [t1 topLeft - (0 @ self height)]
						ifFalse: [t1 bottomLeft + (0 @ 8)])]! !

!ScratchToolTipMorph methodsFor: 'accessing' stamp: 'jm 12/15/2005 14:31'!
target: aMorph

	target _ aMorph.
! !


!ScratchToolTipMorph methodsFor: 'stepping' stamp: 'jm 5/5/2009 17:15'!
step

	initialCursorPoint ifNotNil: [
		(Sensor cursorPoint - initialCursorPoint) r > 80 ifTrue: [
			target ifNotNil: [target setProperty: #toolTip toValue: nil].
			self delete]].
! !

!ScratchToolTipMorph methodsFor: 'stepping' stamp: 'jm 3/14/2009 10:16'!
stepTime

	^ 200
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchToolTipMorph class
	instanceVariableNames: ''!

!ScratchToolTipMorph class methodsFor: 'instance creation' stamp: 'jm 12/15/2005 14:31'!
string: str for: morph

	^ self new
		message: str;
		target: morph;
		color: Color paleYellow;
		borderWidth: 1;
		borderColor: Color black
! !


!ScratchToolTipMorph class methodsFor: 'utilities' stamp: 'jm 8/22/2006 08:04'!
clearToolTips
	"Delete all tooltip morphs from the world."

	World ifNil: [^ self].
	World submorphsDo: [:m |
		(m isKindOf: ScratchToolTipMorph) ifTrue: [m delete]].
! !
