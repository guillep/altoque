"
A CEBlockTest is a test class for testing the behavior of CEBlock
"
Class {
	#name : #CEBlockTest,
	#superclass : #TestCase,
	#category : #'Altoque-Tests'
}

{ #category : #tests }
CEBlockTest >> testEmpty [
	| block |
	block := CEBlock new.
	self assert: block instructions isEmpty.
]

{ #category : #tests }
CEBlockTest >> testJumpInstruction [
	| entry target |
	target := CEBlock new.
	entry := CEBlock buildWith: [:builder |
		builder jumpTo: target
	].
	target buildWith: [:builder |
		builder return: (builder selfOperand)
	].

	self assert: entry instructions size equals: 1.
	self assert: target instructions size equals: 2.
]

{ #category : #tests }
CEBlockTest >> testNew [
	| block |
	block := CEBlock new.
	self assert: block predecessors isEmpty.
	self assert: block successors isEmpty.
]

{ #category : #tests }
CEBlockTest >> testOneInstructions [
	| block |
	block := CEBlock buildWith: [:builder |
		builder selfOperand
	].
	self assert: block instructions size equals: 1.
]
