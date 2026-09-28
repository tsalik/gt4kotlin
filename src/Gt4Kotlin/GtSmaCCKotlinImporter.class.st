Class {
	#name : 'GtSmaCCKotlinImporter',
	#superclass : 'Object',
	#instVars : [
		'baseDirectory',
		'model',
		'asts',
		'folders'
	],
	#category : 'Gt4Kotlin',
	#package : 'Gt4Kotlin'
}

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> baseDirectory: anObject [
	baseDirectory := anObject asFileReference.
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> buildKotlinModel [
	model := MooseModel new.
	self importFiles.
	self importClasses.
	^ model
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> createClassFrom: aNode [
	| class |
	class := FAMIXClass new
			name: aNode name source;
			mooseModel: model;
			yourself.
	^ class
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureFileFrom: aFileReference [
	| file |
	file := FAMIXFile new.
	file name: aFileReference basename.
	model add: file.
	^ file
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> importClasses [
	self
		kotlinAstsDo: [ :node | 
			node
				withAllNodesOfType: KotlinClassDeclarationNode
				do: [ :each | self createClassFrom: each ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> importFiles [
	self
		kotlinAstsDo: [ :node | self ensureFileFrom: node filename asFileReference ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> kotlinAstsDo: aBlock [
	asts
		ifNil: [ asts := (KotlinParser sourceFilesIn: baseDirectory)
					collect: [ :each | KotlinParser parseFileWithErrors: each ] ].
	asts do: aBlock
]
