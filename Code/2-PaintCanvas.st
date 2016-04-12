Morph subclass: #PaintCanvas
	instanceVariableNames: 'palette canvasForm bgForm feedbackForm bufferForm transformSrcForm transformScale transformDegrees transformHFlip transformVFlip transformUndoList transformUndoIndex undoList undoIndex scale scrollX scrollY brush startPoint lastPoint dragOffset selectionRect showSelection moveOrStampForm textBox textColor textForm textDragMode registrationPoint regPointUndoList regPointUndoIndex '
	classVariableNames: 'BrushDict CanvasExtent EnlargeFactor MaxUndo '
	poolDictionaries: ''
	category: 'Scratch-Paint'!
!PaintCanvas commentStamp: 'jm 11/19/2005 11:03' prior: 0!
I am a paint editor that supports scrolling and scaling.


My instance variables are:
	palette				the UI for my drawing tool state
	canvasForm			the current contents of my painting
	bgForm				checkerboard pattern for showing transparent areas
	feedbackForm		holds feedback during line/rect/oval drawing; same extent as canvasForm
	bufferForm			used for updating my view on the screen
	undoList			keeps copies of recent canvasForms for undo
	undoIndex			index of current undo recorder
	scale				current scale factor
	scrollX				horizontal scroll in canvasForm coordinates
	scrollY				vertical scroll in canvasForm coordinates
	startPoint			starting point of current drag in canvasForm coordinates
	lastPoint			previous point of current drag in canvasForm coordinates
	brush				the Pen used for paint/erase
	moveOrStampForm	holds the image being moved or stamped
	textBox				holds editable text (although this is a morph, it is not in the world)
	textForm			holds text layer bitmap; same extent as canvasForm
	textDragMode		what to do when dragging in text mode (select, move, resize, etc.)
	textDragoffset		offset used during textBox moving and resizing

!


!PaintCanvas methodsFor: 'initialization' stamp: 'EMP 12/18/2015 10:55'!
initialize

	super initialize.
	palette _ PaintPalette new canvasMorph: self; extent:  56@45.
	scale _ 1.
	scrollX _ scrollY _ 0.
	showSelection _ false.
	textColor _ Color black.
	textBox _ MultilineStringMorph new
		font: (StrikeFont osFontName: 'Helvetica Bold' size: 24);
		suppressAntiAliasing: true;
		textColor: Color black;		"pixel value 1 at depth 2"
		borderColor: Color white;		"pixel value 2 at depth 2"
		borderWidth: 0.
	textDragMode _ #none.
	self extent: 250@250.
! !


!PaintCanvas methodsFor: 'entry points' stamp: 'jm 12/21/2005 17:55'!
editForm: aForm
	"Set the Form that I should edit. Make a copy of the original Form."

	self editForm: aForm regPoint: aForm center textBox: nil isStage: false.
! !

!PaintCanvas methodsFor: 'entry points' stamp: 'jm 8/11/2008 07:42'!
editForm: aForm regPoint: regPoint textBox: savedTextBox isStage: isStage
	"Set the Form and textBox that I should edit. Make a copy of the original Form."

	| p |
	canvasForm _ Form extent: (aForm extent max: self extent) depth: 32.
	p _ (((canvasForm extent // 2) - regPoint) min: (canvasForm extent - aForm extent)) max: 0@0.
	aForm displayOn: canvasForm at: p rule: Form paint.
	registrationPoint _ p + regPoint.
	bgForm _ self makeCheckerboard.
	self clearTextBox.
	undoList _ OrderedCollection new.
	undoIndex _ 0.
	scrollX _ scrollY _ 0.
	self clearMoveState.

	savedTextBox ifNotNil: [  "install saved textbox"
		textBox _ savedTextBox copy.
		isStage ifFalse: [textBox position: p + textBox position].
		textBox extent: (self extent - textBox topLeft).
		textColor _ textBox textColor.
		textBox
			suppressAntiAliasing: true;
			renderWithSqueak: true;
			textColor: Color black;
			borderWidth: 0].

	self changed.
! !


!PaintCanvas methodsFor: 'accessing' stamp: 'jm 9/15/2005 10:44'!
canvasForm

	^ canvasForm
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 12/9/2005 17:02'!
canvasTextBox
	"Answer my text box."

	^ textBox
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 9/26/2005 11:12'!
palette

	^ palette
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 11/15/2005 17:45'!
scale

	^ scale
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 12/2/2005 11:05'!
scale: aNumber
	"Set the scale factor of my view. For example, 8 shows each pixel of canvas at eight times its actual size." 

	| oldCenter |
	oldCenter _ self screenToCanvas: self center.
	scale _ aNumber asFloat max: 0.01.
	self centerAt: oldCenter.
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 11/19/2005 10:36'!
scrollFractionX
	"Answer my horizontal scroll fraction, a number between 0.0 and 1.0."

	| total |
	total _ canvasForm width - (self width // scale).
	total <= 0.0 ifTrue: [^ 0.0].
	^ (scrollX asFloat / total) min: 1.0

! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 11/19/2005 10:36'!
scrollFractionX: aNumber

	| total |
	total _ canvasForm width - (self width // scale).
	scrollX _ (aNumber * total) rounded within: 0 and: canvasForm width.
	self changed.
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 11/19/2005 10:37'!
scrollFractionY
	"Answer my vertical scroll fraction, a number between 0.0 and 1.0."

	| total |
	total _ canvasForm height - (self height // scale).
	total <= 0.0 ifTrue: [^ 0.0].
	^ (scrollY asFloat / total) min: 1.0

! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 11/19/2005 10:37'!
scrollFractionY: aNumber

	| total |
	total _ canvasForm height - (self height // scale).
	scrollY _ (aNumber * total) rounded within: 0 and: canvasForm height.
	self changed.
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 12/22/2005 11:32'!
textColor

	^ textColor
! !

!PaintCanvas methodsFor: 'accessing' stamp: 'jm 12/22/2005 11:32'!
textColor: aColor

	textColor _ aColor.
! !


!PaintCanvas methodsFor: 'registration point' stamp: 'jm 8/22/2006 12:19'!
clearRegistrationPoint

	registrationPoint _ nil.
	regPointUndoList _ nil.
	regPointUndoIndex _ 0.
! !

!PaintCanvas methodsFor: 'registration point' stamp: 'jm 9/18/2006 15:52'!
redoRegPointMove

	regPointUndoList ifNil: [^ self beep].  "no undo entries yet"
	regPointUndoIndex < 2 ifTrue: [^ self beep].  "nothing more to redo"
	regPointUndoIndex _ regPointUndoIndex - 1.
	registrationPoint _ regPointUndoList at: regPointUndoIndex.
	self changed.
! !

!PaintCanvas methodsFor: 'registration point' stamp: 'jm 12/20/2005 12:13'!
registrationPoint

	^ registrationPoint
! !

!PaintCanvas methodsFor: 'registration point' stamp: 'jm 12/20/2005 12:14'!
registrationPoint: aPointOrNil
	"Set the registration point for the current drawing. If the registration point is nil, a new one will be computed on demand." 

	registrationPoint _ aPointOrNil.
! !

!PaintCanvas methodsFor: 'registration point' stamp: 'jm 12/21/2005 17:46'!
saveRegPointForUndo
	"Save the current registration point to allow undoing." 

	regPointUndoList ifNil: [  "create registration point undo list"
		regPointUndoList _ OrderedCollection new.
		regPointUndoIndex _ 0].

	registrationPoint ifNotNil: [
		regPointUndoList addFirst: registrationPoint.
		regPointUndoIndex _ 0].
! !

!PaintCanvas methodsFor: 'registration point' stamp: 'jm 12/21/2005 17:44'!
undoRegPointMove

	regPointUndoList ifNil: [^ self beep].  "no undo entries yet"
	regPointUndoIndex >= regPointUndoList size ifTrue: [^ self beep].  "nothing more to undo"
	regPointUndoIndex = 0 ifTrue: [
		self saveRegPointForUndo.
		regPointUndoIndex _ 1].

	regPointUndoIndex _ regPointUndoIndex + 1.
	registrationPoint _ regPointUndoList at: regPointUndoIndex.
	self changed.
! !


!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/18/2006 14:44'!
enlarge

	Sensor shiftPressed ifTrue: [^ self magnify].
	self scaleBy: EnlargeFactor.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/20/2006 14:52'!
eraseAll

	palette showRotationCenter: false.
	palette mode = #stamp ifFalse: [self clearMoveState].
	self clearRegistrationPoint.
	self saveForUndo.
	canvasForm _ Form extent: self extent depth: 32.
	self changed.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/20/2006 14:52'!
flipH

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformHFlip _ transformHFlip not.
	self applyTransform.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/20/2006 14:52'!
flipV

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformVFlip _ transformVFlip not.
	self applyTransform.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'EMP 12/15/2015 19:08'!
import
	"Import an image from the image library, or the current directory if there is not image library."

	| fName f spriteOrStage type |
	palette showRotationCenter: false.

	spriteOrStage _ self owner originalObject.
	(spriteOrStage isKindOf: ScratchStageMorph)
		ifTrue: [type _ #background]
		ifFalse: [type _ #costume].
	fName _ ScratchFileChooserDialog
		chooseImageFileType: type
		title: 'Import Image'.
	(fName isNil or: [fName = #cancelled]) ifTrue: [^ self].

	(fName asLowercase endsWith: '.sprite')
		ifTrue: [
			f _ self importCostumeFromSprite: fName]
		ifFalse: [
			[f _ Form fromFileNamed: fName] ifError: [nil]].
	f ifNil: [^ self].

	f _ ScratchFrameMorph scaledFormForPaintEditor: f.

	(owner isKindOf: PaintFrame) ifTrue: [owner scaleCanvas: 1].
	(owner isKindOf: InlinePaintFrame) ifTrue: [owner scaleCanvas: 1].

	self commitMove.  "commit previous move, if any"
	palette mode: #move.
	moveOrStampForm _ f.
	selectionRect _ ((canvasForm extent - f extent) // 2) extent: f extent.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 12/15/2006 17:25'!
redo

	palette mode = #text ifTrue: [^ self beep].

	palette showRotationCenter ifTrue: [^ self redoRegPointMove].
	transformSrcForm ifNotNil: [^ self redoTransform].

	undoIndex > 1 ifFalse: [^ self beep].  "nothing more to redo"
	undoIndex _ undoIndex - 1.
	canvasForm _ undoList at: undoIndex.
	self clearMoveState.
	self changed.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/18/2006 14:43'!
rotateCCW

	Sensor shiftPressed ifTrue: [^ self rotate: false].
	self rotateCWBy: -30.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/18/2006 14:44'!
rotateCW

	Sensor shiftPressed ifTrue: [^ self rotate: true].
	self rotateCWBy: 30.
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 9/18/2006 14:44'!
shrink

	Sensor shiftPressed ifTrue: [^ self magnify].
	self scaleBy: (1.0 / EnlargeFactor).
! !

!PaintCanvas methodsFor: 'button actions' stamp: 'jm 12/15/2006 17:25'!
undo

	palette mode = #text ifTrue: [^ self beep].

	palette showRotationCenter ifTrue: [^ self undoRegPointMove].
	transformSrcForm ifNotNil: [^ self undoTransform].

	undoIndex >= undoList size ifTrue: [^ self beep].  "nothing more to undo"

	palette mode = #move ifTrue: [moveOrStampForm _ selectionRect _ nil].

	undoIndex = 0 ifTrue: [
		self saveForUndo.  "save the current canvas so we can redo"
		undoIndex _ 1].

	undoIndex _ undoIndex + 1.
	canvasForm _ undoList at: undoIndex.
	self clearMoveState.
	self changed.
! !


!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/12/2006 21:41'!
autoScroll: cursorPoint
	"Autoscroll towards the given point."

	| scrollDelta deltaX deltaY max |
	(bounds containsPoint: cursorPoint) ifTrue: [^ self].  "no scrolling needed"

	scrollDelta _ 64 // scale.  "this controls autoscroll speed"

	cursorPoint x < bounds left ifTrue: [deltaX _ scrollDelta negated].
	cursorPoint x > bounds right ifTrue: [deltaX _ scrollDelta].
	cursorPoint y < bounds top ifTrue: [deltaY _ scrollDelta negated].
	cursorPoint y > bounds bottom ifTrue: [deltaY _ scrollDelta].

	deltaX ifNotNil: [
		max _ canvasForm width - (self width // scale).
		scrollX _ (scrollX + deltaX) rounded within: 0 and: max].
	deltaY ifNotNil: [
		max _ canvasForm height - (self height // scale).
		scrollY _ (scrollY + deltaY) rounded within: 0 and: max].

	(owner respondsTo: #updateScrollbars) ifTrue: [owner updateScrollbars].
	self changed.

! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 12/20/2006 15:56'!
dragBrushTo: aPoint
	"While painting or erasing, move the brush to the given point. Called repeatedly while dragging. All points are in canvas coordinates."

	| p |
	p _ (aPoint max: scrollX@scrollY) min: (scrollX@scrollY) + (bounds extent // scale).
	brush goto: p.
	self canvasChanged: ((lastPoint rect: p) expandBy: (brush sourceForm width / 2.0) ceiling).
	lastPoint _ p.
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 4/15/2007 18:40'!
dragShapeTo: aPoint
	"Draw or drag out a line or shape from the starting point to the given point. Called repeatedly while dragging. All points are in canvas coordinates."

	| mode w shapeCanvas endPoint r dx dy side |
	mode _ palette mode.

	w _ palette brushSize.
	feedbackForm bits atAllPut: 0.  "fast clear"
	shapeCanvas _ FormCanvas on: feedbackForm.

	#line = mode ifTrue:[
		endPoint _ aPoint.
		Sensor shiftPressed ifTrue: [
			(endPoint y - startPoint y) abs > (endPoint x - startPoint x) abs
				ifTrue: [endPoint _ startPoint x@endPoint y]
				ifFalse: [endPoint _ endPoint x@startPoint y]].
		shapeCanvas line: startPoint to: endPoint width: w color: Color black].

	#oval = mode ifTrue: [
		r _ startPoint rect: aPoint.
		Sensor shiftPressed ifTrue: [
			dx _ aPoint x - startPoint x.
			dy _ aPoint y - startPoint y.
			side _ dx abs max: dy abs.
			r _ startPoint rect: startPoint + (side * (dx sign@dy sign))].
		palette shapeFilling
			ifTrue: [shapeCanvas fillOval: r color: Color black]
			ifFalse: [shapeCanvas frameOval: r width: w color: Color black]].

	#rect = mode ifTrue:[
		r _ startPoint rect: aPoint.
		Sensor shiftPressed ifTrue: [
			dx _ aPoint x - startPoint x.
			dy _ aPoint y - startPoint y.
			side _ dx abs max: dy abs.
			r _ startPoint rect: startPoint + (side * (dx sign@dy sign))].
		palette shapeFilling
			ifTrue: [shapeCanvas fillRectangle: r color: Color black]
			ifFalse: [shapeCanvas frameRectangle: r width: w color: Color black]].

	lastPoint _ aPoint.
	self changed.
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/11/2006 16:41'!
dragTo: aPoint
	"Drag to the given point with the current drawing tool. The point is in canvas coordinates."

	| mode c |
	mode _ palette mode.
	((#paint = mode) | (#erase = mode)) ifTrue: [^ self dragBrushTo: aPoint].
	(#(line oval rect) includes: mode) ifTrue: [^ self dragShapeTo: aPoint].

	#eyedropper = mode ifTrue: [
		(bounds containsPoint: Sensor cursorPoint)
			ifTrue: [c _ canvasForm colorNoAlphaAt: aPoint]  "if over me, get color from canvasForm"
			ifFalse: [c _ Display colorAt: Sensor cursorPoint].
		palette color1: c.
		^ self].

	"holding shift with the stamp tool does multiple stamps while dragging"
	((#stamp = palette mode) & (Sensor shiftPressed)) ifTrue: [
		self stampAt: aPoint.
		Delay waitMSecs: 50.
		^ self].
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/13/2005 13:26'!
handlesMouseDown: evt

	^ true
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 11/16/2005 10:22'!
handlesMouseOver: evt

	^ true
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 10/3/2006 09:06'!
keyStroke: evt

	| k |
	#text = palette mode ifTrue: [
		textBox extent: canvasForm extent - textBox position.
		textBox keyStroke: evt.
		^ self changed].

	k _ evt keyValue.
	(evt commandKeyPressed | evt controlKeyPressed)
		ifTrue: [k _ k \\ 32].  "treat command/alt same as the control key"

	k = ($a asciiValue \\ 32) ifTrue: [^ self selectAll].
	k = ($c asciiValue \\ 32) ifTrue: [^ self copyMoveSelection].
	(#(8 24 127) includes: k) ifTrue: [^ self deleteOrCropCurrentSelection: evt].
	k = ($z asciiValue \\ 32) ifTrue: [^ self undo].

	(palette mode = #move and: [selectionRect notNil]) ifTrue: [
		self startMove.
		"keys that act on the selection"
		k = 28 ifTrue: [^ self nudge: -1@0].  "left"
		k = 29 ifTrue: [^ self nudge:  1@0].  "right"
		k = 30 ifTrue: [^ self nudge:  0@-1].  "up"
		k = 31 ifTrue: [^ self nudge:  0@1]].  "down"

	self beep.
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/18/2006 15:40'!
mouseDown: evt

	startPoint _ lastPoint _ self screenToCanvas: evt cursorPoint.
	(#(stamp move) includes: palette mode) ifFalse: [self clearMoveState].

	palette showRotationCenter
		ifTrue: [^ self saveRegPointForUndo]
		ifFalse: [regPointUndoList _ nil].

	#eyedropper = palette mode ifTrue: [^ self].
	#move = palette mode ifTrue: [^ self moveToolMouseDown: startPoint].
	#text = palette mode ifTrue: [^ self textMouseDown: evt].

	self saveForUndo.

	brush _ (Pen newOnForm: canvasForm)
		roundNib: palette brushSize;
		color: palette color1;
		place: startPoint.

	(#erase = palette mode) | (palette color1 isTransparent) ifTrue: [
		brush color: Color black.
		brush combinationRule: Form erase1bitShape].

	(#(line oval rect) includes: palette mode) ifTrue: [
		feedbackForm _ Form extent: canvasForm extent depth: 1].

	#fill = palette mode ifTrue: [self fillAt: startPoint].
	#stamp = palette mode ifTrue: [self stampAt: startPoint].

	self dragTo: startPoint.
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 1/8/2006 15:36'!
mouseEnter: evt

	World activeHand newKeyboardFocus: self.
	self installCursorInHand: evt hand.
	scale > 1 ifTrue: [
		evt hand
			gridTo: scale truncated
			origin: (self canvasToScreen: 0@0)].
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/11/2006 17:00'!
mouseLeave: evt

	evt hand
		showTemporaryCursor: nil;
		turnOffGridding.
	self changed.! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 3/26/2008 12:11'!
mouseMove: evt
	"Draw and/or give feedback."

	| screenP |
	((#paint ~= palette mode) & (ScratchFrameMorph isXO not))
		ifTrue: [self autoScroll: evt cursorPoint].

	palette showRotationCenter ifTrue: [
		screenP _ evt cursorPoint adhereTo: (self topLeft corner: self bottomRight - 1).
		registrationPoint _ self screenToCanvas: screenP.
		^ self changed].

	#text = palette mode ifTrue: [^ self textMouseMove: evt].

	self dragTo: (self screenToCanvas: evt cursorPoint).
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/11/2006 15:34'!
mouseUp: evt
	"Finish a drag."

	| rule shapeCM |
	textDragMode _ #none.
	palette showRotationCenter ifTrue: [^ self].

	feedbackForm ifNotNil: [  "draw final rect/oval/line onto canvasForm"
		rule _ Form paint.
		shapeCM _ Bitmap new: 2.
		shapeCM at: 2 put: (palette color1 pixelValueForDepth: 32).
		palette color1 isTransparent ifTrue: [
			rule _ Form erase.
			shapeCM at: 2 put: 16rFFFFFFFF].
		(BitBlt toForm: canvasForm)
			sourceForm: feedbackForm;
			colorMap: shapeCM;
			combinationRule: rule;
			copyBits.
		feedbackForm _ nil.
		self changed].
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/19/2006 16:10'!
selectRectangleStartingAt: aPoint
	"Set selectionRect to a rectangular area starting at the given canvas point."

	| p |
	selectionRect _ aPoint extent: 0@0.
	showSelection _ true.
	World activeHand showTemporaryCursor: nil.
	Cursor crossHair showWhile: [
		[Sensor anyButtonPressed] whileTrue: [
			p _ Sensor cursorPoint.
			self autoScroll: p.
			self canvasChanged: selectionRect.
			selectionRect _ aPoint rect: (self screenToCanvas: p).
			selectionRect _ selectionRect intersect: canvasForm boundingBox.
			self canvasChanged: selectionRect.
			World displayWorld]].
	showSelection _ false.
	self changed.
	World displayWorld.

	selectionRect area = 0 ifTrue: [selectionRect _ nil].
	^ selectionRect
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/12/2006 21:18'!
stampAt: aPoint
	"Perform a stamp operation at the given point. If there is no stamp form, grab one from the screen. Otherwise, stamp it at the given point in canvas coordinates."

	| canvasR |
	moveOrStampForm ifNil: [  "no stamp form yet; grab one"
		canvasR _ self selectRectangleStartingAt: aPoint.
		canvasR ifNil: [^ self].
		selectionRect _ nil.
		moveOrStampForm _ canvasForm copy: canvasR.
		moveOrStampForm ifNil: [^ self].  "empty selection rectangle"
		dragOffset _ moveOrStampForm extent // 2.
		self installCursorInHand: World activeHand. "update cursor"
		^ self].

	"stamp the stamp form"
	moveOrStampForm
		displayOn: canvasForm
		at: (aPoint - (moveOrStampForm extent // 2))
		rule: Form paint.
	canvasR _ (aPoint - (moveOrStampForm extent // 2)) extent: moveOrStampForm extent.
	self canvasChanged: canvasR.
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 1/6/2006 18:44'!
textHandleContainsPoint: aPoint
	"Answer true if the the text handle contains the given point in canvas coordinates."

	#text = palette mode ifFalse: [^ false].
	^ (textBox topLeft - 5 extent: 9) containsPoint: aPoint
! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 8/25/2008 19:25'!
textMouseDown: evt
	"Handle a mouse down event in text mode at the given point in canvas coordinates."

	| p |
	evt hand newKeyboardFocus: self.
	p _ self screenToCanvas: evt cursorPoint.

	(self textHandleContainsPoint: p) ifTrue: [  "click in drag handle"
		dragOffset _ textBox position - p.
		textDragMode _ #move.
		^ self].

	((textBox bounds insetBy: 2) containsPoint: p) ifTrue: [  "click in textBox"
		textDragMode _ #select.
		textBox ensureOSFont.
		textBox mouseDown: (evt copy setCursorPoint: p).
		evt hand newKeyboardFocus: self.  "take focus back from textBox"
		^ self].

	"click not in textBox or drag handle; do nothing"
	textDragMode _ #none.

! !

!PaintCanvas methodsFor: 'event handling' stamp: 'jm 9/11/2006 10:33'!
textMouseMove: evt
	"Draw and/or give feedback."

	| p |
	p _ self screenToCanvas: evt cursorPoint.
	#move = textDragMode ifTrue: [
		textBox position: ((p + dragOffset) max: 0@0).
		textBox extent: canvasForm extent - textBox position].
	#select = textDragMode ifTrue: [
		textBox mouseMove: (evt copy setCursorPoint: p)].
	self changed.
! !


!PaintCanvas methodsFor: 'stepping' stamp: 'jm 3/26/2008 11:50'!
step

	| h screenP canvasP |
	h _ World activeHand.
	screenP _ h gridPointRaw.
	canvasP _ self screenToCanvas: screenP.

	moveOrStampForm ifNotNil: [
		((palette mode = #stamp) or:
		 [(palette mode = #move) and: [h hasMouseFocus: self]]) ifTrue: [
			selectionRect ifNotNil: [self canvasChanged: selectionRect].
			selectionRect _ canvasP - dragOffset extent: moveOrStampForm extent.
			self canvasChanged: (selectionRect expandBy: 1)]].	"force redraw to show move/stamp feedback"

	(bounds containsPoint: screenP) ifFalse: [^ self].

	palette mode = #move ifTrue: [
		selectionRect ifNil: [h showTemporaryCursor: Cursor crossHair asXOCursorForm].
		(selectionRect notNil and: [Sensor anyButtonPressed not]) ifTrue: [
			(selectionRect containsPoint: canvasP)
				ifTrue: [h showTemporaryCursor: Cursor handOpen asXOCursorForm]
				ifFalse: [h showTemporaryCursor: Cursor crossHair asXOCursorForm]]].

	palette mode = #text ifTrue: [
		(self textHandleContainsPoint: canvasP)
			ifTrue: [h showTemporaryCursor: Cursor handOpen asXOCursorForm]
			ifFalse: [h showTemporaryCursor: Cursor normal asXOCursorForm]].
! !

!PaintCanvas methodsFor: 'stepping' stamp: 'jm 9/11/2006 13:33'!
stepTime

	^ 50
! !


!PaintCanvas methodsFor: 'drawing' stamp: 'jm 12/20/2005 13:13'!
drawBGOnBufferSrcRect: srcRect dstRect: dstRect
	"Draw a checkboard background pattern onto my buffer form with the given source and destination rectangles."

	| cm |
	(bgForm isNil or: [bgForm extent ~= canvasForm extent])
		ifTrue: [bgForm _ self makeCheckerboard].

	cm _ Bitmap
		with: ((Color gray: 0.9) pixelValueForDepth: 32)
		with: ((Color gray: 0.99) pixelValueForDepth: 32).
	(WarpBlt toForm: bufferForm)
		sourceForm: bgForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.
! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 12/19/2005 23:20'!
drawFeedbackOnBufferSrcRect: srcRect dstRect: dstRect
	"Draw my shape-drawing feedback scaled onto my buffer form with the given source and destination rectangles."

	| cm tempForm |
	palette color1 isTransparent ifFalse: [  "normal case: drawing with a color"
		cm _ Bitmap new: 2.
		cm at: 1 put: 0.  "transparent"
		cm at: 2 put: (palette color1 pixelValueForDepth: 32).
		(WarpBlt toForm: bufferForm)
			sourceForm: feedbackForm;
			colorMap: cm;
			cellSize: 1;
			combinationRule: Form paint;
			copyQuad: srcRect innerCorners toRect: dstRect.
		^ self].

	"special case: drawing with transparent"
	tempForm _ Form extent: bufferForm extent depth: 32.
	cm _ Bitmap new: 2.
	cm at: 1 put: 0.  "transparent"
	cm at: 2 put: 16rFFFFFFFF.
	(WarpBlt toForm: tempForm)
		sourceForm: feedbackForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

	cm _ Bitmap
		with: ((Color gray: 0.9) pixelValueForDepth: 32)
		with: (Color white pixelValueForDepth: 32).
	(WarpBlt toForm: tempForm)
		sourceForm: bgForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form and;
		copyQuad: srcRect innerCorners toRect: dstRect.

	(BitBlt toForm: bufferForm)
		sourceForm: tempForm;
		destRect: dstRect;
		combinationRule: Form paint;
		copyBits.
! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 9/11/2006 16:56'!
drawMoveOrStampFormSrcRect: srcRect dstRect: dstRect
	"Draw the Form being moved or stamped on the bufferForm at the given point."

	| r |
	(moveOrStampForm isNil | selectionRect isNil) ifTrue: [^ self].
	((palette mode = #stamp) and: [(bounds containsPoint: Sensor cursorPoint) not]) ifTrue: [^ self].

	r _ (selectionRect origin - srcRect origin extent: moveOrStampForm extent) scaleBy: scale.
	(WarpBlt toForm: bufferForm)
		sourceForm: moveOrStampForm;
		colorMap: (moveOrStampForm colormapIfNeededForDepth: 32);
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: moveOrStampForm boundingBox innerCorners toRect: r.

! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 9/11/2006 15:41'!
drawOn: aCanvas

	| damageRect srcRect dstRect |
	(bufferForm notNil and: [bufferForm extent = self extent]) ifFalse: [
		bufferForm _ Form extent: self extent depth: 32].

	damageRect _ bounds intersect: aCanvas clipRect.
	srcRect _ (self screenToCanvas: damageRect origin)
		extent: ((damageRect extent / scale) truncated + 1).
	dstRect _ 0@0 extent: srcRect extent * scale.

	"draw the checkboard background onto the buffer"
	self drawBGOnBufferSrcRect: srcRect dstRect: dstRect.

	"draw the paint layer onto the buffer"
	(WarpBlt toForm: bufferForm)
		sourceForm: canvasForm;
		colorMap: (canvasForm colormapIfNeededForDepth: 32);
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.

	"draw text, move/stamp, and feedback layers onto the buffer"
	self drawTextOnBufferSrcRect: srcRect dstRect: dstRect.
	moveOrStampForm ifNotNil: [self drawMoveOrStampFormSrcRect: srcRect dstRect: dstRect].
	selectionRect notNil ifTrue: [self drawSelectionOnBufferSrcRect: srcRect dstRect: dstRect].
	feedbackForm ifNotNil: [self drawFeedbackOnBufferSrcRect: srcRect dstRect: dstRect].

	(palette notNil and: [palette showRotationCenter]) ifTrue: [
		self drawRegistrationPointOnBufferSrcRect: srcRect dstRect: dstRect].

	"draw the buffer onto the canvas"
	(aCanvas copyClipRect: bounds)
		image: bufferForm
		at: (self canvasToScreen: srcRect origin)
		sourceRect: (0@0 extent: dstRect extent)
		rule: Form paint.
! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 12/20/2005 13:13'!
drawRegistrationPointOnBufferSrcRect: srcRect dstRect: dstRect
	"Draw the registation point."

	| r offset bitBlt x y |
	registrationPoint ifNil: [  "compute an initial registration point"
		r _ canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
		r area = 0
			ifTrue: [registrationPoint _ canvasForm center]
			ifFalse: [registrationPoint _ r center]].
	registrationPoint _ (registrationPoint max: 0@0) min: canvasForm extent.

	offset _ scale > 1 ifTrue: [scale // 2] ifFalse: [0].

	bitBlt _ (BitBlt toForm: bufferForm)
		clipRect: dstRect;
		fillColor: (Color quickHighLight: bufferForm depth);
		combinationRule: Form reverse.

	(registrationPoint x between: srcRect left and: srcRect right) ifTrue: [
		x _ dstRect left + (scale * (registrationPoint x - srcRect left)) rounded + offset.
		bitBlt
			destRect: (x@0 extent: 1@bufferForm height);
			copyBits].
	(registrationPoint y between: srcRect top and: srcRect bottom) ifTrue: [
		y _ dstRect top + (scale * (registrationPoint y - srcRect top)) rounded + offset..
		bitBlt
			destRect: (0@y extent: bufferForm width@1);
			copyBits].
! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 9/12/2006 21:25'!
drawSelectionOnBufferSrcRect: srcRect dstRect: dstRect
	"Draw the selection rectangle."

	| bitBlt r |
	(showSelection or: [palette mode = #move]) ifFalse: [^ self].
 
	bitBlt _ (BitBlt toForm: bufferForm)
		clipRect: dstRect;
		fillColor: (Color quickHighLight: bufferForm depth);
		combinationRule: Form reverse.

	r _ ((selectionRect translateBy: srcRect topLeft negated) scaleBy: scale) rounded translateBy: dstRect topLeft.
	bitBlt destRect: (r topLeft extent: r width@1); copyBits.
	bitBlt destRect: (r topLeft + (0@1) extent: 1@(r height - 1)); copyBits.
	bitBlt destRect: (r topRight + (-1@1) extent: 1@(r height - 1)); copyBits.
	bitBlt destRect: (r bottomLeft + (1@-1) extent: (r width - 2)@1); copyBits.
! !

!PaintCanvas methodsFor: 'drawing' stamp: 'jm 1/6/2006 18:38'!
drawTextOnBufferSrcRect: srcRect dstRect: dstRect
	"Draw my text box scaled onto my buffer form with the given source and destination rectangles."

	| frameColor selectionColor cm bgColor |
	(textBox isEmpty and: [#text ~= palette mode]) ifTrue: [
		textForm _ nil.
		^ self].  "don't show empty textbox"

	(textForm isNil or:
	 [textForm extent ~= canvasForm extent]) ifTrue: [  "create textForm if needed"
		textForm _ Form extent: canvasForm extent depth: 4].
	textForm unhibernate.
	textForm bits atAllPut: 0.  "quick clear"

	textBox drawOn: (FormCanvas on: textForm).  "draw text box"

	#text = palette mode
		ifTrue: [
			"draw text handle with color entry 6 (green) from the 4-bit color palette"
			textForm fill: (textBox topLeft - 5 extent: 8) fillColor: Color green.

			bgColor _ Color white.
			frameColor _ Color black.
			selectionColor _ Color r: 0.353 g: 0.607 b: 0.788]
		ifFalse: [
			bgColor _ frameColor _ selectionColor _ Color transparent].

	"draw the text form (4-bits) onto the buffer form at the appropriate scale mapping its colors in the process"
	cm _ Bitmap new: 16.
	cm at: 1 put: 0.  "transparent"
	cm at: 2 put: (textColor pixelValueForDepth: 32).
	cm at: 3 put: (frameColor pixelValueForDepth: 32).
	cm at: 4 put: (selectionColor pixelValueForDepth: 32).
	cm at: 5 put: (bgColor pixelValueForDepth: 32).
	cm at: 6 put: (Color black pixelValueForDepth: 32).	"corner handle"
	(WarpBlt toForm: bufferForm)
		sourceForm: textForm;
		colorMap: cm;
		cellSize: 1;
		combinationRule: Form paint;
		copyQuad: srcRect innerCorners toRect: dstRect.
! !


!PaintCanvas methodsFor: 'private-move tool' stamp: 'jm 9/18/2006 16:09'!
clearMoveState

	selectionRect _ nil.
	moveOrStampForm _ nil.
	transformSrcForm _ nil.
	transformUndoList _ nil.
! !

!PaintCanvas methodsFor: 'private-move tool' stamp: 'jm 9/18/2006 15:47'!
commitMove
	"Commit the last move operation, if any."

	(moveOrStampForm isNil | selectionRect isNil) ifTrue: [^ self].

	palette mode = #move ifTrue: [
		moveOrStampForm
			displayOn: canvasForm
			at: selectionRect origin
			rule: Form paint.
		self changed].

	self clearMoveState.

! !

!PaintCanvas methodsFor: 'private-move tool' stamp: 'jm 3/26/2008 11:48'!
moveToolMouseDown: aPoint
	"Mouse up with move tool selected."

	(selectionRect notNil and:
	 [(selectionRect containsPoint: aPoint) not]) ifTrue: [
		"click outside current selection; select again"
		self commitMove.
		selectionRect _ nil.
		self changed.
		World displayWorldSafely].  "force redraw to remove old selection"

	selectionRect ifNil: [  "choose a selection rectangle"
		selectionRect _ self selectRectangleStartingAt: aPoint.
		moveOrStampForm _ nil.
		^ self changed].

	self startMove.

	dragOffset _ aPoint - selectionRect origin.
	World activeHand showTemporaryCursor: Cursor handClosed asXOCursorForm.
	self changed.
! !

!PaintCanvas methodsFor: 'private-move tool' stamp: 'jm 9/29/2006 10:06'!
startMove
	"Start a move operation if there is a selection rectangle and if a move operation is not already in progress. (A move is in progress if moveOrStampForm is not nil.) Copy the canvas bits within the selection rectangle and clear that part of the canvas."

	transformSrcForm ifNotNil: [self saveTransformForUndo].
	moveOrStampForm notNil | selectionRect isNil ifTrue: [^ self].

	self saveForUndo.
	moveOrStampForm _ canvasForm copy: selectionRect.
	canvasForm fill: selectionRect fillColor: Color transparent.
! !


!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 9/18/2006 15:35'!
applyTransform
	"Apply the current transform."

	| f degrees |
	f _ transformSrcForm.
	degrees _ transformDegrees.
	transformHFlip ifTrue: [degrees _ degrees negated].
	transformVFlip ifTrue: [degrees _ degrees negated].
	degrees ~= 0.0 ifTrue: [f _ f rotateBy: degrees].
	transformScale ~= 1.0 ifTrue: [
		f _ f magnify: f boundingBox by: transformScale smoothing: 1].
	transformHFlip ifTrue: [	f _ f flipBy: #horizontal centerAt: f boundingBox center].
	transformVFlip ifTrue: [	f _ f flipBy: #vertical centerAt: f boundingBox center].
	f _ f copy: (f rectangleEnclosingPixelsNotOfColor: Color transparent).
	f offset: nil.
	moveOrStampForm _ f.
	selectionRect _ (selectionRect center - (f extent // 2)) extent: f extent.
	self changed.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'ee 6/27/2008 17:45'!
magnify
	"Prompt the user for a percent and rescale by that factor."

	| percent s |
	percent _ transformScale ifNil: [100] ifNotNil: [(100 * transformScale) rounded].
	s _ StringDialog
		ask: 'Percent? (100 gives original size)'
		initialAnswer: percent printString.
	s isEmpty ifTrue: [^ self].
	[percent _ s asNumber max: 1] ifError: [^ self nonNumberWarning].

	transformScale _ 1.0.
	self scaleBy: percent / 100.0.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 11/8/2007 10:30'!
nonNumberWarning

	DialogBoxMorph inform: 'Please enter a number' localized.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 1/3/2007 20:30'!
prepareToTransform

	| f r |
	transformSrcForm ifNotNil: [^ self].

	(selectionRect isNil or: [palette mode ~= #move]) ifTrue: [
		self selectAll.
		selectionRect ifNil: [^ self]].  "empty canvas; do nothing".

	self startMove.

	f _ moveOrStampForm.
	r _ f rectangleEnclosingPixelsNotOfColor: Color transparent.
	(r width > 0) & (r height > 0) ifFalse: [transformSrcForm _ nil. ^ self].

	transformSrcForm _ moveOrStampForm _ f copy: r.
	selectionRect _ (selectionRect origin + r origin) extent: moveOrStampForm extent.

	transformScale _ 1.0.
	transformDegrees _ 0.
	transformHFlip _ false.
	transformVFlip _ false.
	transformUndoList _ nil.  "clear undo list"
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 9/29/2006 10:02'!
redoTransform

	| rec |
	transformUndoList ifNil: [^ self beep].  "no undo entries yet"
	transformUndoIndex < 2 ifTrue: [^ self beep].  "nothing more to redo"
	transformUndoIndex _ transformUndoIndex - 1.

	rec _ transformUndoList at: transformUndoIndex.
	transformScale _ rec at: 1.
	transformDegrees _ rec at: 2.
	transformHFlip _ rec at: 3.
	transformVFlip _ rec at: 4.
	selectionRect _ Rectangle center: (rec at: 5) extent: selectionRect extent.
	self applyTransform.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'ee 6/27/2008 17:45'!
rotate: clockwiseFlag

	| s degrees |
	s _ StringDialog ask: 'Rotation degrees?' initialAnswer: '30'.
	s isEmpty ifTrue: [^ self].
	[degrees _ s asNumber.
	clockwiseFlag
		ifTrue: [self rotateCWBy: degrees]
		ifFalse: [self rotateCWBy: degrees negated]
	] ifError: [
		^ self nonNumberWarning].
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 9/20/2006 14:53'!
rotateCWBy: degrees
	"Rotate my contents clockwise by the given angle in degrees."

	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	self saveTransformForUndo.
	transformDegrees _ transformDegrees + degrees.
	self applyTransform.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 9/29/2006 10:00'!
saveTransformForUndo
	"Save the current transform to allow undoing." 

	transformUndoList ifNil: [  "create transform undo list"
		transformUndoList _ OrderedCollection new.
		transformUndoIndex _ 0].

	transformUndoList addFirst: {
		transformScale.
		transformDegrees.
		transformHFlip.
		transformVFlip.
		selectionRect center}.

	transformUndoIndex _ 0.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 12/15/2006 18:21'!
scaleBy: scaleFactor
	"Scale my contents by the given factor."

	| maxScale |
	palette showRotationCenter: false.
	self prepareToTransform.
	transformSrcForm ifNil: [^ self].
	maxScale _ 1000.0 / (transformSrcForm width max: transformSrcForm height).
	self saveTransformForUndo.
	transformScale _ (transformScale * scaleFactor) min: maxScale.
	self applyTransform.
! !

!PaintCanvas methodsFor: 'private-tranforms' stamp: 'jm 9/29/2006 10:02'!
undoTransform

	| rec |
	transformUndoList ifNil: [^ self beep].  "no undo entries yet"
	transformUndoIndex >= transformUndoList size ifTrue: [^ self beep].  "nothing more to undo"
	transformUndoIndex = 0 ifTrue: [
		self saveTransformForUndo.
		transformUndoIndex _ 1].

	transformUndoIndex _ transformUndoIndex + 1.
	rec _ transformUndoList at: transformUndoIndex.
	transformScale _ rec at: 1.
	transformDegrees _ rec at: 2.
	transformHFlip _ rec at: 3.
	transformVFlip _ rec at: 4.
	selectionRect _ Rectangle center: (rec at: 5) extent: selectionRect extent.
	self applyTransform.
! !


!PaintCanvas methodsFor: 'private' stamp: 'jm 9/19/2006 08:47'!
brushCursorSize: brushSize color: brushColor
	"Answer a round brush cursor of the given size and color."

	^ self class brushCursorSize: brushSize color: brushColor scale: scale
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 9/12/2006 19:00'!
canvasChanged: aRectangle
	"The given rectangle of the canvas form has changed. Report this change to my owner in screen coordinates."
	"Note: The extra pixel of expansion is for the selection rectangle, which draws one pixel outside the enclosed pixels."

	| r |
	r _ ((aRectangle origin - (scrollX@scrollY) - 1) * scale) floor corner:
		((aRectangle corner - (scrollX@scrollY) + 1) * scale) ceiling.
	owner invalidRect: (r translateBy: bounds origin).
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 11/19/2005 10:41'!
canvasToScreen: aPoint
	"Answer the given canvas point in screen coordinates."

	^ bounds origin + ((aPoint - (scrollX@scrollY)) * scale) rounded
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 12/2/2005 13:15'!
centerAt: aPoint
	"Center the viewable area on the given point in the canvasForm--or as close as possible at the current scale."

	| limits |
	limits _ (canvasForm extent - (self extent // scale)) max: (0@0).
	scrollX _ (aPoint x - (self width // (2 * scale))) within: 0 and: limits x.
	scrollY _ (aPoint y - (self height // (2 * scale))) within: 0 and: limits y.
	(self owner respondsTo: #updateScrollbars) ifTrue: [self owner updateScrollbars].
	self changed.

! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 1/5/2006 20:34'!
clearTextBox

	textBox contents: ''.
	textBox position: (self extent // 2) - (50@25).
	textBox extent: (self extent - textBox topLeft).
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 9/12/2006 19:21'!
copyMoveSelection
	"If we've made a selection with the move tool but haven't yet picked it up, make a copy of the selection."

	| f r |
	((palette mode = #move) & selectionRect notNil) ifFalse: [^ self beep].

	moveOrStampForm
		ifNil: [moveOrStampForm _ canvasForm copy: selectionRect]
		ifNotNil: [
			"commit current move, then copy bits"
			self saveForUndo.
			f _ moveOrStampForm.
			r _ selectionRect.
			self commitMove.
			moveOrStampForm _ f.
			selectionRect _ r].

	selectionRect _ selectionRect translateBy: 5@5.
	self changed.! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 10/31/2006 08:51'!
deleteOrCropCurrentSelection: evt

	| r selForm |
	selectionRect ifNil: [^ self].  "no selection"
	moveOrStampForm ifNotNil: [
		r _ selectionRect.
		self commitMove.
		selectionRect _ r].
	self saveForUndo.
	evt shiftPressed
		ifTrue: [  "crop everything outside of the selection rectangle"
			selForm _ canvasForm copy: selectionRect.
			canvasForm fillColor: Color transparent.
			selForm displayOn: canvasForm at: selectionRect origin rule: Form over]
		ifFalse: [  "delete current selection"
			canvasForm fill: selectionRect fillColor: Color transparent].
	selectionRect _ moveOrStampForm _ nil.
	self changed.
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 5/11/2009 22:06'!
extractProjectFrom: aByteArray
	"Answer a Scratch project (i.e. a ScratchStageMorph possibly containing sprites) from the given ByteArray. Answer nil if the project cannot be unpacked."

	| s version proj |
	s _ ReadStream on: aByteArray.
	version _ ObjStream scratchFileVersionFrom: (s next: 10) asString.
	version = 0 ifTrue: [
		s position: 0.
		proj _ ObjStream new readObjFrom: s showProgress: true].
	(version = 1) | (version = 2) ifTrue: [
		s skip: s uint32.  "skip header"
		proj _ ObjStream new readObjFrom: s showProgress: true].

	proj class = ScratchStageMorph ifFalse: [
		version > 2
			ifTrue: [self error: 'Project created by a later version of Scratch']
			ifFalse: [self error: 'Problem reading project.'].
		^ nil].

	ScriptableScratchMorph buildBlockSpecDictionary.
	proj allMorphsDo: [:m |
		(m isKindOf: ScriptableScratchMorph) ifTrue: [  "covert to new blocks"
			m convertStacksToTuples.
			m convertTuplesToStacks]].

	^ proj
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 11/18/2005 12:55'!
fillAt: aPoint
	"Perform a fill operation starting at the given point."

	| fillStyle |
	fillStyle _ palette fillStyle.

	#color = fillStyle ifTrue: [
		canvasForm shapeFill: palette color1 interiorPoint: aPoint].
	#erase = fillStyle ifTrue: [
		canvasForm shapeFill: Color transparent interiorPoint: aPoint].
	#hGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #horizontal].
	#vGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #vertical].
	#rGradient = fillStyle ifTrue: [
		canvasForm shapeFillGradientFrom: palette color1 to: palette color2 at: aPoint type: #radial].

	self changed.! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 5/19/2009 13:54'!
importCostumeFromSprite: fName
	"Return the current costume from the give sprite file."

	| data  f importedStage |
	(FileDirectory default fileExists: fName) ifFalse: [^ nil].
	f _ (FileStream readOnlyFileNamed: fName) binary.
	f ifNil: [^ nil].
	data _ f contentsOfEntireFile.

	[importedStage _ self extractProjectFrom: data] ifError: [^ nil].

	importedStage submorphs do: [:m |
		(m isKindOf: ScratchSpriteMorph) ifTrue: [
			^ m costumeForm]].

	^ nil
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 3/26/2008 11:47'!
installCursorInHand: h
	"Note: use XO cursors on XO except for paint and erase, which should be a their actual size."

	| mode cursor |
	h showTemporaryCursor: nil.
	palette showRotationCenter ifTrue: [^ self].

	mode _ palette mode.
	#eyedropper = mode ifTrue: [h showTemporaryCursor: Cursor eyeDropper asXOCursorForm].
	#fill = mode ifTrue: [h showTemporaryCursor: Cursor paintBucket asXOCursorForm].
	(#(line oval rect) includes: mode) ifTrue: [h showTemporaryCursor: Cursor crossHair asXOCursorForm].

	(#(stamp move) includes: mode) ifTrue: [
		moveOrStampForm
			ifNil: [h showTemporaryCursor: Cursor crossHair asXOCursorForm]
			ifNotNil: [
				#stamp = mode
					ifTrue: [h showTemporaryCursor: Cursor blank]
					ifFalse: [h showTemporaryCursor: Cursor handOpen asXOCursorForm]]].

	#erase = mode ifTrue: [
		cursor _ self brushCursorSize: palette brushSize color: Color transparent.
		h
			showTemporaryCursor: cursor
			hotSpotOffset: (cursor center truncateTo: scale)].

	#paint = mode ifTrue: [
		cursor _ self brushCursorSize: palette brushSize color: palette color1.
		h
			showTemporaryCursor: cursor
			hotSpotOffset: (cursor center truncateTo: scale)].
! !

!PaintCanvas methodsFor: 'private' stamp: 'EMP 12/22/2015 15:48'!
makeCheckerboard
	"Create a checkboard form the same size as my canvas form and fill it with a checkboard pattern (used to show transparnecy). "

	| f squareSize blt |
	f _ Form extent: canvasForm extent depth: 1.
	squareSize _ 4.
	f fillColor: (Color white).

	blt _ (BitBlt toForm: f)
		fillColor: Color black;
		combinationRule: Form over;
		destRect: (0@0 extent: squareSize).

	0 to: f height by: (2 * squareSize) do: [:y |
		blt destY: y.
		0 to: f width by: (2 * squareSize) do: [:x | blt destX: x; copyBits].
		blt destY: y + squareSize.
		squareSize to: f width by: (2 * squareSize) do: [:x | blt destX: x; copyBits]].

	^ f
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 12/2/2005 12:52'!
newContents: aForm center: centerPoint
	"Replace the contents of my canvas with the new form after some transformation."

	| r f p |
	r _ aForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	r = aForm boundingBox
		ifTrue: [f _ aForm]
		ifFalse: [f _ aForm copy: r].

	"adjust canvasForm extent if necessary"
	((f width > canvasForm width) |
	 (f height > canvasForm height) |
	 ((f width < canvasForm width) & (canvasForm width > self width)) |
	 ((f height < canvasForm height) & (canvasForm height > self height))) ifTrue: [
		canvasForm _ Form extent: (self extent max: f extent) depth: canvasForm depth].

	p _ centerPoint - (f extent // 2).				"try to center"
	p _ p min: canvasForm extent - f extent.		"but don't go off bottom or right"
	p _ p max: 0@0.								"and don't go off the top or left"

	canvasForm fillColor: Color transparent.
	f displayOn: canvasForm at: p.

	self centerAt: (p + (f extent // 2)).

! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 9/12/2006 18:33'!
nudge: aPoint

	selectionRect ifNotNil: [
		self canvasChanged: selectionRect.
		selectionRect _ selectionRect translateBy: aPoint.
		self canvasChanged: selectionRect].
	! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 12/23/2005 20:05'!
saveForUndo
	"Record my current canvas Form for undo."
	"Note: The most recent canvas is added to the front of the undo list. If the undo list is already of maximum size, the oldest
entry is removed and, if possible, recycled."

	| f |
	undoIndex > 0 ifTrue: [undoList _ undoList copyFrom: undoIndex + 1 to: undoList size].

	((undoList size >= MaxUndo) and:
	 [undoList last extent = canvasForm extent])
		ifTrue: [f _ undoList removeLast. f unhibernate]
		ifFalse: [f _ Form extent: canvasForm extent depth: canvasForm depth].

	"quickly copy current canvas contents; f must be same size & depth and unhibernated"
	canvasForm unhibernate.
	f bits replaceFrom: 1 to: f bits size with: canvasForm bits startingAt: 1.

	undoList addFirst: f.
	undoIndex _ 0.
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 11/19/2005 10:43'!
screenToCanvas: aPoint
	"Answer the given screen point in canvas coordinates."

	^ ((aPoint - bounds origin) // scale) + (scrollX@scrollY)
! !

!PaintCanvas methodsFor: 'private' stamp: 'jm 9/12/2006 19:08'!
selectAll
	"Select all non-transparent pixels and switch to move mode."

	| r |
	self commitMove.
	r _ canvasForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	r area = 0 ifTrue: [^ self].
	selectionRect _ r.
	palette mode: #move.
	self changed.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

PaintCanvas class
	instanceVariableNames: ''!

!PaintCanvas class methodsFor: 'class initialization' stamp: 'jm 6/26/2006 10:20'!
initialize
	"self initialize"

	MaxUndo _ 10.
	EnlargeFactor _ 1.2.
	BrushDict _ Dictionary new.
	CanvasExtent _ 480@360.
! !


!PaintCanvas class methodsFor: 'accessing' stamp: 'jm 6/26/2006 10:20'!
canvasExtent

	^ CanvasExtent
! !


!PaintCanvas class methodsFor: 'brush creation' stamp: 'jm 12/22/2005 15:29'!
brushCursorSize: brushSize color: brushColor scale: scale
	"Answer a round brush cursor of the given size and color."
	"BrushDict _ Dictionary new. (PaintCanvas new brushCursorSize: 21 color: Color yellow) display"

	| outline f cm hole c |
	(BrushDict includesKey: brushSize) ifFalse: [
		outline _ Form dotOfSize: brushSize.
		f _ ColorForm extent: outline extent depth: 2.
		cm _ Bitmap with: 0 with: (brushSize > 2 ifTrue: [1] ifFalse: [2]).
		(BitBlt toForm: f)
			sourceForm: outline;
			destRect: f boundingBox;
			combinationRule: Form paint;
			colorMap: cm;
			copyBits.
		brushSize > 2 ifTrue: [
			hole _ Form dotOfSize: brushSize - 2.
			cm _ Bitmap with: 0 with: 2.
			(BitBlt toForm: f)
				sourceForm: hole;
				sourceRect: hole boundingBox;
				destOrigin: 1@1;
				combinationRule: Form paint;
				colorMap: cm;
				copyBits].
		BrushDict at: brushSize put: f].

	c _ brushColor.
	c isTransparent & (brushSize <= 2) ifTrue: [c _ Color black].  "small erasers"
	f _ (BrushDict at: brushSize) magnifyBy: scale.
	f colors: (Array with: Color transparent with: Color black with: c with: Color transparent).
	^ f
! !


PaintCanvas initialize!
