BlockMorph subclass: #CommandBlockMorph
	instanceVariableNames: 'commandSpec argPermutation argMorphs titleMorph receiver selector isReporter isTimed wantsName wantsPossession numberArgFlags isMobile '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!CommandBlockMorph commentStamp: 'jm 5/10/2004 19:25' prior: 0!
I represent a command or reporter. I have a label and may also have one or more arguments. The label text, number of arguments, and ordering of arguments and keywords are defined by my commandSpec string. This string consists of a sequence of keywords interspersed with argument specifications that indicate where the arguments appear. Here are some possible argument specifications:

	%b	- boolean
	%c	- color
	%C	- color (chosen with eyedropper, not palette)
	%m	- morph reference
	%n	- number
	%s	- string

Examples:

	%b and %b
	%m's color %C sees %C
	repeat %n times
!


!CommandBlockMorph methodsFor: 'initialization' stamp: 'EMP 11/8/2015 11:39'!
initialize

	super initialize.
	commandSpec _ ''.
	isMobile _ true.
	argMorphs _ OrderedCollection new.
	receiver _ nil.
	selector _ nil.
	isTimed _ false.
! !


!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 8/6/2008 20:59'!
argMorphs

	^ argMorphs
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'ee 3/2/2009 11:53'!
argPermutation: aSet

	argPermutation _ aSet
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 4/1/2009 10:37'!
args
	"Answer my arguments evaluated and permuted into the order expected by the underlying Squeak method."

	^ self organizeArgs: (argMorphs collect: [:m | m evaluate]) asArray
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 8/24/2003 17:05'!
color: aColor

	super color: aColor.
	self layoutChanged.
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 11/20/2002 09:16'!
commandSpec

	^ commandSpec
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'EMP 4/11/2016 15:42'!
commandSpec: aString
	"Set my command spec string. See my class comment."
	"CommandBlockMorph new commandSpec: 'forward %n'"

	commandSpec _ aString.
	numberArgFlags _ nil.
	self addLabel.
	self addCommandIcons! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 5/7/2009 14:16'!
defaultArgs: defaultValues
	"Set the default values of my arguments from the given list."

	| argM defaultValue |
	1 to: (defaultValues size min: argMorphs size) do: [:i |
		argM _ argMorphs at: (argPermutation at: i).
		defaultValue _ defaultValues at: i.
		(argM  isKindOf: ExpressionArgMorph)
			ifTrue: [argM defaultValueFromSpec: defaultValue]
			ifFalse: [argM defaultValue: defaultValue]].

! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 1/21/2007 11:43'!
helpScreenName
	"Answer the name of the help screen for this block, or nil if no help is available."

	selector isInfix ifTrue: [
		'+' = selector ifTrue: [^ 'minus'].
		'-' = selector ifTrue: [^ 'minus'].
		'*' = selector ifTrue: [^ 'minus'].
		'/' = selector ifTrue: [^ 'minus'].

		'<' = selector ifTrue: [^ 'lessThan'].
		'=' = selector ifTrue: [^ 'equals'].
		'>' = selector ifTrue: [^ 'greaterThan'].

		'&' = selector ifTrue: [^ 'and'].
		'|' = selector ifTrue: [^ 'or'].

		'\\' = selector ifTrue: [^ 'mod'].

		^ nil].

	"answer the selector with colons mapped to underscores"
	^ selector asString collect: [:ch | ch = $: ifTrue: [$_] ifFalse: [ch]]
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 4/15/2007 20:01'!
isForever

	^ (selector = #doForever) | (selector = #doForeverIf)
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 14:11'!
isMobile
	^ isMobile! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'EMP 11/8/2015 11:39'!
isMobile: aBoolean
	isMobile _ aBoolean! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 12/10/2003 20:58'!
isTimed

	^ isTimed
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'DaveF 7/10/2003 17:41'!
isTimed: aBoolean
	"Indicates that this block's evaluate method will be called repeatedly throughout some time interval."

	isTimed _ aBoolean.! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'ee 2/28/2009 17:05'!
numberArgFlags
	"Answer an array of booleans indicating which of my arguments must be numbers. Compute on first use and cache the result."

	| argSpecs argM |
	numberArgFlags ifNotNil: [^ numberArgFlags].

	argSpecs _ (CommandBlockMorph parseCommandSpec: commandSpec) select: [:s | CommandBlockMorph isArgSpec: s].
	argSpecs _ self organizeArgs: argSpecs.
	numberArgFlags _ argSpecs collect: [:spec |
		argM _ self uncoloredArgMorphFor: spec.
		(argM isKindOf: ExpressionArgMorph)
			ifTrue: [
				(argM isKindOf: ExpressionArgMorphWithMenu)
					ifTrue: [
						argM isNumberExpression or:
						[#(listIndexMenu listIndexForDeleteMenu) includes: argM menuSelector]]
					ifFalse: [argM isNumberExpression]]
			ifFalse: [false]].

	^ numberArgFlags
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 6/22/2003 21:50'!
receiver

	^ receiver
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 7/7/2004 00:09'!
receiver: anObject
	"Set my receiver object."

	receiver _ anObject.
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 7/2/2003 11:47'!
selector

	^ selector
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'jm 8/3/2003 23:52'!
selector: aSymbol

	selector _ aSymbol.
! !

!CommandBlockMorph methodsFor: 'accessing' stamp: 'EMP 10/3/2015 17:05'!
selectorAndArg
	"Answer an array containing my selector and argument (if any)."

	| args |
	args _ self args.
	^ Array with: selector with: (args size = 0 ifTrue: [nil] ifFalse: [args first])
! !


!CommandBlockMorph methodsFor: 'evaluation' stamp: 'ee 3/2/2009 11:53'!
argumentAt: index
	"Returns the argument morph at the given index."

	^ argMorphs at: (argPermutation at: index).
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'jm 12/10/2003 18:41'!
argumentCount
	"Returns the number of arguments to this command block."

	^ argMorphs size
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'ee 2/28/2009 17:09'!
coerceArgs: argList
	"Answer an arugments array in which all arguments that should be numbers have been coerced to numbers if necessary."

	| args specialCommands numFlags |
	args _ argList asArray.
	specialCommands _ #(
		append:toList: deleteLine:ofList: getLine:ofList: insert:at:ofList: list:contains: setLine:ofList:to:
		lookLike: showBackground:
		playSound: doPlaySoundAndWait
		setVar:to:).

	(specialCommands includes: selector) ifFalse: [
		"ensure args are numbers where numbers are expected"
		numFlags _ self numberArgFlags.
		1 to: args size do: [:i |
			(numFlags at: i) ifTrue: [args at: i put: (args at: i) asNumberNoError]]].

	^ args
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'EMP 1/12/2016 15:31'!
evaluate
	self isSpecialForm ifTrue: [] ifFalse: [^ self evaluateWithArgs: self args].
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'jm 6/25/2009 16:05'!
evaluateInfixWithArgs: rawArgs
	"Evalue an infix operator with the given arguments list. Special case for comparison operatores when both operands are strings. Reverse order of comparison operands in RTL languages."
	"Note: The strings 'true' and 'false' in either English or the current language are equal to the boolean value that they name."

	| args result arg1 arg2 |
	args _ rawArgs.

	#= = selector ifTrue: [
		"special case: check for equality between a boolean and the special strings 'true' or 'false'"
		((args first isKindOf: String) and: [args second isKindOf: Boolean]) ifTrue: [
			(args first = 'true') ifTrue: [^ args second = true].
			(args first = 'false') ifTrue: [^ args second = false].
			(args first = (ScratchTranslator translationFor: 'true')) ifTrue: [^ args second = true].
			(args first = (ScratchTranslator translationFor: 'false')) ifTrue: [^ args second = false]].
		((args first isKindOf: Boolean) and: [args second isKindOf: String]) ifTrue: [
			(args second = 'true') ifTrue: [^ args first = true].
			(args second = 'false') ifTrue: [^ args first = false].
			(args second = (ScratchTranslator translationFor: 'true')) ifTrue: [^ args first = true].
			(args second = (ScratchTranslator translationFor: 'false')) ifTrue: [^ args first = false]]].

	(#(< = >) includes: selector)
		ifTrue: [((args first isKindOf: String) or: [args second isKindOf: String]) ifTrue: [
				arg1 _ receiver interpretStringAsNumberIfPossible: args first.
				arg2 _ receiver interpretStringAsNumberIfPossible: args second.
				((arg1 isKindOf: String) and: [arg2 isKindOf: String]) ifTrue: [
					result _ args first compare: args second.
					#< = selector ifTrue: [^ result = 1].
					#= = selector ifTrue: [^ result = 2].
					#> = selector ifTrue: [^ result = 3]].
				((arg1 isKindOf: Number) and: [arg2 isKindOf: Number]) ifTrue: [
					^ arg1 perform: selector with: arg2].
				^ false]]
		ifFalse: [(ScratchTranslator isRTLMath and: [((selector = #\\) not)]) ifTrue: [args _ args reversed]]. "RTLMath operators are RTL"

	(#(& |) includes: selector) ifTrue: [^ args first perform: selector with: args second].

	^ args first asNumberNoError perform: selector with: args second asNumberNoError
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'EMP 12/1/2015 16:35'!
evaluateWithArgs: rawArgs
	"Evalue this block with the given argument list."

	| args |
	"special case for math and boolean infix operators"
	selector isInfix ifTrue: [^ self evaluateInfixWithArgs: rawArgs].
	receiver ifNil: [^ self error: 'Unknown reciever'].
	args _ self coerceArgs: rawArgs..

	"special case for unary operators"
	(#(abs not rounded sqrt truncated) includes: selector) ifTrue: [^ args first perform: selector].
	"begin special selectors"
	self selector == #createCloneOf ifTrue: [^ receiver perform: #createCloneOf: withArguments: args].
	self selector == #startScene ifTrue: [^ receiver perform: #changeBackdropTo: withArguments: args].
	self selector == #timeAndDate ifTrue: [^ receiver perform: #getDateOrTime: withArguments: args].
	self selector == #'CLR_COUNT' ifTrue: [^ receiver perform: #resetCounter].
	self selector == #'INCR_COUNT' ifTrue: [^ receiver perform: #incCounter].
	self selector == #COUNT ifTrue: [^ receiver perform: #getCounter].
	"end special selectors"
	^ receiver perform: selector withArguments: args
! !

!CommandBlockMorph methodsFor: 'evaluation' stamp: 'jm 5/5/2009 17:05'!
organizeArgs: argList
	"Answer an arugments array in which all arguments have been rearranged to the original English permutation"

	| newArgList |
	argPermutation ifNil: [^ argList].
	(#(+ - / * =) includes: selector) ifTrue: [^ argList].
	newArgList _ #().
	1 to: argPermutation size do: [:i |
		newArgList _ newArgList copyWith: (argList at: (argPermutation at: i))].
	^ newArgList
! !


!CommandBlockMorph methodsFor: 'menus' stamp: 'EMP 2/9/2016 15:26'!
fields
	| args fields |
	args := argMorphs
				select: [:t3 | (t3 isKindOf: ExpressionArgMorph)
						| (t3 isKindOf: ReporterBlockMorph)].
	fields := OrderedCollection new.
	args
		do: [:t3 | (t3 isKindOf: ExpressionArgMorph)
				ifTrue: [fields add: t3]
				ifFalse: [fields addAll: t3 fields]].
	^ fields! !

!CommandBlockMorph methodsFor: 'menus' stamp: 'EMP 2/9/2016 15:58'!
highestCommandBlock
	| current |
	current _ self.
	[current owner isKindOf: ReporterBlockMorph] whileTrue: [
		current _ current owner].
	(self isKindOf: ReporterBlockMorph) not ifFalse: [
	(current owner isKindOf: CommandBlockMorph) ifTrue: [current _ current owner]].
	^ current
! !

!CommandBlockMorph methodsFor: 'menus' stamp: 'EMP 2/9/2016 15:57'!
tabToNextField: evt
	| t3 args fields t6 |
	args _ OrderedCollection new.
	t6 _ self highestCommandBlock.
	t6 fields do: [:m | args add: m].

	fields := OrderedCollection new.
	args
		do: [:t5 | (t5 isKindOf: ExpressionArgMorph)
				ifTrue: [fields add: t5]
				ifFalse: [fields addAll: t5 fields]].
	t3 := (1 to: fields size)
				detect: [:i | (fields at: i) labelMorph == evt hand keyboardFocus]
				ifNone: [fields size].
	evt hand newKeyboardFocus: (fields at: (t3 \\ fields size  + 1)) labelMorph! !


!CommandBlockMorph methodsFor: 'processes' stamp: 'jm 12/21/2008 12:25'!
start

	| stage |
	self stop.
	self receiver ifNil: [^ self].
	scratchProc ifNotNil: [^ self].  "this stack is already running"

	(stage _ self receiver ownerThatIsA: ScratchStageMorph) ifNil: [^ self].
	scratchProc _ stage startProcessFor: self.
	self changed.
! !

!CommandBlockMorph methodsFor: 'processes' stamp: 'EMP 11/8/2015 11:45'!
startDrag: evt
	isMobile 
		ifTrue: [^ super startDrag: evt] 
		ifFalse: [^ (self ownerThatIsA: ProcedureHatBlockMorph) startDrag: evt].! !


!CommandBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 18:54'!
fieldsVersion

	^ 1
! !

!CommandBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:01'!
initFieldsFrom: anObjStream version: classVersion

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) from: anObjStream.
! !

!CommandBlockMorph methodsFor: 'object i/o' stamp: 'jm 9/24/2003 19:01'!
storeFieldsOn: anObjStream

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		commandSpec
		argMorphs
		titleMorph
		receiver
		selector
		isReporter
		isTimed
		wantsName
		wantsPossession
	) on: anObjStream.
! !


!CommandBlockMorph methodsFor: 'stack/tuple conversion' stamp: 'ee 3/1/2009 17:42'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	| blockTuple argList arg |
	blockTuple _ Array new: argMorphs size + 1.
	blockTuple at: 1 put: selector.

	argList _ argMorphs.
	argList _ self organizeArgs: argList.
	((#(+ - / * =) includes: selector) and: [ScratchTranslator isRTLMath]) "RTLMath operators are RTL"
		ifTrue: [argList _ argList reversed].
	1 to: argList size do: [:i |
		arg _ argList at: i.
		(arg isKindOf: ArgMorph) | (arg isKindOf: EventTitleMorph)
			ifTrue: [blockTuple at: i + 1 put: arg evaluate]
			ifFalse: [blockTuple at: i + 1 put: arg asBlockTuple]].

	^ blockTuple
! !

!CommandBlockMorph methodsFor: 'stack/tuple conversion' stamp: 'EMP 10/4/2015 12:39'!
evaluateIsStop
	^ (self selector == #stopScripts) ifTrue: [((self args first) asSymbol == #'all') | ((self args first) asSymbol == #'this script')] ifFalse: [false]! !

!CommandBlockMorph methodsFor: 'stack/tuple conversion' stamp: 'EMP 10/4/2015 12:08'!
isStop

	^ (selector = #doReturn) | (selector = #stopAll) | (selector = #deleteClone) | (self evaluateIsStop)! !


!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 4/11/2016 15:42'!
addCommandIcons
	| t1 t2 t3 |
	true ifTrue: [^ self].
	#turnLeft: = selector
		ifTrue: [t1 := ScratchFrameMorph
						skinAt: #turnCCW
						ifAbsent: [^ self].
			t3 := Form extent: 15 @ 14 depth: t1 depth.
			t1 displayInterpolatedIn: t3 boundingBox on: t3.
			t2 := self firstSubmorph delete.
			self
				addMorphFront: (ImageMorph new form: t3).
			self addMorphFront: t2].
	#turnRight: = selector
		ifTrue: [t1 := ScratchFrameMorph
						skinAt: #turnCW
						ifAbsent: [^ self].
			t3 := Form extent: 14 @ 14 depth: t1 depth.
			t1 displayInterpolatedIn: t3 boundingBox on: t3.
			t2 := self firstSubmorph delete.
			self
				addMorphFront: (ImageMorph new form: t3).
			self addMorphFront: t2]! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 4/11/2016 16:14'!
addLabel
	"Add a label for my command and arguments. This is the method that really creates the whole block."
	"Details: We remove all the pieces of this block, and then reassemble them, being careful not to destroy any argument morphs that we might still want to use. This is helpful if someone adds/removes parameters from a hat block."

	| tokens args nextArgIndex m next |
	commandSpec ifNil: [^ self].

	"we make sure not to remove the next block."
	next _ self nextBlock.
	self removeAllMorphsIn: (self submorphs reject: [:t | t = next]).

	tokens _ CommandBlockMorph parseCommandSpec: commandSpec.
	args _ tokens select: [:s | CommandBlockMorph isArgSpec: s].

	"remove any excess arg morphs from the list."
	[argMorphs size > args size] whileTrue: [
		m _ argMorphs last.
		argMorphs remove: m.

		"if the argument we're throwing out is anything complicated, we'd like to keep it around in the world."
		(m isKindOf: BlockMorph) ifTrue: [m openInWorld]].

	"create new arg morphs."
	[argMorphs size < args size] whileTrue: [
		argMorphs addLast: (self argMorphFor: (args at: argMorphs size + 1))].

	nextArgIndex _ 1.

	tokens do: [:s |
		(CommandBlockMorph isArgSpec: s)
			ifTrue:	[
				m _ argMorphs at: nextArgIndex.
				nextArgIndex _ nextArgIndex + 1]
			ifFalse:	[
				(CommandBlockMorph isIconSpec: s) ifTrue: [m _ self iconForName: s] ifFalse: 
				[m _ self labelMorphFor: s]].
		self addMorphBack: m].

	self isReporter ifTrue: [
		m _ submorphs first.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphFront: (Morph new color: Color transparent; extent: 2@5)].

		m _ submorphs last.
		((m isKindOf: ChoiceArgMorph) | (m isKindOf: SpriteArgMorph)) ifTrue: [  "add spacer"
			self addMorphBack: (Morph new color: Color transparent; extent: 2@5)]].
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 3/28/2005 17:32'!
argMorphFor: specString
	"Answer an argument morph for the given argument specification string. Set it's color appropriately."

	| m |
	m _ self uncoloredArgMorphFor: specString.
	(m isKindOf: ColorArgMorph)
		ifTrue: [m color: Color random].
	^ m
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 6/2/2009 22:03'!
argMorphToReplace: aMorph
	"Answer a new argument morph to be used to replace the given morph. Answer nil if the given morph is not one of my argMorphs."

	| i argSpecs spec argM defaults v |
	i _ argMorphs indexOf: aMorph ifAbsent: [^ nil].
	argSpecs _ (CommandBlockMorph parseCommandSpec: commandSpec) select: [:s | CommandBlockMorph isArgSpec: s].
	i > argSpecs size ifTrue: [^ nil].
	argM _ self argMorphFor: (argSpecs at: i).

	(#setVar:to: = selector and: [(argSpecs at: i) = '%n']) ifTrue: [
		^ argM stringExpression: '0'].
	spec _ ScriptableScratchMorph blockSpecDict at: selector ifAbsent: [^ argM].

	defaults _ receiver defaultArgsFor: spec.
	i <= defaults size ifTrue: [
		v _ defaults at: (argPermutation indexOf: i).
		(v isKindOf: String)
			ifTrue: [
				(argM isKindOf: ExpressionArgMorph)
					ifTrue: [argM defaultValueFromSpec: v localized]
					ifFalse: [argM defaultValue: v localized]]
			ifFalse: [argM defaultValue: v]].

	^ argM
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 10/3/2015 17:12'!
canBecomeWatcher
	"I determine which blocks can become watchers."

	| i |
	i _ selector asString findAnySubStr: #('mouse' 'key' 'touching' 'distance') startingAt: 1.
	^ (self isReporter) &
	   (self argumentCount <= 1) &
	   ((#(not atRandom abs rounded lineCountOfList: stringLength: COUNT) includes: selector) not) &
	   (i > selector asString size)
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 7/4/2008 18:17'!
fixBlockLayout
	"Update the positions of my submorphs."

	| isFirst h x minXForArgs hAdjust nextB w oldPos oldExtent |
	blockLayoutNeeded ifFalse: [^ self].
	super fixBlockLayout.
	oldPos _ self position.
	oldExtent _ self extent.
	hAdjust _ 4.

	isFirst _ true.
	h _ 14.  "minimum height"
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: BlockMorph) ifTrue: [m fixBlockLayout].
		(m isKindOf: ArgMorph) ifTrue: [m fixArgLayout].
		(isFirst and: [(m isKindOf: StringMorph) not]) ifTrue: [
			"extra space when an arg overlaps with notch"
			h _ h max: m height + 3.
			hAdjust _ 1].
		isFirst _ false.
		h _ h max: m height].

	((self isKindOf: CBlockMorph) or: [self isKindOf: IfElseBlockMorph])
		ifTrue: [minXForArgs _ self left + PuzzleInset + PuzzleWidth + 8]
		ifFalse: [minXForArgs _ self left].

	h _ h + 10. 
	self isReporter ifTrue: [h _ h - 2. hAdjust _ 2].
	self isStop ifTrue: [h _ h - 5. hAdjust _ 0].

	x _ self left + 5.
	self nonControlFlowSubmorphs do: [:m |
		(m isKindOf: StringMorph)
			ifTrue: [m color: self labelColor]
			ifFalse: [x _ x max: minXForArgs].
		m position: x@(self top + (((h - hAdjust) - m height) // 2)).
		x _ x + m width + 4].

	w _ (x - self left) max: 37.
	((self isKindOf: CBlockMorph) or:
	 [self isKindOf: IfElseBlockMorph])
		ifTrue: [w _ w max: 71].
	self extent: w @ h.
	ScratchTranslator isRTL ifTrue: [
		self left: oldPos x + (oldExtent x - self width)].

	(nextB _ self nextBlock) ifNotNil: [
		(self isKindOf: CBlockMorph) ifFalse: [
			ScratchTranslator isRTL
				ifTrue: [nextB position: (self right - nextB width)@(self bottom - 4)]
				ifFalse: [nextB position: self left@(self bottom - 4)]].
		nextB fixBlockLayout].
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 4/11/2016 15:44'!
iconForName: aString
	| t1 t3 |
	'@turnLeft' = aString
		ifTrue: [t1 := ScratchFrameMorph
						skinAt: #turnCCW
						ifAbsent: [^ self].
			t3 := Form extent: 15 @ 14 depth: t1 depth.
			t1 displayInterpolatedIn: t3 boundingBox on: t3.
			^ (ImageMorph new form: t3)].
	'@turnRight' = aString
		ifTrue: [t1 := ScratchFrameMorph
						skinAt: #turnCW
						ifAbsent: [^ self].
			t3 := Form extent: 14 @ 14 depth: t1 depth.
			t1 displayInterpolatedIn: t3 boundingBox on: t3.
			^ (ImageMorph new form: t3)].
	 ^ Morph new! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 6/20/2007 19:10'!
labelColor
	"Answer a label color, either black or white, that maximizes the contrast with my color."

	^ LabelColor

"old:
	^ self color luminance > 0.8
		ifTrue: [Color black]
		ifFalse: [Color white]
"
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 4/11/2016 16:21'!
labelMorphFor: aString

	| s |
	s _ ((((aString copyReplaceAll: '\\@' with: '@') copyReplaceAll: '\\%' with: '%') copyReplaceAll: '\/' with: '/') copyReplaceAll: '\\\\' with: '\').
	commandSpec isUnicode ifTrue: [s _ UTF8 withAll: s].
	^ (StringMorph contents: s font: (ScratchFrameMorph getFont: #Label))
		color: self labelColor
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 6/3/2009 16:38'!
mapReceiver: oldObj to: newObj
	"Used in cloning an object to make blocks that refererred to the original object new refer to the new copy."

	receiver == oldObj ifTrue: [receiver _ newObj].
	argMorphs do: [:arg |
		(arg isKindOf: CommandBlockMorph) ifTrue: [
			arg mapReceiver: oldObj to: newObj]].
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 8/31/2006 09:18'!
nextBlock
	"Answer the block following myself in the block sequence or nil if I am the last block in the sequence. Each block is a submorph of the previous block."

	^ self submorphs
		detect: [:m | (m isKindOf: BlockMorph) and: [(argMorphs includes: m) not]]
		ifNone: [nil]
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 3/23/2005 18:02'!
nextBlock: aBlock
	"Add the given block as the block following me. Delete old nextBlock, if any."

	self nextBlock ifNotNil: [self nextBlock delete].
	self addMorph: aBlock.
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 6/3/2008 15:48'!
parseCommandSpec
	"Answer an array of token strings containing my keywords and argument specs."

	| spec result len i j |
	result _ OrderedCollection new.
	spec _ commandSpec.
	(spec isKindOf: UTF8) ifTrue: [spec _ String withAll: spec].
	len _ commandSpec size.

	i _ 1.
	[(i < len) and: [(spec at: i) isSeparator]] whileTrue: [i _ i + 1].
	[i <= len] whileTrue: [
		j _ spec indexOf: $% startingAt: i.
		j > 0
			ifTrue: [
				j > i ifTrue: [result addLast: (spec copyFrom: i to: j - 1)].
				j < len
					ifTrue: [result addLast: (spec copyFrom: j to: j + 1)]
					ifFalse: [result addLast: '%'].
				i _ j + 2]
			ifFalse: [
				result addLast: (spec copyFrom: i to: len).
				i _ len + 1]].

	^ result asArray collect: [:s | s withBlanksTrimmed]
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 12/10/2005 11:04'!
printCodeOn: aStream indent: indent
	"Append a human-readable string for this block on the given stream."

	| nextB hasFinalSpace |
	indent timesRepeat: [aStream nextPutAll: '    '].
	nextB _ self nextBlock.
	hasFinalSpace _ false.
	submorphs do: [:m |
		m ~~ nextB ifTrue: [
			self printCodeSubmorph: m on: aStream.
			hasFinalSpace _ true.
			aStream space]].
	hasFinalSpace ifTrue: [aStream skip: -1].
	aStream cr.
	self nextBlock ifNotNil: [self nextBlock printCodeOn: aStream indent: indent].
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 8/24/2003 17:06'!
replaceArgMorph: oldMorph by: newMorph
	"Replace oldMorph with newMorph in my argMorphs and submorphs lists. This is done when dropping a reporter block onto one of my arguments."

	argMorphs _ argMorphs collect: [:m |
		m == oldMorph ifTrue: [newMorph] ifFalse: [m]].
	self replaceSubmorph: oldMorph by: newMorph.
	self layoutChanged.
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 11/8/2015 11:49'!
rightButtonMenu

	| menu sFrame choice spec |
	isMobile ifFalse: [^ (self ownerThatIsA: ProcedureHatBlockMorph) rightButtonMenu].
	menu _ CustomMenu new.
	menu add: 'help' action: #presentHelpScreen.

	(owner isKindOf: ScratchBlockPaletteMorph) ifFalse: [
		menu addLine.
		(#(+ - * / \\) includes: selector) ifTrue: [
			#(+ - * / mod) with: #(+ - * / \\) do: [:s :op | menu add: s action: op]].
		(#(< = >) includes: selector) ifTrue: [
			#(< = >) do: [:op | menu add: op action: op]].
		(#(& |) includes: selector) ifTrue: [
			#(and or) with: #(& |) do: [:s :op | menu add: s action: op]].

		menu addLine.
		menu add: 'duplicate' action: #duplicate.
		(self owner isKindOf: BlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
			menu add: 'delete' action: #delete]].

	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	(sFrame notNil and: [#(sensor: sensorPressed:) includes: selector]) ifTrue: [
		menu addLine.
		menu add: 'show ScratchBoard watcher' action: #showSensorBoard.
		sFrame workPane scratchServer
			ifNil: [menu add: 'enable remote sensor connections' action: #enableRemoteSensors]
			ifNotNil: [menu add: 'disable remote sensor connections' action: #exitScratchSession]].

	DebugMenu ifTrue: [
		menu addLine.
		menu add: 'show tuples' action: #showTuples].
	
	(choice _ menu localize; startUp) ifNil: [^ self].
	(#(presentHelpScreen duplicate delete) includes: choice) ifTrue: [^ self perform: choice].
	choice = #showSensorBoard ifTrue: [sFrame showSensorBoard. ^ self].
	choice = #enableRemoteSensors ifTrue: [sFrame enableRemoteSensors. ^ self].
	choice = #exitScratchSession ifTrue: [sFrame exitScratchSession. ^ self].
	choice = #showTuples ifTrue: [^ self showTuples].

	"change operator"
	spec _ '%n ', choice, ' %n'.
	'\\' = choice	ifTrue: [spec _ ScratchTranslator translationFor: '%n mod %n'].
	'&' = choice	ifTrue: [spec _ ScratchTranslator translationFor: '%b and %b'].
	'|' = choice	ifTrue: [spec _ ScratchTranslator translationFor: '%b or %b'].

	self commandSpec: spec.
	self selector: choice.
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'EMP 4/9/2016 15:21'!
uncoloredArgMorphFor: specString
	"Answer an argument morph for the given argument specification string."

	| code |
	code _ specString copyFrom: 2 to: (specString size).
	'm.rotationStyle' = code ifTrue: [^ ChoiceArgMorph new choice: 'left-right'; options: #(#'left-right' #'don''t rotate' #'all around')].
	'm.attribute' = code ifTrue: [^ AttributeArgMorph new choice: 'volume'].
	'b' = code ifTrue: [^ BooleanArgMorph new].
	'm.stop' = code ifTrue: [^ ChoiceArgMorph new choice: 'all'; options: #(#'all' #'this script' #'other scripts in sprite')].
	'm.colorPicker' = code ifTrue: [^ ColorArgMorph new showPalette: true].
	'c' = code ifTrue: [^ ColorArgMorph new showPalette: false].  "don't use palette; pick from screen"
	'd.direction' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '0'; menuSelector: #directionMenu].
	'd.drum' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '48'; menuSelector: #midiDrumMenu].
	'm.broadcast' = code ifTrue: [^ EventTitleMorph new].
	'm.mathOp' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #mathFunctionNames; choice: 'sqrt'].
	'm.effect' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #graphicEffectNames; choice: 'color'].
	'm.sensor' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupSensorNames].
	'm.booleanSensor' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #hookupBooleanSensorNames].
	'd.instrument' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #midiInstrumentMenu].
	'd.listItem' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexMenu].
	'm.key' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #keyNames; choice: 'space'].
	'm.list' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #listVarMenu].
	'm.costume' = code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #costumeNames; choice: 'costume1'].
	'm.spriteOnly' = code ifTrue: [^ SpriteArgMorph new type: #spriteOnly].
	'm.spriteOrMouse' = code ifTrue: [^ SpriteArgMorph new type: #spriteOrMouse].
	'm.spriteOrStage' = code ifTrue: [^ SpriteArgMorph new type: #spriteOrStage].
	'm.location' = code ifTrue: [^ SpriteArgMorph new type: #location].
	'm.touching' = code ifTrue: [^ SpriteArgMorph new type: #touching].
	'M' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorNames].
	'n' = code ifTrue: [^ ExpressionArgMorph new numExpression: '10'].
	'd.note' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '60'; menuSelector: #noteSelector].
	's' = code ifTrue: [^ ExpressionArgMorph new stringExpression: ''].
	'm.sound' = code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #soundNames; choice: 'pop'].
	'm.var' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #varNamesMenu; choice: ''].
	'm.backdrop' = code ifTrue: [^ ChoiceOrExpressionArgMorph new getOptionsSelector: #backdropNames; choice: 'backdrop1'].
	'm.motorDirection' = code ifTrue: [^ ChoiceArgMorph new getOptionsSelector: #motorDirection].
	'd.listDeleteItem' = code ifTrue: [^ ExpressionArgMorphWithMenu new numExpression: '1'; menuSelector: #listIndexForDeleteMenu].
	'm.timeAndDate' = code ifTrue: [^ ChoiceArgMorph new choice: 'minute'; options: #(#'year' #'month' #'date' #'day of week' #'hour' #'minute' #'second')].
	^ ExpressionArgMorph new numExpression: '10'
! !

!CommandBlockMorph methodsFor: 'private' stamp: 'jm 3/15/2003 11:23'!
updateReferencesUsing: aDictionary
	"Update my arg morphs."

	super updateReferencesUsing: aDictionary.
	argMorphs _ argMorphs collect: [:m | aDictionary at: m ifAbsent: [m]].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

CommandBlockMorph class
	instanceVariableNames: ''!

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'ee 3/28/2009 20:07'!
argPermutationForSpec: spec withTranslation: translatedSpec
	"CommandBlockMorph argPermutationForSpec: '%a of %m of %m of %t' withTranslation: '%a de %m de %m de %t'"
	"CommandBlockMorph argPermutationForSpec: '%a of %m of %m of %t' withTranslation: '%t de %m2 de %m1 de %a'"

	| parsedSpec parsedTranslatedSpec parsedSpecArgs parsedTranslatedSpecArgs permutation a copiesSize n originalPermutation |

	parsedSpec _ CommandBlockMorph parseCommandSpec: spec.
	parsedSpecArgs _ parsedSpec select: [:s | CommandBlockMorph isArgSpec: s].
	parsedTranslatedSpec _ CommandBlockMorph parseCommandSpec: translatedSpec.
	parsedTranslatedSpecArgs _ parsedTranslatedSpec select: [:s | CommandBlockMorph isArgSpec: s].

	permutation _ #().
	1 to: parsedSpecArgs size do: [:i | permutation _ permutation copyWith: i].
	originalPermutation _ permutation.

	"no change"
	(parsedSpecArgs = parsedTranslatedSpecArgs) ifTrue: [
			^ originalPermutation].

	"otherwise, calculate permutation"
	1 to: parsedSpecArgs size do: [:i |
		a _ parsedSpecArgs at: i.
		copiesSize _ (parsedSpecArgs select: [:s | (s = a)]) size.
		(copiesSize = 1)
			ifTrue:[permutation at: i put: (parsedTranslatedSpecArgs indexOf: a
				ifAbsent: [Transcript show: 'Permutation failed: ', spec.
						^ originalPermutation])]
			ifFalse:["count copies until now"
				n _ ((parsedSpecArgs copyFrom: 1 to: i) select: [:s | (s = a)]) size.
				permutation at: i put: (parsedTranslatedSpecArgs indexOf: (a,n asString)
					ifAbsent: [Transcript show: 'Permutation failed: ', spec.
						^ originalPermutation])]].
	^ permutation
! !

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'ee 2/28/2009 13:39'!
isArgSpec: aString
	"Answer true if the given string is an argument specification."

	^ ((aString size > 1) and: [aString first = $%])
! !

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'EMP 4/11/2016 15:30'!
isIconSpec: aString
	"Answer true if the given string is an argument specification."

	^ ((aString size > 1) and: [aString first = $@])
! !

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'EMP 4/11/2016 16:34'!
parseCommandSpec: aString
	"CommandBlockMorph xparseCommandSpec: '\\%n'"
	| result temp i |
	result _ OrderedCollection new.
	temp _ ''.
	i _ 1.

	(aString asByteArray asString) do: [:char |
		temp _ temp, char asString.
		i _ i + 1.

		(((((aString at: i ifAbsent: [$ ]) = $% | ((aString at: i ifAbsent: [$ ]) = $@)) and: [((aString at: i + 1 ifAbsent: [$ ]) = $ ) not]) and: [(((aString at: i - 3 ifAbsent: [$ ]) ~= $\) and: [((aString at: i - 1 ifAbsent: [$ ]) = $\) & ((aString at: i - 2 ifAbsent: [$ ]) = $\)]) not])) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ ''].
		((((temp at: 1 ifAbsent: [nil]) = $%) | ((temp at: 1 ifAbsent: [nil]) = $@)) and: [(aString at: i ifAbsent: [nil]) = $ ]) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ '']].
	result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
	^ ( result select: [:m | m ~= '']) asArray! !

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'EMP 4/11/2016 16:12'!
xparseCommandSpec: aString
	"CommandBlockMorph xparseCommandSpec: 'turn @turnRight %n degrees \\\%n'"
	| result temp i |
	result _ OrderedCollection new.
	temp _ ''.
	i _ 1.

	(aString asByteArray asString) do: [:char |
		temp _ temp, char asString.
		i _ i + 1.

		(((((aString at: i ifAbsent: [$ ]) = $% | ((aString at: i ifAbsent: [$ ]) = $@)) and: [((aString at: i + 1 ifAbsent: [$ ]) = $ ) not]) and: [(((aString at: i - 3 ifAbsent: [$\]) ~= $\) and: [((aString at: i - 1 ifAbsent: [$ ]) = $\) & ((aString at: i - 2 ifAbsent: [$ ]) = $\)]) not])) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ ''].
		((((temp at: 1 ifAbsent: [nil]) = $%) | ((temp at: 1 ifAbsent: [nil]) = $@)) and: [(aString at: i ifAbsent: [nil]) = $ ]) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ '']].
	result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
	^ ( result select: [:m | m ~= '']) asArray! !

!CommandBlockMorph class methodsFor: 'utilities' stamp: 'EMP 4/11/2016 16:33'!
xxparseCommandSpec: aString
	"CommandBlockMorph parseCommandSpec: 'turn @turnRight %n degrees'"
	| result temp i |
	result _ OrderedCollection new.
	temp _ ''.
	i _ 1.

	(aString asByteArray asString) do: [:char |
		temp _ temp, char asString.
		i _ i + 1.

		(((aString at: i ifAbsent: [$ ]) = $% | ((aString at: i ifAbsent: [$ ]) = $@)) and: [((aString at: i + 1 ifAbsent: [$ ]) = $ ) not]) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ ''].
		((((temp at: 1 ifAbsent: [nil]) = $%) | ((temp at: 1 ifAbsent: [nil]) = $@)) and: [(aString at: i ifAbsent: [nil]) = $ ]) ifTrue: [
			result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
			temp _ '']].
	result add: (temp withoutLeadingBlanks withoutTrailingBlanks).
	^ ( result select: [:m | m ~= '']) asArray! !
