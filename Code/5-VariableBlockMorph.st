ReporterBlockMorph subclass: #VariableBlockMorph
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Blocks'!
!VariableBlockMorph commentStamp: 'jm 2/20/2004 18:45' prior: 0!
I am a block that reports the value of either a built-in or a user variable. When dropped into the workspace, I turn into a WatcherMorph for that variable with an optional slider.
!


!VariableBlockMorph methodsFor: 'initialization' stamp: 'jm 2/23/2004 11:07'!
initialize

	super initialize.
	commandSpec _ ''.
	self color: (Color r: 0.4 g: 1.0 b: 0.4).
! !


!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 1/9/2006 12:34'!
helpScreenName
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	^ 'variable'
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 2/23/2004 11:07'!
isReporter

	^ true
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 7/3/2008 15:57'!
receiver: anObject
	"Set my receiver object and, if possible, my block color."

	receiver _ anObject.
	(receiver respondsTo: #variableBlockColor)
		ifTrue: [self color: receiver variableBlockColor].
! !

!VariableBlockMorph methodsFor: 'accessing' stamp: 'jm 12/13/2006 20:12'!
variable

	^ commandSpec
! !


!VariableBlockMorph methodsFor: 'evaluation' stamp: 'EMP 4/26/2016 16:17'!
evaluateInStackFrame: t1 
	^ self evaluateWithArgs: nil! !

!VariableBlockMorph methodsFor: 'evaluation' stamp: 'jm 11/15/2006 11:38'!
evaluateWithArgs: args
	"Overridden to read my variable value."

	^ receiver getVar: commandSpec
! !


!VariableBlockMorph methodsFor: 'watcher' stamp: 'TIS 6/19/2006 13:52'!
canBecomeWatcher
	"All variable blocks can become watchers when dragged onto the stage."

	^ true! !

!VariableBlockMorph methodsFor: 'watcher' stamp: 'jm 11/30/2007 19:23'!
createWatcher
	"Return a new watcher for me."

	| newWatcher |
	newWatcher _ WatcherMorph new setCategoryColor: self color.
	newWatcher target: receiver selector: #getVar: parameter: commandSpec.

	^ newWatcher
! !

!VariableBlockMorph methodsFor: 'watcher' stamp: 'jm 11/30/2007 12:26'!
selectorAndArg
	"Answer an array containing my selector and argument (if any)."

	^ Array with: #getVar: with: self variable
! !


!VariableBlockMorph methodsFor: 'object i/o' stamp: 'jm 2/24/2004 18:24'!
fieldsVersion

	^ 1
! !


!VariableBlockMorph methodsFor: 'private' stamp: 'jens 11/18/2008 09:40'!
addLabel
	"Add a label for my command and arguments. 
	This is the method that really creates the whole block."
	"Details: This overrides the superclass method to allow 
	using percent character in variable/list names"

	commandSpec ifNil: [^ self].
	self removeAllMorphs.
	self addMorphBack: (self labelMorphFor: commandSpec).
! !

!VariableBlockMorph methodsFor: 'private' stamp: 'jm 3/23/2005 10:57'!
asBlockTuple
	"Answer a tuple (Array) describing this block and its arguments."

	^ Array with: #readVariable with: commandSpec
! !

!VariableBlockMorph methodsFor: 'private' stamp: 'EMP 12/12/2015 11:37'!
delVar
	(DialogBoxMorph ask: '' title: ('Delete ' , self commandSpec, '?')) ifTrue: [self receiver deleteVariableOwned: (self commandSpec)]! !

!VariableBlockMorph methodsFor: 'private' stamp: 'EMP 12/12/2015 12:18'!
rename
	| newName |
	newName _ (StringDialog askWithCancel: 'New name: ' initialAnswer: (self commandSpec) title: ('Rename ', self commandSpec)).
	newName = '' ifTrue: [^ self]. newName = #cancelled ifTrue: [^ self].
	newName = (self commandSpec) ifTrue: [^ self].
	(self receiver allVarNames includes: newName) ifTrue: [DialogBoxMorph inform: 'That name is already in use.' title: 'Cannot rename'].

	self receiver bindVar: (self commandSpec) to: (newName) fromBlock: self.! !

!VariableBlockMorph methodsFor: 'private' stamp: 'EMP 4/13/2016 15:42'!
rightButtonMenu

	| menu sFrame choice spec |
	isMobile ifFalse: [^ (self ownerThatIsA: ProcedureHatBlockMorph) rightButtonMenu].
	menu _ CustomMenu new color: (self color lighter lighter).

	(owner isKindOf: ScratchBlockPaletteMorph) 
	ifTrue: 
	[
	menu add: 'rename variable' action: #rename.
	menu add: 'delete variable' action: #delVar.
	menu addLine.
	menu add: 'help' action: #presentHelpScreen.
	]
	
	ifFalse: [
		(#(+ - * / \\) includes: selector) ifTrue: [
			#(+ - * / mod) with: #(+ - * / \\) do: [:s :op | menu add: s action: op]].
		(#(< = >) includes: selector) ifTrue: [
			#(< = >) do: [:op | menu add: op action: op]].
		(#(& |) includes: selector) ifTrue: [
			#(and or) with: #(& |) do: [:s :op | menu add: s action: op]].

		menu addLine.
		menu add: 'duplicate' action: #duplicate.
		(self owner isKindOf: BlockMorph) ifFalse: [  "can't yet delete a blocks inside a script"
			menu add: 'delete' action: #delete].
		menu addLine.
		menu add: 'add comment' action: #addComment.
		menu add: 'help' action: #presentHelpScreen.].

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
	(#(presentHelpScreen duplicate delete rename delVar addComment) includes: choice) ifTrue: [^ self perform: choice].
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
