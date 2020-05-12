Class {
	#name : #CEControlFlowGraphBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'pc'
	],
	#category : #'Altoque-Tests'
}

{ #category : #helpers }
CEControlFlowGraphBuilderTest >> pc [
	^ pc
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testBackwardsConditionalJumpAppendsBlockEndInstruction [

	| block builder fallthroughBlock |
	"Target of itself"
	block := CEBlock new.
	fallthroughBlock := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.
	block addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block.

	builder := CEControlFlowGraphBuilder new
		blockList: { block . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	pc := 1.
	builder pushConstant: true.
	builder jump: -1 if: true.
		
	self assert: block lastInstruction isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testBackwardsConditionalJumpAppendsIfWithFallthroughJumpTarget [

	| block builder fallthroughBlock |
	"Target of itself"
	block := CEBlock new.
	fallthroughBlock := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.
	block addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block.

	builder := CEControlFlowGraphBuilder new
		blockList: { block . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	pc := 1.
	builder pushConstant: true.
	builder jump: -1 if: true.
		
	self assert: block lastInstruction falseConditionJumpTarget equals: fallthroughBlock
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testBackwardsConditionalJumpAppendsIfWithJumpTarget [

	| block builder fallthroughBlock |
	"Target of itself"
	block := CEBlock new.
	fallthroughBlock := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.
	block addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block.

	builder := CEControlFlowGraphBuilder new
		blockList: { block . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	pc := 1.
	builder pushConstant: true.
	builder jump: -1 if: true.
		
	self assert: block lastInstruction trueConditionJumpTarget equals: block
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testBackwardsJumpAppendsBlockEndInstruction [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CEControlFlowGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder jump: -1.
		
	self assert: block firstInstruction next isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testBackwardsJumpAppendsGotoWithJumpTarget [

	| block builder |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	builder := CEControlFlowGraphBuilder new
		blockList: { block };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block.
	
	"We jump to the same point."
	block bytecodeIndex: 0.
	pc := 1.
	builder jump: -1.
		
	self assert: block firstInstruction next jumpTarget equals: block
]

{ #category : #tests }
CEControlFlowGraphBuilderTest >> testBlocHasAsManyArgumentsAsMethod [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		initializeBlockArguments: block.
	self assert: block locals size equals: 2
]

{ #category : #tests }
CEControlFlowGraphBuilderTest >> testBlockWithOneIncomingBackwardBranchIsLoopHeader [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.
	
	self assert: block isLoopHeader
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testForwardConditionalJumpAppendsBlockEndInstruction [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CEControlFlowGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end isBlockEnd
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testForwardConditionalJumpAppendsIfWithFallthroughJumpTarget [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CEControlFlowGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end falseConditionJumpTarget equals: fallthroughBlock
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testForwardConditionalJumpAppendsIfWithJumpTarget [

	| builder block1 targetBlock fallthroughBlock |
	block1 := CEBlock new.
	targetBlock := CEBlock new.
	fallthroughBlock := CEBlock new.
	block1 addSuccessor: targetBlock.
	targetBlock addPredecessor: block1.
	block1 addSuccessor: fallthroughBlock.
	fallthroughBlock addPredecessor: block1.

	builder := CEControlFlowGraphBuilder new
		blockList: { block1 . targetBlock . fallthroughBlock };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	fallthroughBlock bytecodeIndex: 1.
	targetBlock bytecodeIndex: 2.
	pc := 1.
	builder pushConstant: true.
	builder jump: 1 if: true.
		
	self assert: block1 end trueConditionJumpTarget equals: targetBlock
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testForwardJumpAppendsAppendsGotoWithJumpTarget [

	| builder block1 block2 |
	block1 := CEBlock new.
	block2 := CEBlock new.
	block1 addSuccessor: block2.
	block2 addPredecessor: block1.

	builder := CEControlFlowGraphBuilder new
		blockList: { block1 . block2 };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	block2 bytecodeIndex: 1.
	pc := 1.
	builder jump: 0.
		
	self assert: block1 firstInstruction next jumpTarget equals: block2
]

{ #category : #'tests-branchinstructions' }
CEControlFlowGraphBuilderTest >> testForwardJumpAppendsBlockEndInstruction [

	| builder block1 block2 |
	block1 := CEBlock new.
	block2 := CEBlock new.
	block1 addSuccessor: block2.
	block2 addPredecessor: block1.

	builder := CEControlFlowGraphBuilder new
		blockList: { block1 . block2 };
		bytecodeScanner: self;
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block1.
	
	"We jump to block 2"
	block1 bytecodeIndex: 0.
	block2 bytecodeIndex: 1.
	pc := 1.
	builder jump: 0.
		
	self assert: block1 firstInstruction next isBlockEnd
]

{ #category : #tests }
CEControlFlowGraphBuilderTest >> testInitializeLoopHeaderBlocArgumentsHasPhiFunctions [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		initializeBlockArguments: block.
	self assert: (block locals allSatisfy: [ :e | e isPhi ])
]

{ #category : #'tests-pushinstructions' }
CEControlFlowGraphBuilderTest >> testPushConstantAppendsConstantInstruction [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushConstant: 17.
		
	self assert: block firstInstruction next isConstant.
	self assert: block firstInstruction next value equals: 17.
]

{ #category : #'tests-pushinstructions' }
CEControlFlowGraphBuilderTest >> testPushLiteralAppendsLiteralInstruction [

	| block literal |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	literal := #Global -> 17.
	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushLiteralVariable: literal.
		
	self assert: block firstInstruction next isLiteralVariable.
	self assert: block firstInstruction next value equals: literal.
]

{ #category : #'test-pusharguments' }
CEControlFlowGraphBuilderTest >> testPushReceiverAppendsLoadLocalInstructionOnUse [

	| block |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushReceiver;
		send: #unary super: false numArgs: 0.
		
	self assert: block firstInstruction next isLoadLocal
]

{ #category : #'test-pusharguments' }
CEControlFlowGraphBuilderTest >> testPushReceiverAppendsLoadLocalInstructionOnUseWithReceiverIndex [

	| block |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushReceiver;
		send: #unary super: false numArgs: 0.
		
	self assert: block firstInstruction next isSelf
]

{ #category : #'test-pusharguments' }
CEControlFlowGraphBuilderTest >> testPushReceiverAppendsLoadLocalInstructionOnlyOnFirstUse [

	| block messageSend |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushReceiver;
		pushReceiver;
		send: #keyword: super: false numArgs: 1.
		
	self assert: block firstInstruction next isLoadLocal.
	messageSend := block firstInstruction next next.
	self assert: messageSend receiver equals: messageSend arguments first
]

{ #category : #'tests-pushinstructions' }
CEControlFlowGraphBuilderTest >> testPushReceiverDoesNotAppendReceiverInstruction [

	| block |
	block := CEBlock new.
	block incrementIncomingBackwardBranches.
	block addSuccessor: block.
	block addPredecessor: block.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		pushReceiver.
		
	self assert: block firstInstruction next isNil
]

{ #category : #'test-sendInstructions' }
CEControlFlowGraphBuilderTest >> testSendBinaryAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		pushConstant: 2;
		send: #+ super: false numArgs: 1.
		
	self assert: block firstInstruction next next next selector equals: #+
]

{ #category : #'test-sendInstructions' }
CEControlFlowGraphBuilderTest >> testSendKeywordAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		pushConstant: 2;
		send: #keyword: super: false numArgs: 1.
		
	self assert: block firstInstruction next next next selector equals: #keyword:
]

{ #category : #'test-sendInstructions' }
CEControlFlowGraphBuilderTest >> testSendUnaryAppendsSendInstruction [

	| block |
	block := CEBlock new.

	CEControlFlowGraphBuilder new
		initializeMethodTemporaryArrayWithArguments: 2 andTemps: 2;
		setBlock: block;
		"Receiver, then send"
		pushConstant: 1;
		send: #unary super: false numArgs: 0.
		
	self assert: block firstInstruction next next selector equals: #unary
]
