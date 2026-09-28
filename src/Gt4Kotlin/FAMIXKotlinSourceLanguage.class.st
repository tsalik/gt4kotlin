Class {
	#name : 'FAMIXKotlinSourceLanguage',
	#superclass : 'FAMIXSourceLanguage',
	#category : 'Gt4Kotlin',
	#package : 'Gt4Kotlin'
}

{ #category : 'meta' }
FAMIXKotlinSourceLanguage >> annotation [
	<MSEClass: #KotlinSourceLanguage super: #FAMIXSourceLanguage>
	<package: #FAMIX>
]

{ #category : 'private' }
FAMIXKotlinSourceLanguage >> gtASTNodeFor: aString at: anInterval [
	| ast |
	ast := KotlinParser parseWithErrors: aString.
	ast
		withAllNodesDo: [ :each | 
			(anInterval first <= each startPosition
				and: [ anInterval last = each stopPosition ])
				ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'private' }
FAMIXKotlinSourceLanguage >> gtStyler [
	^ KotlinParser gtStyler
]
