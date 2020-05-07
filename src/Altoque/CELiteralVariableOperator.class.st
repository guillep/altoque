Class {
	#name : #CELiteralVariableOperator,
	#superclass : #CEHIROperation,
	#instVars : [
		'value'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #'instance creation' }
CELiteralVariableOperator class >> value: aValue [

	^ self new
		value: aValue;
		yourself
]

{ #category : #printing }
CELiteralVariableOperator >> description [
	
	^ value printString
]

{ #category : #accessing }
CELiteralVariableOperator >> value [
	^ value
]

{ #category : #accessing }
CELiteralVariableOperator >> value: anObject [
	value := anObject
]
