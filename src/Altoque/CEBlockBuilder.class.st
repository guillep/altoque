Class {
	#name : #CEBlockBuilder,
	#superclass : #Object,
	#instVars : [
		'block'
	],
	#category : #'Altoque-Base'
}

{ #category : #'instance creation' }
CEBlockBuilder class >> on: aBlock [
	^ self new block: aBlock; yourself
]

{ #category : #accessing }
CEBlockBuilder >> addInstruction: anInstruction [
	self ensureBlockBeginExists.
	block addInstruction: anInstruction.
	^ anInstruction
]

{ #category : #accessing }
CEBlockBuilder >> block [
	^ block
]

{ #category : #accessing }
CEBlockBuilder >> block: anObject [
	block := anObject
]

{ #category : #accessing }
CEBlockBuilder >> ensureBlockBeginExists [
	| begin |
	block firstInstruction ifNotNil: [ ^ self ].
	
	begin := CEBlockBeginOperation new.
	begin end: begin.
	block firstInstruction: begin.
]

{ #category : #instructions }
CEBlockBuilder >> jumpTo: aTargetCEBlock [
	^ self addInstruction: (CEJumpOperation jumpTarget: aTargetCEBlock)
]

{ #category : #instructions }
CEBlockBuilder >> return: resultOperand [
	^ self addInstruction: (CEReturnOperation result: resultOperand)
]

{ #category : #instructions }
CEBlockBuilder >> selfOperand [
	^ self addInstruction: CESelfOperand new
]
