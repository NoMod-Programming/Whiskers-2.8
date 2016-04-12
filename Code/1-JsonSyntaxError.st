Object subclass: #JsonSyntaxError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'JSON'!
!JsonSyntaxError commentStamp: '<historical>' prior: 0!
Class Json signals instances of me when an input stream contains invalid JSON input.!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

JsonSyntaxError class
	instanceVariableNames: ''!

!JsonSyntaxError class methodsFor: 'as yet unclassified' stamp: 'EMP 12/3/2015 15:19'!
signal: aMessage
	^ (self confirm: (aMessage, '. Continue?')) ifFalse: [^ self error: aMessage]! !
