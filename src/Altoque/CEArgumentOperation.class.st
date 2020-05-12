Class {
	#name : #CEArgumentOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'index',
		'loadInstruction'
	],
	#category : #'Altoque-High-Level-IR'
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

{ #category : #testing }
CEArgumentOperation >> isLoaded [
	
	^ loadInstruction notNil
]

{ #category : #accessing }
CEArgumentOperation >> loadInstruction [
	
	^ loadInstruction
]

{ #category : #accessing }
CEArgumentOperation >> loadInstruction: aCELoadLocal [ 
	loadInstruction := aCELoadLocal
]
