require File.expand_path("scrivener/validations", File.dirname(__FILE__))

class Scrivener
  VERSION = "0.0.3"

  include Validations

  # Initialize with a hash of attributes and values.
  # If extra attributes are sent, a NoMethodError exception will be raised.
  #
  # The grand daddy of all assertions. If you want to build custom
  # assertions, or even quick and dirty ones, you can simply use this method.
  #
  # @example
  #
  #   class EditPost < Scrivener
  #     attr_accessor :title
  #     attr_accessor :body
  #
  #     def validate
  #       assert_present :title
  #       assert_present :body
  #     end
  #   end
  #
  #   edit = EditPost.new(title: "Software Tools")
  #
  #   edit.valid? #=> false
  #
  #   edit.errors[:title] #=> []
  #   edit.errors[:body]  #=> [:not_present]
  #
  #   edit.body = "Recommended reading..."
  #
  #   edit.valid? #=> true
  #
  #   # Now it's safe to initialize the model.
  #   post = Post.new(edit.attributes)
  #   post.save
  def initialize(attrs)
    attrs.each do |key, val|
      send(:"#{key}=", val)
    end
  end

  # Return hash of attributes and values.
  def attributes
    Hash.new.tap do |atts|
      instance_variables.each do |ivar|
        next if ivar == :@errors

        att = ivar[1..-1].to_sym
        atts[att] = send(att)
      end
    end
  end
end

