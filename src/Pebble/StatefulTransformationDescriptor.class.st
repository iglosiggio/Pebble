Class {
	#name : 'StatefulTransformationDescriptor',
	#superclass : 'TransformationDescriptor',
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'interpreting' }
StatefulTransformationDescriptor >> asExecutor [

	^ StatefulTransformationExecutor new
		state: self initialState;
		update: self;
		yourself.
]

{ #category : 'compiling' }
StatefulTransformationDescriptor >> astForInitialValue [

	^ self subclassResponsibility
]

{ #category : 'compiling w/inlines' }
StatefulTransformationDescriptor >> astForInitialValueWithPrefix: aPrefix [

	^ self subclassResponsibility
]

{ #category : 'interpreting' }
StatefulTransformationDescriptor >> evalOnValue: anElement withPreviousValue: aState pushingResultsTo: aBlock [

	self subclassResponsibility
]

{ #category : 'interpreting' }
StatefulTransformationDescriptor >> initialState [

	self subclassResponsibility
]

{ #category : 'accessing' }
StatefulTransformationDescriptor >> isExecutable [

	^ false
]
