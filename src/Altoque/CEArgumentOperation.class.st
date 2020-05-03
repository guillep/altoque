Class {
	#name : #CEArgumentOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'index'
	],
	#category : #Altoque
}

{ #category : #printing }
CEArgumentOperation >> description [
	
	^ 'arg', index asString
]

{ #category : #accessing }
CEArgumentOperation >> index [
	^ index
]

{ #category : #accessing }
CEArgumentOperation >> index: anObject [
	index := anObject
]

{ #category : #printing }
CEArgumentOperation >> instructionID [
	"Arguments have no instruction IDs as they are not valid instructions.
	They need to be used in a load instruction to be available."
	^ '?'
]

{ #category : #testing }
CEArgumentOperation >> isArgument [
	
	^ true
]
