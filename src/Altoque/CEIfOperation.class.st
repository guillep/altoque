Class {
	#name : #CEIfOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'x',
		'condition',
		'jumpTarget',
		'falseConditionJumpTarget'
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
	
	^ 'if t', x instructionID asString, ' = ', condition asString, ' then B', jumpTarget blockID asString, ' else B???'
]

{ #category : #accessing }
CEIfOperation >> falseConditionJumpTarget [
	
	^ falseConditionJumpTarget
]

{ #category : #accessing }
CEIfOperation >> falseConditionJumpTarget: aCEBlock [ 
	falseConditionJumpTarget := aCEBlock
]

{ #category : #accessing }
CEIfOperation >> jumpTarget: aBlock [ 

	jumpTarget := aBlock
]

{ #category : #accessing }
CEIfOperation >> trueConditionJumpTarget [
	
	^ jumpTarget
]

{ #category : #accessing }
CEIfOperation >> x [
	^ x
]

{ #category : #accessing }
CEIfOperation >> x: anObject [
	x := anObject
]
