TextAttribute subclass: #TextEmphasis
	instanceVariableNames: 'emphasisCode setMode '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Collections-Text'!
!TextEmphasis commentStamp: '<historical>' prior: 0!
A TextEmphasis, encodes a characteristic applicable to all fonts.  The encoding is as follows:
	1	bold
	2	itallic
	4	underlined
	8	narrow
	16	struck out!


!TextEmphasis methodsFor: 'as yet unclassified' stamp: 'di 10/31/97 11:15'!
= other 
	^ (other class == self class) 
		and: [other emphasisCode = emphasisCode]! !

!TextEmphasis methodsFor: 'as yet unclassified' stamp: 'di 10/31/97 13:11'!
dominatedByCmd0
	"Cmd-0 should turn off emphasis"
	^ true! !

!TextEmphasis methodsFor: 'as yet unclassified' stamp: 'di 10/31/97 13:13'!
dominates: other
	(emphasisCode = 0 and: [other dominatedByCmd0]) ifTrue: [^ true].
	^ (other class == self class)
		and: [emphasisCode = other emphasisCode]! !

!TextEmphasis methodsFor: 'as yet unclassified'!
emphasisCode
	^ emphasisCode! !

!TextEmphasis methodsFor: 'as yet unclassified'!
emphasisCode: int
	emphasisCode _ int.
	setMode _ true! !

!TextEmphasis methodsFor: 'as yet unclassified' stamp: 'di 10/29/97 11:57'!
emphasizeScanner: scanner
	"Set the emphasist for text scanning"
	scanner addEmphasis: emphasisCode! !

!TextEmphasis methodsFor: 'as yet unclassified'!
printOn: strm
	super printOn: strm.
	strm nextPutAll: ' code: '; print: emphasisCode! !

!TextEmphasis methodsFor: 'as yet unclassified'!
set
	^ setMode and: [emphasisCode ~= 0]! !

!TextEmphasis methodsFor: 'as yet unclassified'!
turnOff
	setMode _ false! !

!TextEmphasis methodsFor: 'as yet unclassified' stamp: 'tk 12/16/97 09:28'!
writeScanOn: strm

	emphasisCode = 1 ifTrue: [strm nextPut: $b].
	emphasisCode = 2 ifTrue: [strm nextPut: $i].
	emphasisCode = 0 ifTrue: [strm nextPut: $n].
	emphasisCode = 16 ifTrue: [strm nextPut: $=].
	emphasisCode = 4 ifTrue: [strm nextPut: $u].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

TextEmphasis class
	instanceVariableNames: ''!

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:18'!
bold
	^ self new emphasisCode: 1! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:18'!
italic
	^ self new emphasisCode: 2! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'di 10/31/97 13:05'!
narrow
	^ TextKern kern: -1! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:18'!
normal
	^ self new emphasisCode: 0! !

!TextEmphasis class methodsFor: 'as yet unclassified'!
struckOut
	^ self new emphasisCode: 16! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:18'!
struckThrough
	^ self new emphasisCode: 8! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:19'!
subscript
	^ self new emphasisCode: 32! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:19'!
superscript
	^ self new emphasisCode: 16! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:19'!
underlined
	^ self new emphasisCode: 4! !

!TextEmphasis class methodsFor: 'as yet unclassified' stamp: 'EMP 3/22/2016 10:19'!
withST80Glyphs
	^ self new emphasisCode: 64! !
