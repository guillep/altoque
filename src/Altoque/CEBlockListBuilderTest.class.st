Class {
	#name : #CEBlockListBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'pc'
	],
	#category : #'Altoque-Tests'
}

{ #category : #testing }
CEBlockListBuilderTest class >> isAbstract [

	^ self == CEBlockListBuilderTest
]

{ #category : #accessing }
CEBlockListBuilderTest >> pc [
	"Simulated program counter for testing.
	The builder will call this to calculate absolute jump targets,
	because jumps are relative"
	^ pc
]
