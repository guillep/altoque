"
| blockList |
blockList := CECallGraphBuilder buildHIRFromMethod: SequenceableCollection >> #do:.
blockList := CECallGraphBuilder buildHIRFromMethod: Integer>>#slowFactorial.

CEHIRPrinter print: blockList

"
Class {
	#name : #CEControlFlowGraphFromBytecodeBuilder,
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
CEControlFlowGraphFromBytecodeBuilder class >> buildHIRFromBlocks: aBlockList [

	^ self new buildHIRFromBlocks: aBlockList
]

{ #category : #processing }
CEControlFlowGraphFromBytecodeBuilder class >> buildHIRFromBlocks: aBlockList andMethod: aMethod [

	^ self new
		method: aMethod;
		blockList: aBlockList;
		build
]

{ #category : #processing }
CEControlFlowGraphFromBytecodeBuilder class >> buildHIRFromMethod: aCompiledMethod [
	
	| instructionFactory blockListBuilder blockList |
	instructionFactory := CEInstructionFactory new.
	blockListBuilder := CEBlockListFromBytecodeBuilder new.
	blockListBuilder instructionFactory: instructionFactory.
	blockList := blockListBuilder buildBlocksFrom: aCompiledMethod.
	blockList := blockList sorted: [ :a :b | a bytecodeIndex < b bytecodeIndex ].

	self new
		instructionFactory: instructionFactory;
		method: aCompiledMethod;
		blockList: blockList;
		build.

	^ CEMethod new
		blocks: blockList asOrderedCollection;
		yourself
]

{ #category : #'block-building' }
CEControlFlowGraphFromBytecodeBuilder >> append: anInstruction [
	
	currentInstruction next: anInstruction.
	currentInstruction := anInstruction.
	^ anInstruction
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> blockList [
	^ blockList
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> blockList: anObject [
	blockList := anObject
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> build [

	| start |
	self assert: [ blockList isSortedBy: [ :a :b | a bytecodeIndex < b bytecodeIndex ] ].
	bytecodeScanner := InstructionStream on: method.
	start := self buildStartBlock.
	self
		depthFirstSearchStartingAt: start
		doing: [ :pred :sux |
			self calculateDominatorBetween: sux andPredecessor: pred.
			self fillBlockWithInstructions: sux ]
]

{ #category : #'dominator-tree' }
CEControlFlowGraphFromBytecodeBuilder >> buildDominatorTreeFrom: aCEBlock [

	self
		depthFirstSearchStartingAt: aCEBlock
		doing: [ :pred :sux | 
			self calculateDominatorBetween: sux andPredecessor: pred ]
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> buildStartBlock [
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
CEControlFlowGraphFromBytecodeBuilder >> bytecodeScanner: aCECallGraphBuilderTest [ 
	bytecodeScanner := aCECallGraphBuilderTest
]

{ #category : #'dominator-tree' }
CEControlFlowGraphFromBytecodeBuilder >> calculateDominatorBetween: aBlock andPredecessor: aPredecessorBlock [

	aBlock dominator: (aBlock dominator
		ifNil: [ aPredecessorBlock ]
		ifNotNil: [ :currentDominator | 
			self commonDominatorBetween: currentDominator and: aPredecessorBlock ])
]

{ #category : #'dominator-tree' }
CEControlFlowGraphFromBytecodeBuilder >> commonDominatorBetween: path1 and: path2 [ 
	
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
CEControlFlowGraphFromBytecodeBuilder >> depthFirstSearchFrom: predecessor to: successor doing: aBlockClosure [

	| predecessorsNotVisited |
	predecessorsNotVisited := visitedIncomingEdges at: successor ifAbsentPut: [ successor predecessors size ].
	visitedIncomingEdges at: successor put: (predecessorsNotVisited := predecessorsNotVisited - 1).
	
	aBlockClosure value: predecessor value: successor.
	
	predecessorsNotVisited = successor incomingBackwardBranches
		ifFalse: [ ^ self ].
	self depthFirstSearchStartingAt: successor doing: aBlockClosure
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> depthFirstSearchStartingAt: aCEBlock doing: aBlock [

	"Iterate the successors using a to:do: loop because the successor collection can be modified in the middle.
	Specially when phi-functions are manipulated, extra blocks can be created"
	1 to: aCEBlock successors size do: [ :i | | successor |
		successor := aCEBlock successors at: i.
		self depthFirstSearchFrom: aCEBlock to: successor doing: aBlock ]
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> detectBlockWithStartBytecodeIndex: aBytecodeIndex [

	^ blockList detect: [ :begin | begin bytecodeIndex = aBytecodeIndex ]
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> doPop [
	
	self pop
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> fillBlockWithInstructions: aBlock [

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
CEControlFlowGraphFromBytecodeBuilder >> initialize [

	super initialize.
	instructionFactory := CEInstructionFactory new.
	visitedIncomingEdges := Dictionary new.
]

{ #category : #'block-building' }
CEControlFlowGraphFromBytecodeBuilder >> initializeBlockArguments: aBlock [

	aBlock predecessors size > 1 ifTrue: [
		aBlock locals: temporaryArray copy ].
]

{ #category : #building }
CEControlFlowGraphFromBytecodeBuilder >> initializeMethodTemporaryArrayWithArguments: numArgs andTemps: numTemps [
	selfOperand := instructionFactory newSelfOperand.
	temporaryArray := Array new: numTemps.
	1 to: numArgs do: [ :i | 
		| argument |
		argument := CEArgumentOperation new index: i.
		temporaryArray at: i put: argument ].
	numArgs + 1 to: numTemps do: [ :i |
		temporaryArray at: i put: (CETemporaryOperand new index: i) ]
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> instructionFactory: aCEInstructionFactory [ 
	instructionFactory := aCEInstructionFactory
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> jump: anInteger [ 

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
CEControlFlowGraphFromBytecodeBuilder >> jump: anInteger if: aBoolean [
	
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

{ #category : #'stack-management' }
CEControlFlowGraphFromBytecodeBuilder >> loadInstructionForArgument: anArgument [
	| loadInstruction |
	anArgument isLoaded ifTrue: [ ^ anArgument loadInstruction ].
	
	loadInstruction := anArgument isTemporary
		ifTrue: [ CEConstantOperator new value: nil ]
		ifFalse: [ instructionFactory newLoad: anArgument ].	
	
	anArgument loadInstruction: loadInstruction.
	^ loadInstruction
]

{ #category : #temporariesArray }
CEControlFlowGraphFromBytecodeBuilder >> mergeTemporariesOfBlock: aBlock from: aPredecessor [

	"We generate phi functions in loop headers for all variables in advance.
	Otherwise all variables in the loop could be subject to a rename when the backward branch is visited"
	aBlock isLoopHeader ifTrue: [ 
		aBlock locals: ((1 to: temporaryArray size) collect: [ :temp | instructionFactory newPhiFunction ]) ].

	"If a block has only one predecessor, no merge is necessary and no state array is stored for this block."
	aBlock predecessors size <= 1 ifTrue: [ ^ aBlock locals: temporaryArray ].
	
	"If a block with at least 2 predecessors is visited for the first time the incoming state array is stored in this block."
	aBlock locals ifNil: [ ^ aBlock locals: aPredecessor locals copy ].
	
	"If it is visited again, the new state array is compared with the stored state array element by
element, and phi functions are generated or updated for each different value"
	aBlock locals: (aBlock locals with: aPredecessor locals collect: [ :a :b |
		a = b
			ifTrue: [ a ]
			ifFalse: [ | arga argb |
				arga := a isArgument ifTrue: [ | blockToAppendTo |
					blockToAppendTo := (aBlock dominator = (aBlock predecessors at: 1) and: [ 
						aBlock predecessors anySatisfy: [ :otherPredecessor |
							otherPredecessor ~= (aBlock predecessors at: 1)  and: [ (aBlock dominates: otherPredecessor) not ] ] ])
								ifTrue: [ "Should append a new block between aBlock and aPredecessor"
									| newBlock |
									newBlock := CEBlock new.
									(aBlock predecessors at: 1)  replaceSuccessor: aBlock by: newBlock.
									aBlock replacePredecessor: (aBlock predecessors at: 1)  by: newBlock.
									newBlock addPredecessor: (aBlock predecessors at: 1) .
									newBlock addSuccessor: aBlock.
									newBlock firstInstruction: (CEJumpOperation new jumpTarget: aBlock) ]
								ifFalse: [ aPredecessor ].
						blockToAppendTo appendBeforeEnd: (self loadInstructionForArgument: a) ]
					ifFalse: [a].
				argb := b isArgument ifTrue: [ | blockToAppendTo |
					blockToAppendTo := (aBlock dominator = aPredecessor and: [ 
						aBlock predecessors anySatisfy: [ :otherPredecessor |
							otherPredecessor ~= aPredecessor and: [ (aBlock dominates: otherPredecessor) not ] ] ])
								ifTrue: [ "Should append a new block between aBlock and aPredecessor"
									| newBlock |
									newBlock := CEBlock new.
									1halt.
									aPredecessor replaceSuccessor: aBlock by: newBlock.
									aBlock replacePredecessor: aPredecessor by: newBlock.
									newBlock addPredecessor: aPredecessor.
									newBlock addSuccessor: aBlock.
									newBlock firstInstruction: (CEJumpOperation new jumpTarget: aBlock) ]
								ifFalse: [ aPredecessor ].
					blockToAppendTo appendBeforeEnd: (self loadInstructionForArgument: b) ]
					ifFalse: [b].
			instructionFactory newPhiFunctionWith: arga with: argb ] ]).
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> method [
	^ method
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> method: anObject [
	method := anObject
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> methodReturnReceiver [
	
	self return: self selfOperand
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> methodReturnTop [
	
	self return: self popForUsage
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> nextBlock [
	
	^ blockList after: currentBlock
]

{ #category : #'stack-management' }
CEControlFlowGraphFromBytecodeBuilder >> pop [
	
	^ operandStack pop
]

{ #category : #'stack-management' }
CEControlFlowGraphFromBytecodeBuilder >> popForUsage [

	| poppedValue |
	poppedValue := self pop.
	poppedValue isArgument ifFalse: [ ^ poppedValue ].
	
	^ self append: (self loadInstructionForArgument: poppedValue)
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> popIntoTemporaryVariable: anInteger [ 

	temporaryArray at: anInteger + 1 put: self pop
]

{ #category : #'stack-management' }
CEControlFlowGraphFromBytecodeBuilder >> push: aValue [
	
	aValue instructionID: instructionFactory allocateInstructionID.
	aValue bytecodeIndex: currentPC.

	operandStack push: aValue
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> pushConstant: anInteger [ 
	
	| instruction |
	instruction := CEConstantOperator value: anInteger.
	self append: instruction.
	self push: instruction.
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> pushLiteralVariable: aLiteralVariable [
	
	| instruction |
	instruction := CELiteralVariableOperator value: aLiteralVariable.
	self append: instruction.
	self push: instruction.
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> pushReceiver [

	self push: self selfOperand
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> pushTemporaryVariable: anInteger [ 
	
	self push: (temporaryArray at: anInteger + 1)
]

{ #category : #'block-building' }
CEControlFlowGraphFromBytecodeBuilder >> return: aValue [
	
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
CEControlFlowGraphFromBytecodeBuilder >> selfOperand [

	^ selfOperand
]

{ #category : #'instruction decoding' }
CEControlFlowGraphFromBytecodeBuilder >> send: aString super: aBoolean numArgs: aNumberOfArguments [ 
	
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
CEControlFlowGraphFromBytecodeBuilder >> setBlock: aBlock [

	currentBlock := aBlock.
	currentInstruction := instructionFactory
		newBlockBeginWithBytecodeIndex: currentBlock bytecodeIndex.
	currentBlock firstInstruction: currentInstruction.
	operandStack := Stack new.
]

{ #category : #accessing }
CEControlFlowGraphFromBytecodeBuilder >> temporaryArray [
	^ temporaryArray
]
