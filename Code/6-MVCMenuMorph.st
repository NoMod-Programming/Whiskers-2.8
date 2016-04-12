MenuMorph subclass: #MVCMenuMorph
	instanceVariableNames: 'done selectedItem '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Morphic-Menus'!
!MVCMenuMorph commentStamp: '<historical>' prior: 0!
I simulate the MVC menu classes PopUpMenu, SelectionMenu, and CustomMenu when running in a Morphic world. I am also used to implement Utilities>informUser:during:.!


!MVCMenuMorph methodsFor: 'invoking' stamp: 'jm 2/13/2009 16:57'!
abort

	done _ true.
	self delete.
	World activeHand newMouseFocus: nil.
! !

!MVCMenuMorph methodsFor: 'invoking' stamp: 'sma 4/30/2000 10:40'!
displayAt: aPoint during: aBlock
	"Add this menu to the Morphic world during the execution of the given block."

	Smalltalk isMorphic ifFalse: [^ self].

	World addMorph: self centeredNear: aPoint.
	self world displayWorld.  "show myself"
	aBlock value.
	self delete! !

!MVCMenuMorph methodsFor: 'invoking' stamp: 'jm 10/13/2002 18:21'!
informUserAt: aPoint during: aBlock
	"Add this menu to the Morphic world during the execution of the given block."

	| title |
	Smalltalk isMorphic ifFalse: [^ self].

	title _ submorphs first submorphs first.
	self isHidden: true.
	aBlock value: [:string |
		self isHidden ifTrue: [
			World addMorph: self centeredNear: aPoint.
			self isHidden: false].
		title contents: string.
		self setConstrainedPositionFrom: Sensor cursorPoint.
		self changed.
		World displayWorld].  "show myself"
	self delete.
	World displayWorld! !

!MVCMenuMorph methodsFor: 'invoking' stamp: 'jm 12/7/2005 09:35'!
invokeAt: aPoint in: aWorld
	"Add this menu to the given world centered at the given point. Wait for the user to make a selection and answer it. The selection value returned is an integer in keeping with PopUpMenu, if the menu is converted from an MVC-style menu."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop." 

	self popUpAt: aPoint forHand: aWorld activeHand.
	done _ false.
	[self isInWorld & done not] whileTrue: [aWorld doOneCycle].
	self delete.
	^ selectedItem
! !

!MVCMenuMorph methodsFor: 'invoking' stamp: 'EMP 10/11/2015 19:44'!
labelColor: aColor
	self items do: [:m | m color: aColor].! !


!MVCMenuMorph methodsFor: 'private' stamp: 'jm 5/6/1998 19:59'!
cancelValue: selectionOrNil
	"Set the value to be returned if the user cancels without making a selection."

	selectedItem _ selectionOrNil.
! !

!MVCMenuMorph methodsFor: 'private' stamp: 'di 3/14/1999 13:12'!
invokeItem: aMenuItem event: evt
	"Called by the MenuItemMorph that the user selects.
	Record the selection and set the done flag to end this interaction."

	selectedItem _ aMenuItem selector.
	done _ true.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

MVCMenuMorph class
	instanceVariableNames: ''!

!MVCMenuMorph class methodsFor: 'instance creation' stamp: 'EMP 12/3/2015 12:33'!
from: t1 title: t2 
	| t3 t4 t5 t6 t7 t8 t9 t10 t11 |
	t3 _ self new.
	t1 isHorizontal ifTrue: [t3 orientation: #horizontal].
	t2
		ifNotNil: [t2 isEmpty ifFalse: [t3 addTitle: t2]].
	t7 _ t1 labelString.
	t4 _ t7 asString findTokens: String cr.
	t10 _ t1 icons.
	t10 ifNil: [t10 _ Array empty].
	t10 size = t4 size ifFalse: [t10 _ Array new: t4 size].
	t7 isText
		ifTrue: 
			[t8 _ 1.
			t4 _ t4
						collect: 
							[:t12 | 
							t8 _ t7 asString findString: t12 startingAt: t8.
							t9 _ TextEmphasis new emphasisCode: (t7 emphasisAt: t8).
							t12 asText addAttribute: t9]].
	t5 _ t1 lineArray.
	t5 ifNil: [t5 _ #()].
	t3 cancelValue: 0.
	t6 _ (1 to: t4 size) asArray.
	ScratchTranslator isRTL & t1 isHorizontal
		ifTrue: 
			[t4 size
				to: 1
				by: -1
				do: 
					[:t13 | 
					t11 _ t10 at: t13.
					t11 isNil
						ifTrue: [t3 add: (t4 at: t13)
								action: (t6 at: t13)]
						ifFalse: [t3
								addIcon: t11 first
								tooltip: t11 second
								action: (t6 at: t13)].
					(t5 includes: t13)
						ifTrue: [t3 addLine]].
			nil]
		ifFalse: 
			[1 to: t4 size do: 
				[:t13 | 
				t11 _ t10 at: t13.
				t11 isNil
					ifTrue: [t3 add: (t4 at: t13)
							action: (t6 at: t13)]
					ifFalse: [t3
							addIcon: t11 first
							tooltip: t11 second
							action: (t6 at: t13)].
				(t5 includes: t13)
					ifTrue: [t3 addLine]].
			nil].
	(ScratchTranslator canRenderUnicode
		and: [t7 notNil
				and: [t7 isUnicode or: [(UTF8 withAll: t7) isMacRoman not]]])
		ifTrue: [t3 convertItemsToUTF8].
	^ t3! !
