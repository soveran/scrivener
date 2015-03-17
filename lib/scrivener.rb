require_relative "scrivener/validations"

class Scrivener
  VERSION = "0.4.1"

  include Validations

  def self.attributes
    @attributes ||= []
  end

  # Define attributes
  def self.attribute(*atts)
    attributes.replace(attributes | atts)
  end

  # Initialize with a hash of attributes and values.
  # Extra attributes are discarded.
  #
  # @example
  #
  #   class EditPost < Scrivener
  #     attribute :title, :body
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
    @attributes = {}

    _attributes.each do |att|
      @attributes[att] = atts[att]
    end
  end

  def _attributes
    self.class.attributes
  end

  # Return hash of attributes and values.
  def attributes
    @attributes
  end

  def slice(*keys)
    Hash.new.tap do |atts|
      keys.each do |att|
        atts[att] = attributes[att]
      end
    end
  end
end
