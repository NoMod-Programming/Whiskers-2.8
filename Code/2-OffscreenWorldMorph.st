Morph subclass: #OffscreenWorldMorph
	instanceVariableNames: 'damageRecorder frame '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!OffscreenWorldMorph commentStamp: '<historical>' prior: 0!
This morph is used to collect and redisplay damage when Scratch is in presentation mode.
!


!OffscreenWorldMorph methodsFor: 'initialization' stamp: 'EMP 11/18/2015 11:56'!
initialize

	super initialize.
	color _ Color black.
	damageRecorder _ DamageRecorder new.
	self changed.
! !

!OffscreenWorldMorph methodsFor: 'initialization' stamp: 'EMP 11/18/2015 12:05'!
on: aMorph

	aMorph position: 0@0.
	self bounds: (aMorph bounds).
	self addMorph: aMorph.
! !


!OffscreenWorldMorph methodsFor: 'accessing' stamp: 'jm 7/31/2008 14:40'!
frame

	^ frame
! !

!OffscreenWorldMorph methodsFor: 'accessing' stamp: 'jm 8/3/2008 12:41'!
frame: aScratchFrameMorph

	frame _ aScratchFrameMorph.
! !


!OffscreenWorldMorph methodsFor: 'change reporting' stamp: 'EMP 11/17/2015 19:34'!
invalidRect: damageRect

	damageRecorder recordInvalidRect: (damageRect intersect: bounds).
! !

!OffscreenWorldMorph methodsFor: 'change reporting' stamp: 'EMP 11/17/2015 19:34'!
redrawAll

	damageRecorder reset.
	submorphs do: [:m | m changed].
! !


!OffscreenWorldMorph methodsFor: 'drawing' stamp: 'EMP 11/18/2015 11:52'!
incrRedrawDouble: doubleFlag
	"Draw the damage areas on the display. Draw at double size if so indicated."

	| damageList m f c p screenR |
	damageRecorder updateIsNeeded ifFalse: [^ self].
	damageList _ damageRecorder invalidRectsFullBounds: bounds.
	damageRecorder reset.

	submorphs size = 0 ifTrue: [^ self].
	m _ submorphs first.

	damageList do: [:r |
		f _ Form extent: r extent depth: 32.
		c _ (FormCanvas on: f) copyOffset: r origin negated.
		m fullDrawOn: c.
		doubleFlag
			ifTrue: [
				p _ (m center - m extent) + (2 * (r origin - m topLeft)).
				screenR _ p extent: 2 * f extent.
				(Display boundingBox containsRect: screenR) ifTrue: [
					[
						ScratchPlugin
							primDouble: f bits w: f width h: f height
							into: Display bits w: Display width h: Display height
							x: screenR left y: screenR top.
					] ifError: [].
					Display forceToScreen: screenR]]
			ifFalse: [
				f displayOn: Display at: r topLeft rule: Form over]].
! !
