Class {
	#name : #CEBlockListFromBytecodeBuilder,
	#superclass : #InstructionClient,
	#instVars : [
		'instructionFactory',
		'currentPC',
		'blocks',
		'bytecodeScanner',
		'nextBlockID',
		'currentBlock',
		'incoming',
		'fallThroughNextInstruction',
		'endPC'
	],
	#category : #'Altoque-Base'
}

{ #category : #building }
CEBlockListFromBytecodeBuilder class >> buildBlocksFrom: aCollection [ 
	
	^ self new buildBlocksFrom: aCollection
]

{ #category : #'block-management' }
CEBlockListFromBytecodeBuilder >> appendBlockAtBytecodeIndex: aBytecodeIndex [
	
	^ self appendBlockAtBytecodeIndex: aBytecodeIndex isBackwardsBranch: false
]

{ #category : #'block-management' }
CEBlockListFromBytecodeBuilder >> appendBlockAtBytecodeIndex: aBytecodeIndex isBackwardsBranch: aBoolean [
	| block |
	blocks
		detect: [ :b | b bytecodeIndex = aBytecodeIndex ]
		ifFound: [ :b | ^ b ].
	
	block := CEBlock new
		id: instructionFactory allocateBlockID;
		bytecodeIndex: aBytecodeIndex.
	
	"If it is a backwards branch and we found no block with that bytecode index it is a split.
	Just keep track that the parent block falls through it"
	aBoolean ifTrue: [
		self
			trackIncomingBytecode: aBytecodeIndex - 1
			toBlock: block	 ].
	
	^ blocks add: block
]

{ #category : #'block-management' }
CEBlockListFromBytecodeBuilder >> blockContainingInstruction: aBytecodeIndex [

	"Return the block contaning the bytecode index.
	I.e., the first block in the list which 
	 - bytecode index is smaller than the one searched
	 - has a next whose bytecode index is greater than the one searched "
	"Assume: blocks are sorted by bytecodeIndex"
	| previousBlock |
	previousBlock := blocks first.
	2 to: blocks size do: [ :index | | block |
		block := blocks at: index.
		block bytecodeIndex > aBytecodeIndex
			ifTrue: [ ^ previousBlock ].
		previousBlock := block ].
	^ previousBlock
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> blocks [
	^ blocks
]

{ #category : #building }
CEBlockListFromBytecodeBuilder >> build [
	
	"Calculate successors and predecessors from tracked incoming bytecode edges"
	incoming keysAndValuesDo: [ :block :incomingBytecodeIndexes |
		incomingBytecodeIndexes do: [ :bytecodeIndex | | predecessor |
			predecessor := self blockContainingInstruction: bytecodeIndex.
			predecessor addSuccessor: block.
			block addPredecessor: predecessor.
		]	
	].

	^ blocks
]

{ #category : #building }
CEBlockListFromBytecodeBuilder >> buildBlocksFrom: aBytecodeMethod [ 
	
	self bytecodeScanner: (InstructionStream on: aBytecodeMethod).
	currentBlock := self startOnBytecodeIndex: aBytecodeMethod initialPC.
	self endPC: aBytecodeMethod endPC.	
	
	[bytecodeScanner pc <= endPC] whileTrue: [
		self interpretInstruction: [ bytecodeScanner interpretNextInstructionFor: self ].
	].
	self build.
	^ self blocks
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> bytecodeScanner: aBytecodeScanner [ 
	bytecodeScanner := aBytecodeScanner
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> currentPC: anObject [
	currentPC := anObject
]

{ #category : #'private-building' }
CEBlockListFromBytecodeBuilder >> doJumpTo: offset [

	| pcAfterJump jumpBlock targetPC |
	pcAfterJump := bytecodeScanner pc.
	"All jumps delimit blocks"
	self appendBlockAtBytecodeIndex: pcAfterJump.

	"Jump targets delimit blocks"
	targetPC := pcAfterJump + offset.
	jumpBlock := self appendBlockAtBytecodeIndex: targetPC isBackwardsBranch: offset < 0.
	offset < 0 ifTrue: [ jumpBlock incrementIncomingBackwardBranches ].
	
	"Keep track of back jumps.
	The incoming set of entries is used later to calculate successors at the end"
	self trackIncomingBytecode: currentPC toBlock: jumpBlock.
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> endPC [
	
	^ endPC
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> endPC: aProgramCounter [
	
	endPC := aProgramCounter
]

{ #category : #initialization }
CEBlockListFromBytecodeBuilder >> initialize [
	super initialize.
	blocks := SortedCollection sortBlock: [ :a :b | a bytecodeIndex < b bytecodeIndex ].
	incoming := Dictionary new.
	instructionFactory := CEInstructionFactory new.
]

{ #category : #accessing }
CEBlockListFromBytecodeBuilder >> instructionFactory: aCEInstructionFactory [ 
	instructionFactory := aCEInstructionFactory
]

{ #category : #building }
CEBlockListFromBytecodeBuilder >> interpretInstruction: aBlockClosure [

	currentPC := bytecodeScanner pc.
	fallThroughNextInstruction := true.
	aBlockClosure value.
	currentBlock := blocks
		detect: [ :b | b bytecodeIndex = bytecodeScanner pc ]
		ifFound: [ :nextBlock |
			(fallThroughNextInstruction and: [ nextBlock ~~ currentBlock  ]) ifTrue: [ 
				self trackIncomingBytecode: currentPC - 1 toBlock: nextBlock ].
			nextBlock ]
		ifNone: [ currentBlock ].
]

{ #category : #'instruction decoding' }
CEBlockListFromBytecodeBuilder >> jump: offset [

	self doJumpTo: offset.
	
	"Unconditional jumps do not fall through"
	fallThroughNextInstruction := false.
]

{ #category : #'instruction decoding' }
CEBlockListFromBytecodeBuilder >> jump: offset if: aBoolean [

	self doJumpTo: offset
]

{ #category : #'instruction decoding' }
CEBlockListFromBytecodeBuilder >> methodReturnConstant: aConstant [

	self return
]

{ #category : #'instruction decoding' }
CEBlockListFromBytecodeBuilder >> methodReturnReceiver [

	self return
]

{ #category : #'instruction decoding' }
CEBlockListFromBytecodeBuilder >> methodReturnTop [

	self return
]

{ #category : #'private-building' }
CEBlockListFromBytecodeBuilder >> return [

	| pcAfterReturn |
	fallThroughNextInstruction := false.
	pcAfterReturn := bytecodeScanner pc.
	"Returns delimit blocks"
	pcAfterReturn <= self endPC
		ifTrue: [ self appendBlockAtBytecodeIndex: pcAfterReturn ]
]

{ #category : #building }
CEBlockListFromBytecodeBuilder >> startOnBytecodeIndex: aBytecodeIndex [

	currentBlock := self appendBlockAtBytecodeIndex: aBytecodeIndex
]

{ #category : #'block-management' }
CEBlockListFromBytecodeBuilder >> trackIncomingBytecode: aBytecodeIndex toBlock: aBlock [
	"Keep track of back jumps.
	The incoming set of entries is used later to calculate successors at the end"
	(incoming at: aBlock ifAbsentPut: [ Set new ]) add: aBytecodeIndex.
]
