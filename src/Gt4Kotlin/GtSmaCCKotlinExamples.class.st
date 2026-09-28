Class {
	#name : 'GtSmaCCKotlinExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Kotlin',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Kotlin'
}

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassFile [
	<gtExample>
	<return: #FAMIXFileGroup>
	| directory model file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'class Example'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles at: 1.
	self assert: file name equals: 'Example.kt'.
	^ model allFiles
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassModel [
	<gtExample>
	<return: #MooseModel>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'class Example'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: (model allModelClasses collect: #mooseName) asArray sorted equals: #('Example').
	^ model
]

{ #category : 'examples - support' }
GtSmaCCKotlinExamples >> sourceDirectoryNamed: aString withFiles: aDictionary [
	| sourceDirectory directory |
	sourceDirectory:= FileSystem memory root / 'src'.
	sourceDirectory ensureCreateDirectory.
	directory := sourceDirectory / aString.
	directory ensureCreateDirectory.
	aDictionary
		keysAndValuesDo: [ :path :source | 
			| file |
			file := directory / path.
			file writeStreamDo: [ :stream | stream nextPutAll: source ] ].
	^ sourceDirectory
]
