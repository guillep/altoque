Class {
	#name : #CEBlock,
	#superclass : #Object,
	#instVars : [
		'id',
		'bytecodeIndex',
		'successors',
		'predecessors',
		'incomingBackwardBranches',
		'firstInstruction',
		'dominator',
		'locals'
	],
	#category : #Altoque
}

{ #category : #accessing }
CEBlock >> addPredecessor: aBlock [

	predecessors add: aBlock
]

{ #category : #accessing }
CEBlock >> addSuccessor: aBlock [

	successors add: aBlock
]

{ #category : #accessing }
CEBlock >> blockID [
	
	^ id
]

{ #category : #accessing }
CEBlock >> bytecodeIndex [
	^ bytecodeIndex
]

{ #category : #accessing }
CEBlock >> bytecodeIndex: anObject [
	bytecodeIndex := anObject
]

{ #category : #'dominator-tree' }
CEBlock >> dominator [
	^ dominator
]

{ #category : #'dominator-tree' }
CEBlock >> dominator: aCEBlockBeginOperation [ 
	dominator := aCEBlockBeginOperation
]

{ #category : #accessing }
CEBlock >> end [
	
	^ self firstInstruction end
]

{ #category : #accessing }
CEBlock >> firstInstruction [
	
	^ firstInstruction
]

{ #category : #accessing }
CEBlock >> firstInstruction: aCEBlockBeginOperation [
	
	firstInstruction := aCEBlockBeginOperation
]

{ #category : #testing }
CEBlock >> hasPredecessors [
	
	^ predecessors notEmpty
]

{ #category : #testing }
CEBlock >> hasSuccessors [
	
	^ successors notEmpty
]

{ #category : #accessing }
CEBlock >> id [
	^ id
]

{ #category : #accessing }
CEBlock >> id: anObject [
	id := anObject
]

{ #category : #accessing }
CEBlock >> incrementIncomingBackwardBranches [
	
	incomingBackwardBranches := incomingBackwardBranches + 1
]

{ #category : #initialization }
CEBlock >> initialize [ 
	super initialize.
	successors := OrderedCollection new.
	predecessors := OrderedCollection new.
	incomingBackwardBranches := 0
]

{ #category : #accessing }
CEBlock >> instructionsDo: aBlockClosure [ 

	firstInstruction instructionsDo: aBlockClosure
]

{ #category : #testing }
CEBlock >> isLoopHeader [

	^ incomingBackwardBranches > 0
]

{ #category : #accessing }
CEBlock >> locals [
	
	^ locals
]

{ #category : #accessing }
CEBlock >> locals: aCollection [ 
	
	locals := aCollection
]

{ #category : #accessing }
CEBlock >> predecessor [

	self assert: predecessors size = 1.
	^ predecessors anyOne
]

{ #category : #accessing }
CEBlock >> predecessors [
	^ predecessors
]

{ #category : #accessing }
CEBlock >> successor [

	self assert: successors size = 1.
	^ successors anyOne
]

{ #category : #accessing }
CEBlock >> successors [

	^ successors
]