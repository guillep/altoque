Class {
	#name : #CELiveAnalysis,
	#superclass : #Object,
	#instVars : [
		'intervals',
		'inState',
		'outState'
	],
	#category : #Altoque
}

{ #category : #executing }
CELiveAnalysis >> calculateLivenesOfBasicBlock: aBasicBlock withGenAndKill: aBlock [

	"GEN and KILL come from data-flow analysis terminology.
	GEN[s]  = The set of variables that are used in s before any assignment.
	KILL[s] = The set of variables that are assigned a value in the basic block"
	| assigned usedBeforeAssigned |
	
	"assigned aka KILL"
	assigned := Set new.
	
	"used before assigned aka GEN"
	usedBeforeAssigned := Set new.
	
	aBasicBlock instructions do: [ :instruction |
		instruction usedVariables do: [ :usedVariable |
			(assigned includes: usedVariable)
				ifFalse: [ usedBeforeAssigned add: usedVariable ] ].
		assigned add: instruction variable ].
	
	^ aBlock value: usedBeforeAssigned value: assigned
]

{ #category : #executing }
CELiveAnalysis >> computeIncomingIn: basicBlock [

	^ self calculateLivenesOfBasicBlock: basicBlock withGenAndKill: [ :gen :kill |
		(gen, ((self computeOutgoingIn: basicBlock) copyWithout: kill)) asSet ]
]

{ #category : #executing }
CELiveAnalysis >> computeOutgoingIn: basicBlock [
	
	^ (basicBlock successors gather: [ :succ |
		inState at: succ ifAbsent: [ #() ] ]) asSet
]

{ #category : #executing }
CELiveAnalysis >> executeOn: aCEBasicBlockMethod [ 

	"iterate instructionsFrom the end"
	| workingSet |
	workingSet := OrderedCollection new.
	workingSet addAll: aCEBasicBlockMethod end precedessors.
	[ workingSet notEmpty ] whileTrue: [
		| basicBlock in out |
		basicBlock := workingSet removeFirst.
		in := self computeIncomingIn: basicBlock.
		out := self computeOutgoingIn: basicBlock.
		(in ~= (self incomingIn: basicBlock)
			or: [ out ~= (self outgoingIn: basicBlock) ])
				ifTrue: [ 
					self incomingIn: basicBlock put: in.
					self outgoingIn: basicBlock put: out.
					workingSet addAll: basicBlock precedessors ] ]
]

{ #category : #executing }
CELiveAnalysis >> incomingIn: basicBlock [
	
	^ inState at: basicBlock ifAbsent: [ #() asSet ]
]

{ #category : #executing }
CELiveAnalysis >> incomingIn: basicBlock put: aSet [
	
	^ inState at: basicBlock put: aSet
]

{ #category : #executing }
CELiveAnalysis >> initialize [

	super initialize.
	intervals := Dictionary new.
	
	inState := Dictionary new.
	outState := Dictionary new
]

{ #category : #marking }
CELiveAnalysis >> markAsLive: aVariable in: aCEInstruction [
	
	intervals
		at: aVariable
		ifAbsentPut: [ -1 to: aCEInstruction pc ]
]

{ #category : #marking }
CELiveAnalysis >> markStartOfLife: aVariable in: aCEInstruction [ 
	
	aVariable ifNil: [ ^ self ].
	intervals
		at: aVariable
		ifPresent: [ :interval |
			interval
				setFrom: aCEInstruction pc
				to: interval last
				by: 1 ]
		ifAbsentPut: [ aCEInstruction pc to: aCEInstruction pc ]
]

{ #category : #executing }
CELiveAnalysis >> outgoingIn: basicBlock [
	
	^ outState at: basicBlock ifAbsent: [ #() asSet ]
]

{ #category : #executing }
CELiveAnalysis >> outgoingIn: basicBlock put: aSet [

	^ outState at: basicBlock put: aSet
]
