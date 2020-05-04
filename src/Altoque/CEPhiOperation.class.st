Class {
	#name : #CEPhiOperation,
	#superclass : #CEHIROperation,
	#instVars : [
		'v1',
		'v2',
		'operations'
	],
	#category : #'Altoque-High-Level-IR'
}

{ #category : #accessing }
CEPhiOperation >> addOperation: aCEOperation [
	
	operations add: aCEOperation
]

{ #category : #accessing }
CEPhiOperation >> initialize [
	super initialize.
	operations := OrderedCollection new
]

{ #category : #testing }
CEPhiOperation >> isPhi [

	^ true
]

{ #category : #accessing }
CEPhiOperation >> operations [
	^ operations
]

{ #category : #accessing }
CEPhiOperation >> v1 [
	^ v1
]
