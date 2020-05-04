Class {
	#name : #CEIfOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'x',
		'condition',
		'jumpTarget'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #accessing }
CEIfOperation >> condition [
	^ condition
]

{ #category : #accessing }
CEIfOperation >> condition: anObject [
	condition := anObject
]

{ #category : #printing }
CEIfOperation >> description [
	
	^ 'if t', x instructionID asString, ' = ', condition asString, ' then B', successors first blockID asString, ' else B', successors second blockID asString
]

{ #category : #accessing }
CEIfOperation >> jumpTarget: aBlock [ 

	jumpTarget := aBlock
]

{ #category : #accessing }
CEIfOperation >> x [
	^ x
]

{ #category : #accessing }
CEIfOperation >> x: anObject [
	x := anObject
]
