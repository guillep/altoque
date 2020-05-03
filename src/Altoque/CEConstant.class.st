Class {
	#name : #CEConstant,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #Altoque
}

{ #category : #testing }
CEConstant >> isConstant [
	
	^ true
]

{ #category : #testing }
CEConstant >> isVariable [
	
	^ false
]

{ #category : #accessing }
CEConstant >> name [
	
	^ value printString
]

{ #category : #accessing }
CEConstant >> value [
	^ value
]

{ #category : #accessing }
CEConstant >> value: anObject [
	value := anObject
]
