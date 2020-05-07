Class {
	#name : #CEInstructionFactory,
	#superclass : #Object,
	#instVars : [
		'nextInstructionID',
		'nextBlockID'
	],
	#category : #'Altoque-Base'
}

{ #category : #initialization }
CEInstructionFactory >> allocateBlockID [
	
	| allocatedID |
	allocatedID := nextBlockID.
	nextBlockID := nextBlockID + 1.
	^ allocatedID
]

{ #category : #initialization }
CEInstructionFactory >> allocateInstructionID [

	| allocatedInstructionID |
	allocatedInstructionID := nextInstructionID.
	nextInstructionID := nextInstructionID + 1.
	^ allocatedInstructionID
]

{ #category : #initialization }
CEInstructionFactory >> initialize [

	super initialize.
	nextInstructionID := 0.
	nextBlockID := 0
]

{ #category : #factory }
CEInstructionFactory >> newBlockBeginWithBytecodeIndex: anInteger [ 

	^ CEBlockBeginOperation
		newWithID: self allocateInstructionID
		bytecodeIndex: anInteger
]

{ #category : #factory }
CEInstructionFactory >> newLoad: aLocal [
	
	^ CELoadLocal new
		bytecodeIndex: aLocal bytecodeIndex;
		instructionID: self allocateInstructionID;
		index: aLocal index;
		yourself
]

{ #category : #factory }
CEInstructionFactory >> newPhiFunctionWith: aCEArgumentOperation [ 
	
	^ CEPhiOperation new
		instructionID: self allocateInstructionID;
		addOperation: aCEArgumentOperation;
		yourself
]

{ #category : #factory }
CEInstructionFactory >> newPhiFunctionWith: aCEPhiOperation with: aCEPhiOperation2 [ 

	^ (self newPhiFunctionWith: aCEPhiOperation)
		addOperation: aCEPhiOperation2;
		yourself
]

{ #category : #factory }
CEInstructionFactory >> newSelfOperand [
	
	^ CESelfOperand new instructionID: self allocateInstructionID
]
