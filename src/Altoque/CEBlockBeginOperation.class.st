Class {
	#name : #CEBlockBeginOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'block_id',
		'predecessors',
		'end',
		'locals',
		'incomingBackwardBranches',
		'dominator'
	],
	#category : #Altoque
}

{ #category : #'instance creation' }
CEBlockBeginOperation class >> newWithID: aBlockID bytecodeIndex: bytecodeIndex [

	^ self new
		blockID: aBlockID;
		bytecodeIndex: bytecodeIndex;
		yourself
]

{ #category : #accessing }
CEBlockBeginOperation >> addPredecessor: aCEBlockBeginOperation [

	predecessors add: aCEBlockBeginOperation
]

{ #category : #accessing }
CEBlockBeginOperation >> blockID [
	
	^ block_id
]

{ #category : #accessing }
CEBlockBeginOperation >> blockID: aBlockID [
	
	block_id := aBlockID
]

{ #category : #accessing }
CEBlockBeginOperation >> dominator [
	^ dominator
]

{ #category : #accessing }
CEBlockBeginOperation >> dominator: anObject [
	self haltIf: [ (anObject isKindOf: CEBlockBeginOperation) not ].
	dominator := anObject
]

{ #category : #accessing }
CEBlockBeginOperation >> end [
	^ end
]

{ #category : #accessing }
CEBlockBeginOperation >> end: aCEIfOperation [ 
	end := aCEIfOperation
]

{ #category : #testing }
CEBlockBeginOperation >> hasPredecessors [
	
	^ predecessors notEmpty
]

{ #category : #testing }
CEBlockBeginOperation >> hasSuccessors [
	
	^ end hasSuccessors
]

{ #category : #accessing }
CEBlockBeginOperation >> incomingBackwardBranches [
	^ incomingBackwardBranches
]

{ #category : #accessing }
CEBlockBeginOperation >> incrementIncomingBackwardBranches [
	
	incomingBackwardBranches := incomingBackwardBranches + 1
]

{ #category : #initialization }
CEBlockBeginOperation >> initialize [

	super initialize.
	predecessors := Set new.
	incomingBackwardBranches := 0
]

{ #category : #accessing }
CEBlockBeginOperation >> instructions [
	
	| instructions |
	instructions := OrderedCollection new.
	self instructionsDo: [ :i | instructions add: i ].
	^ instructions
]

{ #category : #enumerating }
CEBlockBeginOperation >> instructionsDo: aBlockClosure [ 
	
	| current |
	current := next.
	[ current notNil ] whileTrue: [
		aBlockClosure value: current.
		current := current next ]
]

{ #category : #accessing }
CEBlockBeginOperation >> isLoopHeader [

	^ incomingBackwardBranches > 0
]

{ #category : #accessing }
CEBlockBeginOperation >> locals [
	^ locals
]

{ #category : #accessing }
CEBlockBeginOperation >> locals: aCollection [ 
	locals := aCollection
]

{ #category : #accessing }
CEBlockBeginOperation >> predecessor [
	"Only if one predecessor"
	self assert: self predecessors size = 1.
	^ self predecessors anyOne
]

{ #category : #accessing }
CEBlockBeginOperation >> predecessors [
	^ predecessors
]

{ #category : #printing }
CEBlockBeginOperation >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream print: block_id.
	stream nextPut: $)
]

{ #category : #accessing }
CEBlockBeginOperation >> successor [
	
	^ end successor
]

{ #category : #accessing }
CEBlockBeginOperation >> successors [
	
	^ end successors
]
