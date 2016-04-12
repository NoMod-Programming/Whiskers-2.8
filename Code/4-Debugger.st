CodeHolder subclass: #Debugger
	instanceVariableNames: 'interruptedProcess interruptedController contextStack contextStackTop contextStackIndex contextStackList receiverInspector contextVariablesInspector externalInterrupt proceedValue selectingPC sourceMap tempNames savedCursor '
	classVariableNames: 'ContextStackKeystrokes ErrorRecursion '
	poolDictionaries: ''
	category: 'Tools-Debugger'!
!Debugger commentStamp: '<historical>' prior: 0!
I represent the machine state at the time of an interrupted process. I also represent a query path into the state of the process. The debugger is typically viewed through a window that views the stack of suspended contexts, the code for, and execution point in, the currently selected message, and inspectors on both the receiver of the currently selected message, and the variables in the current context.

Special note on recursive errors:
Some errors affect Squeak's ability to present a debugger.  This is normally an unrecoverable situation.  However, if such an error occurs in an isolation layer, Squeak will attempt to exit from the isolation layer and then present a debugger.  Here is the chain of events in such a recovery.

	* A recursive error is detected.
	* The current project is queried for an isolationHead
	* Changes in the isolationHead are revoked
	* The parent project of isolated project is returned to
	* The debugger is opened there and execution resumes.

If the user closes that debugger, execution continues in the outer project and layer.  If, after repairing some damage, the user proceeds from the debugger, then the isolationHead is re-invoked, the failed project is re-entered, and execution resumes in that world. !


!Debugger methodsFor: 'initialize' stamp: 'sbw 12/23/1999 10:00'!
buildMVCDebuggerViewLabel: aString minSize: aPoint

	| topView stackListView stackCodeView rcvrVarView rcvrValView ctxtVarView ctxtValView deltaY underPane annotationPane buttonsView |
	self expandStack.
	topView _ StandardSystemView new model: self.
	topView borderWidth: 1.
	stackListView _ PluggableListView on: self
			list: #contextStackList
			selected: #contextStackIndex
			changeSelected: #toggleContextStackIndex:
			menu: #contextStackMenu:shifted:
			keystroke: #contextStackKey:from:.
		stackListView menuTitleSelector: #messageListSelectorTitle.
		stackListView window: (0 @ 0 extent: 150 @ 50).
		topView addSubView: stackListView.
	deltaY _ 0.
	Preferences useAnnotationPanes
		ifTrue:
			[annotationPane _ PluggableTextView on: self
				text: #annotation accept: nil readSelection: nil menu: nil.
			annotationPane window: (0@0 extent: 150@self optionalAnnotationHeight).
			topView addSubView: annotationPane below: stackListView.
			deltaY _ deltaY + self optionalAnnotationHeight.
			underPane _ annotationPane]
		ifFalse:
			[underPane _ stackListView].
	Preferences optionalButtons ifTrue:
			[buttonsView _ self buildMVCOptionalButtonsButtonsView.
			buttonsView borderWidth: 1.
			topView addSubView: buttonsView below: underPane.
			underPane _ buttonsView.
			deltaY _ deltaY + self optionalButtonHeight].
	stackCodeView _ PluggableTextView on: self
			text: #contents accept: #contents:notifying:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:.
		stackCodeView window: (0 @ 0 extent: 150 @ (75 - deltaY)).
		topView addSubView: stackCodeView below: underPane.
	rcvrVarView _ PluggableListView on: self receiverInspector
			list: #fieldList
			selected: #selectionIndex
			changeSelected: #toggleIndex:
			menu: #fieldListMenu:
			keystroke: #inspectorKey:from:.
		rcvrVarView window: (0 @ 0 extent: 25 @ (50 - deltaY)).
		topView addSubView: rcvrVarView below: stackCodeView.
	rcvrValView _ PluggableTextView on: self receiverInspector
			text: #contents accept: #accept:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:.
		rcvrValView window: (0 @ 0 extent: 50 @ (50 - deltaY)).
		topView addSubView: rcvrValView toRightOf: rcvrVarView.
	ctxtVarView _ PluggableListView on: self contextVariablesInspector
			list: #fieldList
			selected: #selectionIndex
			changeSelected: #toggleIndex:
			menu: #fieldListMenu:
			keystroke: #inspectorKey:from:.
		ctxtVarView window: (0 @ 0 extent: 25 @ (50 - deltaY)).
		topView addSubView: ctxtVarView toRightOf: rcvrValView.
	ctxtValView _ PluggableTextView on: self contextVariablesInspector
			text: #contents accept: #accept:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:.
		ctxtValView window: (0 @ 0 extent: 50 @ (50 - deltaY)).
		topView addSubView: ctxtValView toRightOf: ctxtVarView.
	topView label: aString.
	topView minimumSize: aPoint.
	^ topView! !

!Debugger methodsFor: 'initialize' stamp: 'sw 12/28/1999 13:12'!
buildMVCNotifierButtonView

	| aView bHeight priorButton buttonView |
	aView _ View new model: self.
	bHeight _ self notifierButtonHeight.
	aView window: (0@0 extent: 350@bHeight).
	priorButton _ nil.
	self preDebugButtonQuads do:
		[:aSpec |
			buttonView _ PluggableButtonView
				on: self
				getState: nil
				action: aSpec second..
			buttonView
				label: aSpec first;
				insideColor: (Color perform: aSpec third) muchLighter lighter;
				borderWidthLeft: 1 right: 1 top: 0 bottom: 0;
				window: (0@0 extent: 117@bHeight).
			priorButton
				ifNil:
					[aView addSubView: buttonView]
				ifNotNil:
					[aView addSubView: buttonView toRightOf: priorButton].
			priorButton _ buttonView].
	^ aView! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/23/1999 08:36'!
buildMVCNotifierViewLabel: aString message: messageString minSize: aPoint

	| topView aStringHolderView buttonView x y bHeight |
	topView _ StandardSystemView new model: self.
	topView borderWidth: 1.
	buttonView _ self buildMVCNotifierButtonView.
	topView addSubView: buttonView.
	aStringHolderView _ PluggableTextView on: self
		text: #contents
		accept: #doNothing:
		readSelection: #contentsSelection
		menu: #debugProceedMenu:.
	aStringHolderView
		editString: messageString;
		askBeforeDiscardingEdits: false.
	x _ 350 max: (aPoint x).
	y _ ((4 * 15) + 16) max: (aPoint y - 16 - self optionalButtonHeight).
	bHeight _ self optionalButtonHeight.
	y _ y - bHeight.
	aStringHolderView window: (0@0 extent: x@y).
	topView
		addSubView: aStringHolderView below: buttonView;
		label: aString;
		minimumSize: aPoint.
	^ topView! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/28/1999 11:38'!
buildMVCOptionalButtonsButtonsView

	| aView bHeight offset aButtonView wid pairs windowWidth previousView |
	aView _ View new model: self.
	bHeight _ self optionalButtonHeight.
	windowWidth _ 150.
	aView window: (0@0 extent: windowWidth@bHeight).
	offset _ 0.
	pairs _ self optionalButtonPairs.
	previousView _ nil.
	pairs do: [:pair |
		aButtonView _ PluggableButtonView on: self getState: nil action: pair last.
		pair last = pairs last last
			ifTrue:
				[wid _ windowWidth - offset]
			ifFalse:
				[aButtonView borderWidthLeft: 0 right: 1 top: 0 bottom: 0.
				wid _ windowWidth // (pairs size)].
		aButtonView
			label: pair first asParagraph;
			insideColor: Color red muchLighter lighter;
			window: (offset@0 extent: wid@bHeight).
		offset _ offset + wid.
		pair last = pairs first last
			ifTrue: [aView addSubView: aButtonView]
			ifFalse: [aView addSubView: aButtonView toRightOf: previousView].
		previousView _ aButtonView].
	^ aView! !

!Debugger methodsFor: 'initialize' stamp: 'tk 1/3/2000 12:57'!
buildMorphicNotifierLabelled: label message: messageString
	| notifyPane window contentTop extentV |
	window _ (PreDebugWindow labelled: label) model: self.

	"Preferences optionalMorphicButtons" true
		ifTrue:
			[contentTop _ 0.2.
			window addMorph: (self buttonRowForPreDebugWindow: window)
				frame: (0@0 corner: 1 @ contentTop).
			extentV _ 156]
		ifFalse:
			[extentV _ 116.
			contentTop _ 0].
	notifyPane _ PluggableTextMorph on: self text: nil accept: nil
		readSelection: nil menu: #debugProceedMenu:.
	notifyPane editString: messageString; askBeforeDiscardingEdits: false.
	window addMorph: notifyPane frame: (0@contentTop corner: 1@1).

	^ window openInWorldExtent: 450 @ extentV! !

!Debugger methodsFor: 'initialize' stamp: 'EMP 1/7/2016 11:41'!
buildMorphicNotifierNoButtonsLabelled: label message: messageString
	| notifyPane window contentTop extentV |
	window _ (PreDebugWindow labelled: label) model: self.
	"Preferences optionalMorphicButtons" false "We don't want the user to be able to debug. Just dump a stack to a file the end-user can read"
		ifTrue:
			[contentTop _ 0.2.
			window addMorph: (self buttonRowForPreDebugWindow: window)
				frame: (0@0 corner: 1 @ contentTop).
			extentV _ 156]
		ifFalse:
			[extentV _ 260.
			contentTop _ 0].
	notifyPane _ PluggableTextMorph on: self text: nil accept: nil
		readSelection: nil menu: nil.
	notifyPane editString: messageString; askBeforeDiscardingEdits: false.
	window addMorph: notifyPane frame: (0@contentTop corner: 1@1).
	self writeDebugLog: messageString title: label.
	^ window openInWorldExtent: 450 @ extentV! !

!Debugger methodsFor: 'initialize' stamp: 'jm 6/5/2003 18:27'!
buttonRowForPreDebugWindow: aDebugWindow

	| aRow aButton |
	aRow _ AlignmentMorph newRow hResizing: #spaceFill.
	aRow isSticky: true.
	aButton _ SimpleButtonMorph new target: aDebugWindow.
	aButton color: Color transparent; borderWidth: 1.
	aRow addMorphBack: (AlignmentMorph newSpacer: self defaultBackgroundColor).
	self preDebugButtonQuads do:
			[:quad |
				aButton _ aButton fullCopy.
				aButton actionSelector: quad second.
				aButton label: quad first.
				aButton submorphs first color: (Color colorFrom: quad third).
				aButton setBalloonText: quad fourth.
				aRow addMorphBack: aButton.
				aRow addMorphBack: (AlignmentMorph newSpacer: self defaultBackgroundColor)].
	^ aRow
! !

!Debugger methodsFor: 'initialize' stamp: 'sw 12/28/1999 13:07'!
notifierButtonHeight

	^ 18! !

!Debugger methodsFor: 'initialize' stamp: 'sw 1/12/2000 16:47'!
openFullMorphicLabel: labelString
	| window aListMorph codeTop aTextMorph |
	self expandStack.
	window _ (SystemWindow labelled: labelString) model: self.
	aListMorph _ PluggableListMorph on: self list: #contextStackList
			selected: #contextStackIndex changeSelected: #toggleContextStackIndex:
			menu: #contextStackMenu:shifted: keystroke: #contextStackKey:from:.
	aListMorph menuTitleSelector: #messageListSelectorTitle.
	window addMorph: aListMorph
		frame: (0@0 corner: 1@0.3).

	Preferences useAnnotationPanes
		ifFalse:
			[codeTop _ 0.3]
		ifTrue:
			[aTextMorph _ PluggableTextMorph on: self
					text: #annotation accept: nil
					readSelection: nil menu: nil.
			aTextMorph askBeforeDiscardingEdits: false.
			window addMorph: aTextMorph
				frame: (0@0.3 corner: 1@0.35).
			codeTop _ 0.35].

	Preferences optionalButtons ifTrue:
		[window addMorph: self optionalButtonRow frame: ((0@codeTop corner: 1 @ (codeTop + 0.1))).
		codeTop _ codeTop + 0.1].
	window addMorph: (PluggableTextMorph on: self
			text: #contents accept: #contents:notifying:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:)
		frame: (0 @ codeTop corner: 1 @ 0.7).
	window addMorph: ((PluggableListMorph on: self receiverInspector list: #fieldList
			selected: #selectionIndex changeSelected: #toggleIndex:
			menu: #fieldListMenu: keystroke: #inspectorKey:from:) doubleClickSelector: #inspectSelection)
		frame: (0@0.7 corner: 0.2@1).
	window addMorph: (PluggableTextMorph on: self receiverInspector
			text: #contents accept: #accept:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:)
		frame: (0.2@0.7 corner: 0.5@1).
	window addMorph: ((PluggableListMorph on: self contextVariablesInspector list: #fieldList
			selected: #selectionIndex changeSelected: #toggleIndex:
			menu: #fieldListMenu: keystroke: #inspectorKey:from:) doubleClickSelector: #inspectSelection)
		frame: (0.5@0.7 corner: 0.7@1).
	window addMorph: (PluggableTextMorph on: self contextVariablesInspector
			text: #contents accept: #accept:
			readSelection: #contentsSelection menu: #codePaneMenu:shifted:)
		frame: (0.7@0.7 corner: 1@1).

	^ window openInWorld! !

!Debugger methodsFor: 'initialize' stamp: 'ls 3/5/2000 14:20'!
openFullNoSuspendLabel: aString
	"Create and schedule a full debugger with the given label. Do not terminate the current active process."

	| topView |
	Smalltalk isMorphic ifTrue:
		[self openFullMorphicLabel: aString.
		^ Project current spawnNewProcessIfThisIsUI: interruptedProcess].
	topView _ self buildMVCDebuggerViewLabel: aString minSize: 300@200.
	topView controller openNoTerminate.
	^ topView
! !

!Debugger methodsFor: 'initialize' stamp: 'EMP 1/7/2016 12:07'!
openNotifierContents: msgString label: label
	"Create and schedule a notifier view with the given label and message. A notifier view shows just the message or the first several lines of the stack, with a menu that allows the user to open a full debugger if so desired."
	"NOTE: When this method returns, a new process has been scheduled to run the windows, and thus this notifier, but the previous active porcess has not been suspended.  The sender will do this."
	| msg topView p lowSpace |
	Sensor flushKeyboard.
	savedCursor _ Cursor currentCursor.
	Cursor normal show.
	msg _ msgString.
	lowSpace _ false.
	(label asString beginsWith: 'Space is low') ifTrue: [lowSpace _ true. msg _ self lowSpaceChoices, msgString].

	Smalltalk isMorphic
		ifTrue:
			[Preferences noviceMode ifTrue: [lowSpace ifTrue: [self buildMorphicNotifierNoButtonsLabelled: label message: msg]] ifFalse: [self buildMorphicNotifierLabelled: label message: msg].
			^ Project current spawnNewProcessIfThisIsUI: interruptedProcess].

	Display fullScreen.
	topView _ self buildMVCNotifierViewLabel: label message: msg minSize: 350@((14 * 5) + 16 + self optionalButtonHeight).
	ScheduledControllers activeController
		ifNil: [p _ Display boundingBox center]
		ifNotNil: [p _ ScheduledControllers activeController view displayBox center].
	topView controller openNoTerminateDisplayAt: (p max: (200@60)).

	^ topView! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/23/1999 09:50'!
optionalAnnotationHeight

	^ 10! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/23/1999 08:31'!
optionalButtonHeight

	^ 10! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/23/1999 09:28'!
optionalButtonPairs

	^ #(('Proceed'		proceed)
		('Restart'		restart)
		('Send'			send)
		('Step'			doStep)
		('Full Stack'		fullStack)
		('Where'		where)
		('Browse'		browseMethodFull))! !

!Debugger methodsFor: 'initialize' stamp: 'jm 10/13/2002 18:05'!
optionalButtonRow
	| aRow aButton |
	aRow _ AlignmentMorph newRow.
	aRow isSticky: true.
	aRow setProperty: #clipToOwnerWidth toValue: true.
	aButton _ SimpleButtonMorph new target: self.
	aButton color: Color lightRed; borderWidth: 1; borderColor: Color red darker.
	aRow addTransparentSpacerOfSize: (5@0).
	self optionalButtonPairs do:
		[:pair |
				aButton _ PluggableButtonMorph
					on: self
					getState: nil
					action: pair second.
				aButton useRoundedCorners;
					label: pair first asString;
					askBeforeChanging: true;
					onColor: Color transparent offColor: Color transparent.
				aRow addMorphBack: aButton.
				aRow addTransparentSpacerOfSize: (3 @ 0)].
	^ aRow! !

!Debugger methodsFor: 'initialize' stamp: 'sbw 12/22/1999 16:20'!
preDebugButtonQuads

	^ #(('Proceed'		proceed 	blue 	'continue execution' )
		('Abandon'		abandon 	black 	'close this window')
		('Debug'		debug 		red 		'bring up a debugger'))! !

!Debugger methodsFor: 'initialize' stamp: 'jm 8/20/1998 18:31'!
release

	self windowIsClosing.
	super release.
! !

!Debugger methodsFor: 'initialize' stamp: 'jm 8/20/1998 18:30'!
windowIsClosing
	"My window is being closed; clean up. Restart the low space watcher."

	interruptedProcess == nil ifTrue: [^ self].
	interruptedProcess terminate.
	interruptedProcess _ nil.
	interruptedController _ nil.
	contextStack _ nil.
	contextStackTop _ nil.
	receiverInspector _ nil.
	contextVariablesInspector _ nil.
	Smalltalk installLowSpaceWatcher.  "restart low space handler"
! !


!Debugger methodsFor: 'accessing' stamp: 'di 10/9/1998 17:15'!
contents 
	"Depending on the current selection, different information is retrieved.
	Answer a string description of that information.  This information is the
	method in the currently selected context."

	contents == nil ifTrue: [^ String new].
	^ contents copy! !

!Debugger methodsFor: 'accessing' stamp: 'tk 12/6/97 21:31'!
contents: aText notifying: aController 
	"The retrieved information has changed and its source must now be 
	updated. In this case, the retrieved information is the method of the 
	selected context."
	| selector classOfMethod category method priorMethod parseNode |
	contextStackIndex = 0 ifTrue: [^self].
	(self selectedContext isKindOf: MethodContext)
		ifFalse:
			[(self confirm:
'I will have to revert to the method from
which this block originated.  Is that OK?')
				ifTrue: [self resetContext: self selectedContext home]
				ifFalse: [^self]].
	classOfMethod _ self selectedClass.
	category _ self selectedMessageCategoryName.
	Cursor execute showWhile:
		[method _ classOfMethod
		compile: aText
		notifying: aController
		trailer: #(0 0 0 0)
		ifFail: [^ false]
		elseSetSelectorAndNode: 
			[:sel :methodNode | selector _ sel.
			selector == self selectedMessageName
				ifFalse: [self notify: 'can''t change selector'. ^ false].
			priorMethod _ (classOfMethod includesSelector: selector)
				ifTrue: [classOfMethod compiledMethodAt: selector]
				ifFalse: [nil].
			sourceMap _ methodNode sourceMap.
			tempNames _ methodNode tempNames.
			parseNode _ methodNode].
		method cacheTempNames: tempNames].
	category isNil ifFalse: "Skip this for DoIts"
		[method putSource: aText
				fromParseNode: parseNode
				class: classOfMethod
				category: category
				inFile: 2 priorMethod: priorMethod.
		classOfMethod organization classify: selector under: category].
	contents _ aText copy.
	self selectedContext restartWith: method.
	contextVariablesInspector object: nil.
	self resetContext: self selectedContext.
	^true! !

!Debugger methodsFor: 'accessing'!
contextVariablesInspector
	"Answer the instance of Inspector that is providing a view of the 
	variables of the selected context."

	^contextVariablesInspector! !

!Debugger methodsFor: 'accessing' stamp: 'tk 4/16/1998 12:16'!
doNothing: newText
	"Notifier window can't accept text"! !

!Debugger methodsFor: 'accessing'!
interruptedContext
	"Answer the suspended context of the interrupted process."

	^contextStackTop! !

!Debugger methodsFor: 'accessing'!
interruptedProcess
	"Answer the interrupted process."

	^interruptedProcess! !

!Debugger methodsFor: 'accessing' stamp: 'tk 4/16/1998 15:47'!
isNotifier
	"Return true if this debugger has not been expanded into a full sized window"

	^ receiverInspector == nil! !

!Debugger methodsFor: 'accessing'!
proceedValue
	"Answer the value to return to the selected context when the interrupted 
	process proceeds."

	^proceedValue! !

!Debugger methodsFor: 'accessing'!
proceedValue: anObject 
	"Set the value to be returned to the selected context when the interrupted 
	process proceeds."

	proceedValue _ anObject! !

!Debugger methodsFor: 'accessing'!
receiver
	"Answer the receiver of the selected context, if any. Answer nil 
	otherwise."

	contextStackIndex = 0
		ifTrue: [^nil]
		ifFalse: [^self selectedContext receiver]! !

!Debugger methodsFor: 'accessing'!
receiverInspector
	"Answer the instance of Inspector that is providing a view of the 
	variables of the selected context's receiver."

	^receiverInspector! !

!Debugger methodsFor: 'accessing' stamp: 'EMP 1/7/2016 12:05'!
writeDebugLog: message title: titleString
	| s |
	s _ (FileStream oldFileNamed: 'report.log').
	s setToEnd.
	s nextPutAll: 'Timestamp: ', (Date today printString); crlf.
	s nextPutAll: 'Version: ' , ScratchFrameMorph versionDate; crlf.
	s nextPutAll: 'Image Location: ', Smalltalk imageName; crlf.
	s nextPutAll: 'VM Location: ', Smalltalk vmPath; crlf.
	s nextPutAll: 'BUG: '; crlf.
	s nextPutAll: titleString asString; crlf; crlf; nextPutAll: message asString; crlf; nextPutAll: '-------------------------------------------------------------------------------------------------------------'; crlf.
	s finalize.! !


!Debugger methodsFor: 'notifier menu' stamp: 'sma 4/30/2000 09:24'!
debug
	"Open a full DebuggerView."
	| topView |
	topView _ self topView.
	topView model: nil.  "so close won't release me."
	Smalltalk isMorphic
		ifTrue:
			[self breakDependents.
			self openFullMorphicLabel: topView label.
			^ topView delete].
	topView controller controlTerminate.
	topView deEmphasizeView; erase.
	self openFullNoSuspendLabel: topView label.
	topView controller closeAndUnscheduleNoErase.
	Processor terminateActive.
! !


!Debugger methodsFor: 'context stack (message list)'!
contextStackIndex
	"Answer the index of the selected context."

	^contextStackIndex! !

!Debugger methodsFor: 'context stack (message list)'!
contextStackList
	"Answer the array of contexts."

	^contextStackList! !

!Debugger methodsFor: 'context stack (message list)' stamp: 'tk 4/17/1998 18:05'!
expandStack
	"A Notifier is being turned into a full debugger.  Show a substantial amount of stack in the context pane."

	self newStack: (contextStackTop stackOfSize: 20).
	contextStackIndex _ 0.
	receiverInspector _ Inspector inspect: nil.
	contextVariablesInspector _ ContextVariablesInspector inspect: nil.
	proceedValue _ nil! !

!Debugger methodsFor: 'context stack (message list)'!
fullyExpandStack
	"Expand the stack to include all of it, rather than the first four or five
	contexts."

	self okToChange ifFalse: [^ self].
	self newStack: contextStackTop stack.
	self changed: #contextStackList! !

!Debugger methodsFor: 'context stack (message list)'!
messageListIndex
	"Answer the index of the currently selected context."

	^contextStackIndex! !

!Debugger methodsFor: 'context stack (message list)' stamp: 'sw 11/6/1999 22:58'!
selectedMessage
	"Answer the source code of the currently selected context."
	contents _ [self selectedContext sourceCode] ifError: [ :err :rcvr |
		'ERROR
"',(err reject: [ :each | each == $"]),'"'
	].
	Preferences browseWithPrettyPrint ifTrue: [contents _ self selectedClass compilerClass new
					format: contents
					in: self selectedClass
					notifying: nil
					decorated: Preferences colorWhenPrettyPrinting].
	^ contents _ contents asText makeSelectorBoldIn: self selectedClass! !

!Debugger methodsFor: 'context stack (message list)'!
selectedMessageName
	"Answer the message selector of the currently selected context."

	^self selectedContext selector! !

!Debugger methodsFor: 'context stack (message list)' stamp: 'tk 4/6/98 23:00'!
spawn: aString 
	"Create and schedule a message browser on the message, aString. Any 
	edits already made are retained."

	self messageListIndex > 0
		ifTrue: 
			[^Browser
				openMessageBrowserForClass: self selectedClass
				selector: self selectedMessageName
				editString: aString]! !

!Debugger methodsFor: 'context stack (message list)'!
toggleContextStackIndex: anInteger 
	"If anInteger is the same as the index of the selected context, deselect it. 
	Otherwise, the context whose index is anInteger becomes the selected 
	context."

	self contextStackIndex: 
		(contextStackIndex = anInteger
			ifTrue: [0]
			ifFalse: [anInteger])
		oldContextWas:
		(contextStackIndex = 0
			ifTrue: [nil]
			ifFalse: [contextStack at: contextStackIndex])! !


!Debugger methodsFor: 'context stack menu' stamp: 'sw 12/28/1999 13:04'!
abandon
	"abandon the debugger from its pre-debug notifier"
	self abandon: self topView! !

!Debugger methodsFor: 'context stack menu' stamp: 'sw 12/28/1999 13:05'!
abandon: aTopView 
	"abandon the notifier represented by aTopView"
	aTopView controller close! !

!Debugger methodsFor: 'context stack menu' stamp: 'wod 5/15/1998 00:24'!
browseMessages
	"Present a menu of all messages sent by the currently selected message.
	Open a message set browser of all implementors of the message chosen.
	Do nothing if no message is chosen."

	contextStackIndex = 0 ifTrue: [^ self].
	super browseMessages.! !

!Debugger methodsFor: 'context stack menu' stamp: 'wod 5/15/1998 00:23'!
browseSendersOfMessages
	"Present a menu of the currently selected message, as well as all
	messages sent by it.  Open a message set browser of all implementors
	of the message chosen."

	contextStackIndex = 0 ifTrue: [^ self].
	super browseSendersOfMessages! !

!Debugger methodsFor: 'context stack menu' stamp: 'sw 10/12/1999 17:41'!
browseVersions
	"Create and schedule a message set browser on all versions of the 
	currently selected message selector."
	| class selector |
	class _ self selectedClassOrMetaClass.
	selector _ self selectedMessageName.
	VersionsBrowser
		browseVersionsOf: (class compiledMethodAt: selector)
		class: self selectedClass
		meta: self selectedClass isMeta
		category: self selectedMessageCategoryName
		selector: selector! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/6/98 23:00'!
buildMessageBrowser
	"Create and schedule a message browser on the current method."

	contextStackIndex = 0 ifTrue: [^ self].
	^ Browser
		openMessageBrowserForClass: self selectedClassOrMetaClass
		selector: self selectedMessageName
		editString: nil! !

!Debugger methodsFor: 'context stack menu'!
close: aScheduledController 
	"The argument is a controller on a view of the receiver.
	That view is closed."

	aScheduledController close
! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/18/1998 09:24'!
contextStackKey: aChar from: view
	"Respond to a keystroke in the context list"

 	| selector |
	selector _ ContextStackKeystrokes at: aChar ifAbsent: [nil].
	selector ifNil: [self messageListKey: aChar from: view]
		ifNotNil: [self perform: selector]! !

!Debugger methodsFor: 'context stack menu' stamp: 'sw 5/8/2000 03:02'!
contextStackMenu: aMenu shifted: shifted
	^ shifted ifFalse: [aMenu labels: 
'fullStack (f)
restart (r)
proceed (p)
step (t)
send (e)
where (w)
peel to first like this
senders of... (n)
implementors of... (m)
inheritance (i)
versions (v)
inst var refs...
inst var defs...
class var refs...
class variables
class refs (N)
browse full (b)
file out 
more...'
	lines: #(7 11 13 16 18)
	selections: #(fullStack restart proceed doStep send where peelToFirst
browseSendersOfMessages browseMessages methodHierarchy browseVersions
browseInstVarRefs browseInstVarDefs
browseClassVarRefs browseClassVariables browseClassRefs
browseMethodFull fileOutMessage
shiftedYellowButtonActivity)]

	ifTrue: [aMenu labels: 
'browse class hierarchy
browse class
browse method (O)
implementors of sent messages
change sets with this method
inspect instances
inspect subinstances
revert to previous version
remove from current change set
revert and forget
more...' 
	lines: #(5 7 10)
	selections: #(classHierarchy browseClass 
		openSingleMessageBrowser browseAllMessages findMethodInChangeSets 
		inspectInstances inspectSubInstances
		revertToPreviousVersion 
		removeFromCurrentChanges revertAndForget
		unshiftedYellowButtonActivity)]

! !

!Debugger methodsFor: 'context stack menu' stamp: 'sw 8/6/97 13:45'!
currentCompiledMethod
	^ self selectedClassOrMetaClass compiledMethodAt: self selectedMessageName! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/16/1998 12:19'!
debugProceedMenu: aMenu
	^ aMenu labels: 
'proceed
debug'
	lines: #()
	selections: #(proceed debug )
! !

!Debugger methodsFor: 'context stack menu' stamp: 'di 1/14/1999 09:18'!
doStep
	"Send the selected message in the accessed method, and regain control 
	after the invoked method returns."
	
	| currentContext oldMethod |
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	externalInterrupt ifFalse: [contextStackTop push: proceedValue].
	externalInterrupt _ true. "simulation leaves same state as interrupting"
	currentContext _ self selectedContext.
	self contextStackIndex > 1
		ifTrue: 
			[currentContext completeCallee: contextStackTop.
			self resetContext: currentContext]
		ifFalse: 
			[currentContext stepToSendOrReturn.
			currentContext willReturn
				ifTrue: 
					[oldMethod _ currentContext method.
					currentContext _ currentContext step.
					currentContext stepToSendOrReturn.
					self resetContext: currentContext.
					oldMethod == currentContext method "didnt used to update pc here"
						ifTrue: [self changed: #contentsSelection]]
				ifFalse: 
					[currentContext completeCallee: currentContext step.
					self changed: #contentsSelection.
					self updateInspectors]]! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/15/1998 16:55'!
down
	"move down the context stack to the previous (enclosing) context"

	self toggleContextStackIndex: contextStackIndex+1! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/17/1998 18:06'!
fullStack
	"Change from displaying the minimal stack to a full one."

	self contextStackList size > 20 "Already expanded"
		ifTrue:
			[self changed: #flash]
		ifFalse:
			[self contextStackIndex = 0 ifFalse: [
				self toggleContextStackIndex: self contextStackIndex].
			self fullyExpandStack]! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 7/18/1999 23:01'!
peelToFirst
	"Peel the stack back to the second occurance of the currently selected message.  Very useful for an infinite recursion.  Gets back to the second call so you can see one complete recursion cycle, and how it was called at the beginning.  Also frees a lot of space!!"

	| upperGuy meth second |
	contextStackIndex = 0 ifTrue: [^ self beep].
	"self okToChange ifFalse: [^ self]."
	upperGuy _ contextStack at: contextStackIndex.
	meth _ upperGuy method.
	contextStackIndex+1 to: contextStack size do: [:ind |
		(contextStack at: ind) method == meth ifTrue: [
			second _ upperGuy.
			upperGuy _ contextStack at: ind]].
	second ifNil: [second _ upperGuy].
	self resetContext: second.
	interruptedProcess popTo: self selectedContext.! !

!Debugger methodsFor: 'context stack menu' stamp: 'di 5/5/1998 00:07'!
proceed
	"Proceed execution of the receiver's model, starting after the expression at 
	which an interruption occurred."

	Smalltalk okayToProceedEvenIfSpaceIsLow ifTrue: [
		self proceed: self topView].
! !

!Debugger methodsFor: 'context stack menu' stamp: 'di 5/5/1998 00:07'!
proceed: aTopView 
	"Proceed from the interrupted state of the currently selected context. The 
	argument is the topView of the receiver. That view is closed."

	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	contextStackIndex > 1 | externalInterrupt not 
		ifTrue: [self selectedContext push: proceedValue].
	self resumeProcess: aTopView! !

!Debugger methodsFor: 'context stack menu' stamp: 'di 5/5/1998 00:08'!
restart
	"Proceed execution of the receiver's model, starting at the beginning of 
	the currently selected method."

	self restart: self topView.
! !

!Debugger methodsFor: 'context stack menu' stamp: 'di 5/5/1998 00:08'!
restart: aTopView 
	"Proceed from the initial state of the currently selected context. The 
	argument is a controller on a view of the receiver. That view is closed."

	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	(self selectedContext isKindOf: MethodContext)
		ifFalse:
			[(self confirm:
'I will have to revert to the method from
which this block originated.  Is that OK?')
				ifTrue: [self resetContext: self selectedContext home]
				ifFalse: [^self]].
	self selectedContext restart.
	self resumeProcess: aTopView! !

!Debugger methodsFor: 'context stack menu'!
selectPC
	"Toggle the flag telling whether to automatically select the expression 
	currently being executed by the selected context."

	selectingPC _ selectingPC not! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/16/1998 11:36'!
send
	"Send the selected message in the accessed method, and take control in 
	the method invoked to allow further step or 
send."

	| currentContext |
	"Sensor leftShiftDown ifTrue: [self halt]."
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	externalInterrupt ifFalse: [contextStackTop push: proceedValue].
	externalInterrupt _ true. "simulation leaves same state as interrupting"
	currentContext _ self selectedContext.
	currentContext stepToSendOrReturn.
	self contextStackIndex > 1 | currentContext willReturn
		ifTrue: 
			[self changed: #notChanged]
		ifFalse: 
			[currentContext _ currentContext step.
			currentContext stepToSendOrReturn.
			self resetContext: currentContext]! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/15/1998 16:55'!
up
	"move up the context stack to the next (enclosed) context"

	contextStackIndex > 1 ifTrue: [self toggleContextStackIndex: contextStackIndex-1]! !

!Debugger methodsFor: 'context stack menu' stamp: 'tk 4/15/1998 16:54'!
where
	"Select the expression whose evaluation was interrupted."

	self selectPC! !


!Debugger methodsFor: 'code pane' stamp: 'tk 4/15/1998 18:31'!
contentsSelection

	^ self pcRange! !

!Debugger methodsFor: 'code pane'!
doItContext
	"Answer the context in which a text selection can be evaluated."

	contextStackIndex = 0
		ifTrue: [^super doItContext]
		ifFalse: [^self selectedContext]! !

!Debugger methodsFor: 'code pane'!
doItReceiver
	"Answer the object that should be informed of the result of evaluating a
	text selection."

	^self receiver! !

!Debugger methodsFor: 'code pane' stamp: 'tk 5/2/1998 10:04'!
pc

	^ self pcRange! !

!Debugger methodsFor: 'code pane' stamp: 'di 9/22/1998 00:21'!
pcRange
	"Answer the indices in the source code for the method corresponding to 
	the selected context's program counter value."

	| i methodNode pc end |
	(selectingPC and: [contextStackIndex ~= 0])
		ifFalse: [^1 to: 0].
	sourceMap == nil ifTrue:
		[methodNode _ self selectedClass compilerClass new
			parse: contents
			in: self selectedClass
			notifying: nil.
		sourceMap _ methodNode sourceMap.
		tempNames _ methodNode tempNames.
		self selectedContext method cacheTempNames: tempNames].
	sourceMap size = 0 ifTrue: [^1 to: 0].
	pc_ self selectedContext pc -
		((externalInterrupt and: [contextStackIndex=1])
			ifTrue: [1]
			ifFalse: [2]).
	i _ sourceMap indexForInserting: (Association key: pc value: nil).
	i < 1 ifTrue: [^1 to: 0].
	i > sourceMap size
		ifTrue:
			[end _ sourceMap inject: 0 into:
				[:prev :this | prev max: this value last].
			^ end+1 to: end].
	^(sourceMap at: i) value! !


!Debugger methodsFor: 'code pane menu' stamp: 'tk 4/17/1998 17:25'!
perform: selector orSendTo: otherTarget
	"Selector was just chosen from a menu by a user.  If can respond, then perform it on myself.  If not, send it to otherTarget, presumably the editPane from which the menu was invoked." 

	| result |
	(#(debug proceed) includes: selector)		"When I am a notifier window"
		ifTrue: [^ self perform: selector]
		ifFalse: [result _ super perform: selector orSendTo: otherTarget.
				selector == #doIt ifTrue: [
					result ~~ #failedDoit ifTrue: [self proceedValue: result]].
				^ result]! !


!Debugger methodsFor: 'message category list'!
selectedMessageCategoryName
	"Answer the name of the message category of the message of the 
	currently selected context."

	^self selectedClass organization categoryOfElement: self selectedMessageName! !


!Debugger methodsFor: 'class list'!
selectedClass
	"Answer the class in which the currently selected context's method was 
	found."

	^self selectedContext mclass! !

!Debugger methodsFor: 'class list'!
selectedClassOrMetaClass
	"Answer the class in which the currently selected context's method was 
	found."

	^self selectedContext mclass! !


!Debugger methodsFor: 'dependents access' stamp: 'di 1/14/1999 09:28'!
step 
	"Update the inspectors."

	receiverInspector ifNotNil: [receiverInspector step].
	contextVariablesInspector ifNotNil: [contextVariablesInspector step].
! !

!Debugger methodsFor: 'dependents access'!
updateInspectors 
	"Update the inspectors on the receiver's variables."

	receiverInspector update.
	contextVariablesInspector update! !

!Debugger methodsFor: 'dependents access' stamp: 'di 1/14/1999 09:25'!
wantsSteps
 
	^ true! !


!Debugger methodsFor: 'private'!
checkContextSelection

	contextStackIndex = 0 ifTrue: [contextStackIndex _ 1]! !

!Debugger methodsFor: 'private' stamp: 'sw 9/23/1999 15:58'!
contextStackIndex: anInteger oldContextWas: oldContext

	| newMethod |
	contextStackIndex _ anInteger.
	anInteger = 0
		ifTrue:
			[tempNames _ sourceMap _ contents _ nil.
			self changed: #contextStackIndex.
			self contentsChanged.
			contextVariablesInspector object: nil.
			receiverInspector object: self receiver.
			^self].
	(newMethod _ oldContext == nil or:
		[oldContext method ~~ self selectedContext method])
		ifTrue:
			[tempNames _ sourceMap _ nil.
			contents _ self selectedMessage.
			self contentsChanged.
			self pcRange "will compute tempNamesunless noFrills"].
	self changed: #contextStackIndex.
	tempNames == nil
		ifTrue: [tempNames _ 
					self selectedClassOrMetaClass parserClass new parseArgsAndTemps: contents notifying: nil].
	contextVariablesInspector object: self selectedContext.
	receiverInspector object: self receiver.
	newMethod ifFalse: [self changed: #contentsSelection]! !

!Debugger methodsFor: 'private'!
externalInterrupt: aBoolean

	externalInterrupt _ aBoolean ! !

!Debugger methodsFor: 'private' stamp: 'jm 5/1/1998 16:20'!
lowSpaceChoices
	"Return a notifier message string to be presented when space is running low."

	^ 'Warning!! Squeak is almost out of memory!!

Low space detection is now disabled. It will be restored when you close or proceed from this error notifier. Don''t panic, but do proceed with caution.

Here are some suggestions:

Ä If you suspect an infinite recursion (the same methods calling each other again and again), then close this debugger, and fix the problem.

Ä If you want this computation to finish, then make more space available (read on) and choose "proceed" in this debugger. Here are some ways to make more space available...
   > Close any windows that are not needed.
   > Get rid of some large objects (e.g., images).
   > Leave this window on the screen, choose "save as..." from the screen menu, quit, restart the Squeak VM with a larger memory allocation, then restart the image you just saved, and choose "proceed" in this window.

Ä If you want to investigate further, choose "debug" in this window.  Do not use the debugger "fullStack" command unless you are certain that the stack is not very deep. (Trying to show the full stack will definitely use up all remaining memory if the low-space problem is caused by an infinite recursion!!).

'
! !

!Debugger methodsFor: 'private'!
newStack: stack
	| oldStack diff |
	oldStack _ contextStack.
	contextStack _ stack.
	(oldStack == nil or: [oldStack last ~~ stack last])
		ifTrue: [contextStackList _ contextStack collect: [:ctx | ctx printString].
				^ self].
	"May be able to re-use some of previous list"
	diff _ stack size - oldStack size.
	contextStackList _ diff <= 0
		ifTrue: [contextStackList copyFrom: 1-diff to: oldStack size]
		ifFalse: [diff > 1
				ifTrue: [contextStack collect: [:ctx | ctx printString]]
				ifFalse: [(Array with: stack first printString) , contextStackList]]! !

!Debugger methodsFor: 'private' stamp: 'jm 10/7/2002 05:53'!
process: aProcess controller: aController context: aContext

	super initialize.
	Smalltalk at: #MessageTally ifPresent: [:c | c new close].
	contents _ nil. 
	interruptedProcess _ aProcess.
	interruptedController _ aController.
	contextStackTop _ aContext.
	self newStack: (contextStackTop stackOfSize: 1).
	contextStackIndex _ 1.
	externalInterrupt _ false.
	selectingPC _ true.
! !

!Debugger methodsFor: 'private' stamp: 'tk 4/15/1998 19:04'!
resetContext: aContext 
	"Used when a new context becomes top-of-stack, for instance when the
	method of the selected context is re-compiled, or the simulator steps or
	returns to a new method. There is room for much optimization here, first
	to save recomputing the whole stack list (and text), and secondly to avoid
	recomposing all that text (by editing the paragraph instead of recreating it)."

	| oldContext |
	oldContext _ self selectedContext.
	contextStackTop _ aContext.
	self newStack: contextStackTop stack.
	self changed: #contextStackList.
	self contextStackIndex: 1 oldContextWas: oldContext.
	self changed: #content.! !

!Debugger methodsFor: 'private' stamp: 'jm 11/8/2005 12:27'!
resumeProcess: aTopView

	Smalltalk isMorphic ifFalse: [aTopView erase].
	savedCursor ifNotNil: [Cursor currentCursor: savedCursor].
	interruptedProcess suspendedContext method
			== (Process compiledMethodAt: #terminate)
		ifFalse:
		[contextStackIndex > 1
			ifTrue: [interruptedProcess popTo: self selectedContext]
			ifFalse: [interruptedProcess install: self selectedContext].
		Smalltalk isMorphic
			ifTrue: [Project current resumeProcess: interruptedProcess]
			ifFalse: [ScheduledControllers
						activeControllerNoTerminate: interruptedController
						andProcess: interruptedProcess]].

	"if old process was terminated, just terminate current one"
	interruptedProcess _ nil. "Before delete, so release doesn't terminate it"
	Smalltalk isMorphic
		ifTrue: [aTopView delete. World displayWorld]
		ifFalse: [aTopView controller closeAndUnscheduleNoErase].
	Smalltalk installLowSpaceWatcher.  "restart low space handler"
	Processor terminateActive
! !

!Debugger methodsFor: 'private'!
selectedContext

	contextStackIndex = 0
		ifTrue: [^contextStackTop]
		ifFalse: [^contextStack at: contextStackIndex]! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Debugger class
	instanceVariableNames: ''!

!Debugger class methodsFor: 'class initialization' stamp: 'di 1/14/1999 09:17'!
initialize
	ErrorRecursion _ false.
	ContextStackKeystrokes _ Dictionary new
		at: $e put: #send;
		at: $t put: #doStep;
		at: $p put: #proceed;
		at: $r put: #restart;
		at: $f put: #fullStack;
		at: $w put: #where;
		yourself.

	"Debugger initialize"! !


!Debugger class methodsFor: 'instance creation' stamp: 'jm 10/7/2002 05:55'!
context: aContext
	"Answer an instance of me for debugging the active process starting with the given context."

	^ self new
		process: Processor activeProcess
		controller:
			((Smalltalk isMorphic not and: [ScheduledControllers inActiveControllerProcess])
				ifTrue: [ScheduledControllers activeController]
				ifFalse: [nil])
		context: aContext
! !


!Debugger class methodsFor: 'opening' stamp: 'EMP 1/7/2016 10:58'!
openContext: aContext label: aString contents: contentsString
	"Open a notifier in response to an error, halt, or notify. A notifier view just shows a short view of the sender stack and provides a menu that lets the user open a full debugger."

	<primitive: 19> "Simulation guard"

	ErrorRecursion not & Preferences logDebuggerStackToFile ifTrue:
		[Smalltalk logError: aString inContext: aContext to: 'SqueakDebug.log'].
	ErrorRecursion ifTrue:
		[ErrorRecursion _ false.
		self primitiveError: aString].
	ErrorRecursion _ true.
	(Debugger context: aContext)
		openNotifierContents: contentsString
		label: aString.
	ErrorRecursion _ false.
	Processor activeProcess suspend.
! !

!Debugger class methodsFor: 'opening' stamp: 'ar 5/1/1999 09:25'!
openInterrupt: aString onProcess: interruptedProcess
	"Open a notifier in response to an interrupt. An interrupt occurs when the user types the interrupt key (cmd-. on Macs, ctrl-c or alt-. on other systems) or when the low-space watcher detects that memory is low."
	| debugger |
	<primitive: 19> "Simulation guard"
	debugger _ self new.
	debugger
		process: interruptedProcess
		controller: ((Smalltalk isMorphic not
					and: [ScheduledControllers activeControllerProcess == interruptedProcess])
						ifTrue: [ScheduledControllers activeController])
		context: interruptedProcess suspendedContext.
	debugger externalInterrupt: true.

Preferences logDebuggerStackToFile ifTrue:
	[(aString includesSubString: 'Space') & 
		(aString includesSubString: 'low') ifTrue: [
			Smalltalk logError: aString inContext: debugger interruptedContext to:'LowSpaceDebug.log']].

	^ debugger
		openNotifierContents: debugger interruptedContext shortStack
		label: aString
! !


Debugger initialize!
