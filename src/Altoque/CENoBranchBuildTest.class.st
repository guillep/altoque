Class {
	#name : #CENoBranchBuildTest,
	#superclass : #CEBlockListBuilderTest,
	#instVars : [
		'blockBytecodeIndex',
		'builder'
	],
	#category : #'Altoque-Tests'
}

{ #category : #'tests-no-branch' }
CENoBranchBuildTest >> setUp [

	super setUp.

	blockBytecodeIndex := 10.
	
	builder := CEBlockListFromBytecodeBuilder new.
	builder startOnBytecodeIndex: blockBytecodeIndex.
	builder pushConstant: 17.
	builder pushConstant: 17.
	builder popIntoTemporaryVariable: 1.

]

{ #category : #'tests-no-branch' }
CENoBranchBuildTest >> testNoBranchMethodHasSingleBlock [

	self assert: builder blocks size equals: 1
]

{ #category : #'tests-no-branch' }
CENoBranchBuildTest >> testNoBranchMethodSingleBlockHasBytecodeIndex [

	self assert: builder blocks anyOne bytecodeIndex equals: blockBytecodeIndex
]
