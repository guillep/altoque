Class {
	#name : #CEHIRPrinter,
	#superclass : #Object,
	#instVars : [
		'outputStream'
	],
	#category : #'Altoque-Base'
}

{ #category : #'instance creation' }
CEHIRPrinter class >> on: aStream [
	^ self new outputStream: aStream; yourself
]

{ #category : #'instance creation' }
CEHIRPrinter class >> onTranscript [
	^ self on: Transcript
]

{ #category : #accessing }
CEHIRPrinter >> outputStream [
	^ outputStream
]

{ #category : #accessing }
CEHIRPrinter >> outputStream: anObject [
	outputStream := anObject
]

{ #category : #printing }
CEHIRPrinter >> print: aHIR [
	
	aHIR do: [ :e |
		self printBlock: e.
		outputStream cr; cr
	]
]

{ #category : #printing }
CEHIRPrinter >> printBlock: aCEBlock [

	self printBlockHeader: aCEBlock.
	outputStream cr.
	self printBlockLocalsIfPhi: aCEBlock.
	outputStream cr.
	self printBlockInstructions: aCEBlock.
]

{ #category : #printing }
CEHIRPrinter >> printBlockHeader: aBlock [ 
	
	outputStream
		nextPutAll: 'B';
		print: aBlock blockID.
	outputStream
		nextPutAll: '[';
		print: aBlock bytecodeIndex;
		nextPutAll: ', ';
		print: aBlock end bytecodeIndex;
		nextPutAll: ']'.
	
	aBlock hasPredecessors ifTrue: [
		outputStream nextPutAll: ' pred '.
		aBlock predecessors do: [ :p |
			outputStream
				nextPutAll: 'B';
				print: p blockID
		] separatedBy: [ outputStream space ] ].

	aBlock hasSuccessors ifTrue: [
		outputStream nextPutAll: ' sux '.
		aBlock successors do: [ :p |
			outputStream
				nextPutAll: 'B';
				print: p blockID
		] separatedBy: [ outputStream space ] ]
]

{ #category : #printing }
CEHIRPrinter >> printBlockInstructions: aCEBlock [

	outputStream
		nextPutAll: 'bci';
		tab;
		tab;
		nextPutAll: 'id';
		tab;
		tab;
		nextPutAll: 'description';
		cr.
	outputStream
		print: '____________________________________';
		cr.
	aCEBlock instructionsDo: [ :i |
		self printInstruction: i.
		outputStream cr ]
]

{ #category : #printing }
CEHIRPrinter >> printBlockLocalsIfPhi: aCEBlock [
	
	aCEBlock locals ifNil: [ ^ self ].
	outputStream show: 'Locals:'; cr.
	aCEBlock locals do: [ :e | 
		e isPhi ifTrue: [
			outputStream tab; tab; tab.
			outputStream
				show: 't';
				show: e instructionID asString;
				show: '[ '.
			e operations do: [ :op |
				outputStream
					show: 't';
					show: op instructionID asString;
					space ].
			outputStream show: ']'; cr ] ]
]

{ #category : #printing }
CEHIRPrinter >> printInstruction: anOperation [
	
	outputStream
		print: anOperation bytecodeIndex;
		tab;
		tab;
		nextPutAll: 't';
		print: anOperation instructionID;
		tab;
		tab;
		print: anOperation description
]
