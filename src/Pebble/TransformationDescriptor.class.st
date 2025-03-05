Class {
	#name : 'TransformationDescriptor',
	#superclass : 'Object',
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'interpreting' }
TransformationDescriptor >> asExecutor [

	^ self isExecutable
		ifTrue: [ self ]
		ifFalse: [ self asExecutor ]
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astAfterApplying: arguments on: aBlockAst  withNamespace: aNamespacePrefix [

	| blockAst rewriter |
	blockAst := aBlockAst copy.
	rewriter := ASTParseTreeRewriter new.

	self assert: arguments size = blockAst argumentNames size.
	blockAst argumentNames withIndexDo: [ :name :i |
		rewriter
			replaceTree: (RBVariableNode named: name)
			withTree: (arguments at: i) ].
	blockAst temporaryNames do: [ :name |
		rewriter replace: name with: aNamespacePrefix , name.
		rewriter replaceArgument: name with: aNamespacePrefix , name ].
	rewriter executeTree: blockAst.
	^ blockAst body.
]

{ #category : 'compiling' }
TransformationDescriptor >> astForCallback [

	^ self subclassResponsibility
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astForCallback: aBlock [

	^ aBlock isSymbol
		  ifTrue: [ self astForPerforming: aBlock ]
		  ifFalse: [ aBlock compiledBlock ast copy ]
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astForInitialValue: anInitialValue [
 
	| doItAst |
	anInitialValue isClosure ifTrue: [
		^ self astForSendValueToBlock: anInitialValue ].

	self assert: anInitialValue isLiteral.
	doItAst := OpalCompiler new
		isScripting: true;
		parse: anInitialValue fullPrintString.
	self assert: doItAst body statements size = 1.
	^ doItAst body statements first
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astForInitialValue: anInitialValue inliningWithNamespace: aNamespacePrefix [
 
	| doItAst |
	anInitialValue isClosure ifTrue: [
		^ self
			astAfterApplying: { }
			on: anInitialValue compiledBlock ast copy
			withNamespace: aNamespacePrefix  ].

	self assert: anInitialValue isLiteral.
	doItAst := OpalCompiler new
		isScripting: true;
		parse: anInitialValue fullPrintString.
	self assert: doItAst body statements size = 1.
	^ doItAst body statements first
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astForPerforming: aSelector [

	| arguments |
	arguments := (0 to: aSelector numArgs) collect: [ :i |
		RBVariableNode named: #e , i printString ].
	^ RBBlockNode arguments: arguments body:
		(RBMessageNode
			receiver: arguments first
			selector: aSelector
			arguments: arguments allButFirst) asSequenceNode.
]

{ #category : 'ast manipulation' }
TransformationDescriptor >> astForSendValueToBlock: aBlock [

	| blockAst |
	blockAst := aBlock compiledBlock ast copy.
	^ RBMessageNode receiver: blockAst selector: #value arguments: { }
]

{ #category : 'compiling' }
TransformationDescriptor >> compileWithCallback: callback element: element acc: acc pushingResultsTo: continuation [

	self subclassResponsibility
]

{ #category : 'compiling w/inlines' }
TransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	self subclassResponsibility
]

{ #category : 'interpreting' }
TransformationDescriptor >> isExecutable [

	self subclassResponsibility
]

{ #category : 'naive interpreting' }
TransformationDescriptor >> naiveValue: aCollection [

	self subclassResponsibility
]
