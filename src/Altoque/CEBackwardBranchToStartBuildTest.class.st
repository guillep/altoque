Class {
	#name : #CEBackwardBranchToStartBuildTest,
	#superclass : #CEBlockListBuilderTest,
	#instVars : [
		'jumpSize',
		'initialPC',
		'builder',
		'jumpOffset',
		'blocks',
		'jumpTarget',
		'jumpNextPC'
	],
	#category : #Altoque
}

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> setUp [

	super setUp.
	initialPC := 10.
	jumpSize := 3. "Whatever value, just for testing"
	
	builder := CEBlockListBuilder new.
	builder bytecodeScanner: self.
	builder startOnBytecodeIndex: initialPC.

	"Set the pc of the jump"
	builder currentPC: initialPC.
	
	"Set the pc AFTER the jump"
	pc := jumpNextPC := initialPC + jumpSize.
	jumpOffset := jumpSize negated.
	jumpTarget := pc + jumpOffset.
	builder jump: jumpOffset.

	builder pushConstant: 17.
	builder pushConstant: 17.
	builder popIntoTemporaryVariable: 1.
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test1HasTwoBlocks [

	self assert: builder blocks size equals: 2
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [

	self assert: builder blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test3SecondBlockBytecodeIndexIsJumpNextPC [

	self assert: builder blocks second bytecodeIndex equals: jumpNextPC
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test4FirstIsPredecessorOfFirst [

	self assert: blocks first predecessor equals: builder blocks first
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test5FirstIsSuccessorOfFirst [

	self assert: blocks first successor equals: builder blocks first
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test6SecondHasNoPredecessors [
	
	"The second block is not reachable"
	self assert: blocks second predecessors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchToStartBuildTest >> test7SecondHasNoSuccessors [

	"The second block is not reachable"
	self assert: blocks second successors isEmpty
]
