Class {
	#name : #CEHIROperation,
	#superclass : #Object,
	#instVars : [
		'id',
		'bytecodeIndex',
		'next'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #'instance creation' }
CEHIROperation class >> bytecodeIndex: anInteger [ 
	
	^ self new
		bytecodeIndex: anInteger;
		yourself
]

{ #category : #appending }
CEHIROperation >> appendBeforeEnd: anInstruction [
	
	next isBlockEnd ifTrue: [ 
		anInstruction next: next.
		next := anInstruction.
		^ self ].
	next appendBeforeEnd: anInstruction
]

{ #category : #accessing }
CEHIROperation >> bytecodeIndex [
	^ bytecodeIndex
]

{ #category : #accessing }
CEHIROperation >> bytecodeIndex: anObject [
	bytecodeIndex := anObject
]

{ #category : #printing }
CEHIROperation >> description [
	
	self subclassResponsibility
]

{ #category : #accessing }
CEHIROperation >> instructionID [
	
	^ id
]

{ #category : #accessing }
CEHIROperation >> instructionID: anID [
	
	id := anID
]

{ #category : #testing }
CEHIROperation >> isArgument [
	
	^ false
]

{ #category : #testing }
CEHIROperation >> isBlockEnd [
	
	^ false
]

{ #category : #testing }
CEHIROperation >> isPhi [
	
	^ false
]

{ #category : #accessing }
CEHIROperation >> next [
	^ next
]

{ #category : #accessing }
CEHIROperation >> next: anInstruction [

	next := anInstruction
]
