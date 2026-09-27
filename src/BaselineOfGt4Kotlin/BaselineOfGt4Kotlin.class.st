Class {
	#name : 'BaselineOfGt4Kotlin',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGt4Kotlin',
	#package : 'BaselineOfGt4Kotlin'
}

{ #category : 'loading' }
BaselineOfGt4Kotlin class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt4kotlin' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : 'baseline' }
BaselineOfGt4Kotlin >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'Gt4Kotlin'
		]
]
