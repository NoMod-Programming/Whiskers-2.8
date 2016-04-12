RectangleMorph subclass: #DoubleClickExample
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Demo'!
!DoubleClickExample commentStamp: 'jm 7/15/2003 11:50' prior: 0!
I illustrate the click/drag/double-click capabilities of Morphic.

To make a morph respond to a double-click or distinguish between a single click and a drag operation, it should:
	(1)  Respond "true" to #handlesMouseDown:
	(2)  In the mouseDown: method, send #waitForClicksOrDrag:event: to the hand.
	(3)  Reimplement #click: to react to single-clicked mouse-down.
	(4)  Reimplement #doubleClick: to make the appropriate response to a double-click.
	(5)  Reimplement #drag: to react to non-clicks (i.e. dragging). This message is sent continuously until the button is released. You can check the event argument to react differently on the first, intermediate, and final calls.!


!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'sw 9/28/1999 16:51'!
balloonText
	^ 
'Double-click on me to change my color; 
single-click on me to change border color;
hold mouse down within me to grow 
(if I''m red) or shrink (if I''m blue).'! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'sw 9/28/1999 16:46'!
click: evt
	self showBalloon: 'click'.
	self borderColor: (self borderColor = Color black ifTrue: [Color yellow] ifFalse: [Color black])
! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'bf 9/28/1999 20:55'!
doubleClick: evt
	self showBalloon: 'doubleClick'.
	self color: ((color = Color blue) ifTrue: [Color red] ifFalse: [Color blue])
! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'sw 9/14/1999 16:05'!
handlesMouseDown: evt
	^ true! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'sw 9/23/1999 17:55'!
initialize
	super initialize.
	self color: Color red! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'bf 9/28/1999 17:20'!
mouseDown: evt
	"Do nothing upon mouse-down except inform the hand to watch for a double-click; wait until an ensuing click:, doubleClick:, or drag: message gets dispatched"

	evt hand waitForClicksOrDrag: self event: evt! !

!DoubleClickExample methodsFor: 'as yet unclassified' stamp: 'EMP 12/12/2015 13:28'!
startDrag: evt
	"We'll get a mouseDown first, some mouseMoves, and a mouseUp event last"
	| oldCenter |
	evt isMouseDown ifTrue:
		[self showBalloon: 'drag (mouse down)'.
		self world displayWorld.
		(Delay forMilliseconds: 750) wait].
	evt isMouseUp ifTrue:
		[self showBalloon: 'drag (mouse up)'].
	(evt isMouseUp or: [evt isMouseDown]) ifFalse:
		[self showBalloon: 'drag (mouse still down)'].
	(self containsPoint: evt cursorPoint)
		ifFalse: [^ self].

	oldCenter _ self center.
	color = Color red
		ifTrue:
			[self extent: self extent + (200@200)]
		ifFalse:
			[self extent: ((self extent - (1@1)) max: (16@16))].
	self center: oldCenter! !
