Class {
	#name : #CEForwardBranchBuildTest,
	#superclass : #CEBlockListBuilderTest,
	#instVars : [
		'blocks',
		'initialPC',
		'jumpNextPC',
		'jumpTargetPC'
	],
	#category : #'Altoque-Tests'
}

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> setUp [

	| builder jumpSize jumpOffset |
	initialPC := 10.
	jumpSize := 3. "Whatever value, just for testing"
	
	builder := CEBlockListFromBytecodeBuilder new.
	builder bytecodeScanner: self.
	builder startOnBytecodeIndex: initialPC.

	"** Block 1 **"
	"Set the pc of the jump"
	pc := initialPC.
	jumpOffset := 5.
	jumpNextPC := initialPC + jumpSize.
	jumpTargetPC := jumpNextPC + jumpOffset.
	builder interpretInstruction: [ 
		"Set the pc AFTER the jump"
		pc := jumpNextPC.
		builder jump: jumpOffset ].
	
	"** Block 2 ** - delimited because it is following a jump and followed by a jump target"
	pc := jumpNextPC.
	builder interpretInstruction: [ builder pushConstant: 17 ].
	
	"** Block 3 - delimited by jump target **"
	pc := jumpTargetPC.
	builder interpretInstruction: [ builder popIntoTemporaryVariable: 1 ].
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test1HasThreeBlocks [
	
	self assert: blocks size equals: 3
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [
	
	self assert: blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test3SecondBlockBytecodeIndexIsJumpNextPC [
	
	self assert: blocks second bytecodeIndex equals: jumpNextPC
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test4ThirdBlockBytecodeIndexIsJumpTargetPC [
	
	self assert: blocks third bytecodeIndex equals: jumpTargetPC
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test5ThirdBlockIsSuccessorOfFirstBLock [
	
	self assert: (blocks first successors includes: blocks third)
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test6FirstBlockIsPredecessorOfThirdBLock [
	
	self assert: (blocks third predecessors includes: blocks first)
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test7SecondBlockHasNoPredecessors [
	"because nobody jumps to it nor falls through it"
	self assert: blocks second predecessors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test8ThirdBlockIsSuccessorOfSecondBlock [
	
	self assert: (blocks second successors includes: blocks third)
]

{ #category : #'test-immediate-forward-branch' }
CEForwardBranchBuildTest >> test9SecondBlockIsPredecessorOfThirdBlock [
	
	self assert: (blocks third predecessors includes: blocks second)
]
