Class {
	#name : #CEHIRPrinter,
	#superclass : #Object,
	#category : #Altoque
}

{ #category : #printing }
CEHIRPrinter class >> print: aHIR [
	
	aHIR do: [ :e |
		self printBlock: e.
		Transcript cr; cr
	]
]

{ #category : #printing }
CEHIRPrinter class >> printBlock: aCEBlock [

	self printBlockHeader: aCEBlock.
	Transcript cr.
	self printBlockLocalsIfPhi: aCEBlock.
	Transcript cr.
	self printBlockInstructions: aCEBlock.
]

{ #category : #printing }
CEHIRPrinter class >> printBlockHeader: aCEBlockBeginOperation [ 
	
	Transcript
		show: 'B';
		show: aCEBlockBeginOperation blockID.
	Transcript
		show: '[';
		show: aCEBlockBeginOperation bytecodeIndex;
		show: ', ';
		show: aCEBlockBeginOperation end bytecodeIndex;
		show: ']'.
	
	aCEBlockBeginOperation hasPredecessors ifTrue: [
		Transcript show: ' pred '.
		aCEBlockBeginOperation predecessors do: [ :p |
			Transcript
				show: 'B';
				show: p blockID
		] separatedBy: [ Transcript space ] ].

	aCEBlockBeginOperation hasSuccessors ifTrue: [
		Transcript show: ' sux '.
		aCEBlockBeginOperation successors do: [ :p |
			Transcript
				show: 'B';
				show: p blockID
		] separatedBy: [ Transcript space ] ]
]

{ #category : #printing }
CEHIRPrinter class >> printBlockInstructions: aCEBlock [

	Transcript
		show: 'bci';
		tab;
		tab;
		show: 'id';
		tab;
		tab;
		show: 'description';
		cr.
	Transcript
		print: '____________________________________';
		cr.
	aCEBlock instructionsDo: [ :i |
		self printInstruction: i.
		Transcript cr ]
]

{ #category : #printing }
CEHIRPrinter class >> printBlockLocalsIfPhi: aCEBlock [
	
	aCEBlock locals ifNil: [ ^ self ].
	Transcript show: 'Locals:'; cr.
	aCEBlock locals do: [ :e | 
		e isPhi ifTrue: [
			Transcript tab; tab; tab.
			Transcript
				show: 't';
				show: e instructionID asString;
				show: '[ '.
			e operations do: [ :op |
				Transcript
					show: 't';
					show: op instructionID asString;
					space ].
			Transcript show: ']'; cr ] ]
]

{ #category : #printing }
CEHIRPrinter class >> printInstruction: anOperation [
	
	Transcript
		show: anOperation bytecodeIndex;
		tab;
		tab;
		show: 't';
		show: anOperation instructionID;
		tab;
		tab;
		show: anOperation description
]
