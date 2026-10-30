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
GtSmaCCKotlinExamples >> declaredTypesForwardReference [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute classA classB |
	directory := self
			sourceDirectoryWithFiles: {'a/A.kt' -> 'package a

import b.B

class A {
        lateinit var b: B
}
'.
					'b/B.kt' -> 'package b

class B
'} asDictionary.
	self
		assert: (KotlinParser sourceFilesIn: directory) first basename
		equals: 'A.kt'.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes first.
	classA := model allModelClasses detect: [ :each | each name = 'A' ].
	classB := model allModelClasses detect: [ :each | each name = 'B' ].
	self assert: attribute name equals: 'b'.
	self assert: attribute parentType == classA.
	self assert: attribute declaredType == classB.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> destructuringDeclarationsExplicitTypes [
	<gtExample>
	<return: #Collection>
	| directory model localVariables a b stringType intType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    fun greet(pair: Pair<String, Int>) {
        val (a: String, b: Int) = pair
    }

}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	localVariables := model allLocalVariables.
	self assert: localVariables size equals: 2.
	a := localVariables detect: [ :each | each name = 'a' ].
	b := localVariables detect: [ :each | each name = 'b' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	intType := model allTypes detect: [ :each | each name = 'Int' ].
	self assert: a declaredType == stringType.
	self assert: b declaredType == intType.
	^ localVariables
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> destructuringDeclarationsLocalVariables [
	<gtExample>
	<return: #Collection>
	| directory model localVariables |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    fun greet(pair: Pair<String, String>) {
        val (a,b) = pair
    }

}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	localVariables := model allLocalVariables.
	self assert: localVariables size equals: 2.
	^ localVariables
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> destructuringDeclarationsUnderscoreIsNotALocalVariable [
	<gtExample>
	<return: #FMAIXLocalVariable>
	| directory model localVariables local |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    fun greet(pair: Pair<String, String>) {
        val (_,b) = pair
    }

}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	localVariables := model allLocalVariables.
	self assert: localVariables size equals: 1.
	local := model allLocalVariables first.
	self assert: local name equals: 'b'.
	^ local
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> genericMethodParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model method parameter |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
        package com.example

        class Example {
                fun <T> identity(value: T): T = value
        }
        '}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	method := model allModelMethods detect: [ :each | each name = 'identity' ].
	self assert: method parameters size equals: 1.
	parameter := method parameters first.
	self assert: parameter name equals: 'value'.
	self assert: parameter parentBehaviouralEntity == method.
	self assert: parameter sourceText equals: 'value: T'.
	^ parameter
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
GtSmaCCKotlinExamples >> localVariableIsNotAnAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Car.kt'
						-> 'package com.example

class Car {
	private lateinit var name: String

	fun greet(): String {
		val greeting: String = "Hello"
		return greeting
	}
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
GtSmaCCKotlinExamples >> nestedClassContainer [
	<gtExample>
	<return: #FAMIXClass>
	| directory model outer inner |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Outer.kt'
						-> 'package com.example;

class Outer {
	class Inner {}
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelClasses size equals: 2.
	outer := model allModelClasses detect: [ :each | each name = 'Outer' ].
	inner := model allModelClasses detect: [ :each | each name = 'Inner' ].
	self assert: outer container mooseName equals: 'com::example'.
	self assert: inner container == outer.
	self assert: inner mooseName equals: 'com::example::Outer::Inner'.
	^ inner
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
	| directory model attribute class stringType |
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
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: attribute declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
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

{ #category : 'examples-type-inference' }
GtSmaCCKotlinExamples >> singleClassAttributeInferredType [
	<gtExample>
	<noTest>
	<return: #FAMIXAttribute>
	| directory model attribute stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
	private val greet = "Hello"
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes detect: [ :each | each name = 'greet' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: attribute declaredType == stringType.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ attribute
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
GtSmaCCKotlinExamples >> singleClassAttributeTypeInferenceNilDeclaredType [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model attribute |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
	private val greet = "Hello"
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allAttributes size equals: 1.
	attribute := model allAttributes detect: [:each | each name = 'greet'].
	self assert: attribute declaredType isNil.
	^ attribute
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassConstructorLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model constructor local class stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
        private val name: String = "Example"

        constructor() {
                val greeting: String = "Hello"
        }
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allAttributes size equals: 1.
	self assert: model allAttributes first name equals: 'name'.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parentType == class.
	self assert: local name equals: 'greeting'.
	self assert: local parentBehaviouralEntity == constructor.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: local declaredType == stringType.
	^ local
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassConstructorParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model constructor parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example(message: String)
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 1.
	parameter := constructor parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == constructor.
	self assert: parameter sourceText equals: 'message: String'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	self assert: constructor signature equals: 'Example(String)'.
	self assert: constructor mooseName equals: 'com::example::Example.Example(String)'.
	self assert: model allAttributes size equals: 0.
	^ parameter
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassConstructorParameterInFileEntities [
	<gtExample>
	<return: #FAMIXFile>
	| directory model constructor parameter file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example(message: String)
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 1.
	parameter := constructor parameters first.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: parameter).
	^ file
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassConstructorParameterWithAttribute [
	<gtExample>
	<return: #FAMIXAttribute>
	| directory model class constructor message title stringType file |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
package com.example

class Example(private val message: String, var title: String)'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: model allAttributes size equals: 2.
	self
		assert: (model allAttributes collect: [ :each | each name ]) asSet
		equals: #('message' 'title') asSet.
	self assert: (model allAttributes allSatisfy: [ :each | each parentType == class ]).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: (model allAttributes allSatisfy: [ :each | each declaredType == stringType ]).
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	message := model allAttributes detect: [ :each | each name = 'message' ].
	title := model allAttributes detect: [ :each | each name = 'title' ].
	self assert: message isFinal.
	self assert: title isFinal not.
	self assert: message isPrivate.
	self assert: title isPrivate not.
	self assert: message sourceText equals: 'private val message: String'.
	self assert: title sourceText equals: 'var title: String'.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
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
GtSmaCCKotlinExamples >> singleClassConstructorWithTwoParameters [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example
class Example(first: String, second: String)'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
	self assert: constructor sourceText equals: '(first: String, second: String)'.
	^ constructor
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
GtSmaCCKotlinExamples >> singleClassImplicitEmptyConstructor [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example()
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 0.
	^ model
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassInitializer [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model initializer class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    init {
        // empty block
    }
    
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 1.
	initializer := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: initializer name equals: '$Example'.
	self assert: initializer parentType == class.
	self assert: initializer signature equals: '$Example()'.
	^ initializer
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassInitializerLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model initializer local class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    private lateinit var name: String

    init {
        val greeting: String = "Hello"
        name = greeting
    }
    
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
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
GtSmaCCKotlinExamples >> singleClassLocalVariableTypeInferenceNilDeclaredType [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model localVariable |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
	
	fun greet() {
		val greet = "Hello" 
	}
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allLocalVariables size equals: 1.
	localVariable := model allLocalVariables detect: [:each | each name = 'greet'].
	self assert: localVariable declaredType isNil.
	^ localVariable
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
GtSmaCCKotlinExamples >> singleClassMethodImplicitUnitReturnType [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model method unitType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
        package com.example

        class Example {
                fun greet() {}
        }
        '}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	unitType := model allTypes detect: [ :each | each name = 'Unit' ].
	self assert: method declaredType == unitType.
	self assert: unitType isStub.
	self assert: unitType container mooseName equals: 'kotlin'.
	^ method
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
GtSmaCCKotlinExamples >> singleClassMethodLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model method local stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
	fun greet(): String {
		val greeting: String = "Hello"
		return greeting
	}
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables first.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	self assert: local name equals: 'greeting'.
	self assert: local parentBehaviouralEntity == method.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: local declaredType == stringType.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ local
]

{ #category : 'examples-type-inference' }
GtSmaCCKotlinExamples >> singleClassMethodLocalVariableInferredType [
	<gtExample>
	<noTest>
	<return: #FAMIXLocalVariable>
	| directory model local stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {
	fun greet(): String {
		val greeting = "Hello"
		return greeting
	}
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables detect: [ :each | each name = 'greeting' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: local declaredType == stringType.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ local
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassMethodParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model method parameter stringType |
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
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	self assert: method signature equals: 'greet(String)'.
	self assert: method mooseName equals: 'com::example::Example.greet(String)'.
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
GtSmaCCKotlinExamples >> singleClassMethodReturnType [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model method stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
	package com.example
	
	class Example {
		fun greet(): String {
			return "Hello"
		}
	}
	'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	method := model allModelMethods detect: [ :each | each name = 'greet' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: method declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ method
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
	self assert: (model allModelMethods size) equals: 0.
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
GtSmaCCKotlinExamples >> singleClassPrimaryConstructorWithKeywordAndParameter [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example
class Example constructor(message: String)'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor signature equals: 'Example(String)'.
	self assert: constructor sourceText equals: 'constructor(message: String)'.
	^ constructor
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassPrimaryConstructorWithParameter [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example
class Example(private val message: String)'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor name equals: 'Example'.
	self
		assert: constructor mooseName
		equals: 'com::example::Example.Example(String)'.
	self assert: constructor signature equals: 'Example(String)'.
	self assert: constructor parameters size equals: 1.
	self assert: constructor parameters first name equals: 'message'.
	self assert: constructor sourceText equals: '(private val message: String)'.
	^ constructor
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassPrimaryEmptyConstructorNoKeyword [
	<gtExample>
	<return: #MooseModel>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example()
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 0.
	^ model
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassPrimaryEmptyConstructorWithKeyword [
	<gtExample>
	<return: #MooseModel>
	| directory model |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example constructor()
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 0.
	^ model
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassSecondaryConstructor [
	<gtExample>
	<return: #FAMIXMethod>
	| directory model constructor class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example
                          
  class Example {         
      constructor() {}                            
  }                       
  '}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allModelMethods size equals: 1.
	constructor := model allModelMethods first.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	self assert: constructor name equals: 'Example'.
	self assert: constructor isConstructor.
	self assert: constructor parentType == class.
	self assert: constructor signature equals: 'Example()'.
	self assert: constructor sourceText equals: 'constructor() {}'.
	^ constructor
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassSecondaryConstructorParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model constructor parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> '
        package com.example

        class Example {
                constructor(message: String) {}
        }
        '}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	constructor := model allModelMethods detect: [ :each | each isConstructor ].
	self assert: constructor parameters size equals: 1.
	parameter := constructor parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == constructor.
	self assert: parameter sourceText equals: 'message: String'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	self assert: constructor signature equals: 'Example(String)'.
	self
		assert: constructor mooseName
		equals: 'com::example::Example.Example(String)'.
	self assert: model allAttributes size equals: 0.
	^ parameter
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
GtSmaCCKotlinExamples >> singleClassTwoConstructors [
	<gtExample>
	<return: #Collection>
	| directory model constructors withParameter withoutParameter |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example(message: String) {
        constructor() : this("Hello")
}
'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	constructors := model allModelMethods select: [ :each | each isConstructor ].
	self assert: constructors size equals: 2.
	withParameter := constructors
			detect: [ :each | each signature = 'Example(String)' ].
	withoutParameter := constructors
			detect: [ :each | each signature = 'Example()' ].
	self assert: withParameter parameters size equals: 1.
	self assert: withParameter parameters first name equals: 'message'.
	self assert: withoutParameter parameters isEmpty.
	self assert: (model allWithType: FAMIXParameter) size equals: 1.
	self assert: model allAttributes size equals: 0.
	^ constructors
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleClassTwoInitializers [
	<gtExample>
	<return: #FAMIXMethodGroup>
	| directory model initializers class |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

class Example {

    init {
        // first block
    }

    init {
        // second block
    }
    
}
'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	initializers := model allModelMethods asArray.
	self assert: initializers size equals: 2.
	self assert: initializers first ~~ initializers second.
	class := model allModelClasses detect: [ :each | each name = 'Example' ].
	initializers
		do: [ :each | 
			self assert: each name equals: '$Example'.
			self assert: each parentType == class.
			self assert: each signature equals: '$Example()' ].
	^ model allModelMethods
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

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelConstProperty [
	<gtExample>
	<return: #FAMIXGlobalVariable>
	| directory model variable file stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

const val name: String = "example"'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allGlobalVariables size equals: 1.
	self assert: model allAttributes size equals: 0.
	variable := model allGlobalVariables first.
	self assert: variable name equals: 'name'.
	self assert: variable parentScope mooseName equals: 'com::example'.
	self assert: variable sourceText equals: 'const val name: String = "example"'.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: variable).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: variable declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ variable
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelFunction [
	<gtExample>
	<return: #FAMIXFunction>
	| directory model function unitType |
	directory := self
			sourceDirectoryNamed: 'com/package'
			withFiles: {'Example.kt'
						-> 'package com.example

fun greet() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFunctions size equals: 1.
	function := model allFunctions first.
	self assert: function name equals: 'greet'.
	self assert: function container mooseName equals: 'com::example'.
	self assert: function sourceText equals: 'fun greet() {}'.
	unitType := model allTypes detect: [ :each | each name = 'Unit' ].
	self assert: function declaredType == unitType.
	self assert: unitType isStub.
	self assert: unitType container mooseName equals: 'kotlin'.
	^ function
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelFunctionLocalVariable [
	<gtExample>
	<return: #FAMIXLocalVariable>
	| directory model function local stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

fun greet(): String {
	val greeting: String = "Hello"
	return greeting
}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allLocalVariables size equals: 1.
	local := model allLocalVariables first.
	function := model allFunctions detect: [ :each | each name = 'greet' ].
	self assert: local name equals: 'greeting'.
	self assert: local parentBehaviouralEntity == function.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: local declaredType == stringType.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ local
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelFunctionParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model function parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'package com.example

fun greet(message: String) {}'}
					asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	function := model allFunctions detect: [ :each | each name = 'greet' ].
	self assert: function parameters size equals: 1.
	parameter := function parameters first.
	self assert: parameter name equals: 'message'.
	self assert: parameter parentBehaviouralEntity == function.
	self assert: parameter sourceText equals: 'message: String'.
	self assert: ((model allWithType: FAMIXParameter) includes: parameter).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	self assert: function signature equals: 'greet(String)'.
	self assert: function mooseName equals: 'com::example.greet(String)'.
	^ parameter
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelFunctionReturnType [
	<gtExample>
	<return: #FAMIXFunction>
	| directory model function stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

fun greet(): String {
	return "Hello"
}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	function := model allFunctions detect: [ :each | each name = 'greet' ].
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: function declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ function
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> singleTopLevelProperty [
	<gtExample>
	<return: #FAMIXGlobalVariable>
	| directory model variable file stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt'
						-> 'package com.example

val name: String = "example"'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allGlobalVariables size equals: 1.
	self assert: model allAttributes size equals: 0.
	variable := model allGlobalVariables first.
	self assert: variable name equals: 'name'.
	self assert: variable parentScope mooseName equals: 'com::example'.
	self assert: variable sourceText equals: 'val name: String = "example"'.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: variable).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: variable declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ variable
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
GtSmaCCKotlinExamples >> superTypeForwardReference [
	<gtExample>
	<return: #FAMIXInheritance>
	| directory model inheritance classA classB |
	directory := self
			sourceDirectoryWithFiles: {'a/A.kt' -> 'package a

import b.B

class A : B()
'.
					'b/B.kt' -> 'package b

open class B
'} asDictionary.
	self
		assert: (KotlinParser sourceFilesIn: directory) first basename
		equals: 'A.kt'.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allInheritanceDefinitions size equals: 1.
	inheritance := model allInheritanceDefinitions first.
	classA := model allModelClasses detect: [ :each | each name = 'A' ].
	classB := model allModelClasses detect: [ :each | each name = 'B' ].
	self assert: inheritance subclass == classA.
	self assert: inheritance superclass == classB.
	self assert: inheritance sourceText equals: 'B'.
	^ inheritance
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> topLevelConstPropertyWithoutPackage [
	<gtExample>
	<return: #FAMIXGlobalVariable>
	| directory model variable file stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'const val name: String = "example"'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allGlobalVariables size equals: 1.
	self assert: model allAttributes size equals: 0.
	variable := model allGlobalVariables first.
	self assert: variable name equals: 'name'.
	self assert: variable parentScope isNil.
	self assert: variable sourceText equals: 'const val name: String = "example"'.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: variable).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: variable declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ variable
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> topLevelFunctionWithoutPackage [
	<gtExample>
	<return: #FAMIXFunction>
	| directory model function |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'fun greet() {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allFunctions size equals: 1.
	function := model allFunctions detect: [ :each | each name = 'greet' ].
	self assert: function container isNil.
	^ function
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> topLevelFunctionWithoutPackageParameter [
	<gtExample>
	<return: #FAMIXParameter>
	| directory model function parameter stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'fun greet(message: String) {}'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	function := model allFunctions detect: [ :each | each name = 'greet' ].
	self assert: function parameters size equals: 1.
	parameter := function parameters first.
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: parameter declaredType == stringType.
	self assert: stringType container mooseName equals: 'kotlin'.
	self assert: function signature equals: 'greet(String)'.
	^ parameter
]

{ #category : 'examples' }
GtSmaCCKotlinExamples >> topLevelPropertyWithoutPackage [
	<gtExample>
	<return: #FAMIXGlobalVariable>
	| directory model variable file stringType |
	directory := self
			sourceDirectoryNamed: 'com/example'
			withFiles: {'Example.kt' -> 'val name: String = "example"'} asDictionary.
	model := GtSmaCCKotlinImporter new
			baseDirectory: directory;
			buildKotlinModel.
	self assert: model allGlobalVariables size equals: 1.
	self assert: model allAttributes size equals: 0.
	variable := model allGlobalVariables first.
	self assert: variable name equals: 'name'.
	self assert: variable parentScope isNil.
	self assert: variable sourceText equals: 'val name: String = "example"'.
	file := model allFiles detect: [ :each | each name = 'Example.kt' ].
	self assert: (file entities includes: variable).
	stringType := model allTypes detect: [ :each | each name = 'String' ].
	self assert: variable declaredType == stringType.
	self assert: stringType isStub.
	self assert: stringType container mooseName equals: 'kotlin'.
	^ variable
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
