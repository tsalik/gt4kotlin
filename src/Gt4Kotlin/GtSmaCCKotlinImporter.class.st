Class {
	#name : 'GtSmaCCKotlinImporter',
	#superclass : 'Object',
	#instVars : [
		'baseDirectory',
		'model',
		'asts',
		'folders',
		'rootNamespaces'
	],
	#category : 'Gt4Kotlin',
	#package : 'Gt4Kotlin'
}

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> addInheritanceFrom: aType to: aSpecifierNode [
	| superType |
	superType := self
			lookupTypeNamed: aSpecifierNode type source
			in: aType container.
	^ model
		add: (FAMIXInheritance new
				subclass: aType;
				superclass: superType;
				sourceAnchor: (self sourceAnchorFrom: aSpecifierNode type);
				yourself)
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> addInheritedTypes [
	model allTypes
		do: [ :each | 
			(each propertyNamed: #ast ifAbsent: [  ])
				ifNotNil: [ :ast | 
					(ast isKindOf: KotlinClassDeclarationNode)
						ifTrue: [ ast annotatedSpecifiers
								do: [ :annotated | 
									self addInheritanceFrom: each to: annotated specifier] ] ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> addMethodSignature: method [
	method
		signature: (String
				streamContents: [ :stream | 
					stream << method name << '('.
					method parameters
						do: [ :each | stream << (each declaredType ifNil: [ each name ] ifNotNil: [ :t | t name ]) ]
						separatedBy: [ stream << ', ' ].
					stream << ')' ])
]

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
	self importNamespaces.
	self importClasses.
	self importClassParts.
	self addInheritedTypes.
	^ model
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> containerIn: aNode [
	| current |
	current := aNode.
	[ current notNil ]
		whileTrue: [ (current attributeNamed: #container ifAbsent: [  ]) ifNotNil: [ :c | ^ c ].
			current := current parent ].
	^ nil 
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> createClassFrom: aNode [
	| class |
	class := FAMIXClass new
			name: aNode name source;
			mooseModel: model;
			container: (self containerIn: aNode parent);
			sourceAnchor: (self sourceAnchorFrom: aNode);
			yourself.
	(aNode topParent attributeNamed: #famixFile) addEntity: class.
	aNode attributeNamed: #container put: class.
	class propertyNamed: #ast put: aNode.
	^ class
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> createUnknownType: aString in: aNamespace [
	^ FAMIXType new
		name: aString;
		isStub: true;
		mooseModel: model;
		container: aNamespace;
		yourself
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
GtSmaCCKotlinImporter >> ensureMethodFrom: functionDeclarationNode [
	| method |
	method := FAMIXMethod new
			name: functionDeclarationNode name source;
			parentType: (self containerIn: functionDeclarationNode parent);
			sourceAnchor: (self sourceAnchorFrom: functionDeclarationNode);
			mooseModel: model;
			yourself.
	(functionDeclarationNode topParent attributeNamed: #famixFile) addEntity: method.
	self addMethodSignature: method.
	^ method
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureNamespace: aString in: aNamespace [
	^ aNamespace childScopes
		detect: [ :each | each name = aString ]
		ifNone: [ model
				add: (FAMIXNamespace new
						name: aString;
						parentScope: aNamespace;
						yourself) ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureRootNamespace: aString [
	rootNamespaces ifNil: [ rootNamespaces := Dictionary new ].
	^ rootNamespaces
		at: aString
		ifAbsentPut: [ model
				add: (FAMIXNamespace new
						name: aString;
						yourself) ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> importClassParts [
	self
		kotlinAstsDo: [ :node | 
			node
				withAllNodesOfType: KotlinFunctionDeclarationNode
				do: [ :functionDeclaration | self ensureMethodFrom: functionDeclaration ] ]
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
GtSmaCCKotlinImporter >> importNamespaces [
	self
		kotlinAstsDo: [ :node | 
			node name
				ifNotNil: [ :package | 
					node
						attributeNamed: #container
						put: (package names
								inject: nil
								into: [ :parent :each | 
									parent
										ifNil: [ self ensureRootNamespace: each source ]
										ifNotNil: [ self ensureNamespace: each source in: parent ] ]) ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> kotlinAstsDo: aBlock [
	asts
		ifNil: [ asts := (KotlinParser sourceFilesIn: baseDirectory)
					collect: [ :each | KotlinParser parseFileWithErrors: each ] ].
	asts do: aBlock
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> lookupTypeNamed: aString in: aContainer [
	^ aContainer children
		detect: [ :each | each name = aString and: [ each isKindOf: FAMIXType ] ]
		ifNone: [ self unknownTypeNamed: aString ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> sourceAnchorFrom: aNode [
	^ FAMIXIndexedFileEntityAnchor
		file: (aNode topParent attributeNamed: #famixFile)
		startPos: aNode startPosition
		endPos: aNode stopPosition
		model: model
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> unknownTypeNamed: aString [
	| unknown |
	unknown := self ensureRootNamespace: '__UNKNOWN__'.
	^ unknown children
		detect: [ :each | each name = aString and: [ each isKindOf: FAMIXType ] ]
		ifNone: [ self createUnknownType: aString in: unknown ]
]
