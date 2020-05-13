Class {
	#name : #CEMethod,
	#superclass : #Object,
	#instVars : [
		'blocks'
	],
	#category : #'Altoque-Base'
}

{ #category : #accessing }
CEMethod >> blocks [
	^ blocks
]

{ #category : #accessing }
CEMethod >> blocks: anObject [
	blocks := anObject
]

{ #category : #accessing }
CEMethod >> childrenNodes [
	^ blocks
]

{ #category : #'as yet unclassified' }
CEMethod >> gtInstructions: composite [
	<gtInspectorPresentationOrder: 5>
	composite text
			title: 'Instructions';
			format: #asText;
			display: [ self asString];
			withLineNumbers: true
]

{ #category : #'as yet unclassified' }
CEMethod >> gtTreeViewIn: composite [
	<gtInspectorPresentationOrder: 6>
	composite tree 
		title: 'Nodes';
		display: [ :node | node ];
		children: [ :each | each childrenNodes];
		format: [ :node | node nodeTitle ]
]

{ #category : #accessing }
CEMethod >> nodeTitle [
	^ 'Method'
]

{ #category : #printing }
CEMethod >> printOn: aStream [
	(CEHIRPrinter on: aStream) print: blocks
]
