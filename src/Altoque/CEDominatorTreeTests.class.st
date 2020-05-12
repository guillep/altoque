Class {
	#name : #CEDominatorTreeTests,
	#superclass : #TestCase,
	#instVars : [
		'entry',
		'exit',
		'blocks'
	],
	#category : #'Altoque-Tests'
}

{ #category : #helpers }
CEDominatorTreeTests >> assert: aCEBlock dominatesBlock: id [
	
	self assert: aCEBlock strictlyDominates: (blocks at: id)
]

{ #category : #helpers }
CEDominatorTreeTests >> assert: aCEBlock strictlyDominates: aCEBlock2 [ 
	
	self assert: aCEBlock2 dominator equals: aCEBlock
]

{ #category : #helpers }
CEDominatorTreeTests >> assertBlock: id1 strictlyDominatesBlock: id2 [
	
	self assert: (blocks at: id1) strictlyDominates: (blocks at: id2)
]

{ #category : #helpers }
CEDominatorTreeTests >> connect: aCEBlock with: aCEBlock2 [ 
	
	aCEBlock addSuccessor: aCEBlock2.
	aCEBlock2 addPredecessor: aCEBlock.
	aCEBlock id > aCEBlock2 id
		ifTrue: [ aCEBlock2 incrementIncomingBackwardBranches ]
]

{ #category : #running }
CEDominatorTreeTests >> setUp [
	super setUp.
	entry := CEBlock new id: 0.
	exit := CEBlock new id: 13.
	blocks := (1 to: 12) collect: [ :i | CEBlock new id: i ].
	self connect: entry with: exit.
	self connect: entry with: (blocks at: 1).
	self connect: (blocks at: 1) with: (blocks at: 2).
	self connect: (blocks at: 2) with: (blocks at: 3).
	self connect: (blocks at: 2) with: (blocks at: 7).
	self connect: (blocks at: 3) with: (blocks at: 4).
	self connect: (blocks at: 3) with: (blocks at: 5).
	self connect: (blocks at: 4) with: (blocks at: 6).
	self connect: (blocks at: 5) with: (blocks at: 6).
	self connect: (blocks at: 6) with: (blocks at: 8).
	self connect: (blocks at: 7) with: (blocks at: 8).
	self connect: (blocks at: 8) with: (blocks at: 9).
	self connect: (blocks at: 9) with: (blocks at: 10).
	self connect: (blocks at: 9) with: (blocks at: 11).
	self connect: (blocks at: 10) with: (blocks at: 11).
	self connect: (blocks at: 11) with: (blocks at: 9).
	self connect: (blocks at: 11) with: (blocks at: 12).
	self connect: (blocks at: 12) with: (blocks at: 2).
	self connect: (blocks at: 12) with: exit.

	CEControlFlowGraphBuilder new buildDominatorTreeFrom: entry
]

{ #category : #tests }
CEDominatorTreeTests >> test11Dominates12 [

	self assertBlock: 11 strictlyDominatesBlock: 12
]

{ #category : #tests }
CEDominatorTreeTests >> test1Dominates2 [

	self assertBlock: 1 strictlyDominatesBlock: 2
]

{ #category : #tests }
CEDominatorTreeTests >> test2Dominates3 [

	self assertBlock: 2 strictlyDominatesBlock: 3
]

{ #category : #tests }
CEDominatorTreeTests >> test2Dominates7 [

	self assertBlock: 2 strictlyDominatesBlock: 7
]

{ #category : #tests }
CEDominatorTreeTests >> test2Dominates8 [

	self assertBlock: 2 strictlyDominatesBlock: 8
]

{ #category : #tests }
CEDominatorTreeTests >> test3Dominates4 [

	self assertBlock: 3 strictlyDominatesBlock: 4
]

{ #category : #tests }
CEDominatorTreeTests >> test3Dominates5 [

	self assertBlock: 3 strictlyDominatesBlock: 5
]

{ #category : #tests }
CEDominatorTreeTests >> test3Dominates6 [

	self assertBlock: 3 strictlyDominatesBlock: 6
]

{ #category : #tests }
CEDominatorTreeTests >> test8Dominates9 [

	self assertBlock: 8 strictlyDominatesBlock: 9
]

{ #category : #tests }
CEDominatorTreeTests >> test9Dominates10 [

	self assertBlock: 9 strictlyDominatesBlock: 10
]

{ #category : #tests }
CEDominatorTreeTests >> test9Dominates11 [

	self assertBlock: 9 strictlyDominatesBlock: 11
]

{ #category : #tests }
CEDominatorTreeTests >> testEntryDominates1 [

	self assert: entry dominatesBlock: 1
]

{ #category : #tests }
CEDominatorTreeTests >> testEntryDominatesExit [

	self assert: entry strictlyDominates: exit
]

{ #category : #tests }
CEDominatorTreeTests >> testReflexivity [

	1 to: 12 do: [ :i |
		self assert: ((blocks at: i) dominates: (blocks at: i)) ]
	
]
