require_relative "scrivener/validations"

class Scrivener
  VERSION = "1.1.1"

  include Validations

  # Initialize with a hash of attributes and values.
  # Extra attributes are discarded.
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
    @_accessors = atts.keys.map { |key| "#{key}=".to_sym }

    atts.each do |key, val|
      accessor = "#{key}="

      if respond_to?(accessor)
        send(accessor, val)
      end
    end
  end

  def _accessors
    @_accessors & public_methods(false).select do |name|
      name[-1] == "="
    end
  end

  # Return hash of attributes and values.
  def attributes
    Hash.new.tap do |atts|
      _accessors.each do |accessor|
        att = accessor[0..-2].to_sym
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
