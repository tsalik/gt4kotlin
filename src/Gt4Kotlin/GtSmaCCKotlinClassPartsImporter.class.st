"
I walk a Kotlin AST for a {{gtClass:GtSmaCCKotlinImporter}} and import the parts of its classes: functions become FAMIXMethods, properties become FAMIXAttributes, and properties inside a function body become FAMIXLocalVariables. While descending I track the current container (the enclosing class, or the file's namespace) and the current method.
"
Class {
	#name : 'GtSmaCCKotlinClassPartsImporter',
	#superclass : 'KotlinNodeNodeVisitor',
	#instVars : [
		'importer',
		'currentContainer',
		'currentMethod'
	],
	#category : 'Gt4Kotlin',
	#package : 'Gt4Kotlin'
}

{ #category : 'accessing' }
GtSmaCCKotlinClassPartsImporter >> importer: aKotlinImporter [
	importer := aKotlinImporter
]

{ #category : 'visiting' }
GtSmaCCKotlinClassPartsImporter >> visitClassDeclaration: aClassDeclaration [
	| outerContainer |
	outerContainer := currentContainer.
	currentContainer := aClassDeclaration attributeNamed: #container.
	super visitClassDeclaration: aClassDeclaration.
	currentContainer := outerContainer.
	^ aClassDeclaration
]

{ #category : 'visiting' }
GtSmaCCKotlinClassPartsImporter >> visitFile: aFile [
	currentContainer := aFile attributeNamed: #container ifAbsent: [ nil ].
	^ super visitFile: aFile
]

{ #category : 'visiting' }
GtSmaCCKotlinClassPartsImporter >> visitFunctionDeclaration: aFunctionDeclaration [
	| outerMethod |
	outerMethod := currentMethod.
	currentMethod := (currentContainer isNil or: [ currentContainer isNamespace ])
			ifTrue: [ importer ensureFunctionFrom: aFunctionDeclaration in: currentContainer ]
			ifFalse: [ importer ensureMethodFrom: aFunctionDeclaration in: currentContainer ].
	super visitFunctionDeclaration: aFunctionDeclaration.
	currentMethod := outerMethod.
	^ aFunctionDeclaration
]

{ #category : 'visiting' }
GtSmaCCKotlinClassPartsImporter >> visitPropertyDeclaration: aPropertyDeclaration [
	currentMethod
		ifNil: [ importer ensurePropertyFrom: aPropertyDeclaration in: currentContainer ]
		ifNotNil: [ importer ensureLocalVariableFrom: aPropertyDeclaration in: currentMethod ].
	^ super visitPropertyDeclaration: aPropertyDeclaration
]
