Class {
	#name : 'StatelessTransformationDescriptor',
	#superclass : 'TransformationDescriptor',
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
StatelessTransformationDescriptor >> compileWithCallback: callback element: element acc: acc pushingResultsTo: continuation [

	^ self compileWithCallback: callback element: element pushingResultsTo: continuation
]

{ #category : 'compiling' }
StatelessTransformationDescriptor >> compileWithCallback: callback element: element pushingResultsTo: continuation [

	self subclassResponsibility
]

{ #category : 'interpreting' }
StatelessTransformationDescriptor >> evalOnValue: anElement pushingResultsTo: aBlock [

	self subclassResponsibility
]

{ #category : 'accessing' }
StatelessTransformationDescriptor >> isExecutable [

	^ true
]
