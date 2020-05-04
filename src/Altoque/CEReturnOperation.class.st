Class {
	#name : #CEReturnOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'result'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #printing }
CEReturnOperation >> description [

	^ 'return t', result instructionID asString
]

{ #category : #accessing }
CEReturnOperation >> result [
	^ result
]

{ #category : #accessing }
CEReturnOperation >> result: anObject [
	result := anObject
]
