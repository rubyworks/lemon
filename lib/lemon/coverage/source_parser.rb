require 'ripper'
require 'lemon/coverage/snapshot'

module Lemon

  #
  class SourceParser
    # Converts Ruby code into a data structure.
    #
    # text - A String of Ruby code.
    #
    # Returns a Hash with each key a namespace and each value another Hash or Scope.
    def self.parse(text)
      new.parse(text)
    end

    # Converts Ruby code into a data structure.
    #
    # text - A String of Ruby code.
    #
    # Returns an Array of Snapshot::Unit objects.
    def self.parse_units(text)
      sp = new
      sp.parse(text)
      sp.units
    end

    attr_accessor :parser

    attr_accessor :scopes

    attr_accessor :options

    # Each instance of SourceParser accumulates scopes with each
    # parse, making it easy to parse an entire project in chunks but
    # more difficult to parse disparate files in one go. Create
    # separate instances for separate global scopes.
    #
    # Returns an instance of SourceParser.
    def initialize(options = {})
      @options = {}
      @scopes  = {}
      #@parser  = RubyParser.new
    end

    # Resets the state of the parser to a pristine one. Maintains options.
    #
    # Returns nothing.
    def reset
      initialize(@options)
    end

    # Converts Ruby code into a data structure. Note that at the
    # instance level scopes accumulate, which makes it easy to parse
    # multiple files in a single project but harder to parse files
    # that have no connection.
    #
    # text - A String of Ruby code.
    #
    # Examples
    #   @parser = SourceParser.new
    #   files.each do |file|
    #     @parser.parse(File.read(file))
    #   end
    #   pp @parser.scopes
    #
    # Returns a Hash with each key a namespace and each value another Hash or Scope.
    def parse(text)
      process(tokenize(sexp(text)))
      @scopes
    end

    # Converts Ruby sourcecode into an AST.
    #
    # text - A String of Ruby source.
    #
    # Returns a Sexp representing the AST.
    def sexp(text)
      Ripper.sexp(text)
      #@parser.parse(text)
    end

    # Converts a tokenized Array of classes, modules, and methods into
    # Scopes and Methods, adding them to the @scopes instance variable
    # as it works.
    #
    # ast   - Tokenized Array produced by calling `tokenize`.
    # scope - An optional Scope object for nested classes or modules.
    #
    # Returns nothing.
    def process(ast, scope=nil)
      case Array(ast)[0]
      when :module, :class
        name = ast[1]
        new_scope = Scope.new(name, ast[2])

        if scope
          new_scope.parent = scope
          scope.scopes[name] = new_scope
        elsif @scopes[name]
          new_scope = @scopes[name]
        else
          @scopes[name] = new_scope
        end

        process(ast[3], new_scope)
      when :imethod
        ast.shift
        scope.instance_methods << Method.new(*ast)
      when :cmethod
        ast.shift
        scope.class_methods << Method.new(*ast)
      when Array
        ast.map { |a| process(a, scope) }
      end
    end

    # Converts a Ruby AST-style Sexp into an Array of more useful tokens.
    #
    # node - A Ruby AST Sexp or Array
    #
    # Examples
    #
    #   [:module, :Math, "",
    #     [:class, :Multiplexer, "# Class Comment",
    #       [:cmethod,
    #         :multiplex, "# Class Method Comment", [:text]],
    #       [:imethod,
    #         :multiplex, "# Instance Method Comment", [:text, :count]]]]
    #
    #   # In others words:
    #   # [ :type, :name, :comment, other ]
    #
    # Returns an Array in the above format.
    def tokenize(node)
      case Array(node)[0]
      when :module
        name = node[1][1][1]
        [ :module, name, '', tokenize(node[2]) ]
      when :class
        name = node[1][1][1]
        [ :class, name, '', tokenize(node[3]) ]
      when :def
        name = node[1][1]
        args = args_for_node(node[2])
        [ :imethod, name, '', args ]
      when :defs
        name = node[3][1]
        args = args_for_node(node[4])
        [ :cmethod, name, '', args ]
      when :block
        tokenize(node[1..-1])
      when :program, :bodystmt, :scope
        tokenize(node[1])
      when Array
        node.map { |n| tokenize(n) }.compact
      end
    end

    # Given a method sexp, returns an array of the args.
    def args_for_node(node)
      Array(node)[1..-1].select{ |arg| arg.is_a? Symbol }
    end

    #
    def units
      list = []
      @scopes.each do |name, scope|
        list.concat(scope.to_units)
      end
      list
    end

    # A Scope is a Module or Class, and may contain other scopes.
    class Scope
      include Enumerable

      attr_accessor :name, :comment, :instance_methods, :class_methods

      attr_accessor :parent

      attr_accessor :scopes

      def initialize(name, comment='', instance_methods=[], class_methods=[])
        @name             = name
        @comment          = comment
        @instance_methods = instance_methods
        @class_methods    = class_methods
        @scopes           = {}
      end

      def [](scope)
        @scopes[scope]
      end

      def keys
        @scopes.keys
      end

      def each(&block)
        @scopes.each(&block)
      end

      def to_s
        inspect
      end

      def inspect
        scopes   = @scopes.keys.join(', ')
        imethods = @instance_methods.inspect
        cmethods = @class_methods.inspect

        "<#{name} scopes:[#{scopes}] :#{cmethods}: ##{imethods}#>"
      end

      #
      def target
        if parent
          parent.target.const_get(name)
        else
          Object.const_get(name)
        end
      end

      #
      def to_units
        units = []
        @instance_methods.each do |imethod|
          units << Snapshot::Unit.new(target, imethod, :singleton=>false)
        end
        @class_methods.each do |imethod|
          units << Snapshot::Unit.new(target, imethod, :singleton=>true)
        end
        @scopes.each do |name, scope|
          units.concat(scope.to_units)
        end
        units
      end

    end

    # A Method can be instance or class level.
    class Method
      attr_accessor :name, :comment, :args

      def initialize(name, comment='', args=[])
        @name    = name
        @comment = comment
        @args    = args || []
      end
      alias_method :to_s, :name

      def to_sym
        name.to_sym
      end

      def inspect
        "#{name}(#{args.join(', ')})"
      end
    end

  end

end
