Object subclass: #ScratchEvent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Events'!
!ScratchEvent commentStamp: 'jm 3/22/2005 10:52' prior: 0!
I represent a Scratch event. I have a name and an optional argument
!


!ScratchEvent methodsFor: 'accessing' stamp: 'EMP 4/26/2016 15:55'!
broadcastOnServer: t1 
	^ self! !

!ScratchEvent methodsFor: 'accessing' stamp: 'EMP 4/26/2016 15:55'!
extractTargetScriptsFrom: t1 
	self halt! !

!ScratchEvent methodsFor: 'accessing' stamp: 'EMP 4/26/2016 15:55'!
turnsOffGpioServer
	^ false! !
