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

{ #category : #replacing }
CEIfOperation >> replaceSuccessor: aCEBlock by: aCEBlock2 [ 
	
	jumpTarget = aCEBlock ifTrue: [ 
		^ jumpTarget := aCEBlock2 ].
	falseConditionJumpTarget = aCEBlock ifTrue: [ 
		^ falseConditionJumpTarget := aCEBlock2 ].
	self error: 'Invalid successor in branch operation'
]

{ #category : #accessing }
CEIfOperation >> trueConditionJumpTarget [
	
	^ jumpTarget
]

{ #category : #accessing }
CEIfOperation >> trueConditionJumpTarget: aCEBlock [ 
	
	jumpTarget := aCEBlock
]

{ #category : #accessing }
CEIfOperation >> x [
	^ x
]

{ #category : #accessing }
CEIfOperation >> x: anObject [
	x := anObject
]
