Class {
	#name : #CEJumpOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'jumpTarget'
	],
	#category : #Altoque
}

{ #category : #printing }
CEJumpOperation >> description [
	
	^ 'goto B', successors anyOne blockID asString 
]

{ #category : #accessing }
CEJumpOperation >> jumpTarget [
	
	^ jumpTarget
]

{ #category : #accessing }
CEJumpOperation >> jumpTarget: aBlock [
	
	jumpTarget := aBlock
]