Class {
	#name : 'SelectTransformationDescriptor',
	#superclass : 'StatelessTransformationDescriptor',
	#instVars : [
		'block'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
SelectTransformationDescriptor >> astForCallback [

	^ self astForCallback: block
]

{ #category : 'initialization' }
SelectTransformationDescriptor >> block: aBlock [

	block := aBlock
]

{ #category : 'compiling' }
SelectTransformationDescriptor >> compileWithCallback: callback element: element pushingResultsTo: continuation [

	"(<callback> value: <element>) ifTrue: [ <continuation> value: <element> ]"
	^ RBMessageNode
		receiver: (RBMessageNode
			receiver: callback
			selector: #value:
			arguments: { element })
		selector: #ifTrue:
		arguments: { RBBlockNode
			body: (RBMessageNode
				receiver: continuation
				selector: #value:
				arguments: { element }) asSequenceNode }
]

{ #category : 'compiling w/inlines' }
SelectTransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

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
				receiver: (self
					astAfterApplying: { elementAfterRead }
					on: (self astForCallback)
					withNamespace: callback)
				selector: #ifTrue:
				arguments: { RBBlockNode
					body: (self
						astAfterApplying: { elementAfterRead }
						on: continuation
						withNamespace: callback) asSequenceNode } }
]

{ #category : 'interpreting' }
SelectTransformationDescriptor >> evalOnValue: anElement pushingResultsTo: aBlock [

	(block value: anElement) ifTrue: [ aBlock value: anElement ]
]
