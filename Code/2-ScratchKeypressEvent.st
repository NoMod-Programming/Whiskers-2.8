ScratchEvent subclass: #ScratchKeypressEvent
	instanceVariableNames: 'key '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Events'!

!ScratchKeypressEvent methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:57'!
extractTargetScriptsFrom: t1 
	^ t1 keypressEventScriptsFor: key! !

!ScratchKeypressEvent methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:57'!
keyEvent: t1 
	key := t1! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchKeypressEvent class
	instanceVariableNames: ''!

!ScratchKeypressEvent class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:57'!
for: t1 
	^ self new keyEvent: t1! !
