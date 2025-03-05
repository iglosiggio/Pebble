Class {
	#name : 'Transformation',
	#superclass : 'Object',
	#instVars : [
		'description'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'baselines' }
Transformation class >> baseline [

	<script>
	| transformation code |
	transformation := [ :aCollection | ((aCollection
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum ].
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> baselineWithBlocks [

	<script>
	| transformation code |
	transformation := [ :aCollection | ((aCollection
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum ].
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> compilation [

	<script>
	| transformation code |
	transformation := (((Transformation new
		flatCollect: #methods)
		collect: #numArgs)
		sum)
		asBlock.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> compilationInlining [

	<script>
	| transformation code |
	transformation := (((Transformation new
		flatCollect: #methods)
		collect: #numArgs)
		sum)
		asBlockInlining.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> compilationInliningWithBlocks [

	<script>
	| transformation code |
	transformation := (((Transformation new
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum)
		asBlockInlining.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> compilationWithBlocks [

	<script>
	| transformation code |
	transformation := (((Transformation new
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum)
		asBlock.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> handwrittenFullyInlined [

	<script>
	| transformation code |
	transformation := [ :aCollection |
		| result |
		result := 0.
		aCollection do: [ :e |
			e methods do: [ :y | result := result + y numArgs ] ].
		result ].
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> handwrittenUnoptimizedFullyInlined [

	<script>
	| transformation code |
	transformation := [
		| flatCollect collect sum |
		flatCollect := [ :e | e methods ].
		collect := [ :e | e numArgs ].
		sum := [ :acc :e | acc + e ].
		[ :aCollection |
			| result id accSum |
			accSum := 0.
			id := [ :e | result := e ].
			aCollection do: [ :e |
				(flatCollect value: e) do: [ :e | id value: (accSum := sum value: accSum value: (collect value: e)) ] ].
		result ] ] value.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> interpret [

	<script>
	| transformation code |
	transformation := ((Transformation new
		flatCollect: #methods)
		collect: #numArgs)
		sum.
	code := [ transformation value: Smalltalk allClasses ].
	code value.
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> interpretWithBlocks [

	<script>
	| transformation code |
	transformation := ((Transformation new
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum.
	code := [ transformation value: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> naive [

	<script>
	| transformation code |
	transformation := ((Transformation new
		flatCollect: #methods)
		collect: #numArgs)
		sum.
	code := [ transformation naiveValue: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'baselines' }
Transformation class >> naiveWithBlocks [

	<script>
	| transformation code |
	transformation := ((Transformation new
		flatCollect: [ :e | e methods ])
		collect: [ :e | e numArgs ])
		sum.
	code := [ transformation naiveValue: Smalltalk allClasses ].
	self inform: (code benchFor: 10 seconds) asString
]

{ #category : 'combining' }
Transformation >> afterAddingDescriptor: anOperationDescriptor [

	^ self class new
		  withDescription: description , { anOperationDescriptor };
		  yourself
]

{ #category : 'combining' }
Transformation >> as: aCollectionConstructor [

	^ self
		inject: aCollectionConstructor
		into: [ :acc :v |
			acc add: v.
			acc ].
]

{ #category : 'compiling' }
Transformation >> asBlock [

	^ (nil class compiler compile: self ast formattedCode)
		  valueWithReceiver: nil
]

{ #category : 'compiling w/inlines' }
Transformation >> asBlockInlining [

	^ (nil class compiler ast: self astInlining)
		compile
		valueWithReceiver: nil
]

{ #category : 'combining' }
Transformation >> asOrderedCollection [

	^ self as: [ OrderedCollection new ]
]

{ #category : 'compiling' }
Transformation >> ast [

	| requiresAcc constantVariables perInvocationVariables statements constantVariableAssgnments invocationStatements body |
	requiresAcc := (description withIndexCollect: [ :e :i | i -> e ])
		reject: [ :e | e value isExecutable ].

	constantVariables := description withIndexCollect: [ :desc :index |
		RBVariableNode named: #__op , index printString ].
	perInvocationVariables := requiresAcc
		collect: [ :e | RBVariableNode named: #__acc , e key printString ]
		as: OrderedCollection.
	perInvocationVariables add: (RBVariableNode named: #__opID).
	perInvocationVariables add: (RBVariableNode named: #result).

	constantVariableAssgnments := description withIndexCollect: [ :desc :index |
		RBAssignmentNode
			variable: (RBVariableNode named: #__op , index printString)
			value: desc astForCallback ].
	invocationStatements := requiresAcc
		collect: [ :e |
			RBAssignmentNode
				variable: (RBVariableNode named: #__acc , e key printString)
				value: e value astForInitialValue ]
		as: OrderedCollection.
	invocationStatements add: (RBAssignmentNode
					variable: (RBVariableNode named: #__opID)
					value: (RBBlockNode
						arguments: { RBVariableNode named: #e }
						body: (RBAssignmentNode
							variable: (RBVariableNode named: #result)
							value: (RBVariableNode named: #e)) asSequenceNode)).
	invocationStatements add: (RBMessageNode
		receiver: (RBVariableNode named: #aCollection)
		selector: #do:
		arguments: { (self astForOpAt: 1) }).
	invocationStatements add: (RBVariableNode named: #result).

	statements := OrderedCollection new.
	statements addAll: constantVariableAssgnments.
	statements add: (RBReturnNode value:
		(RBBlockNode
			arguments: { RBVariableNode named: #aCollection }
			body: (RBSequenceNode
				temporaries: perInvocationVariables
				statements: invocationStatements))).
	body := RBSequenceNode temporaries: constantVariables statements: statements.
	^ RBMethodNode selector: #value arguments: { } body: body
]

{ #category : 'compiling' }
Transformation >> astForOpAt: opIdx [

	| callback element acc next |
	description size < opIdx ifTrue: [
		^ RBVariableNode named: #__opID ].

	callback := RBVariableNode named: #__op , opIdx printString.
	element := (RBVariableNode named: #__e, opIdx printString).
	acc := RBVariableNode named: #__acc , opIdx printString.
	next := (self astForOpAt: opIdx + 1).
	^ RBBlockNode
		arguments: { element }
		body: ((description at: opIdx)
			compileWithCallback: callback
			element: element
			acc: acc
			pushingResultsTo: next) asSequenceNode.
]

{ #category : 'compiling w/inlines' }
Transformation >> astInlining [

	| requiresAcc perInvocationVariables statements invocationStatements |
	requiresAcc := (description withIndexCollect: [ :e :i | i -> e ])
		reject: [ :e | e value isExecutable ].

	perInvocationVariables := requiresAcc
		collect: [ :e | RBVariableNode named: #__acc , e key printString ]
		as: OrderedCollection.
	perInvocationVariables add: (RBVariableNode named: #result).

	invocationStatements := requiresAcc
		collect: [ :e |
			| name |
			name := #__acc , e key printString.
			RBAssignmentNode
				variable: (RBVariableNode named: name)
				value: (e value astForInitialValueWithPrefix: name) ]
		as: OrderedCollection.
	invocationStatements add: (RBMessageNode
		receiver: (RBVariableNode named: #aCollection)
		selector: #do:
		arguments: { self astInliningForOpAt: 1 }).
	invocationStatements add: (RBVariableNode named: #result).

	statements := { (RBReturnNode value:
		(RBBlockNode
			arguments: { RBVariableNode named: #aCollection }
			body: (RBSequenceNode
				temporaries: perInvocationVariables
				statements: invocationStatements))) }.
	^ RBMethodNode
		selector: #value
		arguments: { }
		body: (RBSequenceNode statements: statements)
]

{ #category : 'compiling w/inlines' }
Transformation >> astInliningForOpAt: opIdx [

	| callbackPrefix element acc next |
	description size < opIdx ifTrue: [
		^ RBBlockNode
			arguments: { RBVariableNode named: #e }
			body: (RBAssignmentNode
				variable: (RBVariableNode named: #result)
				value: (RBVariableNode named: #e)) asSequenceNode ].

	callbackPrefix := #__op , opIdx printString.
	element := RBVariableNode named: #__e, opIdx printString.
	acc := RBVariableNode named: #__acc , opIdx printString.
	next := (self astInliningForOpAt: opIdx + 1).
	^ RBBlockNode
		arguments: { element }
		body: ((description at: opIdx)
			compileWithCallbackNamespace: callbackPrefix
			element: element
			acc: acc
			pushingResultsTo: next) asSequenceNode.
]

{ #category : 'combining' }
Transformation >> collect: aBlock [

	| descriptor |
	descriptor := CollectTransformationDescriptor new
		block: aBlock;
		yourself.
	^ self afterAddingDescriptor: descriptor
]

{ #category : 'combining' }
Transformation >> flatCollect: aBlock [

	| descriptor |
	descriptor := FlatCollectTransformationDescriptor new
		block: aBlock;
		yourself.
	^ self afterAddingDescriptor: descriptor
]

{ #category : 'initialization' }
Transformation >> initialize [

	super initialize.
	description := { }
]

{ #category : 'combining' }
Transformation >> inject: initialValue into: aCombiningBlock [

	| descriptor |
	descriptor := InjectIntoTransformationDescriptor new
		init: initialValue;
		update: aCombiningBlock;
		yourself.
	^ self afterAddingDescriptor: descriptor
]

{ #category : 'naive interpreting' }
Transformation >> naiveValue: aCollection [

	^ description inject: aCollection into: [ :acc :v | v naiveValue: acc ]
]

{ #category : 'combining' }
Transformation >> select: aBlock [

	| descriptor |
	descriptor := SelectTransformationDescriptor new
		block: aBlock;
		yourself.
	^ self afterAddingDescriptor: descriptor
]

{ #category : 'combining' }
Transformation >> sum [

	^ self inject: 0 into: [ :acc :v | acc + v ].
]

{ #category : 'combining' }
Transformation >> unique [

	^ self afterAddingDescriptor: UniqueTransformationDescriptor new
]

{ #category : 'interpreting' }
Transformation >> value: aCollection [

	| result executor |
	executor := description reversed
		inject: [ :e | result := e ]
		into: [ :next :e |
			| descriptionExecutor |
			descriptionExecutor := e asExecutor.
			[ :anElement |
				descriptionExecutor
					evalOnValue: anElement
					pushingResultsTo: next ] ].
	aCollection do: executor.
	^ result
]

{ #category : 'initialization' }
Transformation >> withDescription: aCollection [

	description := aCollection
]
