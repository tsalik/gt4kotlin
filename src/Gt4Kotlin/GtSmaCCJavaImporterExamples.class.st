Class {
	#name : 'GtSmaCCJavaImporterExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Java',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Java'
}

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> sincleClassModelSourceLanguage [
	<gtExample>
	<return: #MooseModel>
	| model file |
	model := self singleClassMooseModel.
	file := model allFiles first.
	self assert: model sourceLanguage class equals: FAMIXJavaSourceLanguage.
	self assert: file sourceLanguage equals:  model sourceLanguage.
	^ model.
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassFile [
	<gtExample>
	<return: #FAMIXFileGroup>
	| directory model file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java' -> 'public class Example {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles at: 1.
	self assert: file name equals: 'Example.java'.
	^ model allFiles
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassFileSource [
	<gtExample>
	<return: #FAMIXFile>
	| file |
	file := self singleClassFile first.
	self assert: file mooseName equals: './com/example/Example.java'.
	self assert: file sourceText equals: 'public class Example {}'.
	^ file.
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassFileStyler [
	<gtExample>
	<return: #FAMIXFile>
	| file |
	file := self singleClassFileSource.
	self assert: file sourceLanguage isJava.
	self assert: file gtStyler notNil.
	^ file
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassFolders [
	<gtExample>
	<return: #FAMIXFolder>
	| model root example |
	model := self singleClassMooseModel.
	self
		assert: (model allFolders collect: #mooseName) asArray sorted
		equals: #('.' './com' './com/example').
	root := model allFolders detect: [ :each | each belongsTo isNil ].
	self assert: root name equals: '.'.
	example := model allFolders detect: [ :each | each name = 'example' ].
	self assert: (example files collect: #name) asArray equals: #('Example.java').
	^ root
]

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
	self
		assert: (model allModelClasses collect: #mooseName) asArray sorted
		equals: #('Example').
	^ model
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassNamespace [
	<gtExample>
	<return: #FAMIXNamespace>
	| directory model namespace class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
			package com.example;

 		public class Example {}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: ((model allNamespaces collect:#mooseName) includes: 'com::example').
	namespace := model allNamespaces
			detect: [ :each | each mooseName = 'com::example' ].
	self assert: namespace name equals: 'example'.
	self assert: namespace parentScope name equals: 'com'.
	self assert: namespace parentScope parentScope isNil.
	class := model allModelClasses
			detect: [ :each | each mooseName = 'com::example::Example' ].
	self assert: class container equals: namespace.
	^ namespace
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassSourceAnchor [
	<gtExample>
	<return: #FAMIXClass>
	| model class directory |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java' -> 'public class Example {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: class sourceText equals: 'public class Example {}'.
	^ class
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

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> twoClassesSamePackageNamespace [
	<gtExample>
	<return: #FAMIXNamespace>
	| directory model first second |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'First.java'
						-> '
			package com.example;

 		 public class First {}
'.
					'Second.java'
						-> '
			package com.example;
			
			public class Second {}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self
		assert: (model allModelNamespaces collect: #mooseName) asArray sorted
		equals: #('com::example').
	self
		assert: (model allNamespaces select: [ :each | each mooseName = 'com' ]) size
		equals: 1.
	self
		assert: (model allNamespaces select: [ :each | each mooseName = 'com::example' ]) size
		equals: 1.
	first := model allModelClasses detect: [ :each | each name = 'First' ].
	second := model allModelClasses detect: [ :each | each name = 'Second' ].
	self assert: first container == second container.
	^ first container.
]
