ImageMorph subclass: #BackpackItemMorph
	instanceVariableNames: 'type media name indexInLibrary '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Support'!

!BackpackItemMorph methodsFor: 'initialization' stamp: 'EMP 4/12/2016 07:45'!
indexInLibrary: aNumber
	indexInLibrary _ aNumber! !

!BackpackItemMorph methodsFor: 'initialization' stamp: 'EMP 4/12/2016 07:45'!
initialize
	super initialize.
	type _ #scripts.
	media _ #((#forward: 10) (#forward: 10)).
	name _ 'unnamed'.
	indexInLibrary _ 999 "The backpack will reorder this later"! !


!BackpackItemMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/12/2016 07:45'!
fieldsVersion
	^ 1! !

!BackpackItemMorph methodsFor: 'as yet unclassified' stamp: 'EMP 4/12/2016 07:47'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
	type
	media
	name
	indexInLibrary
	) from: anObjStream.
	classVersion = 1 ifTrue: [^ self].! !
