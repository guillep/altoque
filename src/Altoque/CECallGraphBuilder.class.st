"
| blockList |
blockList := CECallGraphBuilder buildHIRFromMethod: SequenceableCollection >> #do:.
blockList := CECallGraphBuilder buildHIRFromMethod: Integer>>#slowFactorial.

CEHIRPrinter print: blockList

"
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
	#category : #'Altoque-Base'
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
	1halt.
	start := self buildStartBlock.
	self
		depthFirstSearchStartingAt: start
		doing: [ :pred :sux |
			self calculateDominatorBetween: sux andPredecessor: pred.
			self fillBlockWithInstructions: sux ]
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> buildDominatorTreeFrom: aCEBlock [

	self
		depthFirstSearchStartingAt: aCEBlock
		doing: [ :pred :sux | self calculateDominatorBetween: sux andPredecessor: pred ]
]

{ #category : #building }
CECallGraphBuilder >> buildStartBlock [
	| start |
	start := CEBlock new
		id: instructionFactory allocateBlockID;
		bytecodeIndex: 0.
	start firstInstruction: (instructionFactory newBlockBeginWithBytecodeIndex: 0).
	start firstInstruction next: (CEJumpOperation new
		bytecodeIndex: 0;
		begin: start).

	start firstInstruction end: start firstInstruction next.
	start addSuccessor: blockList first.
	blockList first addPredecessor: start.

	self initializeMethodTemporaryArrayWithArguments: method numArgs andTemps: method numTemps.

	^ start
]

{ #category : #accessing }
CECallGraphBuilder >> bytecodeScanner: aCECallGraphBuilderTest [ 
	bytecodeScanner := aCECallGraphBuilderTest
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> calculateDominatorBetween: aBlock andPredecessor: aPredecessorBlock [

	aBlock dominator: (aBlock dominator
		ifNil: [ aPredecessorBlock ]
		ifNotNil: [ :currentDominator | 
			self commonDominatorBetween: currentDominator and: aPredecessorBlock ])
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

{ #category : #'dominator-tree' }
CECallGraphBuilder >> depthFirstSearchFrom: predecessor to: successor doing: aBlockClosure [

	| predecessorsNotVisited |
	predecessorsNotVisited := visitedIncomingEdges at: successor ifAbsentPut: [ successor predecessors size ].
	visitedIncomingEdges at: successor put: (predecessorsNotVisited := predecessorsNotVisited - 1).
	
	aBlockClosure value: predecessor value: successor.
	
	predecessorsNotVisited = successor incomingBackwardBranches
		ifFalse: [ ^ self ].
	self depthFirstSearchStartingAt: successor doing: aBlockClosure
]

{ #category : #'dominator-tree' }
CECallGraphBuilder >> depthFirstSearchStartingAt: aCEBlock doing: aBlock [

	aCEBlock successors do: [ :s | 
		self depthFirstSearchFrom: aCEBlock to: s doing: aBlock ]
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
CECallGraphBuilder >> fillBlockWithInstructions: aBlock [

	| blockLimitPC |	
	self setBlock: aBlock.
	bytecodeScanner pc: aBlock bytecodeIndex.

	blockLimitPC := blockList size > (blockList indexOf: aBlock)
		ifTrue: [ (blockList at: (blockList indexOf: aBlock) + 1) bytecodeIndex ]
		ifFalse: [ method endPC + 1 ].

	[method initialPC < bytecodeScanner pc
		and: [ bytecodeScanner pc < blockLimitPC ]] whileTrue: [
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
	instructionFactory := CEInstructionFactory new.
	visitedIncomingEdges := Dictionary new.
]

{ #category : #'block-building' }
CECallGraphBuilder >> initializeBlockArguments: aBlock [

	aBlock isLoopHeader
		ifTrue: [ 
			"Should initialize the temporary frame with phi functions"
			temporaryArray := temporaryArray collect: [ :e |
				instructionFactory newPhiFunctionWith: e  ].
			aBlock locals: temporaryArray copy. ]
		ifFalse: [
			aBlock predecessors size > 1 ifTrue: [ 
				"Normal join point"
				self mergeTemporariesOf: currentBlock predecessors.
				aBlock locals: temporaryArray copy ] ].
]

{ #category : #building }
CECallGraphBuilder >> initializeMethodTemporaryArrayWithArguments: numArgs andTemps: numTemps [
	selfOperand := instructionFactory newSelfOperand.
	temporaryArray := Array new: numTemps.
	1 to: numArgs do: [ :i | 
		| argument |
		argument := CEArgumentOperation new index: i.
		temporaryArray at: i put: argument ].
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
	currentBlock firstInstruction end: instruction.

	instruction jumpTarget: targetBlock.
	
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
		x: self popForUsage;
		condition: aBoolean.
	self append: instruction.
	self push: instruction.
	currentBlock firstInstruction end: instruction.
	instruction jumpTarget: targetBlock.
	instruction falseConditionJumpTarget: (self detectBlockWithStartBytecodeIndex: bytecodeScanner pc).
	
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
	
	self return: self popForUsage
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
CECallGraphBuilder >> popForUsage [

	| poppedValue |
	poppedValue := self pop.
	^ poppedValue isArgument
		ifTrue: [ self append: (instructionFactory newLoad: poppedValue) ]
		ifFalse: [ poppedValue ]
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
CECallGraphBuilder >> pushLiteralVariable: aLiteralVariable [
	
	| instruction |
	instruction := CELiteralVariableOperator value: aLiteralVariable.
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
	currentBlock firstInstruction end: instruction.
]

{ #category : #accessing }
CECallGraphBuilder >> selfOperand [

	^ selfOperand
]

{ #category : #'instruction decoding' }
CECallGraphBuilder >> send: aString super: aBoolean numArgs: aNumberOfArguments [ 
	
	| receiver arguments instruction |
	self assert: aBoolean not.
	arguments := Array streamContents: [ :stream |
		aNumberOfArguments timesRepeat: [ stream nextPut: self popForUsage ] ].
	receiver := self popForUsage.
	instruction := CESendOperation receiver: receiver selector: aString arguments: arguments.
	
	self append: instruction.
	self push: instruction.
]

{ #category : #building }
CECallGraphBuilder >> setBlock: aBlock [

	currentBlock := aBlock.
	currentInstruction := instructionFactory
		newBlockBeginWithBytecodeIndex: currentBlock bytecodeIndex.
	currentBlock firstInstruction: currentInstruction.
	operandStack := Stack new.
	
	self initializeBlockArguments: currentBlock
]
