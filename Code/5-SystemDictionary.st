IdentityDictionary subclass: #SystemDictionary
	instanceVariableNames: 'cachedClassNames '
	classVariableNames: 'LastImageName LastQuitLogPosition LowSpaceProcess LowSpaceSemaphore StartupStamp SystemChanges VersionString '
	poolDictionaries: ''
	category: 'System-Support'!
!SystemDictionary commentStamp: '<historical>' prior: 0!
I represent a special dictionary that supports protocol for asking questions about the structure of the system. Other than class names, I contain (print this)...
	Smalltalk keys select: [:k | ((Smalltalk at: k) isKindOf: Class) not]
			thenCollect: [:k | k -> (Smalltalk at: k) class]
!


!SystemDictionary methodsFor: 'dictionary access' stamp: 'di 12/6/1999 12:42'!
associationAtOrAbove: varName ifAbsent: absentBlock 
	"Compatibility with environment protocol."

	^ self associationAt: varName ifAbsent: absentBlock! !

!SystemDictionary methodsFor: 'dictionary access'!
at: aKey put: anObject 
	"Override from Dictionary to check Undeclared and fix up
	references to undeclared variables."
	| index element |
	(self includesKey: aKey) ifFalse: 
		[self declare: aKey from: Undeclared.
		self flushClassNameCache].
	super at: aKey put: anObject.
	^ anObject! !

!SystemDictionary methodsFor: 'dictionary access' stamp: 'di 12/21/1999 12:00'!
atOrAbove: key ifAbsent: absentBlock
	"Compatibility with environment protocol."

	^ self at: key ifAbsent: absentBlock! !

!SystemDictionary methodsFor: 'dictionary access' stamp: 'di 12/6/1999 13:43'!
atOrBelow: key ifAbsent: absentBlock
	"Compatibility with environment protocol."

	^ self at: key ifAbsent: absentBlock! !

!SystemDictionary methodsFor: 'dictionary access' stamp: 'di 12/21/1999 12:00'!
includesKeyOrAbove: key
	"Compatibility with environment protocol."

	self atOrAbove: key ifAbsent: [^ false].
	^ true! !

!SystemDictionary methodsFor: 'dictionary access' stamp: 'di 12/19/1999 21:17'!
scopeFor: varName from: lower envtAndPathIfFound: envtAndPathBlock
	"Null compatibility with partitioning into environments."

	(self includesKey: varName)
		ifTrue: [^ envtAndPathBlock value: self value: String new]
		ifFalse: [^ nil]! !


!SystemDictionary methodsFor: 'browsing' stamp: 'di 9/5/97 16:05'!
browseAllCallsOn: aLiteral 
	"Create and schedule a message browser on each method that refers to
	aLiteral. For example, Smalltalk browseAllCallsOn: #open:label:."
	(aLiteral isKindOf: LookupKey)
		ifTrue: [self browseMessageList: (self allCallsOn: aLiteral) asSortedCollection
					name: 'Users of ' , aLiteral key
					autoSelect: aLiteral key]
		ifFalse: [self browseMessageList: (self allCallsOn: aLiteral) asSortedCollection
					name: 'Senders of ' , aLiteral
					autoSelect: aLiteral keywords first]! !

!SystemDictionary methodsFor: 'browsing'!
browseAllImplementorsOf: selector
	"Create and schedule a message browser on each method that implements 
	the message whose selector is the argument, selector. For example, 
	Smalltalk browseAllImplementorsOf: #at:put:."

	^self browseMessageList: (self allImplementorsOf: selector) name: 'Implementors of ' , selector! !

!SystemDictionary methodsFor: 'browsing'!
browseAllImplementorsOfList: selectorList title: aTitle
	"Create and schedule a message browser on each method that implements the message whose selector is in the argument selectorList. For example,  Smalltalk browseAllImplementorsOf: #(at:put: size).
	1/16/96 sw: this variant adds the title argument.
	1/24/96 sw: use a SortedCollection
	2/1/96 sw: show normal cursor"

	| implementorLists flattenedList |

	implementorLists _ selectorList collect: [:each | self allImplementorsOf: each].
	flattenedList _ SortedCollection new.
	implementorLists do: [:each | flattenedList addAll: each].
	Cursor normal show.
	^ self browseMessageList: flattenedList name: aTitle! !

!SystemDictionary methodsFor: 'browsing'!
browseAllMethodsInCategory: category 
	^self browseMessageList: (self allMethodsInCategory: category)
		name: category! !

!SystemDictionary methodsFor: 'browsing' stamp: 'di 5/4/1999 13:52'!
browseAllObjectReferencesTo: anObject except: objectsToExclude ifNone: aBlock
	"Bring up a list inspector on the objects that point to anObject.
	If there are none, then evaluate aBlock on anObject.  "

	| aList shortName |
	aList _ Smalltalk pointersTo: anObject except: objectsToExclude.
	aList size > 0 ifFalse: [^ aBlock value: anObject].
	shortName _ (anObject name ifNil: [anObject printString]) contractTo: 20.
	OrderedCollectionInspector openOn: aList withEvalPane: false
		withLabel: 'Objects pointing to ', shortName.! !

!SystemDictionary methodsFor: 'browsing'!
browseAllSelect: aBlock
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result. For example, 
	Smalltalk browseAllSelect: [:method | method numLiterals > 10]."

	^self browseMessageList: (self allSelect: aBlock) name: 'selected messages'! !

!SystemDictionary methodsFor: 'browsing' stamp: 'sw 8/15/97 15:32'!
browseAllSelect: aBlock name: aName autoSelect: autoSelectString
	"Create and schedule a message browser on each method that, when used 
	as the block argument to aBlock gives a true result.   Do not return an #DoIt traces."

	"Smalltalk browseAllSelect: [:method | method numLiterals > 10] name: 'Methods with more than 10 literals' autoSelect: 'isDigit'"

	^ self browseMessageList: (self allSelectNoDoits: aBlock) name: aName autoSelect: autoSelectString! !

!SystemDictionary methodsFor: 'browsing'!
browseAllUnSentMessages
	"Create and schedule a message browser on each method whose message is 
	not sent in any method in the system."

	^self browseMessageList: self allUnSentMessages name: 'UnSent Messages'! !

!SystemDictionary methodsFor: 'browsing'!
browseAllUnimplementedCalls
	"Create and schedule a message browser on each method that includes a 
	message that is not implemented in any object in the system."

	^self browseMessageList: self allUnimplementedCalls name: 'Unimplemented calls'! !

!SystemDictionary methodsFor: 'browsing'!
browseMessageList: messageList name: label 
	"Create and schedule a MessageSet browser on messageList."
	^ self browseMessageList: messageList name: label autoSelect: nil! !

!SystemDictionary methodsFor: 'browsing' stamp: 'sw 9/21/1999 11:38'!
browseMessageList: messageList name: labelString autoSelect: autoSelectString
	| title aSize |
	"Create and schedule a MessageSet browser on the message list."

	messageList size = 0 ifTrue: 
		[^ (PopUpMenu labels: ' OK ')
				startUpWithCaption: 'There are no
' , labelString].

	title _ (aSize _ messageList size) > 1
		ifFalse:	[labelString]
		ifTrue:	[ labelString, ' [', aSize printString, ']'].

	MessageSet openMessageList: messageList name: title autoSelect: autoSelectString! !

!SystemDictionary methodsFor: 'browsing'!
browseMethodsWhoseNamesContain: aString
	"Launch a browser on all methods whose names contain the given string; case-insensitive.  This takes a long time right now.  1/16/96 sw"

	| aList |
	aList _ Symbol selectorsContaining: aString.
	aList size > 0 ifTrue: 
		[self browseAllImplementorsOfList: aList asSortedCollection title: 'Methods whose names contain ''', aString, '''']! !

!SystemDictionary methodsFor: 'browsing' stamp: 'di 11/23/1998 12:05'!
browseMethodsWithSourceString: aString
	"Smalltalk browseMethodsWithSourceString: 'SourceString' "
	"Launch a browser on all methods whose source code contains aString as a substring."

	| caseSensitive suffix |
	(caseSensitive _ Sensor shiftPressed)
		ifTrue: [suffix _ ' (case-sensitive)']
		ifFalse: [suffix _ ' (use shift for case-sensitive)'].
	^ self browseMessageList: (self allMethodsWithSourceString: aString
									matchCase: caseSensitive)
		name: 'Methods containing ' , aString printString , suffix autoSelect: aString! !

!SystemDictionary methodsFor: 'browsing' stamp: 'di 11/23/1998 12:05'!
browseMethodsWithString: aString
	"Launch a browser on all methods that contain string literals with aString as a substring. The search is case-insensitive, unless the shift key is pressed, in which case the search is case-sensitive."

	| caseSensitive suffix |
	(caseSensitive _ Sensor shiftPressed)
		ifTrue: [suffix _ ' (case-sensitive)']
		ifFalse: [suffix _ ' (use shift for case-sensitive)'].
	self browseAllSelect:
			[:method |
				method  hasLiteralSuchThat: [:lit |
					lit class == String and:
					[lit includesSubstring: aString caseSensitive: caseSensitive]]]
		name:  'Methods with string ', aString printString, suffix
		autoSelect: aString.
! !

!SystemDictionary methodsFor: 'browsing' stamp: 'tk 6/24/1999 11:28'!
browseObsoleteReferences   "Smalltalk browseObsoleteReferences"
	| references |
	references _ OrderedCollection new.
	(Association allSubInstances select:
		[:x | ((x value isKindOf: Behavior) and: ['AnOb*' match: x value name]) or:
		['AnOb*' match: x value class name]]) 
		do: [:x | references addAll: (Smalltalk allCallsOn: x)].
	Smalltalk browseMessageList: references name: 'References to Obsolete Classes'! !

!SystemDictionary methodsFor: 'browsing' stamp: 'di 4/15/98 09:41'!
showMenuOf: selectorCollection withFirstItem: firstItem ifChosenDo: choiceBlock
	"Show a sorted menu of the given selectors, preceded by firstItem, and all
	abbreviated to 40 characters.  Evaluate choiceBlock if a message is chosen."
	| index menuLabels sortedList |
	sortedList _ selectorCollection asSortedCollection.
	menuLabels _ String streamContents: 
		[:strm | strm nextPutAll: (firstItem contractTo: 40).
		sortedList do: [:sel | strm cr; nextPutAll: (sel contractTo: 40)]].
	index _ (PopUpMenu labels: menuLabels lines: #(1)) startUp.
	index = 1 ifTrue: [choiceBlock value: firstItem].
	index > 1 ifTrue: [choiceBlock value: (sortedList at: index-1)]! !


!SystemDictionary methodsFor: 'retrieving' stamp: 'jm 5/18/2003 15:03'!
allBehaviorsDo: aBlock 
	"Evaluate the argument, aBlock, for each kind of Behavior in the system (that is, Object and its subclasses)."
	"ar 7/15/1999: The code below will not enumerate any obsolete or anonymous behaviors for which the following can be executed:
		Smalltalk allObjectsDo: [:obj | obj isBehavior ifTrue: [aBlock value: obj]].
	but what follows is way faster than enumerating all objects."

	aBlock value: Object.
	Object allSubclassesDo: aBlock.

	"Classes outside the Object hierarchy"
	Class subclassesDo: [:aClass |
		false & aClass isMeta ifTrue: [
			"Enumerate the non-meta class and its subclasses"
			aBlock value: aClass soleInstance.
			aClass soleInstance allSubclassesDo: aBlock]].
! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'ls 10/10/1999 13:22'!
allCallsOn: aLiteral   "Smalltalk browseAllCallsOn: #open:label:."
	"Answer a Collection of all the methods that call on aLiteral."
	| aCollection special thorough aList byte |

	#(23 48 'fred' (new open:label:)) size.
		"Example above should find #open:label:, though it is deeply embedded
here."
	aCollection _ OrderedCollection new.
	special _ self hasSpecialSelector: aLiteral ifTrueSetByte: [:b | byte _
b ].
	thorough _ (aLiteral isMemberOf: Symbol)
				and: ["Possibly search for symbols imbedded in literal arrays"
					Preferences thoroughSenders].
	Cursor wait showWhile: 
		[self allBehaviorsDo: 
			[:class |
				aList _ thorough
					ifTrue:
			 			[(class thoroughWhichSelectorsReferTo: aLiteral special: special
byte: byte)]
					ifFalse:
						[class whichSelectorsReferTo: aLiteral special: special byte:
byte].
				aList do: 
					[:sel | sel ~~ #DoIt
						ifTrue: [aCollection add: class name , ' ' , sel]]]].
	^ aCollection! !

!SystemDictionary methodsFor: 'retrieving'!
allClassesDo: aBlock
	"Evaluate the argument, aBlock, for each class in the system."

	(self classNames collect: [:name | Smalltalk at: name]) do: aBlock! !

!SystemDictionary methodsFor: 'retrieving'!
allClassesImplementing: aSelector  
	"Answer an Array of all classes that implement the message aSelector."

	| aCollection |
	aCollection _ ReadWriteStream on: Array new.
	self allBehaviorsDo:
		[:class | (class includesSelector: aSelector)
			ifTrue: [aCollection nextPut: class]].
	^ aCollection contents! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'bf 9/22/1999 16:56'!
allImplementedMessages
	"Answer a Set of all the messages that are sent by a method in the system 
	but are not implemented."

	| aSet |
	aSet _ IdentitySet new: Symbol instanceCount.
	Cursor wait showWhile: 
		[self allBehaviorsDo: [:cl | cl selectorsDo: [:aSelector | aSet add: aSelector]]].
	^aSet! !

!SystemDictionary methodsFor: 'retrieving'!
allImplementorsOf: aSelector  
	"Answer a SortedCollection of all the methods that implement the message 
	aSelector."

	| aCollection |
	aCollection _ SortedCollection new.
	Cursor wait showWhile:
		[self allBehaviorsDo:
			[:class |
			(class includesSelector: aSelector)
				ifTrue: [aCollection add: class name, ' ', aSelector]]].
	^aCollection! !

!SystemDictionary methodsFor: 'retrieving'!
allMethodsInCategory: category 
	| aCollection |
	aCollection _ SortedCollection new.
	Cursor wait showWhile:
		[self allBehaviorsDo:
			[:x | (x organization listAtCategoryNamed: category) do:
				[:sel | aCollection add: x name , ' ' , sel]]].
	^aCollection! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'di 11/23/1998 12:02'!
allMethodsWithSourceString: aString matchCase: caseSensitive
	"Answer a SortedCollection of all the methods that contain, in source code, aString as a substring.  The search is case-insensitive."
	| list classCount |
	list _ Set new.
'Searching all source code...'
displayProgressAt: Sensor cursorPoint
from: 0 to: Smalltalk classNames size
during:
	[:bar | classCount _ 0.
	Smalltalk allClassesDo:
		[:class | bar value: (classCount _ classCount + 1).
		(Array with: class with: class class) do:
			[:cl | cl selectorsDo:
				[:sel | 
				((cl sourceCodeAt: sel) findString: aString startingAt: 1 caseSensitive: caseSensitive) > 0
					ifTrue:
					[sel == #DoIt ifFalse: [list add: cl name , ' ' , sel]]]]]].
	^ list asSortedCollection! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'sw 8/12/97 20:57'!
allMethodsWithString: aString 
	"Answer a SortedCollection of all the methods that contain, in a string literal, aString as a substring.  2/1/96 sw.  The search is case-sensitive, and does not dive into complex literals, confining itself to string constants.
	5/2/96 sw: fixed so that duplicate occurrences of aString in the same method don't result in duplicated entries in the browser"

	| aStringSize list lits |

	aStringSize _ aString size.
	list _ Set new.

	Cursor wait showWhile: [self allBehaviorsDo: 
		[:class | class selectorsDo:
			[:sel | sel ~~ #DoIt ifTrue:
				[lits _ (class compiledMethodAt: sel) literals.
				lits do:
					[:aLiteral | ((aLiteral isMemberOf: String) and:
						[aLiteral size >= aStringSize])
							ifTrue:
								[(aLiteral findString: aString startingAt: 1)  > 0 ifTrue:
									[list add: class name , ' ' , sel]]]]]]].
	^ list asSortedCollection! !

!SystemDictionary methodsFor: 'retrieving'!
allObjectsDo: aBlock 
	"Evaluate the argument, aBlock, for each object in the system
	 excluding SmallIntegers."

	| object |
	object _ self someObject.
	[0 == object] whileFalse: [
		aBlock value: object.
		object _ object nextObject.
	].! !

!SystemDictionary methodsFor: 'retrieving'!
allPrimitiveMessages
	"Answer an OrderedCollection of all the methods that are implemented by 
	primitives."

	| aColl aSelector method | 
	aColl _ OrderedCollection new: 200.
	Cursor execute showWhile: 
		[self allBehaviorsDo: 
			[:class | class selectorsDo: 
				[:sel | 
				method _ class compiledMethodAt: sel.
				method primitive ~= 0
					ifTrue: [aColl addLast: class name , ' ' , sel 
									, ' ' , method primitive printString]]]].
	^aColl! !

!SystemDictionary methodsFor: 'retrieving'!
allSelect: aBlock 
	"Answer a SortedCollection of each method that, when used as the block 
	argument to aBlock, gives a true result."

	| aCollection |
	aCollection _ SortedCollection new.
	Cursor execute showWhile: 
		[self allBehaviorsDo: 
			[:class | class selectorsDo: 
				[:sel | (aBlock value: (class compiledMethodAt: sel))
					ifTrue: [aCollection add: class name , ' ' , sel]]]].
	^aCollection! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'sw 8/15/97 15:31'!
allSelectNoDoits: aBlock 
	"Like allSelect:, but strip out Doits"

	| aCollection |
	aCollection _ SortedCollection new.
	Cursor execute showWhile: 
		[self allBehaviorsDo: 
			[:class | class selectorsDo: 
				[:sel | ((sel ~~ #DoIt) and: [(aBlock value: (class compiledMethodAt: sel))])
					ifTrue: [aCollection add: class name , ' ' , sel]]]].
	^aCollection! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'bf 9/22/1999 16:39'!
allSentMessages
	"Answer the set of selectors which are sent somewhere in the system."
	| sent |
	sent _ IdentitySet new: CompiledMethod instanceCount.
	Cursor execute showWhile: 
		[self allBehaviorsDo: 
			[:cl | cl selectorsDo: 
				[:sel | "Include all sels, but not if sent by self"
			(cl compiledMethodAt: sel) literals do: 
				[:m | 
				(m isMemberOf: Symbol) ifTrue:  "might be sent"
					[m == sel ifFalse: [sent add: m]].
				(m isMemberOf: Array) ifTrue:  "might be performed"
					[m do: [:x | (x isMemberOf: Symbol) ifTrue:
						[x == sel ifFalse: [sent add: x]]]]]]].
		"The following may be sent without being in any literal frame"
		1 to: self specialSelectorSize do: 
			[:index | 
			sent add: (self specialSelectorAt: index)]].
	^ sent! !

!SystemDictionary methodsFor: 'retrieving'!
allUnSentMessages   "Smalltalk allUnSentMessages"
	"Answer the set of selectors that are implemented by some object
	in the system but not sent by any."
	| sent unsent |
	sent _ self allSentMessages.
	unsent _ Set new.
	self allImplementedMessages do:
		[:sel | (sent includes: sel) ifFalse: [unsent add: sel]].
	^ unsent
"
 | f cl lastClass |
f _ FileStream newFileNamed: 'UnsentMessages.txt'.
lastClass _ 'xx'.
methods _ SortedCollection new.
Smalltalk allUnSentMessages do:
	[:sel | methods addAll: (Smalltalk allImplementorsOf: sel)].
methods do:
	[:m | cl _ m copyUpTo: $ . 
	cl = lastClass
		ifTrue: [f nextPutAll: (m copyFrom: lastClass size+1 to: m size)]
		ifFalse: [f cr; cr; nextPutAll: m.  lastClass _ cl]].
f close.
"! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'di 12/15/1998 21:47'!
allUnSentMessagesIn: selectorSet
	"Answer the subset of selectorSet which are not sent anywhere in the system.
	Factored out from#allUnSentMessages "
	|  all |
	all _ selectorSet copy.
	Cursor execute showWhile: 
		[self allBehaviorsDo: 
			[:cl | cl selectorsDo: 
				[:sel | 
				(cl compiledMethodAt: sel) literals do: 
					[:lit |
					(lit isMemberOf: Symbol)  "might be sent"
						ifTrue: [all remove: lit ifAbsent: []].
					(lit isMemberOf: Array)  "might be performed"
						ifTrue: [lit do:
								[:elt |
								(elt isMemberOf: Array)
									ifTrue: [elt do: [:e | all remove: e ifAbsent: []]]
									ifFalse: [all remove: elt ifAbsent: []]]].
					]]].
		"The following may be sent without being in any literal frame"
		1 to: self specialSelectorSize do: 
			[:index | 
			all remove: (self specialSelectorAt: index) ifAbsent: []]].
	^ all! !

!SystemDictionary methodsFor: 'retrieving'!
allUnimplementedCalls 
	"Answer an Array of each message that is sent by an expression in a 
	method but is not implemented by any object in the system."

	| aStream secondStream all  |
	all _ self allImplementedMessages.
	aStream _ WriteStream on: (Array new: 50).
	Cursor execute showWhile:
		[self allBehaviorsDo:
			[:cl |
			 cl selectorsDo:
				[:sel |
				 secondStream _ WriteStream on: (String new: 5).
				(cl compiledMethodAt: sel) messages do:
					[:m | (all includes: m) ifFalse: [secondStream nextPutAll: m; space]].
				secondStream position = 0 ifFalse:
					[aStream nextPut: cl name , ' ' , sel , ' calls: ', secondStream contents]]]].
	^aStream contents! !

!SystemDictionary methodsFor: 'retrieving'!
pointersTo: anObject
	"Find all occurrences in the system of pointers to the argument anObject."
	"(Smalltalk pointersTo: Browser) inspect."

	^ self pointersTo: anObject except: #()
! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'jm 5/16/2003 10:01'!
pointersTo: anObject except: objectsToExclude
	"Find all occurrences in the system of pointers to the argument anObject. Remove objects in the exclusion list from the results."

	| results anObj |
	Smalltalk garbageCollect.
	"big collection shouldn't grow, so it's contents array is always the same"
	results _ OrderedCollection new: 1000.

	"allObjectsDo: is expanded inline to keep spurious
	 method and block contexts out of the results"
	anObj _ self someObject.
	[0 == anObj] whileFalse: [
		(anObj pointsTo: anObject) ifTrue: [
			"exclude the results collector and contexts in call chain"
			((anObj ~~ results collector) and:
			 [(anObj ~~ objectsToExclude) and:
			 [(anObj ~~ thisContext) and:
			 [(anObj ~~ thisContext sender) and:
			 [anObj ~~ thisContext sender sender]]]])
				 ifTrue: [results add: anObj]].
		anObj _ anObj nextObject].

	objectsToExclude do: [:obj | results removeAllSuchThat: [:el | el == obj]].
	^ results asArray
! !

!SystemDictionary methodsFor: 'retrieving'!
pointersToItem: index of: anArray
	"Find all occurrences in the system of pointers to the given element of the given array. This is useful for tracing up a pointer chain from an inspector on the results of a previous call of pointersTo:. To find out who points to the second element of the results, one would evaluate:

	Smalltalk pointersToItem: 2 of: self

in the inspector."

	^ self pointersTo: (anArray at: index) except: (Array with: anArray)! !

!SystemDictionary methodsFor: 'retrieving' stamp: 'jm 10/31/2002 10:43'!
unimplemented
	"Answer an Array of each message that is sent by an expression in a method but is not implemented by any object in the system."

	| all unimplemented entry |
	all _ IdentitySet new: Symbol instanceCount * 2.
	Cursor wait showWhile: 
		[self allBehaviorsDo: [:cl | cl selectorsDo: [:aSelector | all add: aSelector]]].

	unimplemented _ IdentityDictionary new.
	Cursor execute showWhile: [
		self allBehaviorsDo: [:cl |
			 cl selectorsDo: [:sel |
				(cl compiledMethodAt: sel) messages do: [:m |
					(all includes: m) ifFalse: [
						entry _ unimplemented at: m ifAbsent: [Array new].
						entry _ entry copyWith: (cl name, '>', sel).
						unimplemented at: m put: entry]]]]].

	"remove some clutter from the results:"
	#(DoItIn: primitiveFail uniformWindowColors macOptionKeyAllowed)
		do: [:sel | unimplemented removeKey: sel ifAbsent: []].

	^ unimplemented
! !


!SystemDictionary methodsFor: 'class names' stamp: 'di 3/26/2000 09:06'!
classNamed: className 
	"className is either a class name or a class name followed by ' class'.
	Answer the class or metaclass it names"

	| meta baseName baseClass |
	(className endsWith: ' class')
		ifTrue: [meta _ true.
				baseName _ className copyFrom: 1 to: className size - 6]
		ifFalse: [meta _ false.
				baseName _ className].
	baseClass _ Smalltalk at: baseName asSymbol ifAbsent: [^ nil].
	meta
		ifTrue: [^ baseClass class]
		ifFalse: [^ baseClass]! !

!SystemDictionary methodsFor: 'class names' stamp: 'jm 5/16/2003 09:58'!
classNames
	"Answer a SortedCollection of all class names."

	| names |
	cachedClassNames ifNil: [
		names _ OrderedCollection new: self size.
		self do: [:cl |
			((cl isKindOf: Class) and:
			 [(cl name beginsWith: 'AnObsolete') not])
				ifTrue: [names add: cl name]].
		cachedClassNames _ names asSortedCollection].
	^ cachedClassNames
! !

!SystemDictionary methodsFor: 'class names' stamp: 'di 2/16/2000 10:28'!
flushClassNameCache
	"Smalltalk flushClassNameCache"
	"Forse recomputation of the cached list of class names."

	cachedClassNames _ nil! !

!SystemDictionary methodsFor: 'class names' stamp: 'di 2/3/1999 22:21'!
removeClassFromSystem: aClass
	"Delete the class, aClass, from the system."

	aClass wantsChangeSetLogging ifTrue:
		[SystemChanges noteRemovalOf: aClass].
	aClass acceptsLoggingOfCompilation ifTrue:
		[Smalltalk logChange:  'Smalltalk removeClassNamed: #', aClass name].
	self removeClassFromSystemUnlogged: aClass
! !

!SystemDictionary methodsFor: 'class names' stamp: 'jm 1/1/2004 10:09'!
removeClassFromSystemUnlogged: aClass
	"Delete the class, aClass, from the system, but log the removal neither to the current change set nor to the changes log"

	SystemOrganization removeElement: aClass name.
	self removeKey: aClass name ifAbsent: [].
	self flushClassNameCache.
! !

!SystemDictionary methodsFor: 'class names' stamp: 'sw 9/5/97 18:30'!
removeClassNamed: aName
	"Invoked from fileouts:  if there is currently a class in the system named aName, then remove it.  If anything untoward happens, report it in the Transcript.  "

	| oldClass |
	(oldClass _ self at: aName asSymbol ifAbsent: [nil]) == nil
		ifTrue:
			[Transcript cr; show: 'Removal of class named ', aName, ' ignored because ', aName, ' does not exist.'.
			^ self].

	oldClass removeFromSystem! !

!SystemDictionary methodsFor: 'class names' stamp: 'jm 1/1/2004 10:56'!
renameClass: aClass as: newName 
	"Rename the class, aClass, to have the title newName."

	| oldref |
	SystemOrganization classify: newName under: aClass category.
	SystemOrganization removeElement: aClass name.
	SystemChanges renameClass: aClass as: newName.
	oldref _ self associationAt: aClass name.
	self removeKey: aClass name.
	oldref key: newName.
	self add: oldref.  "Old association preserves old refs"
	self flushClassNameCache.
! !

!SystemDictionary methodsFor: 'class names' stamp: 'sw 10/28/96'!
renameClassNamed: oldName as: newName
	"Invoked from fileouts:  if there is currently a class in the system named oldName, then rename it to newName.  If anything untoward happens, report it in the Transcript.  "

	| oldClass |
	(oldClass _ self at: oldName asSymbol ifAbsent: [nil]) == nil
		ifTrue:
			[Transcript cr; show: 'Class-rename for ', oldName, ' ignored because ', oldName, ' does not exist.'.
			^ self].

	oldClass rename: newName! !


!SystemDictionary methodsFor: 'shrinking' stamp: 'wod 11/3/1998 15:41'!
abandonSources    "Smalltalk abandonSources"
	"Replaces every method by a copy with the 4-byte source pointer 
	replaced by a string of all arg and temp names, followed by its length.
	These names can then be used to inform the decompiler.  See stats below"
	"wod 11/3/1998: zap the organization before rather than after condensing changes."
	 | oldCodeString argsAndTemps bTotal bCount oldMethods newMethods m |
	(self confirm:  '-- CAUTION --
If you have backed up your system and
are prepared to face the consequences of
abandoning source code files, hit Yes.
If you have any doubts, hit No,
to back out with no harm done.')
		==  true ifFalse: [^ self inform: 'Okay - no harm done'].
	Smalltalk forgetDoIts.
	oldMethods _ OrderedCollection new: CompiledMethod instanceCount.
	newMethods _ OrderedCollection new: CompiledMethod instanceCount.
	bTotal _ 0.  bCount _ 0.
	Smalltalk allBehaviorsDo: [: b | bTotal _ bTotal + 1].
'Saving temp names for better decompilation...'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: bTotal
	during: [:bar |
	Smalltalk allBehaviorsDo:    "for test:  (Array with: Arc with: Arc class) do: "
		[:cl |  bar value: (bCount _ bCount + 1).
		cl selectors do:
			[:selector |
			m _ cl compiledMethodAt: selector.
			m fileIndex > 0 ifTrue:
			[oldCodeString _ cl sourceCodeAt: selector.
			argsAndTemps _ (cl compilerClass new
				parse: oldCodeString in: cl notifying: nil)
				tempNames.
			oldMethods addLast: m.
			newMethods addLast: (m copyWithTempNames: argsAndTemps)]]]].
	oldMethods asArray elementsExchangeIdentityWith: newMethods asArray.
	Smalltalk allBehaviorsDo: [: b | b zapOrganization].
	Smalltalk condenseChanges.
	Preferences disable: #warnIfNoSourcesFile.
"
In a system with 7780 methods, we got 83k of temp names, or around 100k with spaces between.  The order of letter frequency was eatrnoislcmdgpSub, with about 60k falling in the first 11.  This suggests that we could encode in 4 bits, with 0-11 beng most common chars, and 12-15 contributing 2 bits to the next nibble for 6 bits, enough to cover all alphaNumeric with upper and lower case.  If we get 3/4 in 4 bits and 1/4 in 8, then we get 5 bits per char, or about 38% savings (=38k in this case).

Summary: about 13 bytes of temp names per method, or 8 with simple compression, plus 1 for the size.  This would be 5 bytes more than the current 4-byte trailer.
"! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 11/1/1998 08:31'!
abandonTempNames
	"Replaces every method by a copy with no source pointer or encoded temp names."
	"Smalltalk abandonTempNames"

	 | continue oldMethods newMethods n m |
	continue _ (self confirm:  '-- CAUTION --
If you have backed up your system and
are prepared to face the consequences of
abandoning all source code, hit Yes.
If you have any doubts, hit No,
to back out with no harm done.').
	continue ifFalse: [^ self inform: 'Okay - no harm done'].

	Smalltalk forgetDoIts; garbageCollect.
	oldMethods _ OrderedCollection new.
	newMethods _ OrderedCollection new.
	n _ 0.
	'Removing temp names to save space...'
		displayProgressAt: Sensor cursorPoint
		from: 0 to: CompiledMethod instanceCount
		during: [:bar |
			Smalltalk allBehaviorsDo: [:cl |
				cl selectors do: [:sel |
					bar value: (n _ n + 1).
					m _ cl compiledMethodAt: sel.
					oldMethods addLast: m.
					newMethods addLast: (m copyWithTrailerBytes: #(0))]]].
	oldMethods asArray elementsExchangeIdentityWith: newMethods asArray.
	Smalltalk closeSourceFiles.
	Preferences disable: #warnIfNoChangesFile.
	Preferences disable: #warnIfNoSourcesFile.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 5/16/1998 10:18'!
discardMIDI
	"Discard support the MIDI score player and the underlying MIDI support."

	Smalltalk removeClassNamed: #ScorePlayerMorph.
	SystemOrganization removeCategoriesMatching: 'Music-Scores'.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'TPR 8/3/2000 23:36'!
discardMVC
   "Smalltalk discardMVC"

	| keepers |
	Smalltalk isMorphic ifFalse:
		[PopUpMenu notify: 'You must be in a Morphic project to discard MVC.'.
		^ self].
	"Check that there are no MVC Projects"
	(Project allInstances inject: true into: [:ok :proj | ok & proj isMorphic]) ifFalse:
		[(self confirm: 'Would you like a chance to remove your
MVC projects in an orderly manner?')
					ifTrue: [^ self].
		(self confirm: 'If you wish, I can remove all MVC projects,
make this project be the top project, and place
all orphaned sub-projects of MVC parents here.
Would you like be to do this
and proceed to discard all MVC classes?')
					ifTrue: [self zapMVCprojects]
					ifFalse: [^ self]].
	Smalltalk reclaimDependents.

	"Remove old Paragraph classes and View classes."
	(ChangeSet superclassOrder: Paragraph withAllSubclasses asArray) reverseDo: 
		[:c | c removeFromSystem].
	(ChangeSet superclassOrder: View withAllSubclasses asArray) reverseDo: 
		[:c | c removeFromSystem].

	"Get rid of ParagraphEditor's ScrollController dependence"
	#(markerDelta viewDelta scrollAmount scrollBar computeMarkerRegion) do:
			[:sel | ParagraphEditor removeSelector: sel].
	ParagraphEditor compile: 'updateMarker'.
	ParagraphEditor superclass: MouseMenuController .

	"Get rid of all Controller classes not needed by ParagraphEditor and ScreenController"
	keepers _ TextMorphEditor withAllSuperclasses copyWith: ScreenController.
	(ChangeSet superclassOrder: Controller withAllSubclasses asArray) reverseDo: 
		[:c | (keepers includes: c) ifFalse: [c removeFromSystem]].

	SystemOrganization removeCategoriesMatching: 'ST80-Paths'.
	SystemOrganization removeCategoriesMatching: 'ST80-Pluggable Views'.

	Smalltalk removeClassNamed: 'FormButtonCache'.
	Smalltalk removeClassNamed: 'WindowingTransformation'.
	Smalltalk removeClassNamed: 'ControlManager'.
	Smalltalk removeClassNamed: 'DisplayTextView'.

	ScheduledControllers _ nil.
	Undeclared removeUnreferencedKeys.
	SystemOrganization removeEmptyCategories.
	Symbol rehash.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 7/3/2004 18:07'!
discardMorphic
   "Smalltalk discardMorphic"
	"Discard Morphic.
Updated for 2.8 TPR"

	| subs |
	"Check that we are in an MVC Project and that there are no Morphic Projects
		or WorldMorphViews."
	subs _ OrderedCollection new.
	Morph allSubclassesWithLevelDo: [:c :i | subs addFirst: c]
		startingLevel: 0.
	subs do: [:c | c removeFromSystem].
	Smalltalk removeClassNamed: #CornerRounder.
	Smalltalk removeKey: #BalloonEngineConstants ifAbsent: [].
	SystemOrganization removeCategoriesMatching: 'Balloon-*'.
	SystemOrganization removeCategoriesMatching: 'Morphic-*'.
	SystemOrganization removeSystemCategory: 'Graphics-Transformations'.
	SystemOrganization removeSystemCategory: 'ST80-Morphic'.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 12/15/2005 13:57'!
discardOddsAndEnds
	"This method throws out lots of classes that are not frequently used."
	"Smalltalk discardOddsAndEnds"

	SystemOrganization removeSystemCategory: 'System-Serial Port'.
	SystemOrganization removeSystemCategory: 'ST80-Symbols'.
	SystemOrganization removeSystemCategory: 'Tools-File Contents Browser'.
	SystemOrganization removeSystemCategory: 'System-Compression'.
	SystemOrganization removeSystemCategory: 'Tools-Explorer'.
	SystemOrganization removeSystemCategory: 'System-Digital Signatures'.

	Smalltalk at: #FormView ifPresent:
		[:c | c compile: 'defaultControllerClass  ^ NoController'
			classified: 'controller access'].
	Smalltalk removeClassNamed: #FormEditorView.
	Smalltalk removeClassNamed: #FormEditor.
	SystemOrganization removeSystemCategory: 'ST80-Paths'.

	"bit editor (remove Form editor first):"
	Form removeSelector: #bitEdit.
	Form removeSelector: #bitEditAt:scale:.
	StrikeFont removeSelector: #edit:.
	Smalltalk removeClassNamed: #FormButtonCache.
	Smalltalk removeClassNamed: #FormMenuController.
	Smalltalk removeClassNamed: #FormMenuView.
	Smalltalk removeClassNamed: #BitEditor.

	"inspector for Dictionaries of Forms"
	Dictionary removeSelector: #inspectFormsWithLabel:.
	SystemDictionary removeSelector: #viewImageImports.
	ScreenController removeSelector: #viewImageImports.
	Smalltalk removeClassNamed: #FormHolderView.
	Smalltalk removeClassNamed: #FormInspectView.

	"experimental hand-drawn character recoginizer:"
	ParagraphEditor removeSelector: #recognizeCharacters.
	ParagraphEditor removeSelector: #recognizer:.
	ParagraphEditor removeSelector: #recognizeCharactersWhileMouseIn:.
	Smalltalk removeClassNamed: #CharRecog.

	"experimental updating object viewer:"
	Object removeSelector: #evaluate:wheneverChangeIn:.
	Smalltalk removeClassNamed: #ObjectViewer.
	Smalltalk removeClassNamed: #ObjectTracer.

	"miscellaneous classes:"
	Smalltalk removeClassNamed: #Array2D.
	Smalltalk removeClassNamed: #DriveACar.
	Smalltalk removeClassNamed: #EventRecorder.
	Smalltalk removeClassNamed: #FindTheLight.
	Smalltalk removeClassNamed: #PluggableTest.
	Smalltalk removeClassNamed: #SystemMonitor.
	Smalltalk removeClassNamed: #DocLibrary.

	Smalltalk removeClassNamed: #ProtocolBrowser.
	Smalltalk removeClassNamed: #ObjectExplorerWrapper.
	Smalltalk removeClassNamed: #HierarchyBrowser.
	Smalltalk removeClassNamed: #LinkedMessageSet.
	Smalltalk removeClassNamed: #ObjectExplorer.
	Smalltalk removeClassNamed: #PackageBrowser.
	Smalltalk removeClassNamed: #AbstractHierarchicalList.
	Smalltalk removeClassNamed: #ChangeList.
	Smalltalk removeClassNamed: #VersionsBrowser.
	Smalltalk removeClassNamed: #ChangeRecord.
	Smalltalk removeClassNamed: #SelectorBrowser.
	Smalltalk removeClassNamed: #HtmlFileStream.
	Smalltalk removeClassNamed: #CrLfFileStream.
	Smalltalk removeClassNamed: #FXGrafPort.
	Smalltalk removeClassNamed: #FXBlt.

	Smalltalk at: #SampledSound ifPresent: [:c |c initialize].
	#(Helvetica Palatino Courier ComicBold ComicPlain) do:
		[:k | TextConstants removeKey: k ifAbsent: []].

Preferences setButtonFontTo:	(StrikeFont fontName: #NewYork size: 12).

#(GZipConstants ZipConstants KlattResonatorIndices ) do:
	[:k | Smalltalk removeKey: k ifAbsent: []].
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 12/1/2005 17:05'!
discardSoundSynthesis
	"Discard the sound synthesis facilities, and the methods and classes that use it. This also discards MIDI."

	Smalltalk discardMIDI.
	SystemOrganization removeCategoriesMatching: 'Sound-Interface'.
	Smalltalk at: #GraphMorph ifPresent: [:graphMorph |
		#(playOnce readDataFromFile)
			do: [:sel | graphMorph removeSelector: sel]].
	SystemOrganization removeCategoriesMatching: 'Sound-Synthesis'.
	SystemOrganization removeCategoriesMatching: 'Sound-Scores'.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'TPR 8/3/2000 19:21'!
discardSpeech
	"Discard support for speech synthesis"

	SystemOrganization removeCategoriesMatching: 'Speech*'.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 1/12/2000 13:05'!
lastRemoval  "Smalltalk lastRemoval" 
	#(abandonSources browseAllSelect: printSpaceAnalysis browseObsoleteReferences  lastRemoval) do:
		[:sel | SystemDictionary removeSelector: sel].
	[self removeAllUnSentMessages > 0] whileTrue.
	Set withAllSubclassesDo:
		[:cls | cls allInstances do: [:s | s rehash]].
	Smalltalk allClassesDo: [:c | c zapOrganization].
	Smalltalk changes initialize.! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'jm 12/1/2005 17:03'!
majorShrink    "Smalltalk majorShrink; abandonSources; lastRemoval"
	"This method throws out lots of the system that is not needed for, eg, operation in a hand-held PC.  majorShrink produces a 999k image in Squeak 2.8"

	Smalltalk isMorphic ifTrue: [^ self error: 'You can only run majorShrink in MVC'].
	Project current isTopProject ifFalse: [^ self error: 'You can only run majorShrink in the top project'].
	(Smalltalk confirm: 'All sub-projects will be deleted from this image.
You should already have made a backup copy,
or you must save with a different name after shrinking.
Shall we proceed to discard most of the content in this image?')
		ifFalse: [^ PopUpMenu notify: 'No changes have been made.'].

	"Remove all projects but the current one.  - saves 522k"
	ProjectView allInstancesDo: [:pv | pv controller closeAndUnscheduleNoTerminate].
	Project current setParent: Project current.
	MorphWorldView allInstancesDo: [:pv | pv topView controller closeAndUnscheduleNoTerminate].

	Smalltalk discardSoundSynthesis.  "544k"
	Smalltalk discardOddsAndEnds.  "227k"
	SystemOrganization removeCategoriesMatching: 'Network-*'.
	Smalltalk discardMorphic.  "1372k"
	Symbol rehash.  "40k"
	"Above by itself saves about 4,238k"

	"Remove references to a few classes to be deleted, so that they won't leave obsolete versions around."
	FileList removeSelector: #fileIntoNewChangeSet.
	ChangeSet class compile: 'defaultName
		^ ''Changes'' ' classified: 'initialization'.
	ScreenController removeSelector: #openChangeManager.
	ScreenController removeSelector: #exitProject.
	ScreenController removeSelector: #openProject.
	ScreenController removeSelector: #viewImageImports.

	"Now delete various other classes.."
	SystemOrganization removeSystemCategory: 'Graphics-Files'.
	SystemOrganization removeSystemCategory: 'System-Object Storage'.
	Smalltalk removeClassNamed: #ProjectController.
	Smalltalk removeClassNamed: #ProjectView.
	"Smalltalk removeClassNamed: #Project."
	Smalltalk removeClassNamed: #Environment.
	Smalltalk removeClassNamed: #Component1.

	Smalltalk removeClassNamed: #FormSetFont.
	Smalltalk removeClassNamed: #FontSet.
	Smalltalk removeClassNamed: #InstructionPrinter.
	Smalltalk removeClassNamed: #ChangeSorter.
	Smalltalk removeClassNamed: #DualChangeSorter.
	Smalltalk removeClassNamed: #EmphasizedMenu.
	Smalltalk removeClassNamed: #MessageTally.

	StringHolder class removeSelector: #originalWorkspaceContents.
	CompiledMethod removeSelector: #symbolic.

	RemoteString removeSelector: #makeNewTextAttVersion.
	Utilities class removeSelector: #absorbUpdatesFromServer.
	Smalltalk removeClassNamed: #PenPointRecorder.
	Smalltalk removeClassNamed: #Path.
	Smalltalk removeClassNamed: #Base64MimeConverter.
	Smalltalk removeClassNamed: #RWBinaryOrTextStream.
	Smalltalk removeClassNamed: #AttributedTextStream.
	Smalltalk removeClassNamed: #WordNet.
	Smalltalk removeClassNamed: #SelectorBrowser.

	TextStyle allSubInstancesDo:
		[:ts | ts newFontArray: (ts fontArray copyFrom: 1 to: (2 min: ts fontArray size))].
	ListParagraph initialize.
	PopUpMenu initialize.
	StandardSystemView initialize.

	Smalltalk noChanges.
	ChangeSorter classPool at: #AllChangeSets 
		put: (OrderedCollection with: Smalltalk changes).
	SystemDictionary removeSelector: #majorShrink.

	[Smalltalk removeAllUnSentMessages > 0]
		whileTrue:
		[Smalltalk unusedClasses do: [:c | (Smalltalk at: c) removeFromSystem]].
	SystemOrganization removeEmptyCategories.
	Smalltalk allClassesDo: [:c | c zapOrganization].
	MethodDictionary allInstances do: [:d | d rehash].
	Smalltalk changes initialize.
	Symbol rehash.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 6/20/1998 12:33'!
printSpaceAnalysis	"Smalltalk printSpaceAnalysis"

	^ Smalltalk printSpaceAnalysis: 0 on: 'STspace.text'
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 9/26/1999 11:32'!
printSpaceAnalysis: threshold on: fileName
	"Smalltalk printSpaceAnalysis: 1000 on: 'STspace.text0'"

	"If threshold > 0, then only those classes with more than that number
	of instances will be shown, and they will be sorted by total instance space.
	If threshold = 0, then all classes will appear, sorted by name."
	| f codeSpace instCount instSpace totalCodeSpace totalInstCount totalInstSpace eltSize n stats totalPercent percent |
	Smalltalk garbageCollect.
	totalCodeSpace _ totalInstCount _ totalInstSpace _ n _ 0.
	stats _ OrderedCollection new.
'Taking statistics...'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: self classNames size
	during: [:bar |
	self allClassesDo:
		[:cl | codeSpace _ cl spaceUsed.
		bar value: (n _ n+1).
		Smalltalk garbageCollectMost.
		instCount _ cl instanceCount.
		instSpace _ (cl indexIfCompact > 0 ifTrue: [4] ifFalse: [8])*instCount. "Object headers"
		cl isVariable
			ifTrue: [eltSize _ cl isBytes ifTrue: [1] ifFalse: [4].
					cl allInstancesDo: [:x | instSpace _ instSpace + (x basicSize*eltSize)]]
			ifFalse: [instSpace _ instSpace + (cl instSize*instCount*4)].
		stats add: (Array with: cl name with: codeSpace) , (Array with: instCount with: instSpace).
		totalCodeSpace _ totalCodeSpace + codeSpace.
		totalInstCount _ totalInstCount + instCount.
		totalInstSpace _ totalInstSpace + instSpace]].
	totalPercent _ 0.0.

	f _ FileStream newFileNamed: fileName.
	f timeStamp.
	f nextPutAll: ('Class' padded: #right to: 30 with: $ );
			nextPutAll: ('code space' padded: #left to: 12 with: $ );
			nextPutAll: ('# instances' padded: #left to: 12 with: $ );
			nextPutAll: ('inst space' padded: #left to: 12 with: $ );
			nextPutAll: ('percent' padded: #left to: 8 with: $ ); cr.

	threshold > 0 ifTrue:
		["If inst count threshold > 0, then sort by space"
		stats _ (stats select: [:s | s third >= threshold or: [s fourth > (totalInstSpace // 500)]])
				asSortedCollection: [:s :s2 | s fourth > s2 fourth]].

	stats do:
		[:s | f nextPutAll: (s first padded: #right to: 30 with: $ );
			nextPutAll: (s second printString padded: #left to: 12 with: $ );
			nextPutAll: (s third printString padded: #left to: 12 with: $ );
			nextPutAll: (s fourth printString padded: #left to: 14 with: $ ).
		percent _ s fourth*100.0/totalInstSpace roundTo: 0.1.
		totalPercent _ totalPercent + percent.
		percent >= 0.1 ifTrue:
			[f nextPutAll: (percent printString padded: #left to: 8 with: $ )].
		f cr].

	f cr; nextPutAll: ('Total' padded: #right to: 30 with: $ );
		nextPutAll: (totalCodeSpace printString padded: #left to: 12 with: $ );
		nextPutAll: (totalInstCount printString padded: #left to: 12 with: $ );
		nextPutAll: (totalInstSpace printString padded: #left to: 14 with: $ );
		nextPutAll: ((totalPercent roundTo: 0.1) printString padded: #left to: 8 with: $ ).
	f close! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 6/20/1998 12:37'!
printSpaceDifferenceFrom: fileName1 to: fileName2
	"For differential results, run printSpaceAnalysis twice with different fileNames,
	then run this method...
		Smalltalk printSpaceAnalysis: 0 on: 'STspace.text1'.
			--- do something that uses space here ---
		Smalltalk printSpaceAnalysis: 0 on: 'STspace.text2'.
		Smalltalk printSpaceDifferenceFrom: 'STspace.text1' to: 'STspace.text2'
"
	| f coll1 coll2 item |
	f _ FileStream oldFileNamed: fileName1.
	coll1 _ OrderedCollection new.
	[f atEnd] whileFalse: [coll1 add: (f upTo: Character cr)].
	f close.
	f _ FileStream oldFileNamed: fileName2.
	coll2 _ OrderedCollection new.
	[f atEnd] whileFalse:
		[item _ (f upTo: Character cr).
		((coll1 includes: item) and: [(item endsWith: 'percent') not])
			ifTrue: [coll1 remove: item]
			ifFalse: [coll2 add: item]].
	f close.
	(StringHolder new contents: (String streamContents: 
			[:s | 
			s nextPutAll: fileName1; cr.
			coll1 do: [:x | s nextPutAll: x; cr].
			s cr; cr.
			s nextPutAll: fileName2; cr.
			coll2 do: [:x | s nextPutAll: x; cr]]))
		openLabel: 'Differential Space Analysis'.
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 8/16/2000 14:20'!
removeAllUnSentMessages   "Smalltalk removeAllUnSentMessages"
	"[Smalltalk unusedClasses do: [:c | (Smalltalk at: c) removeFromSystem].
		Smalltalk removeAllUnSentMessages > 0] whileTrue." 

	"Remove all implementations of unsent messages."
	| sels n |
	sels _ self allUnSentMessages.

	"The following should be preserved for doIts, etc"
	#(browseAllSelect: printSpaceAnalysis lastRemoval
		scrollBarValue: scrollBarMenuButtonPressed: 
		withSelectionFrom:  to: removeClassNamed:
		dragon: hilberts: mandala: web test3 factorial tinyBenchmarks benchFib
		newDepth: restoreAfter: forgetDoIts zapAllMethods obsoleteClasses
		removeAllUnSentMessages abandonSources removeUnreferencedKeys
		reclaimDependents zapOrganization condenseChanges browseObsoleteReferences
		subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
		methodsFor:stamp: methodsFor:stamp:prior: instanceVariableNames:
		startTimerInterruptWatcher unusedClasses) do:
		[:sel | sels remove: sel ifAbsent: []].
	"The following may be sent by perform: in dispatchOnChar..."
	(ParagraphEditor classPool at: #CmdActions) asSet do:
		[:sel | sels remove: sel ifAbsent: []].
	(ParagraphEditor classPool at: #ShiftCmdActions) asSet do:
		[:sel | sels remove: sel ifAbsent: []].
	sels size = 0 ifTrue: [^ 0].

	n _ 0. Smalltalk allBehaviorsDo: [:x | n _ n+1].
	'Removing ', sels size printString , ' messages . . .'
		displayProgressAt: Sensor cursorPoint
		from: 0 to: n
		during:
		[:bar |
		n _ 0.
		self allBehaviorsDo:
			[:class | bar value: (n _ n+1).
			sels do:
				[:sel | class removeSelectorSimply: sel]]].
	^ sels size! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 4/20/1999 12:24'!
unusedClasses
	"Warning: Slow!! Enumerates all classes in the system and returns a list of those that are apparently unused. A class is considered in use if it (a) has subclasses (b) has instances or (c) is referred to by some method. Obsolete classes are not included in this list."
	"Smalltalk unusedClasses"

	| unused c n |
	unused _ SortedCollection new.

'Scanning for unused classes...'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: Metaclass instanceCount
	during: [:bar | n _ 0.

	Metaclass allInstancesDo: [:meta | bar value: (n _ n+1).
		c _ meta soleInstance.
		((c ~~ nil) and:
		 [('AnOb*' match: c name asString) not]) ifTrue: [
			((c subclasses size = 0) and:
			 [(c inheritsFrom: FileDirectory) not & (c instanceCount = 0) and:
			 [(Smalltalk includesKey: c name) and: [(Smalltalk allCallsOn: (Smalltalk associationAt: c name)) size = 0]]])
				ifTrue: [unused add: c name]]]].

	^ unused asArray
! !

!SystemDictionary methodsFor: 'shrinking' stamp: 'di 9/26/1999 21:44'!
zapMVCprojects   "Smalltalk zapMVCprojects"

	| window |
	Smalltalk garbageCollect.  "So allInstances is precise"
	Project allSubInstancesDo:
		[:proj |
		proj isTopProject
		ifTrue: [proj isMorphic ifFalse:
					["Root project is MVC -- we must become the root"
					Project current setParent: Project current]]
		ifFalse: [proj parent isMorphic
				ifFalse: [proj isMorphic ifTrue:
							["Remove Morphic projects from MVC views"
							"... and add them back here."
							window _ (SystemWindow labelled: proj name) model: proj.
							window addMorph: (ProjectViewMorph on: proj)
									frame: (0@0 corner: 1.0@1.0).
							window openInWorld.
							proj setParent: Project current]].
				proj isMorphic
					ifFalse: ["Remove MVC projects from Morphic views"
							Project allInstancesDo: [:p | p deletingProject: proj].
							ProjectViewMorph allInstancesDo: [:p | p deletingProject: proj]]]
		]! !


!SystemDictionary methodsFor: 'memory space'!
bytesLeft
	"Answer the number of bytes of space available. Does a full garbage collection."

	^ self garbageCollect
! !

!SystemDictionary methodsFor: 'memory space'!
createStackOverflow
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; createStackOverflow"

	self createStackOverflow.  "infinite recursion"! !

!SystemDictionary methodsFor: 'memory space'!
garbageCollect
	"Primitive. Reclaims all garbage and answers the number of bytes of available space."

	<primitive: 130>
	^ self primBytesLeft! !

!SystemDictionary methodsFor: 'memory space'!
garbageCollectMost
	"Primitive. Reclaims recently created garbage (which is usually most of it) fairly quickly and answers the number of bytes of available space."

	<primitive: 131>
	^ self primBytesLeft! !

!SystemDictionary methodsFor: 'memory space'!
installLowSpaceWatcher
	"Start a process to watch for low-space conditions."
	"Smalltalk installLowSpaceWatcher"

	self primSignalAtBytesLeft: 0.  "disable low-space interrupts"
	LowSpaceProcess == nil ifFalse: [LowSpaceProcess terminate].
	LowSpaceProcess _ [self lowSpaceWatcher] newProcess.
	LowSpaceProcess priority: Processor lowIOPriority.
	LowSpaceProcess resume.

! !

!SystemDictionary methodsFor: 'memory space' stamp: 'jm 10/14/2002 18:53'!
lowSpaceThreshold 
	"Return the low space threshold. When the amount of free memory (after garbage collection) falls below this limit, the system is in serious danger of completely exhausting memory and crashing. This limit should be made high enough to allow the user open a debugger to diagnose a problem or to save the image."

	^ 250000
! !

!SystemDictionary methodsFor: 'memory space' stamp: 'jm 10/4/2002 11:00'!
lowSpaceWatcher
	"Wait until the low space semaphore is signalled, then take appropriate actions."

	self garbageCollectMost <= self lowSpaceThreshold ifTrue: [
		self garbageCollect <= self lowSpaceThreshold ifTrue: [
			"free space must be above threshold before starting low space watcher"
			^ self beep]].

	LowSpaceSemaphore _ Semaphore new.
	self primLowSpaceSemaphore: LowSpaceSemaphore.
	self primSignalAtBytesLeft: self lowSpaceThreshold.  "enable low space interrupts"

	LowSpaceSemaphore wait.  "wait for a low space condition..."

	self primSignalAtBytesLeft: 0.  "disable low space interrupts"
	self primLowSpaceSemaphore: nil.
	LowSpaceProcess _ nil.
	"Note: user is now unprotected until the low space watcher is re-installed"

	Smalltalk isMorphic
		ifTrue: [Project current interruptName: 'Space is low']
		ifFalse: [ScheduledControllers interruptName: 'Space is low'].
! !

!SystemDictionary methodsFor: 'memory space'!
okayToProceedEvenIfSpaceIsLow
	"Return true if either there is enough memory to do so safely or if the user gives permission after being given fair warning."

	self garbageCollectMost > self lowSpaceThreshold ifTrue: [^ true].  "quick"
	self garbageCollect > self lowSpaceThreshold ifTrue: [^ true].  "work harder"

	^ self confirm:
'WARNING: There is not enough space to start the low space watcher.
If you proceed, you will not be warned again, and the system may
run out of memory and crash. If you do proceed, you can start the
low space notifier when more space becomes available simply by
opening and then closing a debugger (e.g., by hitting Cmd-period.)
Do you want to proceed?'
! !

!SystemDictionary methodsFor: 'memory space'!
primBytesLeft
	"Primitive. Answer the number of bytes available for new object data.
	Not accurate unless preceded by
		Smalltalk garbageCollectMost (for reasonable accuracy), or
		Smalltalk garbageCollect (for real accuracy).
	See Object documentation whatIsAPrimitive."

	<primitive: 112>
	^ 0! !

!SystemDictionary methodsFor: 'memory space'!
primLowSpaceSemaphore: aSemaphore
	"Primitive. Register the given Semaphore to be signalled when the
	number of free bytes drops below some threshold. Disable low-space
	interrupts if the argument is nil."

	<primitive: 124>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'memory space'!
primSignalAtBytesLeft: numBytes
	"Tell the interpreter the low-space threshold in bytes. When the free
	space falls below this threshold, the interpreter will signal the low-space
	semaphore, if one has been registered.  Disable low-space interrupts if the
	argument is zero.  Fail if numBytes is not an Integer."

	<primitive: 125>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'memory space'!
signalLowSpace
	"Signal the low-space semaphore to alert the user that space is running low."

	LowSpaceSemaphore signal.! !

!SystemDictionary methodsFor: 'memory space'!
useUpMemory
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemory"

	| lst |
	lst _ nil.
	[true] whileTrue: [
		lst _ Link new nextLink: lst; yourself.
	].! !

!SystemDictionary methodsFor: 'memory space' stamp: 'di 8/18/2000 21:15'!
useUpMemoryWithArrays 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithArrays"

	| b |  "First use up most of memory."
	b _ String new: self bytesLeft - self lowSpaceThreshold - 100000.
	b _ b.  "Avoid unused value warning"
	(1 to: 10000) collect: [:i | Array new: 10000]! !

!SystemDictionary methodsFor: 'memory space' stamp: 'di 8/18/2000 16:49'!
useUpMemoryWithContexts 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithContexts"

	self useUpMemoryWithContexts! !

!SystemDictionary methodsFor: 'memory space' stamp: 'di 8/18/2000 16:50'!
useUpMemoryWithTinyObjects 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithTinyObjects"

	| b |  "First use up most of memory."
	b _ String new: self bytesLeft - self lowSpaceThreshold - 100000.
	b _ b.  "Avoid unused value warning"
	(1 to: 10000) collect: [:i | BitBlt new]! !


!SystemDictionary methodsFor: 'special objects' stamp: 'JMM 6/6/2000 20:36'!
clearExternalObjects
	"Clear the array of objects that have been registered for use in non-Smalltalk code."
	"Smalltalk clearExternalObjects"

	ExternalSemaphoreTable clearExternalObjects
! !

!SystemDictionary methodsFor: 'special objects'!
compactClassesArray  "Smalltalk compactClassesArray"
	"Return the array of 31 classes whose instances may be
	represented compactly"
	^ Smalltalk specialObjectsArray at: 29! !

!SystemDictionary methodsFor: 'special objects' stamp: 'JMM 6/6/2000 21:01'!
externalObjects
	"Return an array of objects that have been registered for use in non-Smalltalk code. Smalltalk objects should be referrenced by external code only via indirection through this array, thus allowing the objects to move during compaction. This array can be cleared when the VM re-starts, since variables in external code do not survive snapshots. Note that external code should not attempt to access a Smalltalk object, even via this mechanism, while garbage collection is in progress."
	"Smalltalk externalObjects"

	^ ExternalSemaphoreTable externalObjects
! !

!SystemDictionary methodsFor: 'special objects'!
hasSpecialSelector: aLiteral ifTrueSetByte: aBlock

	1 to: self specialSelectorSize do:
		[:index | 
		(self specialSelectorAt: index) == aLiteral
			ifTrue: [aBlock value: index + 16rAF. ^true]].
	^false! !

!SystemDictionary methodsFor: 'special objects' stamp: 'jm 10/7/2002 05:33'!
recreateSpecialObjectsArray    "Smalltalk recreateSpecialObjectsArray"
	"The Special Objects Array is an array of object pointers used by the Smalltalk virtual machine.  Its contents are critical and unchecked, so don't even think of playing here unless you know what you are doing."

	| newArray |
	newArray _ Array new: 48.
	"Nil false and true get used throughout the interpreter"
	newArray at: 1 put: nil.
	newArray at: 2 put: false.
	newArray at: 3 put: true.
	"This association holds the active process (a ProcessScheduler)"
	newArray at: 4 put: (Smalltalk associationAt: #Processor).
	"Numerous classes below used for type checking and instantiation"
	newArray at: 5 put: Bitmap.
	newArray at: 6 put: SmallInteger.
	newArray at: 7 put: String.
	newArray at: 8 put: Array.
	newArray at: 9 put: Smalltalk. 
	newArray at: 10 put: Float.
	newArray at: 11 put: MethodContext.
	newArray at: 12 put: BlockContext.
	newArray at: 13 put: Point.
	newArray at: 14 put: LargePositiveInteger.
	newArray at: 15 put: Display.
	newArray at: 16 put: Message.
	newArray at: 17 put: CompiledMethod.
	newArray at: 18 put: (self specialObjectsArray at: 18)  "(low space Semaphore)".
	newArray at: 19 put: Semaphore.
	newArray at: 20 put: Character.
	newArray at: 21 put: #doesNotUnderstand:.
	newArray at: 22 put: #cannotReturn:.
	newArray at: 23 put: nil.  "*unused*"
	"An array of the 32 selectors that are compiled as special bytecodes,
	paired alternately with the number of arguments each takes."
	newArray at: 24 put: #(+ 1 - 1 < 1 > 1 <= 1 >= 1 = 1 ~= 1 * 1 / 1 \\ 1 @ 1 bitShift: 1 // 1 bitAnd: 1 bitOr: 1 at: 1 at:put: 2 size 0 next 0 nextPut: 1 atEnd 0 == 1 class 0 blockCopy: 1 value 0 value: 1 do: 1 new 0 new: 1 x 0 y 0 ).
	"An array of the 255 Characters in ascii order."
	newArray at: 25 put: ((0 to: 255) collect: [:ascii | Character value: ascii]).
	newArray at: 26 put: #mustBeBoolean.
	newArray at: 27 put: ByteArray.
	newArray at: 28 put: Process.
	"An array of up to 31 classes whose instances will have compact headers"
	newArray at: 29 put: self compactClassesArray.
	newArray at: 30 put: (self specialObjectsArray at: 30)   "(delay Semaphore)".
	newArray at: 31 put: (self specialObjectsArray at: 31)   "(user input Semaphore)".

	"Prototype instances that can be copied for fast initialization"
	newArray at: 32 put: (Float new: 2).
	newArray at: 33 put: (LargePositiveInteger new: 4).
	newArray at: 34 put: Point new.
	newArray at: 35 put: #cannotInterpret:.
	"Note: This must be fixed once we start using context prototypes"
	newArray at: 36 put: (self specialObjectsArray at: 36). 
						"(MethodContext new: CompiledMethod fullFrameSize)."
	newArray at: 37 put: nil.
	newArray at: 38 put: (self specialObjectsArray at: 38). 
						"(BlockContext new: CompiledMethod fullFrameSize)."

	newArray at: 39 put: Array new.  "array of objects referred to by external code"

	newArray at: 40 put: nil.  "was PseudoContext"
	newArray at: 41 put: nil.  "was TranslatedMethod"

	"finalization Semaphore"
	newArray at: 42 put: ((self specialObjectsArray at: 42) ifNil:[Semaphore new]).

	newArray at: 43 put: LargeNegativeInteger.

	"External objects for callout.
	Note: Written so that one can actually completely remove the FFI."
	newArray at: 44 put: (Smalltalk at: #ExternalAddress ifAbsent:[nil]).
	newArray at: 45 put: (Smalltalk at: #ExternalStructure ifAbsent:[nil]).
	newArray at: 46 put: (Smalltalk at: #ExternalData ifAbsent:[nil]).
	newArray at: 47 put: (Smalltalk at: #ExternalFunction ifAbsent:[nil]).
	newArray at: 48 put: (Smalltalk at: #ExternalLibrary ifAbsent:[nil]).

	"Now replace the interpreter's reference in one atomic operation"
	self specialObjectsArray become: newArray! !

!SystemDictionary methodsFor: 'special objects' stamp: 'JMM 6/6/2000 20:39'!
registerExternalObject: anObject
	"Register the given object in the external objects array and return its index. If it is already there, just return its index."

	^ExternalSemaphoreTable registerExternalObject: anObject! !

!SystemDictionary methodsFor: 'special objects'!
specialNargsAt: anInteger 
	"Answer the number of arguments for the special selector at: anInteger."

	^ (self specialObjectsArray at: 24) at: anInteger * 2! !

!SystemDictionary methodsFor: 'special objects'!
specialObjectsArray  "Smalltalk specialObjectsArray at: 1"
	<primitive: 129>
	^ self primitiveFailed! !

!SystemDictionary methodsFor: 'special objects'!
specialSelectorAt: anInteger 
	"Answer the special message selector from the interleaved specialSelectors array."

	^ (self specialObjectsArray at: 24) at: anInteger * 2 - 1! !

!SystemDictionary methodsFor: 'special objects'!
specialSelectorSize
	"Answer the number of special selectors in the system."

	^ (self specialObjectsArray at: 24) size // 2! !

!SystemDictionary methodsFor: 'special objects' stamp: 'JMM 6/6/2000 20:40'!
unregisterExternalObject: anObject
	"Unregister the given object in the external objects array. Do nothing if it isn't registered."

	ExternalSemaphoreTable unregisterExternalObject: anObject! !


!SystemDictionary methodsFor: 'image, changes name' stamp: 'jm 3/27/98 08:20'!
changesName
	"Answer the local name for the changes file corresponding to the image file name."
	"Smalltalk changesName"

	| imName |
	imName _ FileDirectory baseNameFor:
		(FileDirectory localNameFor: self imageName).
	^ imName, FileDirectory dot, 'changes'
! !

!SystemDictionary methodsFor: 'image, changes name' stamp: 'EMP 10/1/2015 16:07'!
imageName
	"Answer the full path name for the current image."
	"Smalltalk imageName"

	<primitive: 121>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'image, changes name'!
imageName: newName
	"Set the the full path name for the current image.  All further snapshots will use this."

	<primitive: 121>
	^ self primitiveFailed! !

!SystemDictionary methodsFor: 'image, changes name' stamp: 'di 5/22/1998 15:51'!
sourcesName
	"Answer the full path to the version-stable source code"
	^ self vmPath , 'SqueakV2' , FileDirectory dot , 'sources'! !

!SystemDictionary methodsFor: 'image, changes name'!
vmPath
	"Answer the path for the directory containing the Smalltalk virtual machine. Return the empty string if this primitive is not implemented."
	"Smalltalk vmPath"

	<primitive: 142>
	^ ''! !


!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 5/31/2003 17:08'!
aboutThisSystem 
	"Identify software version"

	^ self inform: self systemInformationString
! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'di 2/11/2000 17:23'!
assureStartupStampLogged
	"If there is a startup stamp not yet actually logged to disk, do it now."
	| changesFile |
	StartupStamp ifNil: [^ self].
	(SourceFiles isNil or: [(changesFile _ SourceFiles at: 2) == nil]) ifTrue: [^ self].

	changesFile setToEnd; cr; cr.
	changesFile nextChunkPut: StartupStamp asString; cr.
	StartupStamp _ nil.
	self forceChangesToDisk.! !

!SystemDictionary methodsFor: 'sources, change log'!
changes
	"Answer the current system ChangeSet."

	^SystemChanges! !

!SystemDictionary methodsFor: 'sources, change log'!
closeSourceFiles
	"Shut down the source files if appropriate.  1/29/96 sw: changed so that the closing and nilification only take place if the entry was a FileStream, thus allowing stringified sources to remain in the saved image file"

	1 to: 2 do: [:i |
		((SourceFiles at: i) isKindOf: FileStream)
			ifTrue:
				[(SourceFiles at: i) close.
				SourceFiles at: i put: nil]]! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'sw 2/15/1999 16:32'!
currentChangeSetString
	"Smalltalk currentChangeSetString"
	^ 'Current Change Set: ', self changes name! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'JMM 8/10/2000 15:15'!
externalizeSources   
	"Write the sources and changes streams onto external files."
 	"Smalltalk externalizeSources"

	| sourcesName changesName aFile |
	sourcesName _ self sourcesName.
	(FileDirectory default fileExists: sourcesName)
		ifTrue: [^ self inform:
'Sorry, you must first move or remove the
file named ', sourcesName].
	changesName _ self changesName.
	(FileDirectory default fileExists: changesName)
		ifTrue: [^ self inform:
'Sorry, you must first move or remove the
file named ', changesName].

	aFile _  FileStream newFileNamed: sourcesName.
	aFile nextPutAll: SourceFiles first originalContents.
	aFile close.
	"On Mac, set the file type and creator (noop on other platforms)"
	FileDirectory default
		setMacFileNamed: sourcesName
		type: 'STch'
		creator: 'FAST'.
	SourceFiles at: 1 put: (FileStream readOnlyFileNamed: sourcesName).

	aFile _ FileStream newFileNamed: self changesName.
	aFile nextPutAll: SourceFiles last contents.
	aFile close.
	"On Mac, set the file type and creator (noop on other platforms)"
	FileDirectory default
		setMacFileNamed: self changesName
		type: 'STch'
		creator: 'FAST'.
	SourceFiles at: 2 put: (FileStream oldFileNamed: changesName).

	self inform: 'Sources successfully externalized'.
! !

!SystemDictionary methodsFor: 'sources, change log'!
forceChangesToDisk
	"Ensure that the changes file has been fully written to disk by closing and re-opening it. This makes the system more robust in the face of a power failure or hard-reboot."

	| changesFile |
	changesFile _ SourceFiles at: 2.
	(changesFile isKindOf: FileStream) ifTrue: [
		changesFile flush.
		changesFile close.
		changesFile open: changesFile name forWrite: true.
		changesFile setToEnd.
	].
! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 12/5/97 15:30'!
internalizeChangeLog    
		"Smalltalk internalizeChangeLog"
	"Bring the changes file into a memory-resident filestream, for faster access and freedom from external file system.  1/31/96 sw"

	| reply aName aFile |
	reply _ self confirm:  'CAUTION -- do not undertake this lightly!!
If you have backed up your system and
are prepared to face the consequences of
the requested internalization of sources,
hit Yes.  If you have any doubts, hit No
to back out with no harm done.'.

	(reply ==  true) ifFalse:
		[^ self inform: 'Okay - abandoned'].

	aName _ self changesName.
	(aFile _ SourceFiles last) == nil ifTrue:
		[(FileDirectory default fileExists: aName)
			ifFalse: [^ self halt: 'Cannot locate ', aName, ' so cannot proceed.'].
		aFile _ FileStream readOnlyFileNamed: aName].
	SourceFiles at: 2 put: (ReadWriteStream with: aFile contentsOfEntireFile).

	self inform: 'Okay, changes file internalized'! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 12/5/97 15:30'!
internalizeSources    
		"Smalltalk internalizeSources"
	"Bring the sources and changes files into memory-resident filestreams, for faster access and freedom from file-system interface.  1/29/96 sw"

	| reply aName aFile |
	reply _ self confirm:  'CAUTION -- do not undertake this lightly!!
If you have backed up your system and
are prepared to face the consequences of
the requested internalization of sources,
hit Yes.  If you have any doubts, hit No
to back out with no harm done.'.

	(reply ==  true) ifFalse:
		[^ self inform: 'Okay - abandoned'].

	aName _ self sourcesName.
	(aFile _ SourceFiles first) == nil ifTrue:
		[(FileDirectory default fileExists: aName)
			ifFalse: [^ self halt: 'Cannot locate ', aName, ' so cannot proceed.'].
		aFile _ FileStream readOnlyFileNamed: aName].
	SourceFiles at: 1 put: (ReadWriteStream with: aFile contentsOfEntireFile).

	aName _ self changesName.
	(aFile _ SourceFiles last) == nil ifTrue:
		[(FileDirectory default fileExists: aName)
			ifFalse: [^ self halt: 'Cannot locate ', aName, ' so cannot proceed.'].
		aFile _ FileStream readOnlyFileNamed: aName].
	SourceFiles at: 2 put: (ReadWriteStream with: aFile contentsOfEntireFile).

	self inform: 'Okay, sources internalized'! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 12/3/2003 11:12'!
isBigEndian
	"Answer true if the underlying processor is 'big-endian.' A big-endian processor stores the most significant byte of a 32-bit integer first when accessing memory as a sequence of bytes. A little-endian processor stores the least-significant byte first."
	"Details: Use BitBlt to copy the integer '1' from a Bitmap (i.e., a 32-bit word array) into a ByteArray. On a big-endian machine, the 1 will be in the first byte of the ByteArray. On a little-endian machine, it will be in the last byte."
	"Smalltalk isBigEndian"

	| src dstBytes dst |
	src _ Form extent: 4@1 depth: 8.
	src bits at: 1 put: 1.
	dstBytes _ ByteArray withAll: #(0 0 0 0).
	dst _ Form new hackBits: dstBytes.
	(BitBlt toForm: dst) copyForm: src to: 0@0 rule: Form over.
	^ dstBytes last = 1
! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'sma 2/12/2000 12:42'!
lastUpdateString
	"Smalltalk lastUpdateString"
	| aNumber |
	aNumber _ (Smalltalk
		at: #ChangeSorter
		ifAbsent: [^ 'Update # unknown']) highestNumberedChangeSet.
	^ (aNumber notNil and: [aNumber > 0])
		ifTrue: ['latest update: #' , aNumber printString]
		ifFalse: ['No updates present.']! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'sw 2/12/1999 17:18'!
logChange: aStringOrText 
	"Write the argument, aString, onto the changes file."
	| aString changesFile |
	(SourceFiles isNil or: [(SourceFiles at: 2) == nil]) ifTrue: [^ self].
	self assureStartupStampLogged.

	aStringOrText isText
		ifTrue: [aString _ aStringOrText string]
		ifFalse: [aString _ aStringOrText].
	(aString isMemberOf: String)
		ifFalse: [self error: 'can''t log this change'].
	(aString findFirst: [:char | char isSeparator not]) = 0
		ifTrue: [^ self].  "null doits confuse replay"
	(changesFile _ SourceFiles at: 2) setToEnd; cr; cr.
	changesFile nextChunkPut: aString.
		"If want style changes in DoIt, use nextChunkPutWithStyle:, and allow Texts to get here"
	self forceChangesToDisk.! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 10/7/2002 06:34'!
newChanges: aChangeSet 
	"Set the system ChangeSet to be the argument, aChangeSet. Tell the current project that aChangeSet is now its change set. When called from Project enter:, the setChangeSet: call is redundant but harmless; when called from code that changes the current change set from within a project, it's vital"

	SystemChanges _ aChangeSet.

	"following code still works after removal of Projects:"
	Smalltalk at: #Project ifPresent:
		[:projClass | projClass current setChangeSet: aChangeSet].
! !

!SystemDictionary methodsFor: 'sources, change log'!
noChanges 
	"Initialize the system ChangeSet."

	SystemChanges initialize! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'di 4/28/2000 13:01'!
openSourceFiles
	self imageName = LastImageName ifFalse:
		["Reset the author initials to blank when the image gets moved"
		LastImageName _ self imageName.
		Utilities setAuthorInitials: ''].
	FileDirectory
		openSources: self sourcesName
		andChanges: self changesName
		forImage: LastImageName.
	StandardSourceFileArray install! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 5/31/2003 17:08'!
systemInformationString
	"Identify the Squeak image version."
	"Smalltalk systemInformationString"

	^ self version, String cr, self currentChangeSetString
! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'sw 9/27/1999 10:41'!
timeStamp: aStream 
	"Writes system version and current time on stream aStream."

	| dateTime |
	dateTime _ Time dateAndTimeNow.
	aStream nextPutAll: 'From ', Smalltalk version, ' [', Smalltalk lastUpdateString, '] on ', (dateTime at: 1) printString,
						' at ', (dateTime at: 2) printString! !

!SystemDictionary methodsFor: 'sources, change log' stamp: 'jm 5/31/2003 17:07'!
version
	"Answer the version of this release."
	"VersionString _ 'MIT Squeak 0.9.4 (June 1, 2003)'"

	^ VersionString
! !


!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'sma 4/30/2000 09:17'!
isMorphic
	"Answer true if the user interface is running in Morphic rathern than 
	MVC.  By convention the gloabl variable World is set to nil when MVC is 
	running.  ScheduledControllers could be set to nil when Morphic is 
	running, but this symmetry is not yet in effect."

	^ World ~~ nil! !

!SystemDictionary methodsFor: 'snapshot and quit'!
lastQuitLogPosition
	^ LastQuitLogPosition! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 10/29/2008 13:21'!
processShutDownList
	"Send #shutDown to each class that needs to do something when starting up."

	#(
		SoundPlayer
		Delay
		FileDirectory
		Color
		StrikeFont
		ControlManager
		Form
		DisplayScreen
		ScratchTranslator
	) do: [:cName |
		Smalltalk at: cName ifPresent: [:cl | cl shutDown]].
! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 6/26/2008 12:14'!
processStartUpList
	"Send #startUp to each class that needs to do something when starting up."

	#(
		DisplayScreen
		Cursor
		InputSensor
		ProcessorScheduler
		Delay
		FileDirectory
		CrLfFileStream
		ControlManager
		PasteUpMorph
		SoundBuffer
		ScratchTranslator
	) do: [:cName |
		Smalltalk at: cName ifPresent: [:cl | cl startUp]].
! !

!SystemDictionary methodsFor: 'snapshot and quit'!
quitPrimitive
	"Primitive. Exit to another operating system on the host machine, if one
	exists. All state changes in the object space since the last snapshot are lost.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 113>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 5/31/2003 16:09'!
readDocumentFile
	"Hook for starting up an application by double-clicking."

	StartupStamp _ '----STARTUP----', Time dateAndTimeNow printString, ' as ', Smalltalk imageName.
! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 3/5/2005 08:51'!
saveAs

	| dir newName newImageName newChangesName |
	dir _ FileDirectory default.
	newName _ FillInTheBlank
		request: 'New File Name?'
		initialAnswer: (FileDirectory localNameFor: self imageName).
	newName isEmpty ifTrue: [^ self].
	newName _ FileDirectory baseNameFor: newName.

	newImageName _ newName, '.image'.
	newChangesName _ newName, '.changes'.
	((dir includesKey: newImageName) or:
	 [dir includesKey: newChangesName]) ifTrue: [
		^ self notify: newName, ' is already in use.
Please choose another name.'].

	dir copyFileNamed: self changesName toFileNamed: newChangesName.
	
	"On Mac, set the file type and creator (noop on other platforms)"
	FileDirectory default
		setMacFileNamed: newChangesName
		type: 'STch'
		creator: 'FAST'.

	self logChange: '----SAVEAS ', newName, '----', Date dateAndTimeNow printString.
	self imageName: (dir fullNameFor: newImageName).
	LastImageName _ self imageName.
	self closeSourceFiles; openSourceFiles.  "so SNAPSHOT appears in new changes file"
	self snapshot: true andQuit: false.
! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 6/7/1999 21:33'!
setGCParameters
	"Adjust the VM's default GC parameters to avoid premature tenuring."

	Smalltalk vmParameterAt: 5 put: 4000.  "do an incremental GC after this many allocations"
	Smalltalk vmParameterAt: 6 put: 2000.  "tenure when more than this many objects survive the GC"
! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'jm 11/19/2004 11:57'!
snapshot: save andQuit: quit
	"Mark the changes file and close all files. If save is true, save the current state of this Smalltalk in the image file. If quit is true, then exit to the outer shell. The latter part of this method runs when resuming a previously saved image. The resume logic checks for a document file to process when starting up."

	| resuming msg sourceLink |
	save & (SourceFiles at: 2) notNil ifTrue:
		[msg _  (quit
			ifTrue: ['----QUIT----']
			ifFalse: ['----SNAPSHOT----'])
			, Date dateAndTimeNow printString.
		sourceLink _ ' priorSource: ' , LastQuitLogPosition printString.
		self assureStartupStampLogged.
		LastQuitLogPosition _ (SourceFiles at: 2) setToEnd; position.
		self logChange: msg , sourceLink.
		Transcript cr; show: msg].

	self processShutDownList.
	Cursor write show.
	save
		ifTrue: [resuming _ self snapshotPrimitive]  "<-- PC frozen here on image file"
		ifFalse: [resuming _ false].
	quit & resuming not ifTrue: [self quitPrimitive].
	Cursor normal show.
	self setGCParameters.
	resuming ifTrue: [self clearExternalObjects].
	self processStartUpList.
	resuming ifTrue: [self readDocumentFile].
	Smalltalk isMorphic ifTrue: [
		World displayWorldSafely.
		SystemWindow wakeUpTopWindowUponStartup].
	Display restore.
	^ resuming
! !

!SystemDictionary methodsFor: 'snapshot and quit'!
snapshotPrimitive
	"Primitive. Write the current state of the object memory on a file in the
	same format as the Smalltalk-80 release. The file can later be resumed,
	returning you to this exact state. Return normally after writing the file.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 97>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'snapshot and quit' stamp: 'ar 3/26/2000 16:12'!
unbindExternalPrimitives
	"Primitive. Force all external primitives to be looked up again afterwards. Since external primitives that have not found are bound for fast failure this method will force the lookup of all primitives again so that after adding some plugin the primitives may be found."
	<primitive: 570>
	"Do nothing if the primitive fails for compatibility with older VMs"! !


!SystemDictionary methodsFor: 'housekeeping'!
cleanOutUndeclared 
	Undeclared removeUnreferencedKeys! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'di 8/16/2000 10:08'!
condenseChanges		"Smalltalk condenseChanges"
	"Move all the changes onto a compacted sources file."
	| f oldChanges classCount |
	f _ FileStream fileNamed: 'ST80.temp'.
	f header; timeStamp.
'Condensing Changes File...'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: Smalltalk classNames size
	during:
		[:bar | classCount _ 0.
		Smalltalk allClassesDo:
			[:class | bar value: (classCount _ classCount + 1).
			class moveChangesTo: f.
			class class moveChangesTo: f]].
	LastQuitLogPosition _ f position.
	f trailer; close.
	oldChanges _ SourceFiles at: 2.
	oldChanges close.
	FileDirectory default deleteFileNamed: oldChanges name , '.old'.
	FileDirectory default rename: oldChanges name
						toBe: oldChanges name , '.old'.
	FileDirectory default rename: f name
						toBe: oldChanges name.
	FileDirectory default setMacFileNamed: oldChanges name
						type: 'STch' creator: 'FAST'.
	SourceFiles at: 2
			put: (StandardFileStream oldFileNamed: oldChanges name).! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'JMM 8/10/2000 15:13'!
condenseSources		"Smalltalk condenseSources"
	"Move all the changes onto a compacted sources file."
	| f classCount dir |
	dir _ FileDirectory default.

	"Write all sources with fileIndex 1"
	f _ FileStream newFileNamed: self sourcesName , '.temp'.
	f header; timeStamp.
'Condensing Sources File...'
	displayProgressAt: Sensor cursorPoint
	from: 0 to: Smalltalk classNames size
	during:
		[:bar | classCount _ 0.
		Smalltalk allClassesDo:
			[:class | bar value: (classCount _ classCount + 1).
			class fileOutOn: f moveSource: true toFile: 1]].
	f trailer; close.

	"Make a new empty changes file"
	self closeSourceFiles.
	dir rename: self changesName
		toBe: self changesName , '.old'.
	(FileStream newFileNamed: self changesName)
		header; timeStamp; close.
	LastQuitLogPosition _ 0.

	dir rename: self sourcesName
		toBe: self sourcesName , '.old'.
	dir rename: self sourcesName , '.temp'
		toBe: self sourcesName.

	"On Mac, set the file type and creator (noop on other platforms)"
	FileDirectory default
		setMacFileNamed: self changesName
		type: 'STch'
		creator: 'FAST'.

	FileDirectory default
		setMacFileNamed:  self sourcesName
		type: 'STch'
		creator: 'FAST'.

	self openSourceFiles.
	SelectionMenu notify: 'Source files have been rewritten!!
Check that all is well,
and then save/quit.'! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'ar 7/19/1999 23:00'!
forgetDoIts	"Smalltalk forgetDoIts"
	Smalltalk allBehaviorsDo: "get rid of old DoIt methods"
		[:cl | cl forgetDoIts]

! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'sw 9/21/97 01:14'!
makeInternalRelease		"Smalltalk makeInternalRelease"
	(self confirm: self version , '
Is this the correct version designation?
If not, choose no, and fix it.') ifFalse: [^ self].
	(Object classPool at: #DependentsFields) size > 1 ifTrue: [self halt].
	Browser initialize.
	Undeclared isEmpty ifFalse: [self halt].
	Smalltalk garbageCollect.
	self obsoleteClasses isEmpty ifFalse: [self halt].
	Symbol rehash.
	self halt: 'Ready to condense changes'.
	Smalltalk condenseChanges! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'ar 7/15/1999 16:05'!
obsoleteBehaviors   "Smalltalk obsoleteBehaviors inspect"
	"Find all obsolete behaviors including meta classes"
	| obs |
	obs _ OrderedCollection new.
	Smalltalk garbageCollect.
	self allObjectsDo:[:cl|
		(cl isBehavior and:[cl isObsolete]) ifTrue:[obs add: cl]].
	^ obs asArray! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'jm 5/22/1998 11:37'!
obsoleteClasses   "Smalltalk obsoleteClasses inspect"
	"NOTE:  Also try inspecting comments below"
	| obs c |
	obs _ OrderedCollection new.  Smalltalk garbageCollect.
	Metaclass allInstancesDo:
		[:m | c _ m soleInstance.
		(c ~~ nil and: ['AnOb*' match: c name asString])
			ifTrue: [obs add: c]].
	^ obs asArray

"Likely in a ClassDict or Pool...
(Association allInstances select: [:a | (a value isKindOf: Class) and: ['AnOb*' match: a value name]]) asArray
"
"Obsolete class refs or super pointer in last lit of a method...
| n l found |
Smalltalk browseAllSelect:
	[:m | found _ false.
	1 to: m numLiterals do:
		[:i | (((l _ m literalAt: i) isMemberOf: Association)
				and: [(l value isKindOf: Behavior)
				and: ['AnOb*' match: l value name]])
			ifTrue: [found _ true]].
	found]
"! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'tk 6/24/1999 11:47'!
reclaimDependents		"Smalltalk reclaimDependents"
	"Reclaim unused entries in DependentsFields (DF)..."
	"NOTE:  if <object>addDependent: is ever used to add something
		other than a view, this process will fail to reinstate that
		thing after clearing out DependentsFields.  DF was only
		intended to be used as part of the MVC architecture."
	Object classPool at: #DependentsFields  "Remove all entries from DF"
				put: IdentityDictionary new.
	Smalltalk garbageCollect.  "If that was the only reference, they will go away"
	"Now if any views of non-models remain,
		they should be reinstated as dependent views..."
	View allSubInstancesDo:
		[:v | (v model==nil or: [v model isKindOf: Model])
				ifFalse: [v model addDependent: v]].
	SystemWindow allSubInstancesDo:
		[:v | (v model==nil or: [v model isKindOf: Model])
				ifFalse: [v model addDependent: v]].
! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'di 4/24/2000 14:02'!
recompileAllFrom: firstName 
	"Recompile all classes, starting with given name."

	Smalltalk forgetDoIts.
	self allClassesDo: 
		[:class | class name >= firstName
			ifTrue: 
				[Transcript show: class name; cr.
				class compileAll]]

	"Smalltalk recompileAllFrom: 'AAABodyShop'."
! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'di 10/16/1999 20:31'!
removeAllLineFeeds    "Smalltalk removeAllLineFeeds"
	"Scan all methods for source code with lineFeeds.
	Replaces all occurrences of <CR><LF> by <CR>, noted by beep.
	Halts with a message if any other LFs are found."
	 | oldCodeString n crlf cr newCodeString oldStamp oldCategory m |
	crlf _ String with: Character cr with: Character lf.
	cr _ String with: Character cr.
	Smalltalk forgetDoIts.
'Scanning sources for LineFeeds.
This will take a few minutes...'
displayProgressAt: Sensor cursorPoint
from: 0 to: CompiledMethod instanceCount
during: [:bar | n _ 0. m _ 0.
	Smalltalk allBehaviorsDo:
		[:cls | 
		cls selectors do:
			[:selector | (n _ n+1) \\ 100 = 0 ifTrue: [bar value: n].
			oldCodeString _ (cls sourceCodeAt: selector) asString.
			(oldCodeString indexOf: Character lf startingAt: 1) > 0 ifTrue:
				[self beep.
				newCodeString _ oldCodeString copyReplaceAll: crlf with: cr asTokens: false.
				(newCodeString indexOf: Character lf startingAt: 1) > 0
					ifTrue: [(self confirm: cls name , ' ' , (selector contractTo: 30) , '
has an isolated LineFeed (not part of CRLF).
Shall I replace it?') ifFalse: [self halt]].
				oldStamp _ Utilities timeStampForMethod: (cls compiledMethodAt: selector).
				oldCategory _ cls whichCategoryIncludesSelector: selector.
				cls compile: newCodeString classified: oldCategory withStamp: oldStamp notifying: nil.
				m _ m + 1]]].
].
	Transcript cr; show: m printString , ' methods stripped of LFs.'.
! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'di 6/8/1999 15:47'!
removeEmptyMessageCategories
	"Smalltalk removeEmptyMessageCategories"
	Smalltalk garbageCollect.
	(ClassOrganizer allInstances copyWith: SystemOrganization) do:
		[:org | org removeEmptyCategories]! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'jm 11/20/2007 08:31'!
sanityCheckSourceFiles
	"Check the sources for all methods to if (a) their source code can be retrieved and (b) that it starts with the method selector."
	"Smalltalk sanityCheckSourceFiles"

	| result src prefix |
	result _ OrderedCollection new.
	Smalltalk allBehaviorsDo: [:class |
		class selectorsDo: [:sel |
			src _ [class sourceCodeAt: sel] ifError: [''].
			(sel includes: $:)
				ifTrue: [prefix _ sel copyUpTo: $:]
				ifFalse: [prefix _ sel].
			(src asString beginsWith: prefix) ifFalse: [
				result add: class name, '>>>', sel]]].

	^ result asArray! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'di 8/23/1998 14:35'!
testDecompiler    "Smalltalk testDecompiler"
	"Decompiles the source for every method in the system, and then compiles that source and verifies that it generates (and decompiles to) identical code.  This currently fails in a number of places because some different patterns (esp involving conditionals where the first branch returns) decompile the same."
	 | methodNode oldMethod newMethod badOnes oldCodeString n |
	badOnes _ OrderedCollection new.
	Smalltalk forgetDoIts.
'Decompiling all classes...'
displayProgressAt: Sensor cursorPoint
from: 0 to: CompiledMethod instanceCount
during: [:bar | n _ 0.
	Smalltalk allBehaviorsDo:
		[:cls | 
		"Transcript cr; show: cls name."
		cls selectors do:
			[:selector | (n _ n+1) \\ 100 = 0 ifTrue: [bar value: n].
			oldMethod _ cls compiledMethodAt: selector.
			oldCodeString _ (cls decompilerClass new
								decompile: selector in: cls method: oldMethod)
							decompileString.
			methodNode _ cls compilerClass new
						compile: oldCodeString
						in: cls notifying: nil ifFail: [].
			newMethod _ methodNode generate: #(0 0 0 0).
			oldCodeString = (cls decompilerClass new
								decompile: selector in: cls method: newMethod)
							decompileString ifFalse: [Transcript cr; show: '***' , cls name , ' ' , selector.
											badOnes add: cls name , ' ' , selector]]].
].
	Smalltalk browseMessageList: badOnes asSortedCollection name: 'Decompiler Discrepancies'! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'sw 11/9/1999 17:56'!
testFormatter    "Smalltalk testFormatter"
	"Reformats the source for every method in the system, and then compiles that source and verifies that it generates identical code.   The formatting used will be either classic monochrome or fancy polychrome, depending on the setting of the preference #colorWhenPrettyPrinting."

	 | newCodeString methodNode oldMethod newMethod badOnes n |
	badOnes _ OrderedCollection new.
	Smalltalk forgetDoIts.
'Formatting all classes...'
displayProgressAt: Sensor cursorPoint
from: 0 to: CompiledMethod instanceCount
during: [:bar | n _ 0.
	Smalltalk allBehaviorsDo:
		[:cls | 
		"Transcript cr; show: cls name."
		cls selectors do:
			[:selector | (n _ n+1) \\ 100 = 0 ifTrue: [bar value: n].
			newCodeString _ (cls compilerClass new)
				format: (cls sourceCodeAt: selector)
				in: cls notifying: nil decorated: Preferences colorWhenPrettyPrinting.
			methodNode _ cls compilerClass new
						compile: newCodeString
						in: cls notifying: nil ifFail: [].
			newMethod _ methodNode generate: #(0 0 0 0).
			oldMethod _ cls compiledMethodAt: selector.
			oldMethod = newMethod ifFalse: [Transcript cr; show: '***' , cls name , ' ' , selector.
											badOnes add: cls name , ' ' , selector]]].
].
	Smalltalk browseMessageList: badOnes asSortedCollection name: 'Formatter Discrepancies'! !

!SystemDictionary methodsFor: 'housekeeping' stamp: 'sw 11/9/1999 17:56'!
testFormatter2    "Smalltalk testFormatter2"
	"Reformats the source for every method in the system, and then verifies that the order of source tokens is unchanged.  The formatting used will be either classic monochrome or fancy polychrome, depending on the setting of the preference #colorWhenPrettyPrinting."

	 | newCodeString badOnes n oldCodeString oldTokens newTokens |
	badOnes _ OrderedCollection new.
	Smalltalk forgetDoIts.
'Formatting all classes...'
displayProgressAt: Sensor cursorPoint
from: 0 to: CompiledMethod instanceCount
during: [:bar | n _ 0.
	Smalltalk allBehaviorsDo:
		[:cls | 
		"Transcript cr; show: cls name."
		cls selectors do:
			[:selector | (n _ n+1) \\ 100 = 0 ifTrue: [bar value: n].
			oldCodeString _ (cls sourceCodeAt: selector) asString.
			newCodeString _ (cls compilerClass new)
				format: oldCodeString
				in: cls notifying: nil decorated: Preferences colorWhenPrettyPrinting.
			oldTokens _ oldCodeString findTokens: Character separators.
			newTokens _ newCodeString findTokens: Character separators.
			oldTokens = newTokens ifFalse:
					[Transcript cr; show: '***' , cls name , ' ' , selector.
					badOnes add: cls name , ' ' , selector]]].
].
	Smalltalk browseMessageList: badOnes asSortedCollection name: 'Formatter Discrepancies'! !

!SystemDictionary methodsFor: 'housekeeping'!
verifyChanges		"Smalltalk verifyChanges"
	"Recompile all methods in the changes file."
	Smalltalk allBehaviorsDo: [:class | class recompileChanges].
! !


!SystemDictionary methodsFor: 'miscellaneous'!
clipboardText
	"Get the current clipboard text. Return the empty string if the primitive fails."

	<primitive: 141>
	^ ''! !

!SystemDictionary methodsFor: 'miscellaneous'!
clipboardText: aString
	"Set the current clipboard text to the given string."

	<primitive: 141>
	^ self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous'!
exitToDebugger
	"Primitive. Enter the machine language debugger, if one exists. Essential.
	See Object documentation whatIsAPrimitive."

	<primitive: 114>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 7/10/1999 08:26'!
extraVMMemory: extraBytesToReserve
	"Request that the given amount of extra memory be reserved for use by the virtual machine to leave extra C heap space available for things like plugins, network and file buffers, and so on. This request is stored when the image is saved and honored when the image is next started up. Answer the previous value of this parameter."

	extraBytesToReserve < 0
		ifTrue: [self error: 'VM memory reservation must be non-negative'].
	^ Smalltalk vmParameterAt: 23 put: extraBytesToReserve
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 3/10/98 21:43'!
fullScreenMode: aBoolean
	"On platforms that support it, set full-screen mode to the value of the argument. (Note: you'll need to restore the Display after calling this primitive."
	"Smalltalk fullScreenMode: true. Display newDepth: Display depth"

	<primitive: 233>
	self primitiveFailed
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 5/8/1998 11:41'!
getSystemAttribute: attributeID
	"Optional. Answer the string for the system attribute with the given integer ID. Answer nil if the given attribute is not defined on this platform. On platforms that support invoking programs from command lines (e.g., Unix), this mechanism can be used to pass command line arguments to programs written in Squeak. By convention, the first command line argument that is not a VM configuration option is considered a 'document' to be filed in. Such a document can add methods and classes, can contain a serialized object, can include code to be executed, or any combination of these.
	Currently defined attributes include:
	-1000...-1 - command line arguments that specify VM options
	0 - the full path name for currently executing VM
		(or, on some platforms, just the path name of the VM's directory)
	1 - full path name of this image
	2 - a Squeak document to open, if any
	3...1000 - command line arguments for Squeak programs
	1001 - this platform's operating system
	1002 - operating system version
	1003 - this platform's processor type" 

	<primitive: 149>
	^ nil
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ikp 1/2/98 20:29'!
getVMParameters	"Smalltalk getVMParameters"
	"Answer an Array containing the current values of the VM's internal
	parameter/metric registers.  Each value is stored in the array at the
	index corresponding to its VM register.  (See #vmParameterAt: and
	#vmParameterAt:put:.)"

	<primitive: 254>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 8/8/2005 12:26'!
handleUserInterrupt

	World ifNotNil: [
		World allMorphsDo: [:m |
			(m isKindOf: ScratchStageMorph) ifTrue: [m stopAll]].
		Preferences noviceMode ifTrue: [^ self]].

	Preferences cmdDotEnabled ifTrue:
		[Smalltalk isMorphic
			ifTrue: [[Project current interruptName: 'User Interrupt'] fork]
			ifFalse: [[ScheduledControllers interruptName: 'User Interrupt'] fork]]
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'di 7/19/1999 15:44'!
hasMorphic
	"Answer whether the Morphic classes are available in the system (they may have been stripped, such as by a call to Smalltalk removeMorphic"

	^ ((Smalltalk at: #Morph ifAbsent: [nil]) isKindOf: Class)! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 1/23/2007 14:29'!
isMacOSX
	"Answer true if running on Macintosh OS X 10.0 or later."

	^ (self platformName = 'Mac OS') and: [self osVersion asNumber >= 1000]! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 6/3/2009 15:35'!
isUnix
	"Answer true if running on Unix or Linux."

	^ self platformName = 'unix'
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 6/26/2008 17:29'!
isWindows
	"Answer true if running on Windows."

	^ self platformName = 'Win32'
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ar 5/16/2000 00:54'!
listBuiltinModule: index
	"Return the name of the n-th builtin module.
	This list is not sorted!!"
	<primitive: 572>
	^self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ar 6/5/2000 18:44'!
listBuiltinModules
	"Smalltalk listBuiltinModules"
	"Return a list of all builtin modules (e.g., plugins). Builtin plugins are those that are compiled with the VM directly, as opposed to plugins residing in an external shared library. The list will include all builtin plugins regardless of whether they are currently loaded or not. Note that the list returned is not sorted!!"
	| modules index name |
	modules _ WriteStream on: Array new.
	index _ 1.
	[true] whileTrue:[
		name _ self listBuiltinModule: index.
		name ifNil:[^modules contents].
		modules nextPut: name.
		index _ index + 1.
	].! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'TPR 5/16/2000 16:56'!
listLoadedModule: index
	"Return the name of the n-th loaded module.
	This list is not sorted!!"
	<primitive: 573>
	^self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ar 6/5/2000 18:43'!
listLoadedModules
	"Smalltalk listLoadedModules"
	"Return a list of all currently loaded modules (e.g., plugins). Loaded modules are those that currently in use (e.g., active). The list returned will contain all currently active modules regardless of whether they're builtin (that is compiled with the VM) or external (e.g., residing in some external shared library). Note that the returned list is not sorted!!"
	| modules index name |
	modules _ WriteStream on: Array new.
	index _ 1.
	[true] whileTrue:[
		name _ self listLoadedModule: index.
		name ifNil:[^modules contents].
		modules nextPut: name.
		index _ index + 1.
	].! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'di 12/6/1999 19:54'!
logError: errMsg inContext: aContext to: aFilename
	"Log the error message and a stack trace to the given file."
	| ff ctx |
	FileDirectory default deleteFileNamed: aFilename ifAbsent: [].
	(ff _ FileStream fileNamed: aFilename) ifNil: [^ self "avoid recursive errors"].
  	ff print: Date today; space; print: Time now; cr.
  	ff nextPutAll: errMsg; cr.
	"Note: The following is an open-coded version of ContextPart>>stackOfSize:
	since this method may be called during a low space condition and we might
	run out of space for allocating the full stack."
	ctx _ aContext.
	[ctx == nil] whileFalse:[
		ff print: ctx; cr.
		ctx _ ctx sender].
	ff close.! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 12/30/2006 20:04'!
osVersion
	"Smalltalk osVersion"

	^ Smalltalk getSystemAttribute: 1002
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 12/30/2006 20:03'!
platformName
	"Smalltalk platformName"

	^ Smalltalk getSystemAttribute: 1001
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 11/1/1998 11:38'!
spaceForInstancesOf: aClass
	"Answer the number of bytes consumed by all instances of the given class, including thier object headers."

	| instCount isCompact instVarBytes bytesPerElement contentBytes headerBytes total |
	instCount _ aClass instanceCount.
	instCount = 0 ifTrue: [^ 0].
	isCompact _ aClass indexIfCompact > 0.
	instVarBytes _ aClass instSize * 4.
	aClass isVariable
		ifTrue: [
			bytesPerElement _ aClass isBytes ifTrue: [1] ifFalse: [4].
			total _ 0.
			aClass allInstancesDo: [:inst |
				contentBytes _ instVarBytes + (inst size * bytesPerElement).
				headerBytes _
					contentBytes > 255
						ifTrue: [12]
						ifFalse: [isCompact ifTrue: [4] ifFalse: [8]].
				total _ total + headerBytes + contentBytes].
			^ total]
		ifFalse: [
			headerBytes _
				instVarBytes > 255
					ifTrue: [12]
					ifFalse: [isCompact ifTrue: [4] ifFalse: [8]].
			^ instCount * (headerBytes + instVarBytes)].
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 11/1/1998 11:45'!
spaceTally
	"Answer a collection of tuples representing the memory space (in bytes) consumed by the code and instances of each class in the system. The tuples have the form:
	<class> <code size> <instance count> <space for instances>
Code sizes do not currently report memory consumed by class variables. The arrays used to record these results consume a relatively insignificant amount of space."
	"(Smalltalk spaceTally asSortedCollection: [:a :b | a last > b last]) asArray"

	| results entry c |
	"pre-allocate array of entries for results"
	results _ OrderedCollection new: self size.
	self do: [:cl |
		(cl isKindOf: Class) ifTrue: [
			entry _ Array new: 4.
			entry at: 1 put: cl.
			results add: entry]].
	results _ results asArray.

	Smalltalk garbageCollect.
	1 to: results size do: [:i |
		entry _ results at: i.
		c _ entry at: 1.
		entry at: 2 put: c spaceUsed.
		entry at: 3 put: c instanceCount.
		entry at: 4 put: (self spaceForInstancesOf: c).
		Smalltalk garbageCollectMost].
	^ results
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'jm 12/1/2005 16:48'!
unloadPlugin: aString
	"Primitive. Unload the given Squeak plugin. The mechanism for unloading may not be supported on all platforms. If your system does not support plugin unloading you'll need to save your image, quit, and restart Squeak in order to load a new version of a plugin that you're developing."

	<primitive: 571>
	^ self primitiveFailed
! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'sw 9/21/1998 11:03'!
verifyMorphicAvailability
	"If Morphic is available, return true; if not, put up an informer and return false"
	self hasMorphic ifFalse:
		[self beep.
		self inform: 'Sorry, Morphic must
be present to use this feature'.
		^ false].
	^ true! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ikp 1/2/98 20:29'!
vmParameterAt: parameterIndex
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Answer with the current value of that register.
	Fail if parameterIndex has no corresponding register."

	<primitive: 254>
	self primitiveFailed! !

!SystemDictionary methodsFor: 'miscellaneous' stamp: 'ikp 1/2/98 20:29'!
vmParameterAt: parameterIndex put: newValue
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Store newValue (a positive integer) into that
	register and answer with the previous value that was stored there.
	Fail if newValue is out of range, if parameterIndex has no corresponding
	register, or if the corresponding register is read-only."

	<primitive: 254>
	self primitiveFailed! !


!SystemDictionary methodsFor: 'accessing' stamp: 'ar 7/11/1999 21:56'!
organization
	"Return the organizer for the receiver"
	^SystemOrganization! !


!SystemDictionary methodsFor: 'printing' stamp: 'EMP 10/1/2015 16:13'!
printElementsOn: aStream
	aStream nextPutAll:'(lots of globals)'! !
