ScratchScriptsMorph subclass: #WorkspaceMorph
	instanceVariableNames: 'blocks '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
blocks
	^ blocks! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
blocks: t1 
	blocks _ t1! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
clearBackpack
	submorphs do: [:t1 | t1 delete]! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
fieldsVersion
	^ 1! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
initFieldsFrom: t1 version: t2 
	self initFieldsNamed: #(#submorphs #blocks ) from: t1! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
rightButtonMenu
	| t1 |
	t1 _ CustomMenu new.
	t1 add: 'clear backpack' action: #clearBackpack.
	t1 invokeOn: self! !

!WorkspaceMorph methodsFor: 'as yet unclassified' stamp: 'EMP 10/30/2015 12:12'!
storeFieldsOn: t1 
	self storeFieldsNamed: #(#submorphs #blocks ) on: t1.
	t1 putField: nil! !
