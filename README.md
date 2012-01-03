Scrivener
=========

Validation frontend for models.

Description
-----------

Scrivener removes the validation responsibility from models and acts as a
filter for whitelisted attributes.

A model may expose different APIs to satisfy different purposes. For example,
the set of validations for a User in a Sign up process may not be the same
as the one exposed to an Admin when editing a user profile. While you want
the User to provide an email, a password and a password confirmation, you
probably don't want the admin to mess with those attributes at all.

In a wizard, different model states ask for different validations, and a single
set of validations for the whole process is not the best solution.

Scrivener is Bureaucrat's little brother. It draws all the inspiration from it
and its features are a subset of Bureaucrat's. For a more robust and tested
solution, please [check it](https://github.com/tizoc/bureaucrat).

This library exists to satify the need of extracting Ohm's validations for
reuse in other scenarios. By doing this, all projects using Ohm::Validations
will be able to profit from extra assertions such as those provided by
[ohm-contrib](https://github.com/cyx/ohm-contrib).

Usage
-----

Using Scrivener feels very natural no matter what underlying model you are
using. As it provides its own validation and whitelisting features, you can
chose to ignore the ones that come bundled with ORMs.

This short example illustrates how to move the validation and whitelisting
responsibilities away from the model and into Scrivener:

    # We use Sequel::Model in this example, but it applies to other ORMs such
    # as Ohm or ActiveRecord.
    class Article < Sequel::Model

      # Whitelist for mass assigned attributes.
      set_allowed_columns :title, :body, :state

      # Validations for all contexts.
      def validate
        validates_presence :title
        validates_presence :body
        validates_presence :state
      end
    end

    title = "Bartleby, the Scrivener"
    body  = "I am a rather elderly man..."

    # When using the model...
    article = Article.new(title: title, body: body)

    article.valid?            #=> false
    article.errors.on(:state) #=> ["cannot be empty"]

Of course, what you would do instead is declare `:title` and `:body` as allowed
columns, then assign `:state` using the attribute accessor. The reason for this
example is to show how you need to work around the fact that there's a single
declaration for allowed columns and validations, which in many cases is a great
feature and in other is a minor obstacle.

Now see what happens with Scrivener:

    # Now the model has no validations or whitelists. It may still have schema
    # constraints, which is a good practice to enforce data integrity.
    class Article < Sequel::Model
    end

    # The attribute accessors are the only fields that will be set. If more
    # fields are sent when using mass assignment, a NoMethodError exception is
    # raised.
    #
    # Note how in this example we don't ask the name on signup.
    class Edit < Scrivener
      attr_accessor :title
      attr_accessor :body

      def validate
        assert_present :title
        assert_present :body
      end
    end

    edit = Edit.new(title: title, body: body)
    edit.valid?               #=> true

    article = Article.new(edit.attributes)
    article.save

    # And now we only ask for the status.
    class Publish < Scrivener
      attr_accessor :status

      def validate
        assert_format :status, /^(published|draft)$/
      end
    end

    publish = Publish.new(status: "published")
    publish.valid?            #=> true

    article.update_attributes(publish.attributes)

    # If we try to change other fields...
    publish = Publish.new(status: "published", title: "foo")
    #=> NoMethodError: undefined method `title=' for #<Publish...>

It's important to note that using Scrivener implies a greater risk than using
the model validations. Having a central repository of mass assignable
attributes and validations is more secure in most scenarios.

Installation
------------

    $ gem install scrivener
