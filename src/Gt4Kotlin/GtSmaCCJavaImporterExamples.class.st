Class {
	#name : 'GtSmaCCJavaImporterExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Java',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Java'
}

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> classExtendingClassAndImplementingInterface [
	<gtExample>
	<return: #FAMIXClass>
	| directory model child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.java' -> 'package com.example;

public class Base {}'.
					'A.java' -> 'package com.example;

public interface A {}'.
					'Derived.java'
						-> 'package com.example;

public class Derived extends Base implements A {}'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 2.
	child := model allModelClasses detect: [ :each | each name = 'Derived' ].
	self
		assert: (child superInheritances collect: [ :each | each superclass name ]) asSet
		equals: #('A' 'Base') asSet.
	^ child
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> classExtendingDefaultImportType [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance builtInType child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'CustomException.java' -> 'package com.example;

public class CustomException extends Exception {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	builtInType := model allTypes detect: [ :each | each name = 'Exception' ].
	child := model allModelClasses detect: [ :each | each name = 'CustomException' ].
	self assert: inheritance superclass == builtInType.
	self assert: inheritance subclass == child.
	self assert: builtInType isStub.
	self assert: builtInType container mooseName equals: 'java::lang'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> classImplementingInterfaceInTheSamePackage [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance interface child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.java' -> 'package com.example;

public interface Base {}'.
					'Derived.java'
						-> 'package com.example;

public class Derived implements Base {}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	interface := model allClasses detect: [ :each | each name = 'Base' ].
	child := model allModelClasses detect: [ :each | each name = 'Derived' ].
	self assert: inheritance superclass == interface.
	self assert: inheritance subclass == child.
	self assert: interface isInterface.
	^ inheritance
]

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
GtSmaCCJavaImporterExamples >> inheritanceBetweenClassesInDifferentPackagesWithStarImport [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.java'
						-> '
						package com.vehicles;
						
						public class Vehicle {}'.
					'com/cars/Car.java'
						-> '
						package com.cars;
						
						import com.vehicles.*;
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
	^ inheritance.
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
GtSmaCCJavaImporterExamples >> interfaceExtendingInterface [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.java' -> 'package com.example;

public interface Base {}'.
					'Derived.java'
						-> 'package com.example;

public interface Derived extends Base {}'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	parent := model allClasses detect: [ :each | each name = 'Base' ].
	child := model allClasses detect: [ :each | each name = 'Derived' ].
	self assert: inheritance superclass == parent.
	self assert: inheritance subclass == child.
	self assert: parent isInterface.
	self assert: child isInterface.
	self assert: model allModelClasses isEmpty.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> localVariableIsNotAnAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
	private String name;

	public String greet() {
		String greeting = "Hello";
		return greeting;
	}
}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes first.
	class := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: attribute name equals: 'name'.
	self assert: attribute parentType == class.
	^ attribute
]

{ #category : 'exa' }
GtSmaCCJavaImporterExamples >> nestedClassContainer [
	<gtExample>
	<return: #FAMIXClass>
	| directory model outer inner |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Outer.java'
						-> 'package com.example;

public class Outer {
        public static class Inner {}
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelClasses size equals: 2.
	outer := model allModelClasses detect: [ :each | each name = 'Outer' ].
	inner := model allModelClasses detect: [ :each | each name = 'Inner' ].
	self assert: outer container mooseName equals: 'com::example'.
	self assert: inner container == outer.
	self assert: inner mooseName equals: 'com::example::Outer::Inner'.
	^ inner
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
GtSmaCCJavaImporterExamples >> singleClassAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute class stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
	private String name;
}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes first.
	class := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: attribute name equals: 'name'.
	self assert: attribute parentType == class.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: attribute declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'java::lang'.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassAttributeInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model attribute file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
        private String name;
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	file := model allFiles detect: [ :each | each name = 'Car.java' ].
	attribute := model allAttributes first.
	self assert: file entities size equals: 2.
	self assert: (file entities includes: attribute).
	^ file
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassAttributeModifiers [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
        private String name;
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	attribute := model allAttributes first.
	self assert: attribute isPrivate.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassAttributeSourceAnchor [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
        private String name;
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	attribute := model allAttributes first.
	self assert: attribute sourceText equals: 'private String name;'.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructor [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
        public Example() {}
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor signature equals: 'Example()'.
	^ constructor
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructorParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model constructor parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public Example(String message) {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 1.
	parameter := constructor parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == constructor.
	self assert: parameter sourceText equals: 'String message'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'java::lang'.
	self assert: constructor signature equals: 'Example(String)'.
	self assert: constructor mooseName equals: 'com::example::Example.Example(String)'.
	self assert: model allAttributes size equals: 0.
	^ parameter
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructorParameterInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model constructor parameter file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public Example(String message) {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 1.
	parameter := constructor parameters first.
	file := model allFiles detect: [ :each | each name = 'Example.java' ].
	self assert: (file entities includes: parameter).
	^ file
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructorParameterWithAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model class constructor message title stringType file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
package com.example;

public class Example {
	private final String message;
	String title;

	public Example(String message, String title) {
		this.message = message;
		this.title = title;
	}
}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: model allAttributes size equals: 2.
	self
		assert: (model allAttributes collect: [ :each | each name ]) asSet
		equals: #('message' 'title') asSet.
	self assert: (model allAttributes allSatisfy: [ :each | each parentType == class ]).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: (model allAttributes allSatisfy: [ :each | each declaredType == stringType ]).
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'java::lang'.
	message := model allAttributes detect: [ :each | each name = 'message' ].
	title := model allAttributes detect: [ :each | each name = 'title' ].
	self assert: message isFinal.
	self assert: title isFinal not.
	self assert: message isPrivate.
	self assert: title isPrivate not.
	self assert: message sourceText equals: 'private final String message;'.
	self assert: title sourceText equals: 'String title;'.
	file := model allFiles detect: [ :each | each name = 'Example.java' ].
	self assert: (file entities includes: message).
	self assert: (file entities includes: title).
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 2.
	self
		assert: (constructor parameters collect: [ :each | each name ]) asSet
		equals: #('message' 'title') asSet.
	self
		assert: (constructor parameters allSatisfy: [ :each | each parentBehaviouralEntity == constructor ]).
	^ message
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructorWithParameter [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;
public class Example {
		private final String message;
		
		public Example(String message) {
			this.message = message;
		}
}'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor name equals: 'Example'.
	self assert: constructor mooseName equals: ('com::example::Example.Example(String)').
	self assert: constructor signature equals: 'Example(String)'.
	self assert: constructor parameters size equals: 1.
	self assert: constructor parameters first name equals: 'message'.
	self
		assert: constructor sourceText
		equals: 'public Example(String message) {
			this.message = message;
		}'.
	^ constructor
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassConstructorWithTwoParameters [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
        public Example(String first, String second) {}
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor signature equals: 'Example(String, String)'.
	self assert: constructor parameters size equals: 2.
	self
		assert: (constructor parameters collect: [ :each | each name ]) asSet
		equals: #('first' 'second') asSet.
	self
		assert: constructor sourceText
		equals: 'public Example(String first, String second) {}'.
	^ constructor
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
GtSmaCCJavaImporterExamples >> singleClassFinalAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.java'
						-> 'package com.example;

public class Car {
        private final String name = "";
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	attribute := model allAttributes first.
	self assert: attribute isFinal.
	^ attribute
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
GtSmaCCJavaImporterExamples >> singleClassInitializer [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model initializer class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
        private String name;

        {
        		//empty block
        }
}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allModelMethods size equals: 1.
	initializer := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: initializer name equals: '$Example'.
	self assert: initializer parentType == class.
	self assert: initializer signature equals: '$Example()'.
	self assert: (initializer modifiers includes: #static).
	^ initializer
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassInitializerLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model initializer local class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
        private String name;

        {
                String greeting = "Hello";
        }
}
'}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allAttributes size equals: 1.
	self assert: model allAttributes first name equals: 'name'.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	initializer := model allModelMethods detect: [ :each | each name = '$Example' ].
	self assert: initializer parentType == class.
	self assert: local name equals: 'greeting'.
	self assert: local parentBehaviouralEntity == initializer.
	^ local
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
GtSmaCCJavaImporterExamples >> singleClassMethodLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model method local stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
	public String greet() {
		String greeting = "Hello";
		return greeting;
	}
}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables first.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: local name equals: 'greeting'.
	self assert: local parentBehaviouralEntity == method.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: local declaredType == stringType.
	self assert: stringType container mooseName equals: 'java::lang'.
	^ local
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassMethodParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model method parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public void greet(String message) {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: method parameters size equals: 1.
	parameter := method parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == method.
	self assert: parameter sourceText equals: 'String message'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'java::lang'.
	self assert: method signature equals: 'greet(String)'.
	self assert: method mooseName equals: 'com::example::Example.greet(String)'.
	^ parameter
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassMethodParameterInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model method parameter file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public void greet(String message) {}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: method parameters size equals: 1.
	parameter := method parameters first.
	file := model allFiles detect: [ :each | each name = 'Example.java' ].
	self assert: (file entities includes: parameter).
	^ file
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassMethodReturnType [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model method stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> '
	package com.example;
	
	public class Example {
		public String greet() {
			return "Hello";
		}
	}
	'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: method declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'java::lang'.
	^ method
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
	self assert: (model allModelMethods size) equals: 0.
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

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleClassTwoInitializers [
	<gtExample>
	<return: #FAMIXMethodGroup>
	| directory model initializers class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.java'
						-> 'package com.example;

public class Example {
        private String name;

        {
        		//first block
        }

        {
        		//second block
        }
}
'} asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	initializers := model allModelMethods asArray.
	self assert: initializers size equals: 2.
	self assert: initializers first ~~ initializers second.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	initializers
		do: [ :each | 
			self assert: each name equals: '$Example'.
			self assert: each parentType == class.
			self assert: each signature equals: '$Example()'.
			self assert: (each modifiers includes: #static) ].
	^ model allModelMethods
]

{ #category : 'examples' }
GtSmaCCJavaImporterExamples >> singleInterface [
	<gtExample>
	<return: #FAMIXClass>
	| directory model interface |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Example.java'
						-> 'package com.example;

public interface Example {}
                        '}
					asDictionary.
	model := GtSmaCCJavaImporter new
			baseDirectory: directory;
			buildJavaModel.
	self assert: model allClasses size equals: 1.
	interface := model allClasses first.
	self assert: interface name equals: 'Example'.
	self assert: interface isInterface.
	self assert: interface isStub not.
	^ interface
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
