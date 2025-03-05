Class {
	#name : 'InjectIntoTransformationDescriptor',
	#superclass : 'StatefulTransformationDescriptor',
	#instVars : [
		'init',
		'update'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
InjectIntoTransformationDescriptor >> astForCallback [

	^ self astForCallback: update
]

{ #category : 'compiling' }
InjectIntoTransformationDescriptor >> astForInitialValue [

	^ self astForInitialValue: init
]

{ #category : 'compiling w/inlines' }
InjectIntoTransformationDescriptor >> astForInitialValueWithPrefix: aPrefix [

	^ self astForInitialValue: init inliningWithNamespace: aPrefix
]

{ #category : 'compiling' }
InjectIntoTransformationDescriptor >> compileWithCallback: callback element: element acc: acc pushingResultsTo: continuation [

	"<continuation> value: (<acc> := (<callback> value: <acc> value: <element>))".
	^ RBMessageNode
		receiver: continuation
		selector: #value:
		arguments: { RBAssignmentNode
			variable: acc
			value: (RBMessageNode
				receiver: callback
				selector: #value:value:
				arguments: { acc. element }) }
]

{ #category : 'compiling w/inlines' }
InjectIntoTransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	"<continuation> value: (<acc> := (<callback> value: <acc> value: <element>))".
	^ (self
		astAfterApplying: { RBAssignmentNode
			variable: acc
			value: (self
				astAfterApplying: { acc. element }
				on: self astForCallback
				withNamespace: callback) }
		on: continuation
		withNamespace: callback)
]

{ #category : 'interpreting' }
InjectIntoTransformationDescriptor >> evalOnValue: anElement withPreviousValue: aState pushingResultsTo: aBlock [

	| newState |
	newState := update value: aState value: anElement.
	aBlock value: newState.
	^ newState
]

{ #category : 'initialization' }
InjectIntoTransformationDescriptor >> init: anInitialValue [

	anInitialValue isClosure ifTrue: [ self assert: anInitialValue isClean ].
	init := anInitialValue
]

{ #category : 'interpreting' }
InjectIntoTransformationDescriptor >> initialState [

	^ init value
]

{ #category : 'naive interpreting' }
InjectIntoTransformationDescriptor >> naiveValue: aCollection [

	^ aCollection inject: init value into: update
]

{ #category : 'initialization' }
InjectIntoTransformationDescriptor >> update: aCombiningBlock [

	self assert: (aCombiningBlock isSymbol or: [ aCombiningBlock isClean ]).
	update := aCombiningBlock
]
