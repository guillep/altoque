Class {
	#name : #CEReturnOperation,
	#superclass : #CEBlockEndOperation,
	#instVars : [
		'result'
	],
	#category : #Altoque
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
