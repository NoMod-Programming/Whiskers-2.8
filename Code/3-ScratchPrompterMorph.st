ImageFrameMorph subclass: #ScratchPrompterMorph
	instanceVariableNames: 'typeinMorph questionMorph okButton done sprite '
	classVariableNames: 'LastAnswer '
	poolDictionaries: ''
	category: 'Scratch-UI-Dialogs'!
!ScratchPrompterMorph commentStamp: 'jm 2/10/2009 19:55' prior: 0!
Supports Scratch text input from the user.
!


!ScratchPrompterMorph methodsFor: 'initialize' stamp: 'EMP 4/29/2016 13:05'!
initialize
	"Set the forms for all my UI elements, create a row to hold my buttons, and a column to hold my shortcut buttons."

	super initialize.
	self initFromForm: (ScratchFrameMorph skinAt: #promptBubbleFrame).
	done _ false.

	typeinMorph _ StringFieldMorph
		new client: self;
		borderWidth: 2;
		color: (Color gray: 55);
		font: (ScratchFrameMorph getFont: #StringDialogTypeIn).

	okButton _ ToggleButton
		onForm: (ScratchFrameMorph skinAt: #promptCheckButtonPressed)
		offForm: (ScratchFrameMorph skinAt: #promptCheckButton).
	okButton
		target: self;
		actionSelector: #accept;
		actWhen: #buttonDown;
		toggleMode: false;
		setBalloonText: 'Close and continue' localized.

	ScratchTranslator isRTL
		ifTrue: [self addMorph: okButton.
			self addMorph: typeinMorph]
		ifFalse: [self addMorph: typeinMorph.
			self addMorph: okButton].

	self extent: 450@(typeinMorph height + 14).
! !


!ScratchPrompterMorph methodsFor: 'accessing' stamp: 'ee 3/1/2009 12:34'!
question: aString

	questionMorph _ StringMorph new
		contents: aString;
		font: (ScratchFrameMorph getFont: #DialogBoxButton).

	self addMorph: questionMorph.
	self height: questionMorph height + typeinMorph height + 16.
! !

!ScratchPrompterMorph methodsFor: 'accessing' stamp: 'jm 2/25/2009 09:47'!
sprite: aSprite

	sprite _ aSprite.
! !


!ScratchPrompterMorph methodsFor: 'geometry' stamp: 'jm 2/10/2009 20:04'!
extent: aPoint

	super extent: aPoint.
	self fixLayout.
! !

!ScratchPrompterMorph methodsFor: 'geometry' stamp: 'EMP 4/29/2016 13:16'!
fixLayout

	typeinMorph ifNil: [^ self].
	typeinMorph
		width: self width - 36;
		bottom: self bottom - 6.
	ScratchTranslator isRTL
		ifTrue:[typeinMorph right: self right - 8]
		ifFalse:[typeinMorph left: self left + 8].

	questionMorph ifNotNil: [
		ScratchTranslator isRTL
			ifTrue: [questionMorph position: self topRight - ((questionMorph width + 8)@0) + (0@5)]
			ifFalse: [questionMorph position: self position + (8@5)]].

	ScratchTranslator isRTL
		ifTrue:[okButton position: (typeinMorph left - (okButton width + 2))@((self height // 2) - (okButton height // 2))]
		ifFalse:[okButton position: (typeinMorph right + 2)@((self height // 2) - (okButton height // 2))].
! !


!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 2/25/2009 09:50'!
accept
	"Accept button was pressed."

	LastAnswer _ typeinMorph contents.
	done _ true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"
! !

!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 3/2/2009 15:38'!
dispatchKeyStroke: evt

	typeinMorph keyStroke: evt.
! !

!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 2/10/2009 19:53'!
enterKeyPressed
	"Respond to the enter key being pressed in one of my input fields."

	self accept.
! !

!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 2/10/2009 20:51'!
grabKeyboardFocus

	World activeHand newKeyboardFocus: typeinMorph.
! !

!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 2/10/2009 20:39'!
isDone

	^ done
! !

!ScratchPrompterMorph methodsFor: 'other' stamp: 'jm 2/26/2009 21:34'!
stopAsk
	"Stop button was pressed."

	done _ true.
	self delete.
	sprite ifNotNil: [sprite sayNothing].
	World doOneCycle.  "erase myself from the screen"
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ScratchPrompterMorph class
	instanceVariableNames: ''!

!ScratchPrompterMorph class methodsFor: 'initialization' stamp: 'jm 2/11/2009 09:45'!
initialize

	LastAnswer _ ''.
! !


!ScratchPrompterMorph class methodsFor: 'accessing' stamp: 'jm 2/27/2009 18:13'!
clearLastAnswer

	LastAnswer _ ''.
! !

!ScratchPrompterMorph class methodsFor: 'accessing' stamp: 'jm 2/11/2009 09:46'!
lastAnswer

	^ LastAnswer
! !


ScratchPrompterMorph initialize!
