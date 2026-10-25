Class {
	#name : 'GtSmaCCKotlinImporter',
	#superclass : 'KotlinNodeNodeVisitor',
	#instVars : [
		'baseDirectory',
		'model',
		'asts',
		'folders',
		'rootNamespaces',
		'scopeStack',
		'declaredTypeReferences',
		'superTypeReferences',
		'currentFile'
	],
	#category : 'Gt4Kotlin',
	#package : 'Gt4Kotlin'
}

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
GtSmaCCKotlinImporter >> addMethodSignatures [
	model allFunctions do: [ :each | self addMethodSignature: each ].
	model allModelMethods do: [:each |self addMethodSignature: each]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> addModifiers: aCollection to: anEntity [
	aCollection
		do: [ :each | 
			(each isKindOf: KotlinModifierNode)
				ifTrue: [ anEntity addModifier: each name source asSymbol ] ]
]

{ #category : 'private' }
GtSmaCCKotlinImporter >> assignScope: aModelObject around: aBlock [
	scopeStack addLast: aModelObject.
	^ aBlock ensure: [ scopeStack removeLast ]
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
	self kotlinAstsDo: [:each | self accept: each].
	self resolveDeclaredTypeReferences.
	self resolveSuperTypeReferences.
	self addMethodSignatures.
	^ model
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> createClassOrInterfaceFrom: aClassDeclarationNode in: aContainer [
	| class |
	class := FAMIXClass new
			name: aClassDeclarationNode name source;
			mooseModel: model;
			container: aContainer;
			sourceAnchor: (self sourceAnchorFrom: aClassDeclarationNode);
			isInterface: aClassDeclarationNode interfaceToken isNotNil;
			yourself.
	currentFile addEntity: class.
	class propertyNamed: #ast put: aClassDeclarationNode.
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

{ #category : 'private' }
GtSmaCCKotlinImporter >> currentScope [
	^ scopeStack ifEmpty: [ nil ] ifNotEmpty: [ :stack | stack last ]
]

{ #category : 'importing' }
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

{ #category : 'private' }
GtSmaCCKotlinImporter >> ensureFunctionFrom: aFunctionDeclarationNode in: aNamespace [
	| function |
	function := FAMIXFunction new
			name: aFunctionDeclarationNode name source;
			container: aNamespace;
			sourceAnchor: (self sourceAnchorFrom: aFunctionDeclarationNode);
			mooseModel: model;
			yourself.
	aFunctionDeclarationNode colonToken
		ifNil: [ function declaredType: (self defaultImportedTypeNamed: 'Unit') ]
		ifNotNil: [ declaredTypeReferences
				add: {function.
						aFunctionDeclarationNode types last source.
						aFunctionDeclarationNode topParent.
						scopeStack first} ].
	currentFile addEntity: function.
	aFunctionDeclarationNode parameters
		do: [ :each | 
			| param |
			param := FAMIXParameter new
					name: each parameter name source;
					sourceAnchor: (self sourceAnchorFrom: each);
					belongsTo: function;
					mooseModel: model;
					yourself.
			declaredTypeReferences
				add: {param.
						each parameter type source.
						aFunctionDeclarationNode topParent.
						scopeStack first}.
			currentFile addEntity: param ].
	^ function
]

{ #category : 'importing' }
GtSmaCCKotlinImporter >> ensureInitializerFrom: anAnonymousInitializer in: aClass [
	| method |
	method := FAMIXMethod new
			name: '$' , aClass name;
			parentType: aClass;
			sourceAnchor: (self sourceAnchorFrom: anAnonymousInitializer);
			mooseModel: model;
			yourself.
	currentFile addEntity: method.
	^ method
]

{ #category : 'private' }
GtSmaCCKotlinImporter >> ensureLocalVariableFrom: aPropertyNode in: aMethod [
	| var declaredType |
	var := FAMIXLocalVariable new
			name: aPropertyNode declaration name source;
			sourceAnchor: (self sourceAnchorFrom: aPropertyNode);
			parentBehaviouralEntity: aMethod;
			mooseModel: model;
			yourself.
	declaredType := aPropertyNode declaration type.
	declaredType
		ifNotNil: [ declaredTypeReferences
				add: {var.
						declaredType source.
						aPropertyNode topParent.
						scopeStack first} ].
	currentFile addEntity: var.
	^ var
]

{ #category : 'importing' }
GtSmaCCKotlinImporter >> ensureMethodFrom: functionDeclarationNode in: aContainer [
	| method |
	method := FAMIXMethod new
			name: functionDeclarationNode name source;
			parentType: aContainer;
			sourceAnchor: (self sourceAnchorFrom: functionDeclarationNode);
			mooseModel: model;
			yourself.
	functionDeclarationNode colonToken
		ifNil: [ method declaredType: (self defaultImportedTypeNamed: 'Unit') ]
		ifNotNil: [ declaredTypeReferences
				add: {method.
						functionDeclarationNode types last source.
						functionDeclarationNode topParent.
						scopeStack first} ].
	currentFile addEntity: method.
	functionDeclarationNode parameters
		do: [ :each | 
			| param |
			param := FAMIXParameter new
					name: each parameter name source;
					sourceAnchor: (self sourceAnchorFrom: each);
					belongsTo: method;
					mooseModel: model;
					yourself.
			declaredTypeReferences
				add: {param.
						each parameter type source.
						functionDeclarationNode topParent.
						scopeStack first}.
			currentFile addEntity: param ].
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

{ #category : 'importing' }
GtSmaCCKotlinImporter >> ensurePropertyFrom: aPropertyNode in: aContainer [
	| attr  |
	attr := FAMIXAttribute new
			name: aPropertyNode declaration name source;
			sourceAnchor: (self sourceAnchorFrom: aPropertyNode);
			parentType: aContainer;
			mooseModel: model;
			yourself.
	aPropertyNode declaration type
		ifNotNil: [ declaredTypeReferences
				add: {attr.
						aPropertyNode declaration type source.
						aPropertyNode topParent.
						scopeStack first} ].
	self addModifiers: aPropertyNode modifiers to: attr.
	aPropertyNode valToken ifNotNil: [ attr isFinal: true ].
	currentFile addEntity: attr.
	^ attr
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> ensureRootNamespace: aString [
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

{ #category : 'initialization' }
GtSmaCCKotlinImporter >> initialize [
	super initialize.
	scopeStack := OrderedCollection new.
	folders := Dictionary new.
	rootNamespaces := Dictionary new.
	declaredTypeReferences := OrderedCollection new.
	superTypeReferences := OrderedCollection new.
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> kotlinAstsDo: aBlock [
	asts
		ifNil: [ asts := (KotlinParser sourceFilesIn: baseDirectory)
					collect: [ :each | KotlinParser parseFileWithErrors: each ] ].
	asts do: aBlock
]

{ #category : 'private' }
GtSmaCCKotlinImporter >> lookupTypeNamed: aString inFile: aFileNode namespace: aNamespace [
	(self explicitlyImportedTypeNamed: aString in: aFileNode)
		ifNotNil: [ :type | ^ type ].
	(self
		typeNamed: aString
		inNamespace: aNamespace
		ifNone: [ nil ]) ifNotNil: [ :type | ^ type ].
	(self starImportedTypeNamed: aString in: aFileNode) ifNotNil: [ :type | ^ type ].
	(self defaultImportedTypeNamed: aString) ifNotNil: [ :type | ^ type ].
	^ self unknownTypeNamed: aString
]

{ #category : 'private' }
GtSmaCCKotlinImporter >> resolveDeclaredTypeReferences [
	declaredTypeReferences
		do: [ :each | 
			| modelEntity |
			modelEntity := each first.
			modelEntity
				declaredType: (self
						lookupTypeNamed: each second
						inFile: each third
						namespace: each fourth) ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> resolveSuperTypeReferences [
	superTypeReferences
		do: [ :each | 
			model
				add: (FAMIXInheritance new
						subclass: each first;
						superclass: (self
								lookupTypeNamed: each second
								inFile: each third
								namespace: each fourth);
						sourceAnchor: each fifth;
						yourself) ]
]

{ #category : 'accessing' }
GtSmaCCKotlinImporter >> sourceAnchorFrom: aNode [
	^ FAMIXIndexedFileEntityAnchor
		file: currentFile
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

{ #category : 'private' }
GtSmaCCKotlinImporter >> typeNamed: aString inNamespace: aNamespace ifNone: aBlock [
	aNamespace ifNil: [ ^ aBlock value ].
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

{ #category : 'vis' }
GtSmaCCKotlinImporter >> visitAnonymousInitializer: anAnonymousInitializer [
	| initializerMethod |
	initializerMethod := self ensureInitializerFrom: anAnonymousInitializer in: self currentScope.
	^ self assignScope: initializerMethod around: [ super visitAnonymousInitializer: anAnonymousInitializer]
]

{ #category : 'visiting' }
GtSmaCCKotlinImporter >> visitClassDeclaration: aClassDeclaration [
	| class |
	class := self
			createClassOrInterfaceFrom: aClassDeclaration
			in: self currentScope.
	aClassDeclaration annotatedSpecifiers
		do: [ :each | 
			| superTypeNode |
			superTypeNode := self superTypeNodeFrom: each specifier.
			superTypeReferences
				add: {class.
						superTypeNode source.
						aClassDeclaration topParent.
						scopeStack first.
						self sourceAnchorFrom: superTypeNode} ].
	^ self
		assignScope: class
		around: [ super visitClassDeclaration: aClassDeclaration ]
]

{ #category : 'visiting' }
GtSmaCCKotlinImporter >> visitFile: aFile [
	| namespace |
	currentFile := self ensureFileFrom: aFile filename asFileReference.
	namespace := aFile name
			ifNotNil: [ :package | self ensureNamespaceFromNames: (package names collect: [ :each | each source ]) ].
	^ self assignScope: namespace around: [ super visitFile: aFile ]
]

{ #category : 'visiting' }
GtSmaCCKotlinImporter >> visitFunctionDeclaration: aFunctionDeclaration [
	| function |
	function := (self currentScope isNil or: [ self currentScope isNamespace ])
			ifTrue: [ self ensureFunctionFrom: aFunctionDeclaration in: self currentScope ]
			ifFalse: [ self ensureMethodFrom: aFunctionDeclaration in: self currentScope ].
	^ self
		assignScope: function
		around: [ super visitFunctionDeclaration: aFunctionDeclaration ]
]

{ #category : 'visiting' }
GtSmaCCKotlinImporter >> visitPropertyDeclaration: aPropertyDeclaration [
	(self currentScope isFunction or: [self currentScope isMethod])
		ifTrue: [ self ensureLocalVariableFrom: aPropertyDeclaration in: self currentScope]
		ifFalse: [self ensurePropertyFrom: aPropertyDeclaration in: self currentScope].
	^ super visitPropertyDeclaration: aPropertyDeclaration
]
