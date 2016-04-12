Form subclass: #DisplayScreen
	instanceVariableNames: 'clippingBox '
	classVariableNames: 'DisplayChangeSignature ScreenSave '
	poolDictionaries: ''
	category: 'Graphics-Display Objects'!
!DisplayScreen commentStamp: '<historical>' prior: 0!
There is only one instance of me, Display. It is a global and is used to handle general user requests to deal with the whole display screen. 
	Although I offer no protocol, my name provides a way to distinguish this special instance from all other Forms. This is useful, for example, in dealing with saving and restoring the system.
	To change the depth of your Display...
		Display newDepth: 16.
		Display newDepth: 8.
		Display newDepth: 1.
Valid display depths are 1, 2, 4, 8, 16 and 32.  It is suggested that you run with your monitors setting the same, for better speed and color fidelity.  Note that this can add up to 4Mb for the Display form.  Finally, note that newDepth: ends by executing a 'ControlManager restore' which currently terminates the active process, so nothing that follows in the doit will get executed.

Depths 1, 2, 4 and 8 bits go through a color map to put color on the screen, but 16 and 32-bit color use the pixel values directly for RGB color (5 and 8 bits per, respectivlely).  The color choice an be observed by executing Color fromUser in whatever depth you are using.
!


!DisplayScreen methodsFor: 'displaying' stamp: 'jm 5/25/2003 11:48'!
copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aColor 	"Copy the given rectangular area from sourceForm into myself at the given destination point using the given combination rule and fill color."

	(BitBlt
		destForm: self
		sourceForm: sourceForm
		fillColor: aColor
		combinationRule: rule
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: (clipRect intersect: clippingBox)) copyBits.
! !

!DisplayScreen methodsFor: 'displaying' stamp: 'jm 5/29/2003 17:58'!
copyBits: rect from: sf at: destOrigin clippingBox: clipRect rule: cr fillColor: hf map: map

	((BitBlt
		destForm: self
		sourceForm: sf
		fillColor: hf
		combinationRule: cr
		destOrigin: destOrigin
		sourceOrigin: rect origin
		extent: rect extent
		clipRect: (clipRect intersect: clippingBox)) colorMap: map) copyBits! !

!DisplayScreen methodsFor: 'displaying' stamp: 'jm 5/22/1998 01:23'!
flash: aRectangle 
	"Flash the area of the screen defined by the given rectangle."

	self reverse: aRectangle.
	self forceDisplayUpdate.
	(Delay forMilliseconds: 100) wait.
	self reverse: aRectangle.
	self forceDisplayUpdate.
! !


!DisplayScreen methodsFor: 'other'!
boundingBox
	clippingBox == nil
		ifTrue: [clippingBox _ super boundingBox].
	^ clippingBox! !

!DisplayScreen methodsFor: 'other'!
clippingTo: aRect do: aBlock
	"Display clippingTo: Rectangle fromUser do:
	[ScheduledControllers restore: Display fullBoundingBox]"
	| saveClip |
	saveClip _ clippingBox.
	clippingBox _ aRect.
	aBlock value.
	clippingBox _ saveClip! !

!DisplayScreen methodsFor: 'other' stamp: 'jm 11/15/2005 18:14'!
colorAt: aPoint
	"Answer the color in the pixel at the given point. Since this is the display, ignore alpha."

	^ self colorNoAlphaAt: aPoint
! !

!DisplayScreen methodsFor: 'other' stamp: 'jm 5/17/1998 08:29'!
deferUpdates: aBoolean
	"Set the deferUpdates flag in the virtual machine. When this flag is true, BitBlt operations on the Display are not automatically propagated to the screen. If this underlying platform does not support deferred updates, this primitive will fail. Answer the receiver if the primitive succeeds, nil if it fails."

	<primitive: 126>
	^ nil  "answer nil if primitive fails"
! !

!DisplayScreen methodsFor: 'other' stamp: 'RAA 11/27/1999 15:48'!
displayChangeSignature

	^DisplayChangeSignature! !

!DisplayScreen methodsFor: 'other' stamp: 'jm 5/21/1998 23:48'!
forceDisplayUpdate
	"On platforms that buffer screen updates, force the screen to be updated immediately. On other platforms, or if the primitive is not implemented, do nothing."

	<primitive: 231>
	"do nothing if primitive fails"! !

!DisplayScreen methodsFor: 'other' stamp: 'jm 5/19/1998 17:50'!
forceToScreen: aRectangle
	"Force the given rectangular section of the Display to be copied to the screen. The primitive call does nothing if the primitive is not implemented. Typically used when the deferUpdates flag in the virtual machine is on; see deferUpdates:."

	self primShowRectLeft: aRectangle left
		right: aRectangle right
		top: aRectangle top
		bottom: aRectangle bottom.
! !

!DisplayScreen methodsFor: 'other'!
fullScreen   "Display fullScreen"

	ScreenSave notNil ifTrue: [Display _ ScreenSave].
	clippingBox _ super boundingBox! !

!DisplayScreen methodsFor: 'other'!
height
	^ self boundingBox height! !

!DisplayScreen methodsFor: 'other' stamp: 'ar 5/5/1999 23:44'!
newDepth: pixelSize
"
	Display newDepth: 8.
	Display newDepth: 1.
"
	(self supportsDisplayDepth: pixelSize)
		ifFalse:[^self inform:'Display depth ', pixelSize printString, ' is not supported on this system'].
	self newDepthNoRestore: pixelSize.
	self restore.! !

!DisplayScreen methodsFor: 'other'!
replacedBy: aForm do: aBlock
	"Permits normal display to draw on aForm instead of the display."

	ScreenSave _ self.
	Display _ aForm.
	aBlock value.
	Display _ self.
	ScreenSave _ nil.! !

!DisplayScreen methodsFor: 'other' stamp: 'ar 5/1/1999 11:03'!
restore
	Smalltalk isMorphic
		ifTrue: [World fullRepaintNeeded]
		ifFalse: [ScheduledControllers unCacheWindows; restore].! !

!DisplayScreen methodsFor: 'other' stamp: 'sma 4/30/2000 09:27'!
restoreAfter: aBlock
	"Evaluate the block, wait for a mouse click, and then restore the screen."

	aBlock value.
	Sensor waitButton.
	Smalltalk isMorphic
		ifTrue: [World fullRepaintNeeded]
		ifFalse: [(ScheduledControllers restore; activeController) view emphasize]! !

!DisplayScreen methodsFor: 'other' stamp: 'bf 9/18/1999 19:46'!
supportedDisplayDepths
	"Return all pixel depths supported on the current host platform."
	^#(1 2 4 8 16 32) select: [:d | self supportsDisplayDepth: d]! !

!DisplayScreen methodsFor: 'other' stamp: 'ar 5/5/1999 23:45'!
supportsDisplayDepth: pixelDepth
	"Return true if this pixel depth is supported on the current host platform.
	Primitive. Optional."
	<primitive: 91>
	^#(1 2 4 8 16 32) includes: pixelDepth! !

!DisplayScreen methodsFor: 'other'!
width
	^ self boundingBox width! !


!DisplayScreen methodsFor: 'private'!
beDisplay
	"Primitive. Tell the interpreter to use the receiver as the current display 
	image. Fail if the form is too wide to fit on the physical display. 
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 102>
	self primitiveFailed! !

!DisplayScreen methodsFor: 'private' stamp: 'EMP 3/15/2016 12:12'!
copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule 
	super
		copyBits: sourceRect
		from: sourceForm
		at: destOrigin
		clippingBox: clipRect
		rule: rule.! !

!DisplayScreen methodsFor: 'private' stamp: 'ar 5/25/2000 23:43'!
findAnyDisplayDepth
	"Return any display depth that is supported on this system."
	^self findAnyDisplayDepthIfNone:[
		"Ugh .... now this is a biggie - a system that does not support
		any of the Squeak display depths at all."
		Smalltalk
			logError:'Fatal error: This system has no support for any display depth at all.'
			inContext: thisContext
			to: 'SqueakDebug.log'.
		Smalltalk quitPrimitive. "There is no way to continue from here"
	].! !

!DisplayScreen methodsFor: 'private' stamp: 'ar 5/25/2000 23:44'!
findAnyDisplayDepthIfNone: aBlock
	"Return any display depth that is supported on this system.
	If there is none, evaluate aBlock."
	#(1 2 4 8 16 32) do:[:bpp|
		(self supportsDisplayDepth: bpp) ifTrue:[^bpp].
	].
	^aBlock value! !

!DisplayScreen methodsFor: 'private' stamp: 'di 4/15/1999 10:58'!
newDepthNoRestore: pixelSize
	"Change depths.  Check if there is enough space!!  , di"
	| area need |
	pixelSize = depth ifTrue: [^ self  "no change"].
	pixelSize < depth ifFalse:
		["Make sure there is enough space"
		area _ Display boundingBox area. "pixels"
		Smalltalk isMorphic ifFalse:
			[ScheduledControllers scheduledWindowControllers do:
				[:aController | "This should be refined..."
				aController view cacheBitsAsTwoTone ifFalse:
					[area _ area + aController view windowBox area]]].
		need _ (area * (pixelSize-depth) // 8)  "new bytes needed"
				+ Smalltalk lowSpaceThreshold.
		(Smalltalk garbageCollectMost <= need
			and: [Smalltalk garbageCollect <= need])
			ifTrue: [self error: 'Insufficient free space']].
	self setExtent: self extent depth: pixelSize.
	Smalltalk isMorphic ifFalse: [ScheduledControllers updateGray].
	DisplayScreen startUp! !

!DisplayScreen methodsFor: 'private' stamp: 'jm 6/3/1998 13:00'!
primRetryShowRectLeft: l right: r top: t bottom: b
	"Copy the given rectangular section of the Display to to the screen. This primitive is not implemented on all platforms. Do nothing if it fails. "

	<primitive: 127>
	"do nothing if primitive fails"
! !

!DisplayScreen methodsFor: 'private' stamp: 'jm 6/3/1998 13:02'!
primShowRectLeft: l right: r top: t bottom: b
	"Copy the given rectangular section of the Display to to the screen. This primitive is not implemented on all platforms. If this fails, retry integer coordinates."

	<primitive: 127>
	"if this fails, coerce coordinates to integers and try again"
	self primRetryShowRectLeft: l truncated
		right: r rounded
		top: t truncated
		bottom: b rounded.
! !

!DisplayScreen methodsFor: 'private' stamp: 'RAA 11/27/1999 15:48'!
setExtent: aPoint depth: bitsPerPixel  "DisplayScreen startUp"
	"This method is critical.  If the setExtent fails, there will be no
	proper display on which to show the error condition..."
	"ar 5/1/1999: ... and that is exactly why we check for the available display depths first."

	"RAA 27 Nov 99 - if depth and extent are the same and acceptable, why go through this.
	also - record when we change so worlds can tell if it is time to repaint"

	(depth == bitsPerPixel and: [aPoint = self extent and: 
					[self supportsDisplayDepth: bitsPerPixel]]) ifFalse: [
		bits _ nil.  "Free up old bitmap in case space is low"
		DisplayChangeSignature _ (DisplayChangeSignature ifNil: [0]) + 1.
		(self supportsDisplayDepth: bitsPerPixel)
			ifTrue:[super setExtent: aPoint depth: bitsPerPixel]
			ifFalse:["Search for a suitable depth"
					super setExtent: aPoint depth: self findAnyDisplayDepth].
	].
	clippingBox _ super boundingBox! !


!DisplayScreen methodsFor: 'initialize-release' stamp: 'ar 5/26/2000 00:07'!
release
	"I am no longer Display. Release any resources if necessary"! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

DisplayScreen class
	instanceVariableNames: ''!

!DisplayScreen class methodsFor: 'display box access'!
boundingBox
	"Answer the bounding box for the form representing the current display 
	screen."

	^Display boundingBox! !

!DisplayScreen class methodsFor: 'display box access' stamp: 'sma 4/30/2000 09:25'!
checkForNewScreenSize
	Display extent = DisplayScreen actualScreenSize ifTrue: [^ self].
	DisplayScreen startUp.
	Smalltalk isMorphic
		ifTrue: [World restoreDisplay]
		ifFalse: [ScheduledControllers restore; searchForActiveController]! !


!DisplayScreen class methodsFor: 'snapshots'!
actualScreenSize
	<primitive: 106>
	^ 640@480! !

!DisplayScreen class methodsFor: 'snapshots' stamp: 'jm 1/1/2004 11:07'!
shutDown 
	"Minimize Display size to save space in snapshots."

	Display setExtent: 160@120 depth: Display depth.
! !

!DisplayScreen class methodsFor: 'snapshots' stamp: 'jm 1/1/2004 11:17'!
startUp
	"Install Display as the current display."
	"DisplayScreen startUp"

	Display setExtent: self actualScreenSize depth: Display depth.
	Display beDisplay.
! !
