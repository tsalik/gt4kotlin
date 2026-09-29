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
	model sourceLanguage: FAMIXKotlinSourceLanguage new.
	model rootFolder: baseDirectory.
	model name: baseDirectory basenameWithoutExtension.
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
			sourceAnchor: (self sourceAnchorFrom: aNode);
			yourself.
	^ class
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureFileFrom: aFileReference [
	| file anchor |
	file := FAMIXFile new.
	file name: aFileReference basename.
	anchor := FAMIXIndexedFileEntityAnchor
			file: file
			startPos: 1
			endPos: aFileReference contents size
			model: model.
	file sourceAnchor: anchor.
	(self ensureFolderNamed: aFileReference parent)
		ifNotNil: [ :folder | folder addChildFileSystemEntity: file ].
	model add: file.
	^ file
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureFolderNamed: aDirectory [
	^ folders
		at: aDirectory pathString
		ifAbsentPut: [ | folder |
			folder := FAMIXFolder new.
			aDirectory = baseDirectory
				ifTrue: [ folder name: '.' ]
				ifFalse: [ folder name: aDirectory basename.
					(self ensureFolderNamed: aDirectory parent)
						ifNotNil: [ :outer | outer addChildFileSystemEntity: folder ] ].
			model add: folder.
			folder ]
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
	folders := Dictionary new.
	self
		kotlinAstsDo: [ :node | 
			node
				attributeNamed: #famixFile
				put: (self ensureFileFrom: node filename asFileReference) ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> kotlinAstsDo: aBlock [
	asts
		ifNil: [ asts := (KotlinParser sourceFilesIn: baseDirectory)
					collect: [ :each | KotlinParser parseFileWithErrors: each ] ].
	asts do: aBlock
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> sourceAnchorFrom: aNode [
	^ FAMIXIndexedFileEntityAnchor
		file: (aNode topParent attributeNamed: #famixFile)
		startPos: aNode startPosition
		endPos: aNode stopPosition
		model: model
]
