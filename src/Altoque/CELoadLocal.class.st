Class {
	#name : #CELoadLocal,
	#superclass : #CEHIROperation,
	#instVars : [
		'index'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #printing }
CELoadLocal >> description [
	
	^ index
		ifNil: [ 'self' ]
		ifNotNil: [ 'L', index asString ]
]

{ #category : #accessing }
CELoadLocal >> index [
	^ index
]

{ #category : #accessing }
CELoadLocal >> index: anObject [
	index := anObject
]
