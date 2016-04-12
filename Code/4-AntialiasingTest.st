EllipseMorph subclass: #AntialiasingTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Basic'!

!AntialiasingTest methodsFor: 'drawing' stamp: 'EMP 1/7/2016 19:44'!
drawOn: aCanvas 

	aCanvas fillAntialiasedOval: bounds color: color borderWidth: borderWidth borderColor: borderColor.
	! !

!AntialiasingTest methodsFor: 'drawing' stamp: 'EMP 1/7/2016 19:43'!
drawPoint: aPoint color: c on: aCanvas

	aCanvas fillRectangle: (self topLeft + aPoint extent: 1) color: c.
! !
