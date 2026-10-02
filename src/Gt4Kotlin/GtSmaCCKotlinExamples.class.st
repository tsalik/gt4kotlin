Class {
	#name : 'GtSmaCCKotlinExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Kotlin',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Kotlin'
}

{ #category : 'examples' }
GtSmaCCKotlinExamples >> sincleClassModelSourceLanguage [
	<gtExample>
	<return: #MooseModel>
	| model file |
	model := self singleClassModel.
	file := model allFiles first.
	self assert: model sourceLanguage class equals: FAMIXKotlinSourceLanguage.
	self assert: file sourceLanguage equals:  model sourceLanguage.
	^ model.
]

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
GtSmaCCKotlinExamples >> singleClassFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model file class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	class Example
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: file entities size equals: 1.
	self assert: file entities first == class.
	self assert: (class containerFiles includes: file).
	^ file.
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassFileSource [
	<gtExample>
	<return: #FAMIXFile>
	| file |
	file := self singleClassFile first.
	self assert: file mooseName equals: './com/example/Example.kt'.
	self assert: file sourceText equals: 'class Example'.
	^ file
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassFileStyler [
	<gtExample>
	<return: #FAMIXFile>
	| file |
	file := self singleClassFileSource.
	self assert: file gtStyler notNil.
	^ file
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassFolders [
	<gtExample>
	<return: #FAMIXFolder>
	| model root example |
	model := self singleClassModel.
	self
		assert: (model allFolders collect: #mooseName) asArray sorted
		equals: #('.' './com' './com/example').
	root := model allFolders detect: [ :each | each belongsTo isNil ].
	self assert: root name equals: '.'.
	example := model allFolders detect: [ :each | each name = 'example' ].
	self assert: (example files collect: #name) asArray equals: #('Example.kt').
	^ root
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

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassNamespace [
	<gtExample>
	<return: #FAMIXNamespace>
	| directory model namespace class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
			package com.example

 		 class Example
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self
		assert: ((model allNamespaces collect: #mooseName) includes: 'com::example').
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
GtSmaCCKotlinExamples >> singleClassSourceAnchor [
	<gtExample>
	<return: #FAMIXClass>
	| model class directory |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'class Example'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: class sourceText equals: 'class Example'.
	^ class
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

{ #category : 'examples' }
GtSmaCCKotlinExamples >> twoClassesFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model file first second |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	class First
	
	class Second
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	first := model allModelClasses detect: [ :each | each name = 'First' ].
	self assert: file entities size equals: 2.
	self assert: file entities first == first.
	self assert: (first containerFiles includes: file).
	second := model allModelClasses detect: [:each | each name = 'Second'].
	self assert: file entities second == second.
	self assert: (second containerFiles includes: file).
	^ file.
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> twoClassesSameFileNamespace [
	<gtExample>
	<return: #FAMIXNamespace>
	| directory model first second |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'First.kt'
						-> '
			package com.example

 		 class First
 		 
 		 class Second
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
	^ first container
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> twoClassesSamePackageNamespace [
	<gtExample>
	<return: #FAMIXNamespace>
	| directory model first second |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'First.kt'
						-> '
			package com.example

 		 class First
'.
					'Second.kt'
						-> '
			package com.example
			
			class Second
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
