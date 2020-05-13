Class {
	#name : #CEJumpOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'jumpTarget'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #accessing }
CEJumpOperation class >> jumpTarget: aTargetCEBlock [
	^ self new jumpTarget: aTargetCEBlock
]

{ #category : #printing }
CEJumpOperation >> description [
	
	^ 'goto B', jumpTarget id asString
]

{ #category : #accessing }
CEJumpOperation >> jumpTarget [
	
	^ jumpTarget
]

{ #category : #accessing }
CEJumpOperation >> jumpTarget: aBlock [
	
	jumpTarget := aBlock
]

{ #category : #replacing }
CEJumpOperation >> replaceSuccessor: aCEBlock by: aCEBlock2 [ 
	
	self assert: jumpTarget = aCEBlock.
	jumpTarget := aCEBlock2
]
