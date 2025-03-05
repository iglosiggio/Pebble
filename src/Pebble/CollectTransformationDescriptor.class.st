Class {
	#name : 'CollectTransformationDescriptor',
	#superclass : 'StatelessTransformationDescriptor',
	#instVars : [
		'block'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
CollectTransformationDescriptor >> astForCallback [

	^ self astForCallback: block
]

{ #category : 'initialization' }
CollectTransformationDescriptor >> block: aBlock [

	self assert: (aBlock isSymbol or: [ aBlock isClean ]).
	block := aBlock
]

{ #category : 'compiling' }
CollectTransformationDescriptor >> compileWithCallback: callback element: element pushingResultsTo: continuation [

	"<continuation> value: (<callbac> value: <element>)"
		^ RBMessageNode
			receiver: continuation
			selector: #value:
			arguments: { (RBMessageNode
				receiver: callback
				selector: #value:
				arguments: { element }) }
]

{ #category : 'compiling w/inlines' }
CollectTransformationDescriptor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	"<continuation> value: (<callbac> value: <element>)"
	^ self
		astAfterApplying: { self
			astAfterApplying: { element }
			on: self astForCallback
			withNamespace: callback }
		on: continuation
		withNamespace: callback
			
		
]

{ #category : 'interpreting' }
CollectTransformationDescriptor >> evalOnValue: anElement pushingResultsTo: aBlock [

	aBlock value: (block value: anElement)
]
