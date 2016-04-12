Morph subclass: #MenuLineMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Menus'!

!MenuLineMorph methodsFor: 'drawing' stamp: 'EMP 12/3/2015 14:43'!
drawOn: aCanvas
	aCanvas
		fillRectangle: (bounds topLeft corner: bounds rightCenter)
		color: ((Preferences menuColorFromWorld)
					ifFalse:
						[owner color darker darker darker]
					ifTrue:
						[Preferences menuLineUpperColor]).! !


!MenuLineMorph methodsFor: 'initialization' stamp: 'ee 8/18/2006 12:14'!
initialize

	super initialize.
	color _ Color gray.! !


!MenuLineMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
hResizing

	^ #spaceFill
! !

!MenuLineMorph methodsFor: 'layout' stamp: 'di 5/7/1998 01:21'!
isAlignmentMorph

	^ true
! !

!MenuLineMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
layoutInWidth: w height: h

	self extent: w@h.
! !

!MenuLineMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
minHeight

	^ 2
! !

!MenuLineMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
minWidth

	^ 10
! !

!MenuLineMorph methodsFor: 'layout' stamp: 'jm 11/4/97 07:46'!
vResizing

	^ #shrinkWrap
! !
