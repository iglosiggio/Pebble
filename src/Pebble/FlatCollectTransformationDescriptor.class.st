Class {
	#name : 'FlatCollectTransformationDescriptor',
	#superclass : 'StatelessTransformationDescriptor',
	#instVars : [
		'block'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
FlatCollectTransformationDescriptor >> astForCallback [

	^ self astForCallback: block
]

{ #category : 'initialization' }
FlatCollectTransformationDescriptor >> block: aBlock [

	self assert: (aBlock isSymbol or: [ aBlock isClean ]).
	block := aBlock
]

{ #category : 'compiling' }
FlatCollectTransformationDescriptor >> compileWithCallback: callback element: element pushingResultsTo: continuation [

	"(callback value: element) do: continuation"
	^ (RBMessageNode
		receiver: (RBMessageNode
			receiver: callback
			selector: #value:
			arguments: { element })
		selector: #do:
		arguments: { continuation })
]

{ #category : 'compiling w/inlines' }
FlatCollectTransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	"(callback value: element) do: continuation"
	^ (RBMessageNode
		receiver: (self
			astAfterApplying: { element }
			on: (self astForCallback)
			withNamespace: callback)
		selector: #do:
		arguments: { continuation })
]

{ #category : 'interpreting' }
FlatCollectTransformationDescriptor >> evalOnValue: anElement pushingResultsTo: aBlock [

	(block value: anElement) do: aBlock
]
