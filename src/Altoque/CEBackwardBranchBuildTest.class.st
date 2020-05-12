Class {
	#name : #CEBackwardBranchBuildTest,
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
CEBackwardBranchBuildTest >> setUp [

	| builder jumpSize jumpOffset |
	initialPC := 10.
	jumpSize := 3. "Whatever value, just for testing"
	
	builder := CEBlockListBuilder new.
	builder bytecodeScanner: self.
	builder startOnBytecodeIndex: initialPC.

	"** Block 1 ** - ends because the next instruction is a jump target"
	pc := initialPC.
	builder interpretInstruction: [ builder pushConstant: 17 ].
	
	"** Block 2 - starts by jump target **"
	pc := jumpTargetPC := pc + 1.
	builder interpretInstruction: [ builder popIntoTemporaryVariable: 1 ].
	
	pc := pc + 1.
	jumpNextPC := pc + jumpSize.
	jumpOffset := jumpTargetPC - jumpNextPC.
	builder interpretInstruction: [ 
		"Set the pc AFTER the jump"
		pc := jumpNextPC.
		builder jump: jumpOffset ].
	
	"** Block 3 - starts after the jump **"
	builder interpretInstruction: [ builder popIntoTemporaryVariable: 1 ].
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test10ThirdHasNoPredecessors [
	"because nobody jumps to it nor falls through it"
	self assert: blocks third predecessors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test1HasThreeBlocks [
	
	self assert: blocks size equals: 3
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [

	self assert: blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test3SecondBlockBytecodeIndexIsJumpTargetPC [
	
	self assert: blocks second bytecodeIndex equals: jumpTargetPC
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test4ThirdBlockBytecodeIndexIsJumpNextPC [
	
	self assert: blocks third bytecodeIndex equals: jumpNextPC
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test5SecondBlockIsSuccessorOfFirstBLock [
	
	self assert: (blocks first successors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test6FirstBlockIsPredecessorOfSecondBLock [
	
	self assert: (blocks first successors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test7SecondBlockIsSuccessorOfSecondBlock [
	
	self assert: (blocks second successors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test8SecondBlockIsPredecessorOfSecondBlock [
	
	self assert: (blocks second predecessors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEBackwardBranchBuildTest >> test9ThirdHasNoSuccessors [
	"because nobody jumps to it nor falls through it"
	self assert: blocks third successors isEmpty
]
