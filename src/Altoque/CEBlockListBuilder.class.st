Class {
	#name : #CEBlockListBuilder,
	#superclass : #InstructionClient,
	#instVars : [
		'instructionFactory',
		'currentPC',
		'blocks',
		'bytecodeScanner',
		'nextBlockID',
		'currentBlock'
	],
	#category : #Altoque
}

{ #category : #building }
CEBlockListBuilder class >> buildBlocksFrom: aCollection [ 
	
	^ self new buildBlocksFrom: aCollection
]

{ #category : #building }
CEBlockListBuilder >> appendBlockAtBytecodeIndex: aBytecodeIndex [

	| block |
	blocks
		detect: [ :b | b bytecodeIndex = aBytecodeIndex ]
		ifFound: [ :b | ^ b ].
	block := instructionFactory
		newBlockBeginWithBytecodeIndex: aBytecodeIndex
		method: bytecodeScanner method.
	^ blocks add: block
]

{ #category : #building }
CEBlockListBuilder >> buildBlocksFrom: aBytecodeMethod [ 
	
	| endPC |
	bytecodeScanner := InstructionStream on: aBytecodeMethod.
	endPC := aBytecodeMethod endPC.

	blocks := OrderedCollection new.
	currentBlock := self appendBlockAtBytecodeIndex: aBytecodeMethod initialPC.
	
	[bytecodeScanner pc <= endPC] whileTrue: [
		currentBlock := blocks
			detect: [ :b | b bytecodeIndex = bytecodeScanner pc ]
			ifNone: [ currentBlock ].
		currentPC := bytecodeScanner pc.
		bytecodeScanner interpretNextInstructionFor: self.
	].

	^ blocks
]

{ #category : #accessing }
CEBlockListBuilder >> instructionFactory: aCEInstructionFactory [ 
	instructionFactory := aCEInstructionFactory
]

{ #category : #building }
CEBlockListBuilder >> jump: offset [

	| pcAfterJump jumpBlock |
	pcAfterJump := bytecodeScanner pc.
	"All jumps delimit blocks"
	self appendBlockAtBytecodeIndex: pcAfterJump.
	"Jump targets delimit blocks"
	jumpBlock := self appendBlockAtBytecodeIndex: pcAfterJump + offset.
	jumpBlock addPredecessor: currentBlock.
	
	offset < 0 ifTrue: [ jumpBlock incrementIncomingBackwardBranches ].
]

{ #category : #building }
CEBlockListBuilder >> jump: offset if: aBoolean [

	self jump: offset
]

{ #category : #building }
CEBlockListBuilder >> methodReturnConstant: aConstant [

	self return
]

{ #category : #building }
CEBlockListBuilder >> methodReturnReceiver [

	self return
]

{ #category : #building }
CEBlockListBuilder >> methodReturnTop [

	self return
]

{ #category : #building }
CEBlockListBuilder >> return [

	| pcAfterReturn |
	pcAfterReturn := bytecodeScanner pc.
	"Returns delimit blocks"
	pcAfterReturn > bytecodeScanner method endPC
		ifFalse: [ self appendBlockAtBytecodeIndex: pcAfterReturn ]
]
