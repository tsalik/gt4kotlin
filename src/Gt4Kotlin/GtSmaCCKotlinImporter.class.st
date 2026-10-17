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
GtSmaCCKotlinImporter >> addInheritanceFrom: aType to: aTypeNode [
	| superType |
	superType := self
			lookupTypeNamed: aTypeNode source
			in: aType.
	^ model
		add: (FAMIXInheritance new
				subclass: aType;
				superclass: superType;
				sourceAnchor: (self sourceAnchorFrom: aTypeNode);
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
								do: [ :annotated | self addInheritanceFrom: each to: (self superTypeNodeFrom: annotated specifier) ] ] ] ]
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
GtSmaCCKotlinImporter >> addModifiers: aCollection to: anEntity [
	aCollection
		do: [ :each | 
			(each isKindOf: KotlinModifierNode)
				ifTrue: [ anEntity addModifier: each name source asSymbol ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> baseDirectory: anObject [
	baseDirectory := anObject asFileReference.
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> buildDefaultImportedTypes [
	self defaultImportedTypeNames
		do: [ :each | 
			| namespace |
			namespace := self ensureNamespaceFromNames: each key.
			each value do: [ :name | self createUnknownType: name in: namespace ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> buildKotlinModel [
	model := MooseModel new.
	model sourceLanguage: FAMIXKotlinSourceLanguage new.
	model rootFolder: baseDirectory.
	model name: baseDirectory basenameWithoutExtension.
	self buildDefaultImportedTypes.
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
GtSmaCCKotlinImporter >> createClassOrInterfaceFrom: aNode [
	| class |
	class := FAMIXClass new
			name: aNode name source;
			mooseModel: model;
			container: (self containerIn: aNode parent);
			sourceAnchor: (self sourceAnchorFrom: aNode);
			isInterface: aNode interfaceToken isNotNil;
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

{ #category : 'as yet unclassified' }
GtSmaCCKotlinImporter >> defaultImportedNamespaces [
	^ self defaultImportedTypeNames
		collect: [ :each | self ensureNamespaceFromNames: each key ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> defaultImportedTypeNamed: aString [
	self defaultImportedNamespaces
		do: [ :each | 
			(self
				typeNamed: aString
				inNamespace: each
				ifNone: [ nil ]) ifNotNil: [ :type | ^ type ] ].
	^ nil
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> defaultImportedTypeNames [
	^ {#('kotlin')
			-> #('Annotation' 'Any' 'ArithmeticException' 'Array' 'AssertionError' 'AutoCloseable' 'Boolean' 'BooleanArray' 'Byte' 'ByteArray' 'Char' 'CharArray' 'CharSequence' 'ClassCastException' 'Comparable' 'Comparator' 'ConcurrentModificationException' 'DeepRecursiveFunction' 'DeepRecursiveScope' 'DeprecationLevel' 'Double' 'DoubleArray' 'Enum' 'Error' 'Exception' 'Float' 'FloatArray' 'Function' 'IllegalArgumentException' 'IllegalStateException' 'IndexOutOfBoundsException' 'Int' 'IntArray' 'KotlinVersion' 'Lazy' 'LazyThreadSafetyMode' 'Long' 'LongArray' 'NoSuchElementException' 'Nothing' 'NotImplementedError' 'NoWhenBranchMatchedException' 'NullPointerException' 'Number' 'NumberFormatException' 'Pair' 'Result' 'RuntimeException' 'Short' 'ShortArray' 'String' 'Throwable' 'Triple' 'UByte' 'UByteArray' 'UInt' 'UIntArray' 'ULong' 'ULongArray' 'UninitializedPropertyAccessException' 'Unit' 'UnsupportedOperationException' 'UShort' 'UShortArray').
		#('kotlin' 'annotation') -> #('AnnotationRetention' 'AnnotationTarget').
		#('kotlin' 'collections')
			-> #('AbstractCollection' 'AbstractIterator' 'AbstractList' 'AbstractMap' 'AbstractMutableCollection' 'AbstractMutableList' 'AbstractMutableMap' 'AbstractMutableSet' 'AbstractSet' 'ArrayDeque' 'ArrayList' 'BooleanIterator' 'ByteIterator' 'CharIterator' 'Collection' 'DoubleIterator' 'FloatIterator' 'Grouping' 'HashMap' 'HashSet' 'IndexedValue' 'IntIterator' 'Iterable' 'Iterator' 'LinkedHashMap' 'LinkedHashSet' 'List' 'ListIterator' 'LongIterator' 'Map' 'MutableCollection' 'MutableIterable' 'MutableIterator' 'MutableList' 'MutableListIterator' 'MutableMap' 'MutableSet' 'RandomAccess' 'Set' 'ShortIterator').
		#('kotlin' 'ranges')
			-> #('CharProgression' 'CharRange' 'ClosedFloatingPointRange' 'ClosedRange' 'IntProgression' 'IntRange' 'LongProgression' 'LongRange' 'OpenEndRange' 'UIntProgression' 'UIntRange' 'ULongProgression' 'ULongRange').
		#('kotlin' 'sequences') -> #('Sequence' 'SequenceScope').
		#('kotlin' 'text')
			-> #('Appendable' 'CharacterCodingException' 'CharCategory' 'HexFormat' 'MatchGroup' 'MatchGroupCollection' 'MatchNamedGroupCollection' 'MatchResult' 'Regex' 'RegexOption' 'StringBuilder' 'Typography')}
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

{ #category : 'importing' }
GtSmaCCKotlinImporter >> ensureLocalVariableFrom: aPropertyNode [
	| var famixFile |
	famixFile := aPropertyNode topParent attributeNamed: #famixFile.
	var := FAMIXLocalVariable new
			name: aPropertyNode declaration name source;
			sourceAnchor: (self sourceAnchorFrom: aPropertyNode);
			parentBehaviouralEntity: ((aPropertyNode parentOfType: KotlinFunctionDeclarationNode) attributeNamed: #famixMethod);
			mooseModel: model;
			yourself.
	var
		declaredType: (self
				lookupTypeNamed: aPropertyNode declaration type source
				in: var parentBehaviouralEntity parentType).
	famixFile addEntity: var.
	^ var
]

{ #category : 'importing' }
GtSmaCCKotlinImporter >> ensureMethodFrom: functionDeclarationNode [
	| method file |
	method := FAMIXMethod new
			name: functionDeclarationNode name source;
			parentType: (self containerIn: functionDeclarationNode parent);
			sourceAnchor: (self sourceAnchorFrom: functionDeclarationNode);
			mooseModel: model;
			yourself.
	functionDeclarationNode colonToken
		ifNil: [ method declaredType: (self defaultImportedTypeNamed: 'Unit') ]
		ifNotNil: [ method
				declaredType: (self
						lookupTypeNamed: functionDeclarationNode types last source
						in: method parentType) ].
	file := functionDeclarationNode topParent attributeNamed: #famixFile.
	file addEntity: method.
	functionDeclarationNode attributeNamed: #famixMethod put: method.
	functionDeclarationNode parameters
		do: [ :each | 
			| param |
			param := FAMIXParameter new
					declaredType: (self lookupTypeNamed: each parameter type source in: method parentType);
					name: each parameter name source;
					sourceAnchor: (self sourceAnchorFrom: each);
					belongsTo: method;
					mooseModel: model;
					yourself.
			file addEntity: param ].
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
GtSmaCCKotlinImporter >> ensureNamespaceFromNames: aPackageNamesCollection [
	^ aPackageNamesCollection
		inject: nil
		into: [ :parentNamespace :each | 
			parentNamespace
				ifNil: [ self ensureRootNamespace: each ]
				ifNotNil: [ self ensureNamespace: each in: parentNamespace ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensurePropertyFrom: aPropertyNode [
	| attr famixFile |
	famixFile := aPropertyNode topParent attributeNamed: #famixFile.
	attr := FAMIXAttribute new
			name: aPropertyNode declaration name source;
			sourceAnchor: (self sourceAnchorFrom: aPropertyNode);
			parentType: (self containerIn: aPropertyNode parent);
			mooseModel: model;
			yourself.
	attr
		declaredType: (self lookupTypeNamed: aPropertyNode declaration type source in: attr parentType).
	self addModifiers: aPropertyNode modifiers to: attr.
	aPropertyNode valToken ifNotNil: [ attr isFinal: true ].
	famixFile addEntity: attr.
	^ attr
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
GtSmaCCKotlinImporter >> explicitlyImportedTypeNamed: aString in: aFileNode [
	^ aFileNode imports
		detect: [ :import | 
			import star isNil
				and: [ (import alias ifNil: [ import path names last ]) source = aString ] ]
		ifFound: [ :import | self typeNamed: import path names last source importedBy: import ]
		ifNone: [ nil ]
]

{ #category : 'importing' }
GtSmaCCKotlinImporter >> importClassParts [
	self
		kotlinAstsDo: [ :node | 
			node
				withAllNodesDo: [ :each | 
					(each isKindOf: KotlinFunctionDeclarationNode)
						ifTrue: [ self ensureMethodFrom: each ].
					(each isKindOf: KotlinPropertyDeclarationNode)
						ifTrue: [ (each parentOfType: KotlinFunctionDeclarationNode) isNil
								ifTrue: [ self ensurePropertyFrom: each ]
								ifFalse: [ self ensureLocalVariableFrom: each ] ] ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> importClasses [
	self
		kotlinAstsDo: [ :node | 
			node
				withAllNodesOfType: KotlinClassDeclarationNode
				do: [ :each | self createClassOrInterfaceFrom: each ] ]
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
						put: (self ensureNamespaceFromNames: (package names collect:[:each | each source])) ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> kotlinAstsDo: aBlock [
	asts
		ifNil: [ asts := (KotlinParser sourceFilesIn: baseDirectory)
					collect: [ :each | KotlinParser parseFileWithErrors: each ] ].
	asts do: aBlock
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> lookupTypeNamed: aString in: aType [
	| file |
	file := (aType propertyNamed: #ast) topParent.
	(self explicitlyImportedTypeNamed: aString in: file)
		ifNotNil: [ :type | ^ type ].
	(self
		typeNamed: aString
		inNamespace: aType container
		ifNone: [ nil ]) ifNotNil: [ :type | ^ type ].
	(self starImportedTypeNamed: aString in: file) ifNotNil: [ :type | ^ type ].
	(self defaultImportedTypeNamed: aString) ifNotNil: [ :type | ^ type ].
	^ self unknownTypeNamed: aString
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
GtSmaCCKotlinImporter >> starImportedTypeNamed: aString in: aFileNode [
	^ (aFileNode imports select: [ :import | import star notNil ])
		inject: nil
		into: [ :found :import | 
			found
				ifNil: [ self
						typeNamed: aString
						inNamespace: (self
								ensureNamespaceFromNames: (import path names collect: [ :each | each source ]))
						ifNone: [ nil ] ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> superTypeNodeFrom: aSpecifierNode [
	^ ((aSpecifierNode isKindOf: KotlinConstructorInvocationNode)
		or: [ aSpecifierNode isKindOf: KotlinExplicitDelegationNode ])
		ifTrue: [ aSpecifierNode type ]
		ifFalse: [ (aSpecifierNode isKindOf: KotlinUserTypeNode)
				ifTrue: [ aSpecifierNode ]
				ifFalse: [ nil ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> typeNamed: aString importedBy: anImportNode [
	^ (self
		ensureNamespaceFromNames: (anImportNode path names allButLast collect: [ :each | each source ]))
		ifNil: [ self unknownTypeNamed: aString ]
		ifNotNil: [ :namespace | 
			self
				typeNamed: aString
				inNamespace: namespace
				ifNone: [ self createUnknownType: aString in: namespace ] ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> typeNamed: aString inNamespace: aNamespace ifNone: aBlock [
	^ aNamespace children
		detect: [ :each | each name = aString and: [ each isKindOf: FAMIXType ] ]
		ifNone: aBlock.
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> unknownTypeNamed: aString [
	| unknown |
	unknown := self ensureRootNamespace: '__UNKNOWN__'.
	^ self
		typeNamed: aString
		inNamespace: unknown
		ifNone: [ self createUnknownType: aString in: unknown ]
]
