Form subclass: #Cursor
	instanceVariableNames: ''
	classVariableNames: 'BlankCursor CurrentCursor NormalCursor '
	poolDictionaries: ''
	category: 'Graphics-Display Objects'!
!Cursor commentStamp: 'jm 9/8/2006 16:52' prior: 0!
I am a 16x16 bitmap suitable for use as the hardware cursor.
!


!Cursor methodsFor: 'accessing' stamp: 'jm 3/26/2008 11:46'!
asXOCursorForm
	"If in XO mode, answer myself as a 32x32x32 Form with alpha to be used as a cursor on the XO. Otherwise, just answer myself."

	| result map |
	ScratchFrameMorph isXO ifFalse: [^ self].

	result _ Form extent: 32@32 depth: 32.
	map _ Bitmap
		with: (Color white pixelValueForDepth: 32)
		with: (Color black pixelValueForDepth: 32).
	self hasMask ifFalse: [map at: 1 put: 0].  "map white to transparent if there is no mask"

	(BitBlt toForm: result)
		sourceForm: (self magnifyBy: 2);
		sourceOrigin: 0@0;
		combinationRule: Form over;
		colorMap: map;
		copyBits.

	self hasMask ifTrue: [  "apply mask, if I have one"
		(BitBlt toForm: result)
			sourceForm: (self maskForm magnifyBy: 2);
			sourceOrigin: 0@0;
			combinationRule: Form and;
			colorMap: (Bitmap with: 0 with: 16rFFFFFFFF);
			copyBits].

	result offset: offset * 2.
	^ result
! !

!Cursor methodsFor: 'accessing' stamp: 'jm 9/8/2006 16:24'!
hasMask

	^ false
! !

!Cursor methodsFor: 'accessing' stamp: 'jm 9/8/2006 16:24'!
withMask

	^ CursorWithMask derivedFrom: self
! !


!Cursor methodsFor: 'displaying'!
beCursor
	"Primitive. Tell the interpreter to use the receiver as the current cursor 
	image. Fail if the receiver does not match the size expected by the 
	hardware. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 101>
	self primitiveFailed! !

!Cursor methodsFor: 'displaying' stamp: 'jm 9/22/1998 23:33'!
beCursorWithMask: maskForm
	"Primitive. Tell the interpreter to use the receiver as the current cursor image with the given mask Form. Both the receiver and the mask should have extent 16@16 and a depth of one. The mask and cursor bits are combined as follow:
			mask	cursor	effect
			 0		  0		transparent (underlying pixel shows through)
			 1		  1		opaque black
			 1		  0		opaque white
			 0		  1		invert the underlying pixel"
"Essential. See Object documentation whatIsAPrimitive."

	<primitive: 101>
	self primitiveFailed
! !

!Cursor methodsFor: 'displaying' stamp: 'jm 11/8/2005 12:26'!
show
	"Make the current cursor shape be the receiver."

	Cursor currentCursor: self.
! !

!Cursor methodsFor: 'displaying' stamp: 'jm 11/8/2005 12:30'!
showWhile: aBlock 
	"Show this cursor while evaluating the given Block."

	| oldcursor value |
	oldcursor _ Cursor currentCursor.
	self show.
	value _ aBlock value.
	oldcursor show.
	^ value
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Cursor class
	instanceVariableNames: ''!

!Cursor class methodsFor: 'class initialization' stamp: 'EMP 10/9/2015 13:08'!
initNormal

	NormalCursor _ Cursor
		fromArray: #(
			2r0100000000000000
			2r0010000000000000
			2r0001111111111111
			2r0000111111111111
			2r0000011111111111
			2r0000001111111111
			2r0000000111111111
			2r0000111111111111
			2r0000011111111111
			2r0110011111111111
			2r1111001111111111
			2r1111001111111111
			2r1111100111111111
			2r1111100111111111
			2r1111110011111111
			2r1111110011111111)
		offset: 0@0.
! !

!Cursor class methodsFor: 'class initialization' stamp: 'EMP 10/9/2015 13:04'!
initNormalWithMask
	"Cursor initNormalWithMask. Cursor normal show"
	"Cursor initNormal. Cursor normal show"
	"But for a good looking cursor, you have to tweak things..."
	NormalCursor _ (CursorWithMask
		fromArray: #(0 16384 24576 28672 30720 31744 32256 32512 31744 31744 19456 1536 1536 768 768 0)
		offset: -1@-1).

	NormalCursor setMaskForm:
		(Form
			extent: 16@16
			depth: 1
			fromArray: #(3221225472 3758096384 4026531840 4160749568 4227858432 4261412864 4278190080 4286578688 4278190080 4261412864 4261412864 3472883712 251658240 125829120 125829120 50331648)
			offset: 0@0).
! !

!Cursor class methodsFor: 'class initialization' stamp: 'jm 9/8/2006 16:31'!
initialize
	"Create all the most common cursors..."
	"Cursor initialize"

	BlankCursor _ Cursor new.
	self initNormalWithMask.
! !

!Cursor class methodsFor: 'class initialization' stamp: 'jm 11/8/2005 12:37'!
startUp

	self currentCursor: CurrentCursor.
! !


!Cursor class methodsFor: 'instance creation' stamp: 'jm 9/8/2006 15:23'!
fromArray: anArray offset: offsetPoint
	"Answer a new 16x16 cursor offset by offsetPoint and and filled with bits from anArray.
	NOTE: This method takes an array of 16-bit values and left-shifts by 16-bits so they are left-justified in a 32-bit bitmap."

	^ super
		extent: 16@16
		fromArray: (anArray collect: [:bits | bits bitShift: 16])
		offset: offsetPoint
! !

!Cursor class methodsFor: 'instance creation' stamp: 'jm 9/12/2006 20:32'!
new
	"Cursor new show"

	^ self
		fromArray: (Array new: 16 withAll: 0)
		offset: 0@0
! !


!Cursor class methodsFor: 'current cursor' stamp: 'jm 9/8/2006 16:09'!
currentCursor
	"Answer the current Cursor."

	^ CurrentCursor
! !

!Cursor class methodsFor: 'current cursor' stamp: 'jm 3/26/2008 11:36'!
currentCursor: aCursor 
	"Display the given cursor. Raise an error if the argument is not a Cursor."

	(aCursor isKindOf: Cursor) ifFalse: [
		^ self error: 'The new cursor must be an instance of class Cursor'].

	CurrentCursor _ aCursor.
	ScratchFrameMorph isXO ifTrue: [
		"attempt to set XO cursor, but fail gracefully"
		[aCursor withMask asXOCursorForm primBeXOCursor. ^ self] ifError: []].

	aCursor withMask beCursor.
! !


!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:06'!
blank
	"Answer the instance of me that is invisible."
	"Cursor blank showWhile: [Sensor waitButton]"

	^ BlankCursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:27'!
bottomLeft
	"Cursor bottomLeft showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1111111111111111
			2r1111111111111111)
		offset: 0@-15
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:27'!
bottomRight
	"Cursor bottomRight showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r1111111111111111
			2r1111111111111111)
		offset: -15@-15
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:32'!
corner
	"Cursor corner showWhile: [Sensor waitButton]"

	^ Cursor 
		fromArray: #(
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r1111111111111111
			2r1111111111111111)
		offset: -15@-15
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:34'!
crossHair
	"Cursor crossHair showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r1111111111111110
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0000000100000000
			2r0)
		offset: -7@-7
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:35'!
down
	"Cursor down showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r1111110000000000
			2r111100000000000
			2r11000000000000
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:40'!
execute
	"Cursor execute showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1000000000010000
			2r1100000000010000
			2r1110000000111000
			2r1111000111111111
			2r1111100011000110
			2r1111110001000100
			2r1111111001111100
			2r1111000001101100
			2r1101100011000110
			2r1001100010000010
			2r0000110000000000
			2r0000110000000000
			2r0000011000000000
			2r0000011000000000
			2r0000001100000000
			2r0000001100000000)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/12/2006 22:21'!
eyeDropper
	"Cursor eyeDropper showWhile: [Sensor waitButton]"

	| cursor |
	cursor _ CursorWithMask
		fromArray: #(14 31 31 255 126 184 280 552 1088 2176 4352 8704 17408 18432 45056 16384)
		offset: 0@-14.
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(917504 2031616 2031616 16711680 8257536 16252928 33030144 65536000 130023424 260046848 520093696 1040187392 2080374784 2013265920 4026531840 3221225472)
		offset: 0@0).
	^ cursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:28'!
handClosed
	"Cursor handOpen showWhile: [Sensor waitButton].
	 Cursor handClosed showWhile: [Sensor waitNoButton]"

	| cursor |
	cursor _ CursorWithMask
		fromArray: #(0 0 0 448 3704 4686 4105 14337 18434 16386 8194 8196 4100 2056 1032 1032)
		offset: -8@-8.
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(0 0 0 29360128 267911168 536739840 536805376 1073676288 2147352576 2147352576 1073610752 1073479680 536608768 267911168 133693440 133693440)
		offset: 0@0).
	^ cursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:29'!
handOpen
	"Cursor handOpen showWhile: [Sensor waitButton]"

	| cursor |
	cursor _ CursorWithMask
		fromArray: #(384 6768 9800 9802 4685 4681 26633 38913 34818 16386 8194 8196 4100 2056 1032 1032)
		offset: -8@-8.
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(25165824 468713472 1073217536 1073348608 536805376 536805376 1878982656 4294901760 4294836224 2147352576 1073610752 1073479680 536608768 267911168 133693440 133693440)
		offset: 0@0).
	^ cursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:42'!
marker
	"Cursor marker showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0111000000000000
			2r1111100000000000
			2r1111100000000000
			2r0111000000000000
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:44'!
menu
	"Cursor menu showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111100000
			2r1000000000100000
			2r1010011000100000
			2r1000000000100000
			2r1011001010100000
			2r1000000000100000
			2r1010110010100000
			2r1000000000100000
			2r1010010100100000
			2r1000000000100000
			2r1111111111100000
			2r1101001101100000
			2r1111111111100000
			2r1000000000100000
			2r1010101100100000
			2r1111111111100000)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:46'!
move
	"Cursor move showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111111111
			2r1111111111111111
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1111111111111111
			2r1111111111111111
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1100000110000011
			2r1111111111111111
			2r1111111111111111)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:07'!
normal
	"Answer the instance of me that is the shape of an arrow slanted left."
	"Cursor normal showWhile: [Sensor waitButton]"

	^ NormalCursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:59'!
origin
	"Cursor origin showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111111111
			2r1111111111111111
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:58'!
paintBucket
	"Cursor paintBucket showWhile: [Sensor waitButton]"

	| cursor |
	cursor _ CursorWithMask
		fromArray: #(896 1088 1216 1376 1624 1102 2119 4259 8259 16391 16395 8211 4131 2115 1154 768)
		offset: -14@-15.
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(58720256 130023424 130023424 132120576 133693440 134086656 268369920 536805376 1073676288 2147418112 2147155968 1072889856 534970368 264437760 125960192 50462720)
		offset: 0@0).
	^ cursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:58'!
questionMark
	"Cursor questionMark showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(2016 4080 8184 16376 15480 6264 248 496 992 1984 1920 1792 0 1792 1792 1792)
		offset: -8@-8
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:00'!
read
	"Cursor read showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0000110000000110
			2r0001001000001001
			2r0001001000001001
			2r0010000000010000
			2r0100000000100000
			2r1111101111100000
			2r1000010000100000
			2r1000010000100000
			2r1011010110100000
			2r0111101111000000
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'ee 5/14/2008 11:27'!
resizeCorner

	^ Cursor 
		fromArray: #(
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r1111100000000000
			2r1111000000000000
			2r1110000000000000
			2r1101000000000000
			2r1000100000000000
			2r0000010001000000
			2r0000001011000000
			2r0000000111000000
			2r0000001111000000
			2r0000011111000000
			2r0000000000000000
			2r0000000000000000)
		offset: -5@-5
! !

!Cursor class methodsFor: 'constants' stamp: 'ee 5/14/2008 11:00'!
resizeHorizontally

	^ Cursor 
		fromArray: #(
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0001000000100000
			2r0011000000110000
			2r0111000000111000
			2r1111111111111100
			2r0111000000111000
			2r0011000000110000
			2r0001000000100000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000
			2r0000000000000000)
		offset: -5@-5
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:06'!
rightArrow
	"Cursor rightArrow showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r100000000000
			2r111000000000
			2r1111111110000000
			2r111000000000
			2r100000000000
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:02'!
square
	"Cursor square showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0000001111000000
			2r0000001111000000
			2r0000001111000000
			2r0000001111000000
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0
			0)
		offset: -8@-2
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/12/2006 20:31'!
stamp
	"Cursor stamp showWhile: [Sensor waitButton]"

	| cursor |
	cursor _ CursorWithMask
		fromArray: #(2016 3120 2064 2064 3120 1632 576 576 576 1632 31806 32769 32769 32769 65535 32766)
		offset: -8@-8.
	cursor setMaskForm: (Form
		extent: 16@16
		depth: 1
		fromArray: #(132120576 267386880 267386880 267386880 267386880 132120576 62914560 62914560 62914560 132120576 2147352576 4294901760 4294901760 4294901760 4294901760 2147352576)
		offset: 0@0).
	^ cursor
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:57'!
topLeft
	"Cursor topLeft showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111111111
			2r1111111111111111
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000
			2r1100000000000000)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 15:56'!
topRight
	"Cursor topRight showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111111111
			2r1111111111111111
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011
			2r0000000000000011)
		offset: -15@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:03'!
up
	"Cursor up showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r11000000000000
			2r111100000000000
			2r1111110000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r11000000000000
			2r0
			2r0
			2r0
			2r0
			2r0
			2r0)
		offset: -2@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:04'!
wait
	"Cursor wait showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r1111111111111111
			2r1000000000000001
			2r0100000000000010
			2r0010000000000100
			2r0001110000111000
			2r0000111101110000
			2r0000011011100000
			2r0000001111000000
			2r0000001111000000
			2r0000010110100000
			2r0000100010010000
			2r0001000110001000
			2r0010001101000100
			2r0100111111110010
			2r1011111111111101
			2r1111111111111111)
		offset: 0@0
! !

!Cursor class methodsFor: 'constants' stamp: 'jm 9/8/2006 16:04'!
write
	"Cursor write showWhile: [Sensor waitButton]"

	^ Cursor
		fromArray: #(
			2r0000000000000110
			2r0000000000001111
			2r0000000000010110
			2r0000000000100100
			2r0000000001001000
			2r0000000010010000
			2r0000000100100000
			2r0000001001000011
			2r0000010010000010
			2r0000100100000110
			2r0001001000001000
			2r0010010000001000
			2r0111100001001000
			2r0101000010111000
			2r0110000110000000
			2r1111111100000000)
		offset: 0@0
! !


Cursor initialize!
