Class {
	#name : #CEReturnBuildTest,
	#superclass : #CEBlockListBuilderTest,
	#instVars : [
		'blocks',
		'initialPC',
		'endPC',
		'pcAfterReturn'
	],
	#category : #Altoque
}

{ #category : #helpers }
CEReturnBuildTest >> endPC [
	
	^ endPC
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> setUp [

	| builder |
	initialPC := 10.
	
	builder := CEBlockListBuilder new.
	builder bytecodeScanner: self.
	builder startOnBytecodeIndex: initialPC.

	"** Block 1 **"
	pc := initialPC.
	pcAfterReturn := pc + 1.
	endPC := pcAfterReturn + 1.
	builder interpretInstruction: [ 
		pc := pcAfterReturn.
		builder methodReturnTop ].
	
	"** Block 2 - delimited by the return **"
	pc := endPC.
	builder interpretInstruction: [ builder popIntoTemporaryVariable: 1 ].
	
	blocks := builder build.
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test1HasTwoBlocks [
	
	self assert: blocks size equals: 2
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test2FirstBlockBytecodeIndexIsInitialPC [
	
	self assert: blocks first bytecodeIndex equals: initialPC
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test3SecondBlockBytecodeIndexIsPCAfterReturn [
	
	self assert: blocks second bytecodeIndex equals: pcAfterReturn
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test4FirstBlockHasNoSuccessors [
	
	self assert: blocks first successors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test5FirstBlockHasNoPredecessors [
	
	self assert: blocks first predecessors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test6SecondBlockHasNoSuccessors [
	
	self assert: blocks second successors isEmpty
]

{ #category : #'test-immediate-forward-branch' }
CEReturnBuildTest >> test7SecondBlockHasNoPredecessors [
	
	self assert: blocks second predecessors isEmpty
]
