Class {
	#name : 'GtSmaCCJavaImporterExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Java',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Java'
}

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassMooseModel [
	<gtExample>
	<return: #MooseModel>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java' -> 'public class Example {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelClasses size equals: 1.
	^ model
]

{ #category : 'examples - support' }
GtSmaCCJavaImporterExamples >> sourceDirectoryNamed: aString withFiles: aDictionary [
	| sourceDirectory directory |
	sourceDirectory := FileSystem memory root / 'src'.
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
