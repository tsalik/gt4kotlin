Class {
	#name : 'GtSmaCCJavaImporterExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Java',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Java'
}

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInDifferentPackagesModel [
	<gtExample>
	<return: #MooseModel>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.java'
						-> '
						package com.vehicles;
						
						public class Vehicle {}'.
					'com/cars/Car.java'
						-> '
						package com.cars;
						
						import com.vehicles.Vehicle;
						public class Car extends Vehicle {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance subclass == child.
	self assert: inheritance superclass == parent.
	self assert: parent isStub not.
	self assert: parent container name equals: 'vehicles'.
	self assert: child container name equals: 'cars'.
	^ model
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInTheSamePackage [
	<gtExample>
	<return: #FAMIXInheritance>
	| model inheritance parent child |
	model := self inheritanceBetweenClassesInTheSamePackageModel.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance superclass == parent.
	self assert: inheritance subclass == child.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInTheSamePackageModel [
	<gtExample>
	<return: #MooseModel>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Vehicle.java'
						-> '
			package com.example;
			
			public class Vehicle {}
			'.
					'Car.java'
						-> '
			package com.example;
			
			public class Car extends Vehicle {}
			'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance superclass == parent.
	self assert: inheritance subclass == child.
	^ model
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInTheSamePackageOnTypes [
	<gtExample>
	<return: #FAMIXClass>
	| model inheritance parent child |
	model := self inheritanceBetweenClassesInTheSamePackageModel.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: child superInheritances size equals: 1.
	self assert: (child superInheritances includes: inheritance).
	self assert: parent subInheritances size equals: 1.
	self assert: (parent subInheritances includes: inheritance).
	^ child
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInTheSamePackageSourceAnchor [
      <gtExample>
      <return: #FAMIXInheritance>
      | model inheritance |
      model := self inheritanceBetweenClassesInTheSamePackageModel.
      inheritance := model allInheritanceDefinitions first.
      self assert: inheritance sourceText equals: 'Vehicle'.
      ^ inheritance
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceFromClassOutsideTheModel [
      <gtExample>
      <return: #MooseModel>
      | directory model inheritance child |
      directory := self
                      sourceDirectoryNamed: 'com/package'
                      withFiles: {'Car.java'
                                              -> '
                      package com.example;

                      public class Car extends Vehicle {}
                      '} asDictionary.
      model := GtSmaCCJavaImporter new
                      baseDirectory: directory;
                      buildJavaModel.
      self assert: model allInheritanceDefinitions size equals: 1.
      inheritance := model allInheritanceDefinitions first.
      child := model allModelClasses detect: [:each | each name = 'Car'].
      self assert: inheritance subclass == child.
      self assert: inheritance superclass name equals: 'Vehicle'.
      self assert: inheritance superclass isStub.
      self assert: inheritance superclass container name equals: '__UNKNOWN__'.
      ^ model
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> inheritanceFromImportedClassOutsideTheModel [
	<gtExample>
	<return: #MooseModel>
	| directory model inheritance child |
	directory := self
			sourceDirectoryWithFiles: {'com/cars/Car.java'
						-> '
						package com.cars;
						
						import org.vehicles.Vehicle;
						public class Car extends Vehicle {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance subclass == child.
	self assert: inheritance superclass name equals: 'Vehicle'.
	self assert: inheritance superclass isStub.
	self assert: inheritance superclass container name equals: 'vehicles'.
	self assert: inheritance superclass container parentScope name equals: 'org'.
	^ model
]

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
GtSmaCCJavaImporterExamples >> singleClassFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model file class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	public class Example {}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles detect: [ :each | each name = 'Example.java' ].
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: file entities size equals: 1.
	self assert: file entities first == class.
	self assert: (class containerFiles includes: file).
	^ file.
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
GtSmaCCJavaImporterExamples >> singleClassMethod [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model class method |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public void greet() {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: model allModelMethods size equals: 1.
	method := model allModelMethods detect: [:each | each name = 'greet'].
	self assert: method parentType == class.
	self assert: (class methods includes: method).
	self assert: method mooseName equals: 'com::example::Example.greet()'.
	self assert: method sourceText equals: 'public void greet() {}'.
	^ method.
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassMethodInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model class method file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public void greet() {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles detect: [ :each | each name = 'Example.java' ].
	self assert: file entities size equals: 2.
	class := model allModelClasses detect: [:each | each name = 'Example'].
	method := class methods detect: [:each | each name = 'greet'].
	self assert: (file entities includes: method).
	^ file
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

{ #category : 'examples - support' }
GtSmaCCJavaImporterExamples >> sourceDirectoryWithFiles: aDictionary [
	| sourceDirectory |
	sourceDirectory := FileSystem memory root / 'src'.
	sourceDirectory ensureCreateDirectory.
	aDictionary
		keysAndValuesDo: [ :path :source | 
			| file |
			file := sourceDirectory resolveString: path.
			file parent ensureCreateDirectory.
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
