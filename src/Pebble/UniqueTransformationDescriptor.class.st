Class {
	#name : 'UniqueTransformationDescriptor',
	#superclass : 'StatefulTransformationDescriptor',
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
UniqueTransformationDescriptor >> astForCallback [

	^ RBLiteralNode value: nil
]

{ #category : 'compiling' }
UniqueTransformationDescriptor >> astForInitialValue [

	^ RBMessageNode
		receiver: (RBVariableNode named: #Set)
		selector: #new
		arguments: { }
]

{ #category : 'compiling w/inlines' }
UniqueTransformationDescriptor >> astForInitialValueWithPrefix: aPrefix [

	^ self astForInitialValue
]

{ #category : 'compiling' }
UniqueTransformationDescriptor >> compileWithCallback: callback element: element acc: acc pushingResultsTo: continuation [

	"(<acc> includes: <element>) ifTrue: [ acc add: element. <continuation> value: <element> ]"
	^ RBMessageNode
		receiver: (RBMessageNode
			receiver: acc
			selector: #includes:
			arguments: { element })
		selector: #ifFalse:
		arguments: { RBBlockNode
			body: (RBSequenceNode statements: {
				(RBMessageNode
					receiver: acc
					selector: #add:
					arguments: { element }).
				(RBMessageNode
					receiver: continuation
					selector: #value:
					arguments: { element }) }) }
]

{ #category : 'compiling w/inlines' }
UniqueTransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	| elementAfterRead |
	elementAfterRead := RBVariableNode named: #elementAfterRead.
	"(<callback> value: <element>) ifTrue: [ <continuation> value: <element> ]"
	^ RBSequenceNode
		temporaries: { elementAfterRead }
		statements: {
			RBAssignmentNode
				variable: elementAfterRead
				value: element.
			RBMessageNode
				receiver: (RBMessageNode
					receiver: acc
					selector: #includes:
					arguments: { elementAfterRead })
				selector: #ifFalse:
				arguments: { RBBlockNode
					body: (RBSequenceNode statements: {
						RBMessageNode
							receiver: acc
							selector: #add:
							arguments: { elementAfterRead }.
						self
							astAfterApplying: { elementAfterRead }
							on: continuation
							withNamespace: callback }) } }
]

{ #category : 'interpreting' }
UniqueTransformationDescriptor >> evalOnValue: anElement withPreviousValue: aState pushingResultsTo: aBlock [

	(aState includes: anElement) ifFalse: [
		aState add: anElement.
		aBlock value: anElement ].
	^ aState
]

{ #category : 'interpreting' }
UniqueTransformationDescriptor >> initialState [

	^ Set new
]

{ #category : 'naive interpreting' }
UniqueTransformationDescriptor >> naiveValue: aCollection [

	^ (aCollection
		inject: OrderedDictionary new
		into: [ :seen :v |
			seen at: v ifAbsentPut: [ v ].
			seen ]) keys
]
