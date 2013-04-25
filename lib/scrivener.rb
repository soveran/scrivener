require_relative "scrivener/validations"

class Scrivener
  VERSION = "0.0.3"

  include Validations

  # Initialize with a hash of attributes and values.
  # If extra attributes are sent, a NoMethodError exception will be raised.
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
  def initialize(atts)
    atts.each do |key, val|
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

  def slice(*keys)
    Hash.new.tap do |atts|
      keys.each do |att|
        atts[att] = send(att)
      end
    end
  end
end
