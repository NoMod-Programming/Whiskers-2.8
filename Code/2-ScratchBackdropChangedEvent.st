ScratchEvent subclass: #ScratchBackdropChangedEvent
	instanceVariableNames: 'bgName '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Events'!

!ScratchBackdropChangedEvent methodsFor: 'broadcasting' stamp: 'EMP 4/26/2016 15:56'!
extractTargetScriptsFrom: t1 
	^ t1 backdropChangedScriptsFor: bgName! !


!ScratchBackdropChangedEvent methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:56'!
bgName: t1 
	bgName := t1! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchBackdropChangedEvent class
	instanceVariableNames: ''!

!ScratchBackdropChangedEvent class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:56'!
bgName: t1 
	^ self new bgName: t1! !

!ScratchBackdropChangedEvent class methodsFor: 'as yet unclassified' stamp: 'EMP 4/26/2016 15:56'!
for: t1 
	^ self new bgName: t1! !
