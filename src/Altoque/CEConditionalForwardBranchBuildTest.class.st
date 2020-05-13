Class {
	#name : #CEConditionalForwardBranchBuildTest,
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
CEConditionalForwardBranchBuildTest >> setUp [

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
		builder jump: jumpOffset if: true ].
	
	"** Block 2 ** - delimited because it is following a jump and followed by a jump target"
	pc := jumpNextPC.
	builder interpretInstruction: [ builder pushConstant: 17 ].
	
	"** Block 3 - delimited by jump target **"
	pc := jumpTargetPC.
	builder interpretInstruction: [ builder popIntoTemporaryVariable: 1 ].
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test10SecondBlockIsPredecessorOfThirdBlock [
	
	self assert: (blocks third predecessors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test1HasThreeBlocks [
	
	self assert: blocks size equals: 3
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [
	
	self assert: blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test3SecondBlockBytecodeIndexIsJumpNextPC [
	
	self assert: blocks second bytecodeIndex equals: jumpNextPC
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test4ThirdBlockBytecodeIndexIsJumpTargetPC [
	
	self assert: blocks third bytecodeIndex equals: jumpTargetPC
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test5ThirdBlockIsSuccessorOfFirstBLock [
	
	self assert: (blocks first successors includes: blocks third)
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test6FirstBlockIsPredecessorOfThirdBLock [
	
	self assert: (blocks third predecessors includes: blocks first)
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test7FirstBlockIsPredecessorOfSecondBlock [
	"because the conditional jump falls through it"	
	self assert: (blocks second predecessors includes: blocks first)

]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test8SecondBlockIsSuccessorOfFirstBlock [
	"because the conditional jump falls through it"	
	self assert: (blocks first successors includes: blocks second)
]

{ #category : #'test-immediate-forward-branch' }
CEConditionalForwardBranchBuildTest >> test9ThirdBlockIsSuccessorOfSecondBlock [
	
	self assert: (blocks second successors includes: blocks third)
]
