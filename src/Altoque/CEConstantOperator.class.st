Class {
	#name : #CEConstantOperator,
	#superclass : #CEHIROperation,
	#instVars : [
		'value'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #'instance creation' }
CEConstantOperator class >> value: aValue [

	^ self new
		value: aValue;
		yourself
]

{ #category : #printing }
CEConstantOperator >> description [
	
	^ value printString
]

{ #category : #testing }
CEConstantOperator >> isConstant [
	
	^ true
]

{ #category : #accessing }
CEConstantOperator >> value [
	^ value
]

{ #category : #accessing }
CEConstantOperator >> value: anObject [
	value := anObject
]
