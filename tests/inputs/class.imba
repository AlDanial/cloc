# https://github.com/imba/imba/raw/master/test/syntax/class.imba
extern describe, test, ok, eq, it

class Organism

	var lvar = 10

	def self.type
		'organism'

	def initialize
		@ivar = 1
	
	def lineage
		'organism'
		
	def name
		'organism'

	def speak
		'ghaarg'

	def alive
		yes

	def lvar
		lvar

	# hmm, maybe we shouldnt allow this?
	#	class Other
	#
	#		def inner
	#			yes
		
class Virus < Organism

	def initialize
		@ivar = 2

	def lineage
		"{name}.{super.lineage}"

	def name
		'virus'

class Animal < Organism

	# def self.type
	#    "animal.{super}"

	def lineage
		"animal.{super.lineage}"

class Cat < Animal

	# def self.type
	#    "cat.{super}"

	def lineage
		"cat.{super.lineage}"

	def speak
		'miau'

class Dog < Animal

	# def self.type
	#    "dog.{super}"
	def lineage
		"dog.{super.lineage}"
		
	def speak
		'woff'
		

class Human < Animal

	def lineage
		"human.{super.lineage}"

	def speak
		'hello'

class Zombie < Human

	def lineage
		"zombie.{super.lineage}"

	def alive
		no


describe 'Syntax - Class' do

	# test 'nested classes work' do
	# 	ok !!Organism.Other

	test 'should' do

		# you can define variables local to classbody
		var obj = Organism.new
		eq obj.lvar, 10

	describe 'Methods' do

		it 'should define class methods' do
			eq Organism.type, 'organism'

		it 'should inherit class methods' do
			eq Virus:type, Organism:type

		# it 'should call super in class methods' do
		#   eq Dog.type, "dog.animal.organism"
		#   eq Cat.type, "cat.animal.organism"

	describe 'Instance' do

		it 'should call the parent constructor by default' do
			var obj = Cat.new
			eq obj.@ivar, 1

		it 'should define instance methods' do
			var obj = Organism.new
			var val = obj.alive
			# eq val, true
			ok obj.alive
			eq obj.speak, 'ghaarg'

		it 'should inherit instance methods' do
			var obj = Virus.new
			ok obj.alive


		it 'should override instance methods' do
			eq Organism.new.name, 'organism'
			eq Virus.new.name, 'virus'

		it 'should call super in instance methods' do
			# Should not refer to the prototype directly?
			eq Virus.new.lineage, 'virus.organism'
			eq Zombie.new.lineage, 'zombie.human.animal.organism'

	test 'define methods outside scope' do
		class Cls
			def self.a do 1
			def a do 2

		def Cls.b
			1

		extend class Cls
			def b
				2

		eq Cls.a, 1
		eq Cls.b, 1

		eq Cls.new.a, 2
		eq Cls.new.b, 2

	
	test 'Scoping' do

		var variable = 1

		local class A
			var variable = 2

			def self.base
				variable

			def self.add add
				variable += add

			def initialize add
				@sum = variable + add
				self

			def base
				variable

			def sum
				@sum

		eq variable, 1
		eq A.base, 2
		eq A.new.base, 2
		eq A.new(5).sum, 7

		A.add(2)

		eq variable, 1
    ###		eq A.base, 4 ###

###					
	test 'issue #71' do
		var res
		var def ping cb
			res = cb()

		class A
			ping do self

		eq res, A

###					



