Class {
	#name : #CEImmediateForwardBranchBuildTest,
	#superclass : #CEBlockListBuilderTest,
	#instVars : [
		'jumpSize',
		'initialPC',
		'builder',
		'jumpOffset',
		'blocks',
		'jumpTarget'
	],
	#category : #Altoque
}

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> setUp [

	super setUp.
	initialPC := 10.
	jumpSize := 3. "Whatever value, just for testing"
	
	builder := CEBlockListBuilder new.
	builder bytecodeScanner: self.
	builder startOnBytecodeIndex: initialPC.

	"Set the pc of the jump"
	builder currentPC: initialPC.
	
	"Set the pc AFTER the jump"
	pc := initialPC + jumpSize.
	jumpOffset := 0.
	jumpTarget := pc + jumpOffset.
	builder jump: jumpOffset.

	builder pushConstant: 17.
	builder pushConstant: 17.
	builder popIntoTemporaryVariable: 1.
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> test1HasTwoBlocks [

	self assert: builder blocks size equals: 2
]

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [

	self assert: builder blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> test3SecondBlockBytecodeIndexIsJumpTargetPC [

	self assert: builder blocks second bytecodeIndex equals: jumpTarget
]

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> test4FirstIsPredecessorOfSecond [

	self assert: blocks second predecessor equals: builder blocks first
]

{ #category : #'test-immediate-forward-branch' }
CEImmediateForwardBranchBuildTest >> test5SecondIsSuccessorOfFirst [

	self assert: blocks first successor equals: builder blocks second
]
