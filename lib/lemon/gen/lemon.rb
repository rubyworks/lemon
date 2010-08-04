require 'lemon/adapter'

module Lemon::Adapter::Lemon

  class Generator

    def initialize(targets, options={})
    end

    # Generate code template.
    #
    # TODO: support output
    def generate(output=nil)
      code = []

      system.each do |ofmod|
        next if ofmod.base.is_a?(Lemon::Test::Suite)

        code << "TestCase #{ofmod.base} do"

        ofmod.class_methods(public_only?).each do |meth|
          code << "\n  MetaUnit :#{meth} => '' do\n    raise Pending\n  end"
        end

        ofmod.instance_methods(public_only?).each do |meth|
          code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
        end

        code << "\nend\n"
      end

      code.join("\n")
    end

    #
    def generate_uncovered(output=nil)
      code = []
      checklist.each do |base, methods|
        next if /Lemon::Test::Suite/ =~ base.to_s
        code << "TestCase #{base} do"
        methods.each do |meth, covered|
          next if covered
          if meth.to_s =~ /^\:\:/
            meth = meth.sub('::','')
            code << "\n  MetaUnit :#{meth} => '' do\n    raise Pending\n  end"
          else
            code << "\n  Unit :#{meth} => '' do\n    raise Pending\n  end"
          end
        end
        #base.public_instance_methods(false).each do |meth|
        #  code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #end
        #unless public_only?
        #  base.private_instance_methods(false).each do |meth|
        #    code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #  end
        #  base.protected_instance_methods(false).each do |meth|
        #    code << "\n  Unit :#{meth} => '' do\n    Pending\n  end"
        #  end
        #end
        code << "\nend\n"
      end
      code.join("\n")
    end

  end

end

