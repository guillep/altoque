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
	#category : #'Altoque-Base'
}

{ #category : #building }
CEBlock class >> buildWith: aBlockClosure [
	^ self new buildWith: aBlockClosure
]

{ #category : #adding }
CEBlock >> addInstruction: anInstruction [
	self assert: firstInstruction isNotNil.
	self lastInstruction next: anInstruction.
	firstInstruction end: anInstruction.
]

{ #category : #accessing }
CEBlock >> addPredecessor: aBlock [

	predecessors add: aBlock
]

{ #category : #accessing }
CEBlock >> addSuccessor: aBlock [

	successors add: aBlock
]

{ #category : #appending }
CEBlock >> appendBeforeEnd: aCELoadLocal [
	
	firstInstruction isBlockEnd ifFalse: [ 
		^ firstInstruction appendBeforeEnd: aCELoadLocal ].
	aCELoadLocal next: firstInstruction.
	firstInstruction := aCELoadLocal
]

{ #category : #accessing }
CEBlock >> blockID [
	
	^ id
]

{ #category : #building }
CEBlock >> buildWith: aBlockClosure [
	| builder |
	builder := CEBlockBuilder on: self.
	aBlockClosure value: builder.
]

{ #category : #accessing }
CEBlock >> bytecodeIndex [
	^ bytecodeIndex
]

{ #category : #accessing }
CEBlock >> bytecodeIndex: anObject [
	bytecodeIndex := anObject
]

{ #category : #'as yet unclassified' }
CEBlock >> childrenNodes [
	^ self instructions
]

{ #category : #'dominator-tree' }
CEBlock >> dominates: aCEBlock [
	
	aCEBlock == self ifTrue: [ ^ true ].
	aCEBlock dominator == self ifTrue: [ ^ true ].
	aCEBlock dominator ifNil: [ ^ false ].
	^ self dominates: aCEBlock dominator
]

{ #category : #'dominator-tree' }
CEBlock >> dominator [
	^ dominator
]

{ #category : #'dominator-tree' }
CEBlock >> dominator: aCEBlock [ 
	dominator := aCEBlock
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
CEBlock >> incomingBackwardBranches [
	^ incomingBackwardBranches
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
CEBlock >> instructions [
	| result |
	result := OrderedCollection new.
	self instructionsDo: [ :each |
		result add: each
	].
	^ result
]

{ #category : #accessing }
CEBlock >> instructionsDo: aBlockClosure [ 
	firstInstruction ifNil: [ ^ self ].
	
	firstInstruction instructionsDo: aBlockClosure
]

{ #category : #testing }
CEBlock >> isLoopHeader [

	^ incomingBackwardBranches > 0
]

{ #category : #accessing }
CEBlock >> lastInstruction [

	^ firstInstruction end
]

{ #category : #accessing }
CEBlock >> locals [
	
	^ locals
]

{ #category : #accessing }
CEBlock >> locals: aCollection [ 
	
	locals := aCollection
]

{ #category : #'as yet unclassified' }
CEBlock >> nodeTitle [
	^ 'Block ' , id asString
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
CEBlock >> replacePredecessor: aCEBlock by: aCEBlock2 [ 
	
	| index |
	index := predecessors indexOf: aCEBlock.
	predecessors at: index put: aCEBlock2.
]

{ #category : #accessing }
CEBlock >> replaceSuccessor: aCEBlock by: aCEBlock2 [
	
	| index |
	index := successors indexOf: aCEBlock.
	successors at: index put: aCEBlock2.
	
	self end replaceSuccessor: aCEBlock by: aCEBlock2
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
