Class {
	#name : #CESendOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'receiver',
		'selector',
		'arguments'
	],
	#category : #Altoque
}

{ #category : #'instance creation' }
CESendOperation class >> receiver: receiver selector: aString arguments: aCollection [ 
	
	^ self new
		receiver: receiver;
		selector: aString;
		arguments: aCollection;
		yourself
]

{ #category : #accessing }
CESendOperation >> arguments [
	^ arguments
]

{ #category : #accessing }
CESendOperation >> arguments: anObject [
	arguments := anObject
]

{ #category : #printing }
CESendOperation >> description [
	
	^ 't', receiver instructionID asString,
		' perform: ',
		selector printString,
		' withArguments: ',
		(arguments collect: [ :e | 't', e instructionID asString ]) printString
]

{ #category : #accessing }
CESendOperation >> receiver [
	^ receiver
]

{ #category : #accessing }
CESendOperation >> receiver: anObject [
	receiver := anObject
]

{ #category : #accessing }
CESendOperation >> selector [
	^ selector
]

{ #category : #accessing }
CESendOperation >> selector: anObject [
	selector := anObject
]
