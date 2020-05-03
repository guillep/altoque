Class {
	#name : #CECallGraphBuilder,
	#superclass : #Object,
	#instVars : [
		'instructionFactory',
		'currentPC',
		'blockList',
		'method',
		'bytecodeScanner',
		'currentBlock',
		'operandStack',
		'currentInstruction',
		'temporaryArray',
		'selfOperand',
		'visitedIncomingEdges'
	],
	#category : #Altoque
}

{ #category : #processing }
CECallGraphBuilder class >> buildHIRFromBlocks: aBlockList [

	^ self new buildHIRFromBlocks: aBlockList
]

{ #category : #processing }
CECallGraphBuilder class >> buildHIRFromBlocks: aBlockList andMethod: aMethod [

	^ self new
		method: aMethod;
		blockList: aBlockList;
		build
]

{ #category : #processing }
CECallGraphBuilder class >> buildHIRFromMethod: aMethod [
	
	| instructionFactory blockListBuilder blockList |
	instructionFactory := CEInstructionFactory new.
	blockListBuilder := CEBlockListBuilder new.
	blockListBuilder instructionFactory: instructionFactory.
	blockList := blockListBuilder buildBlocksFrom: aMethod.
	blockList := blockList sorted: [ :a :b | a bytecodeIndex < b bytecodeIndex ].

	self new
		instructionFactory: instructionFactory;
		method: aMethod;
		blockList: blockList;
		build.

	^ blockList
]

{ #category : #'block-building' }
CECallGraphBuilder >> append: anInstruction [
	
	currentInstruction next: anInstruction.
	currentInstruction := anInstruction.
	^ anInstruction
]

{ #category : #accessing }
CECallGraphBuilder >> blockList [
	^ blockList
]

{ #category : #accessing }
CECallGraphBuilder >> blockList: anObject [
	blockList := anObject
]

{ #category : #building }
CECallGraphBuilder >> build [
	| start |
	self assert: [ blockList isSortedBy: [ :a :b | a bytecodeIndex < b bytecodeIndex ] ].
	bytecodeScanner := InstructionStream on: method.
	selfOperand := instructionFactory newSelfOperand.
	
	start := self buildStartBlock.
	1 to: blockList size do: [ :currentBlockIndex |
		self fillBlockWithInstructions: currentBlockIndex ].

	"This could be done during block filling,
	but it requires that the successor/predecessor relation is set up beforehand"
	self buildDominatorTreeFrom: start.

	"We have to do this because the dominator tree was not available during instruction filling.
	Otherwise this could be done during instruction filling."
	"self generateParameterLoads"
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> buildDominatorTreeFrom: aCEBlock [

	aCEBlock successors do: [ :s | self buildDominatorTreeFrom: aCEBlock to: s ]
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> buildDominatorTreeFrom: aPredecessor to: aCEBlock [
	
	| predecessorsNotVisited |
	predecessorsNotVisited := visitedIncomingEdges at: aCEBlock ifAbsentPut: [ aCEBlock predecessors size ].
	visitedIncomingEdges at: aCEBlock put: (predecessorsNotVisited := predecessorsNotVisited - 1).
	aCEBlock dominator: (aCEBlock dominator
		ifNil: [ aPredecessor ]
		ifNotNil: [ :currentDominator | self commonDominatorBetween: currentDominator and: aPredecessor ]).
	
	predecessorsNotVisited = aCEBlock incomingBackwardBranches
		ifFalse: [ ^ self ].
	self buildDominatorTreeFrom: aCEBlock
]

{ #category : #building }
CECallGraphBuilder >> buildStartBlock [
	| start |
	start := instructionFactory
		newBlockBeginWithBytecodeIndex: 0
		method: bytecodeScanner method.
	start
		next:
			(CEJumpOperation new
				bytecodeIndex: 0;
				begin: start).
	start end: start next.
	start end addSuccessor: blockList first.
	blockList first addPredecessor: start.
	
	temporaryArray := Array new: bytecodeScanner method numTemps.
	1 to: bytecodeScanner method numArgs do: [ :i | 
		| argument |
		argument := CEArgumentOperation new index: i.
		temporaryArray at: i put: argument ].
	
	^ start
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> commonDominatorBetween: path1 and: path2 [ 
	
	| path1Dominators path1Dominator path2Dominator |
	path1Dominators := OrderedCollection new.
	path1Dominator := path1.
	[ path1Dominator notNil ] whileTrue: [ 
		path1Dominators add: path1Dominator.
		path1Dominator := path1Dominator dominator ].
	
	path2Dominator := path2.
	[ path2Dominator notNil ] whileTrue: [ 
		(path1Dominators includes: path2Dominator) ifTrue: [ ^ path2Dominator ].
		path2Dominator := path2Dominator dominator ].
]

{ #category : #building }
CECallGraphBuilder >> detectBlockWithStartBytecodeIndex: aBytecodeIndex [

	^ blockList detect: [ :begin | begin bytecodeIndex = aBytecodeIndex ]
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> doPop [
	
	self pop
]

{ #category : #building }
CECallGraphBuilder >> fillBlockWithInstructions: index [

	| blockLimitPC |	
	currentInstruction := currentBlock := blockList at: index.
	operandStack := Stack new.
	
	currentBlock isLoopHeader
		ifTrue: [ 
			"Should initialize the temporary frame with phi functions"
			temporaryArray := temporaryArray collect: [ :e |
				instructionFactory newPhiFunctionWith: e  ].
			currentBlock locals: temporaryArray copy. ]
		ifFalse: [
			currentBlock predecessors size > 1 ifTrue: [ 
				"Normal join point"
				self mergeTemporariesOf: currentBlock predecessors.
				currentBlock locals: temporaryArray copy ] ].

	blockLimitPC := blockList size > index
		ifTrue: [ (blockList at: index + 1) bytecodeIndex ]
		ifFalse: [ method endPC + 1 ].

	[bytecodeScanner pc < blockLimitPC] whileTrue: [
		currentPC := bytecodeScanner pc.
		bytecodeScanner interpretNextInstructionFor: self.
	].

	"Finished all the instructions in the block.
	The block may have finished with an explicit end (a jump or a return).
	If not, it means the block was cut because the next block is the target of a jump.
	In that case insert an explicit jump to the next block."
	currentInstruction isBlockEnd ifFalse: [
		self jump: 0.
	].

	currentInstruction isBackwardsBranch ifTrue: [ | newLocals |
		"Should update the phi function with the values at the end"
		"If some phi function has only a single value, remove it."
		newLocals := currentInstruction jumpTarget locals
			with: temporaryArray
			collect: [ :phi :newValue |
				phi == newValue
					ifTrue: [ phi ]
					ifFalse: [ phi addOperation: newValue ] ].
		currentInstruction jumpTarget locals: newLocals ].
]

{ #category : #building }
CECallGraphBuilder >> initialize [

	super initialize.
	visitedIncomingEdges := Dictionary new.
]

{ #category : #accessing }
CECallGraphBuilder >> instructionFactory: aCEInstructionFactory [ 
	instructionFactory := aCEInstructionFactory
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> jump: anInteger [ 

	| absoluteTargetBytecodeIndex targetBlock instruction |
	absoluteTargetBytecodeIndex := bytecodeScanner pc + anInteger.
	targetBlock := self detectBlockWithStartBytecodeIndex: absoluteTargetBytecodeIndex.
	instruction := CEJumpOperation new
		bytecodeIndex: bytecodeScanner pc;
		begin: currentBlock.
	self append: instruction.
	self push: instruction.
	currentBlock end: instruction.
	
	instruction jumpTarget: targetBlock.
	instruction addSuccessor: targetBlock.
	targetBlock addPredecessor: currentBlock.
	
	anInteger < 0 ifTrue: [ instruction beBackwardsBranch ]
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> jump: anInteger if: aBoolean [
	
	| absoluteTargetBytecodeIndex targetBlock instruction |
	absoluteTargetBytecodeIndex := bytecodeScanner pc + anInteger.
	targetBlock := self detectBlockWithStartBytecodeIndex: absoluteTargetBytecodeIndex.
	instruction := CEIfOperation new
		bytecodeIndex: bytecodeScanner pc;
		begin: currentBlock;
		x: self pop;
		condition: aBoolean.
	self append: instruction.
	self push: instruction.
	currentBlock end: instruction.
	
	instruction jumpTarget: targetBlock.
	instruction addSuccessor: targetBlock.
	targetBlock addPredecessor: currentBlock.
	instruction addSuccessor: self nextBlock.
	self nextBlock addPredecessor: currentBlock.
	
	anInteger < 0 ifTrue: [ instruction beBackwardsBranch ]
]

{ #category : #building }
CECallGraphBuilder >> mergeTemporariesOf: aCollection [
	
	| arrayOfPredecessors |
	aCollection size > 2 ifTrue: [ self halt ].
	arrayOfPredecessors := aCollection asArray.
	self assert: arrayOfPredecessors first locals ~= arrayOfPredecessors second locals.

	^ (arrayOfPredecessors first locals ifNil: [ temporaryArray ])
		with: (arrayOfPredecessors second locals ifNil: [ temporaryArray ])
		collect: [ :a :b | instructionFactory newPhiFunctionWith: a with: b ]
]

{ #category : #accessing }
CECallGraphBuilder >> method [
	^ method
]

{ #category : #accessing }
CECallGraphBuilder >> method: anObject [
	method := anObject
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> methodReturnReceiver [
	
	self return: self selfOperand
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> methodReturnTop [
	
	self return: self pop
]

{ #category : #accessing }
CECallGraphBuilder >> nextBlock [
	
	^ blockList after: currentBlock
]

{ #category : #'stack-management' }
CECallGraphBuilder >> pop [
	
	^ operandStack pop
]

{ #category : #'stack-management' }
CECallGraphBuilder >> pop: aNumberOfElements [
	
	^ Array streamContents: [ :stream |
		aNumberOfElements timesRepeat: [ stream nextPut: self pop ] ]
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> popIntoTemporaryVariable: anInteger [ 

	temporaryArray at: anInteger + 1 put: self pop
]

{ #category : #'stack-management' }
CECallGraphBuilder >> push: aValue [
	
	aValue instructionID: instructionFactory allocateInstructionID.
	aValue bytecodeIndex: currentPC.

	operandStack push: aValue
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> pushConstant: anInteger [ 
	
	| instruction |
	instruction := CEConstantOperator value: anInteger.
	self append: instruction.
	self push: instruction.
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> pushReceiver [

	self push: self selfOperand
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> pushTemporaryVariable: anInteger [ 
	
	self push: (temporaryArray at: anInteger + 1)
]

{ #category : #'block-building' }
CECallGraphBuilder >> return: aValue [
	
	| instruction |
	instruction := CEReturnOperation new
		bytecodeIndex: bytecodeScanner pc;
		begin: currentBlock;
		result: aValue.
	self append: instruction.
	self push: instruction.
	currentBlock end: instruction.
]

{ #category : #accessing }
CECallGraphBuilder >> selfOperand [

	^ selfOperand
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> send: aString super: aBoolean numArgs: anInteger [ 
	
	| receiver arguments instruction |
	self assert: aBoolean not.
	arguments := self pop: anInteger.
	receiver := self pop.
	instruction := CESendOperation receiver: receiver selector: aString arguments: arguments.
	
	self append: instruction.
	self push: instruction.
]
