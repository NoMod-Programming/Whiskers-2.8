ScratchEvent subclass: #ScratchNamedEvent
	instanceVariableNames: 'name '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Events'!

!ScratchNamedEvent methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:58'!
extractTargetScriptsFrom: t1 
	^ t1 namedEventScriptsFor: name! !

!ScratchNamedEvent methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:58'!
name: t1 
	name := t1 asString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchNamedEvent class
	instanceVariableNames: ''!

!ScratchNamedEvent class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 16:43'!
for: string
	self new name: string! !
