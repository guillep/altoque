Class {
	#name : #CEReturnOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'result'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #accessing }
CEReturnOperation class >> result: aResultCEOperation [
	^ self new result: aResultCEOperation
]

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
