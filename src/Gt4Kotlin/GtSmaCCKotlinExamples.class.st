Class {
	#name : 'GtSmaCCKotlinExamples',
	#superclass : 'Object',
	#category : 'Gt4Kotlin-Examples-Kotlin',
	#package : 'Gt4Kotlin',
	#tag : 'Examples-Kotlin'
}

{ #category : 'examples' }
GtSmaCCKotlinExamples >> classExtendingClassAndImplementingInterface [
	<gtExample>
	<return: #FAMIXClass>
	| directory model child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.kt' -> 'package com.example

open class Base'.
					'A.kt' -> 'package com.example

interface A'.
					'Derived.kt'
						-> 'package com.example

class Derived : Base(), A'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 2.
	child := model allModelClasses detect: [ :each | each name = 'Derived' ].
	self
		assert: (child superInheritances collect: [ :each | each superclass name ]) asSet
		equals: #('A' 'Base') asSet.
	^ child
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> classExtendingDefaultImportType [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance builtInType child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'CustomException.kt' -> 'package com.example

class CustomException : Exception() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	builtInType := model allTypes detect: [ :each | each name = 'Exception' ].
	child := model allModelClasses detect: [ :each | each name = 'CustomException' ].
	self assert: inheritance superclass == builtInType.
	self assert: inheritance subclass == child.
	self assert: builtInType isStub.
	self assert: builtInType container mooseName equals: 'kotlin'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> classImplementingDefaultImportTypeFromKotlinTextPackage [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance defaultImportType child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Buffer.kt' -> 'package com.example

abstract class Buffer : Appendable'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	defaultImportType := model allTypes
			detect: [ :each | each name = 'Appendable' ].
	child := model allModelClasses detect: [ :each | each name = 'Buffer' ].
	self assert: inheritance superclass == defaultImportType.
	self assert: inheritance subclass == child.
	self assert: defaultImportType isStub.
	self assert: defaultImportType container mooseName equals: 'kotlin::text'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> classImplementingInterfaceByDelegation [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance interface child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.kt' -> 'package com.example

interface Base {}'.
					'Derived.kt'
						-> 'package com.example

class Derived(impl: Base) : Base by impl {}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	interface := model allClasses detect: [ :each | each name = 'Base' ].
	child := model allModelClasses detect: [ :each | each name = 'Derived' ].
	self assert: inheritance superclass == interface.
	self assert: inheritance subclass == child.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> classImplementingInterfaceInTheSamePackage [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance interface child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.kt' -> 'package com.example

interface Base {}'.
					'Derived.kt'
						-> 'package com.example

class Derived : Base {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInDifferentPackagesModel [
	<gtExample>
	<return: #MooseModel>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.kt'
						-> '
						package com.vehicles
						
						open class Vehicle {}'.
					'com/cars/Car.kt'
						-> '
						package com.cars
						
						import com.vehicles.Vehicle
						class Car : Vehicle() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInDifferentPackagesWithImportAlias [
	"Kotlin only: Java has no import aliases, so there is no Java example to compare with"

	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.kt'
						-> '
	package com.vehicles
	
	open class Vehicle
	'.
					'com/cars/Car.kt'
						-> '
	package com.cars
	
	import com.vehicles.Vehicle as Transport
	
	class Car : Transport()
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance subclass == child.
	self assert: inheritance superclass == parent.
	self assert: parent isStub not.
	self assert: parent container name equals: 'vehicles'.
	self assert: (model allTypes noneSatisfy: [:each | each name = 'Transport']). 
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInDifferentPackagesWithStarImport [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.kt'
						-> '
						package com.vehicles
						
						class Vehicle {}'.
					'com/cars/Car.kt'
						-> '
						package com.cars
						
						import com.vehicles.*
						class Car : Vehicle() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	parent := model allModelClasses detect: [ :each | each name = 'Vehicle' ].
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance subclass == child.
	self assert: inheritance superclass == parent.
	self assert: parent isStub not.
	self assert: parent container name equals: 'vehicles'.
	self assert: child container name equals: 'cars'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInTheSamePackage [
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
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInTheSamePackageModel [
	<gtExample>
	<return: #MooseModel>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Vehicle.kt'
						-> '
			package com.example
			
			open class Vehicle {}
			'.
					'Car.kt'
						-> '
			package com.example
			
			class Car : Vehicle() {}
			'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	^ model
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInTheSamePackageOnTypes [
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
GtSmaCCKotlinExamples >> inheritanceBetweenClassesInTheSamePackageSourceAnchor [
      <gtExample>
      <return: #FAMIXInheritance>
      | model inheritance |
      model := self inheritanceBetweenClassesInTheSamePackageModel.
      inheritance := model allInheritanceDefinitions first.
      self assert: inheritance sourceText equals: 'Vehicle'.
      ^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> inheritanceFromClassOutsideTheModel [
      <gtExample>
      <return: #MooseModel>
      | directory model inheritance child |
      directory := self
                      sourceDirectoryNamed: 'com/package'
                      withFiles: {'Car.kt'
                                              -> '
                      package com.example

                      class Car : Vehicle() {}
                      '} asDictionary.
      model := GtSmaCCKotlinImporter new
                      baseDirectory: directory;
                      buildKotlinModel.
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
GtSmaCCKotlinExamples >> inheritanceFromImportedClassOutsideTheModel [
	<gtExample>
	<return: #MooseModel>
	| directory model inheritance child |
	directory := self
			sourceDirectoryWithFiles: {'com/cars/Car.kt'
						-> '
						package com.cars
						
						import org.vehicles.Vehicle
					  class Car : Vehicle() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
GtSmaCCKotlinExamples >> inheritanceFromSamePackageClassWhenImportAliasHidesOriginalName [
	"Kotlin only: Java has no import aliases, so there is no Java example to compare with"

	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance child |
	directory := self
			sourceDirectoryWithFiles: {'com/vehicles/Vehicle.kt'
						-> '
        package com.vehicles

        open class Vehicle
        '.
					'com/cars/Vehicle.kt'
						-> '
        package com.cars

        open class Vehicle
        '.
					'com/cars/Car.kt'
						-> '
        package com.cars

        import com.vehicles.Vehicle as Transport

        class Car : Vehicle()
        '}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	child := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: inheritance subclass == child.
	self assert: inheritance superclass isStub not.
	self assert: inheritance superclass container name equals: 'cars'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> interfaceExtendingInterface [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance parent child |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Base.kt' -> 'package com.example

interface Base {}'.
					'Derived.kt' -> 'package com.example

interface Derived : Base {}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
GtSmaCCKotlinExamples >> singleClassAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
	private lateinit var name: String
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes first.
	class := model allModelClasses detect: [ :each | each name = 'Car' ].
	self assert: attribute name equals: 'name'.
	self assert: attribute parentType == class.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassAttributeInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model attribute file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
        private lateinit var name: String
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	file := model allFiles detect: [ :each | each name = 'Car.kt' ].
	attribute := model allAttributes first.
	self assert: file entities size equals: 2.
	self assert: (file entities includes: attribute).
	^ file
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassAttributeModifiers [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
        private lateinit var name: String
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	attribute := model allAttributes first.
	self assert: attribute isPrivate.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassAttributeSourceAnchor [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
	private lateinit var name: String
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	attribute := model allAttributes first.
	self assert: attribute sourceText equals: 'private lateinit var name: String'.
	^ attribute
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
GtSmaCCKotlinExamples >> singleClassFinalAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
        private val name: String = ""
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	attribute := model allAttributes first.
	self assert: attribute isFinal.
	^ attribute
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
GtSmaCCKotlinExamples >> singleClassMethod [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model class method |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example {
		fun greet() {}
	}
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: model allModelMethods size equals: 1.
	method := model allModelMethods detect: [:each | each name = 'greet'].
	self assert: method parentType == class.
	self assert: (class methods includes: method).
	self assert: method mooseName equals: 'com::example::Example.greet()'.
	self assert: method sourceText equals: 'fun greet() {}'.
	^ method.
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassMethodInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model class method file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example {
		fun greet() {}
	}
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFiles size equals: 1.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: file entities size equals: 2.
	class := model allModelClasses detect: [:each | each name = 'Example'].
	method := class methods detect: [:each | each name = 'greet'].
	self assert: (file entities includes: method).
	^ file
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassMethodParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model method parameter |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example {
		fun greet(message: String) {}
	}
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: method parameters size equals: 1.
	parameter := method parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == method.
	self assert: parameter sourceText equals: 'message: String'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	^ parameter
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassMethodParameterInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model method parameter file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example {
		fun greet(message: String) {}
	}
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: method parameters size equals: 1.
	parameter := method parameters first.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: parameter).
	^ file
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

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleInterface [
	<gtExample>
	<return: #FAMIXClass>
	| directory model interface |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Example.kt' -> 'package com.example

interface Example {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allClasses size equals: 1.
	interface := model allClasses first.
	self assert: interface name equals: 'Example'.
	self assert: interface isInterface.
	self assert: interface isStub not.
	^ interface
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

{ #category : 'examples - support' }
GtSmaCCKotlinExamples >> sourceDirectoryWithFiles: aDictionary [
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
