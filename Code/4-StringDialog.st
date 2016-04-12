DialogBoxMorph subclass: #StringDialog
	instanceVariableNames: 'typeinMorph '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!StringDialog commentStamp: '<historical>' prior: 0!
I am an extension of the DialogBoxMorph used to request string input from the user.

Examples:
	StringDialogBoxMorph ask: 'What is your name?'
	StringDialogBoxMorph ask: 'What is your favorite color?' initialAnswer: 'Red, no blue'
	StringDialogBoxMorph askWithCancel: 'File name?' initialAnswer: 'filename.wav'
!


!StringDialog methodsFor: 'initialization' stamp: 'jm 9/11/2004 09:04'!
initialAnswer: aString
	"Set the default answer string."

	typeinMorph contents: aString.
! !

!StringDialog methodsFor: 'initialization' stamp: 'ee 4/30/2009 12:01'!
initialize
	"Similar to my superclass, but with a string field for the user's response."

	super initialize.

	self title: '?'.

	"create and position typeinMorph"
	mainColumn
		addMorph: (Morph new extent: (5@6); color: Color transparent);
		addMorph: (typeinMorph _ StringFieldMorph
			new client: self;
			borderWidth: 2;
			color: (Color r: (211/255) g: (214/255) b: (216/255)));
		addMorph: (Morph new extent: (5@6); color: Color transparent).
	typeinMorph
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn);
		width: 250.

	tabFields add: typeinMorph.
! !


!StringDialog methodsFor: 'interaction' stamp: 'jm 9/11/2004 09:03'!
accept
	"Enter or carriage return typed or ok button pressed."

	self yes.
! !

!StringDialog methodsFor: 'interaction' stamp: 'jm 2/27/2009 17:43'!
getUserResponse
	"Wait for the user to type in and accept a string, then report that string. Answer the empty string if the user cancels the operation."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	| w |
	self openInWorld.
	self centerOnScreen.

	w _ self world.
	w activeHand newKeyboardFocus: typeinMorph.
	done _ false.
	[done] whileFalse: [w doOneCycle].  "wait for user to press a button"

	self delete.
	w doOneCycle.  "erase myself from the screen"
	response = #cancelled
		ifTrue: [^ '']
		ifFalse: [^ typeinMorph contents asString].
! !


!StringDialog methodsFor: 'event handling' stamp: 'jm 9/10/2004 20:05'!
handlesMouseOver: evt

	^ true
! !

!StringDialog methodsFor: 'event handling' stamp: 'jm 9/11/2004 09:15'!
mouseEnter: evt
	"Grab the keyboard focus when the mouse is over me."

	evt hand newKeyboardFocus: typeinMorph.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

StringDialog class
	instanceVariableNames: ''!

!StringDialog class methodsFor: 'instance creation' stamp: 'ee 6/22/2005 15:25'!
ask: questionString
	"Put up an instance of me to ask the user for string input (such as file name). Answer the edited string."

	^ self askWithCancel: questionString initialAnswer: ''
! !

!StringDialog class methodsFor: 'instance creation' stamp: 'jm 5/14/2005 19:04'!
ask: questionString initialAnswer: aString
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. Answer the edited string."

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: false;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse
! !

!StringDialog class methodsFor: 'instance creation' stamp: 'EMP 12/12/2015 11:32'!
ask: questionString title: titleString
	"Put up an instance of me to ask the user for string input (such as file name). Answer the edited string."

	^ self askWithCancel: questionString initialAnswer: '' title: titleString
! !

!StringDialog class methodsFor: 'instance creation' stamp: 'jm 9/10/2004 21:01'!
askWithCancel: questionString
	"Like ask:, but with a cancel button. Answer the empty string if cancelled."

	^ self askWithCancel: questionString initialAnswer: ''

! !

!StringDialog class methodsFor: 'instance creation' stamp: 'jm 5/14/2005 19:04'!
askWithCancel: questionString initialAnswer: aString
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString.
	^ dialogBox getUserResponse
! !

!StringDialog class methodsFor: 'instance creation' stamp: 'EMP 12/12/2015 11:33'!
askWithCancel: questionString initialAnswer: aString title: titleString
	"Put up an instance of me to ask the user for string input (such as file name). The initial response text is set to the given string, which the user can replace or edit. This version includes a cancel button. Answer the empty string if cancelled."

	| dialogBox |
	dialogBox _ self new
		withButtonsForYes: false no: false okay: true cancel: true;
		message: questionString;
		initialAnswer: aString;
		title: titleString.
	^ dialogBox getUserResponse
! !
