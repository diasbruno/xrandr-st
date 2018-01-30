PackageManifest subclass: #ManifestXrandr
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xrandr'!
!ManifestXrandr commentStamp: '<historical>' prior: 0!
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser!


Object subclass: #Xrandr
	instanceVariableNames: 'window panel displayView displayDropdown settingsDropdown data currentDisplay'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xrandr'!
!Xrandr commentStamp: '<historical>' prior: 0!
Interface to Xrandr.!


!Xrandr methodsFor: 'instance creation' stamp: 'BrunoDias 1/29/2018 05:38'!
open
	window openInWorld.! !


!Xrandr methodsFor: 'initialization' stamp: 'BrunoDias 1/29/2018 09:32'!
setCurrentDisplay: aIndex
	currentDisplay := aIndex.
	self updateDisplaySettingsDropdown! !

!Xrandr methodsFor: 'initialization' stamp: 'BrunoDias 1/30/2018 02:24'!
initialize
	| st bounds m1 m2 t1 t2 |
	window := StandardWindow new.
	window title: 'Xrandr' translated.
	
	bounds := window layoutBounds.
	
	panel := PanelMorph new.

	currentDisplay := 0.
	data := self retrieveData.
	
	displayView := PanelMorph new.
	displayView fillStyle: Color white.
	displayView width: bounds corner x; height: 300.
	
	displayDropdown := DropListMorph new.
	displayDropdown list: self getDisplayList.
	
	displayDropdown on: self list: #getDisplayList 
									 selected: #getCurrentDisplay
									 changeSelected: #setCurrentDisplay:.  
	
	settingsDropdown := DropListMorph new.
	self updateDisplaySettingsDropdown.
 
	m1 := Morph new 
	      color: Color blue;
			width: 100;
			height: 100.
	m2 := Morph new 
	      color: Color red;
			left: 100;
			width: 100; 
			height: 100.
	t1 := TextContainer new setText: 'asdf'.
	t2 := TextContainer new setText: 'b'.
	displayView addMorph: m1;
					addMorph: m2;
					addMorph: t1;
					addMorph: t2.
	
	st := TableLayout new.
	
	panel addMorph: displayView.
	panel addMorph: settingsDropdown.
	panel addMorph: displayDropdown.

	st layout: panel in: window bounds.

	window addMorph: panel frame: LayoutFrame identity.! !

!Xrandr methodsFor: 'initialization' stamp: 'BrunoDias 1/29/2018 09:13'!
retrieveData
	^ (XrandrData parse: XrandrData command) asArray ! !


!Xrandr methodsFor: 'as yet unclassified' stamp: 'BrunoDias 1/29/2018 09:26'!
getDisplayList
	^ data collect: [ :display | display name ].! !

!Xrandr methodsFor: 'as yet unclassified' stamp: 'BrunoDias 1/29/2018 09:24'!
getCurrentDisplay
	^ currentDisplay! !

!Xrandr methodsFor: 'as yet unclassified' stamp: 'BrunoDias 1/29/2018 09:35'!
getSettingsForSelected	
	^ currentDisplay = 0 ifTrue: [ Array new. ]
			   			      ifFalse: [ (data at: currentDisplay) settings collect: [ :setting |
									setting viewport 
								] ].! !

!Xrandr methodsFor: 'as yet unclassified' stamp: 'BrunoDias 1/29/2018 09:32'!
updateDisplaySettingsDropdown
	settingsDropdown list: self getSettingsForSelected! !


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

Xrandr class
	instanceVariableNames: ''!

!Xrandr class methodsFor: 'running' stamp: 'BrunoDias 1/29/2018 05:40'!
run
	^ self new open.
! !


Object subclass: #XrandrData
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xrandr'!
!XrandrData commentStamp: '<historical>' prior: 0!
Retrieve and parse the data from xrandr command.!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

XrandrData class
	instanceVariableNames: ''!

!XrandrData class methodsFor: 'parsing' stamp: 'BrunoDias 1/29/2018 06:00'!
parse: aString
	| rawLines displaysAndInfo currentDisplay allDisplays |
	rawLines := aString lines.
	displaysAndInfo := rawLines copyFrom: 2 to: rawLines size.
	currentDisplay := nil.
	allDisplays := OrderedCollection new.
	displaysAndInfo
		do: [ :line | 
			(line at: 1) = Character space
				ifTrue: [ currentDisplay addSetting: line. ]
				ifFalse: [ 
					currentDisplay := XrandrDisplayInfo newWithInfo: line.
					allDisplays add: currentDisplay. ] ].
	^ allDisplays! !


!XrandrData class methodsFor: 'combining' stamp: 'BrunoDias 1/29/2018 05:42'!
command
	"Run the xrandr command and return its output."
	^ (CommandShell pipeline: 'xrandr') output.! !


Object subclass: #XrandrDisplayInfo
	instanceVariableNames: 'name settings'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xrandr'!
!XrandrDisplayInfo commentStamp: '<historical>' prior: 0!
Display information.!



!XrandrDisplayInfo methodsFor: 'adding' stamp: 'BrunoDias 1/29/2018 05:58'!
addSetting: aString
	| info |
	info := (aString trimBoth splitOn: Character space) reject: [ :i | i = '' ].
	self settings add: (XrandrDisplaySettings newWithViewport: (info at: 1) 
														  andFreqs: (info copyFrom: 2 to: info size)).! !


!XrandrDisplayInfo methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 01:37'!
settings: aCollection
	settings := aCollection! !

!XrandrDisplayInfo methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 01:36'!
settings
	^ settings! !

!XrandrDisplayInfo methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 01:28'!
name
	^ name! !

!XrandrDisplayInfo methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 01:27'!
name: aString
	name := aString! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

XrandrDisplayInfo class
	instanceVariableNames: ''!

!XrandrDisplayInfo class methodsFor: 'initialization' stamp: 'BrunoDias 1/29/2018 06:27'!
newWithInfo: aString
	| info strarr | 
	info := XrandrDisplayInfo new.
	strarr := aString splitOn: Character space.
	info name: (strarr at: 1).
	info settings: OrderedCollection new.
	
	^ info! !


Object subclass: #XrandrDisplaySettings
	instanceVariableNames: 'viewport freq'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Xrandr'!
!XrandrDisplaySettings commentStamp: '<historical>' prior: 0!
Holds each setting of a display.!


!XrandrDisplaySettings methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 05:57'!
viewport: anObject
	viewport := anObject! !

!XrandrDisplaySettings methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 05:56'!
freq
	^ freq! !

!XrandrDisplaySettings methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 05:56'!
freq: anObject
	freq := anObject! !

!XrandrDisplaySettings methodsFor: 'accessing' stamp: 'BrunoDias 1/29/2018 05:57'!
viewport
	^ viewport! !


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

XrandrDisplaySettings class
	instanceVariableNames: ''!

!XrandrDisplaySettings class methodsFor: 'initialization' stamp: 'BrunoDias 1/29/2018 05:55'!
newWithViewport: aString andFreqs: aList
	| setting |
	
	setting := self new.
	
	setting viewport: aString.
	setting freq: aList.
	
	^ setting! !
