Class {
	#name : 'StatefulTransformationExecutor',
	#superclass : 'TransformationDescriptor',
	#instVars : [
		'state',
		'update'
	],
	#category : 'Pebble',
	#package : 'Pebble'
}

{ #category : 'compiling' }
StatefulTransformationExecutor >> compileWithCallback: callback element: value acc: acc pushingResultsTo: continuation [

	self shouldNotImplement
]

{ #category : 'compiling w/inlines' }
StatefulTransformationExecutor >> compileWithCallbackNamespace: callback element: element acc: acc pushingResultsTo: continuation [

	self shouldNotImplement
]

{ #category : 'interpreting' }
StatefulTransformationExecutor >> evalOnValue: anElement pushingResultsTo: aBlock [

	state := update
		evalOnValue: anElement
		withPreviousValue: state
		pushingResultsTo: aBlock
]

{ #category : 'interpreting' }
StatefulTransformationExecutor >> evalOnValue: anElement withPreviousValue: aState pushingResultsTo: aBlock [

	self shouldNotImplement
]

{ #category : 'accessing' }
StatefulTransformationExecutor >> isExecutable [

	^ true
]

{ #category : 'accessing' }
StatefulTransformationExecutor >> state [

	^ state
]

{ #category : 'initialization' }
StatefulTransformationExecutor >> state: anInitialState [

	state := anInitialState
]

{ #category : 'initialization' }
StatefulTransformationExecutor >> update: anUpdateBlock [

	update := anUpdateBlock
]
