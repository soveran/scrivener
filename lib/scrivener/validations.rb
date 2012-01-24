class Scrivener

  # Provides a base implementation for extensible validation routines.
  # {Scrivener::Validations} currently only provides the following assertions:
  #
  # * assert
  # * assert_present
  # * assert_format
  # * assert_numeric
  # * assert_url
  # * assert_email
  # * assert_member
  # * assert_length
  # * assert_decimal
  #
  # The core tenets that Scrivener::Validations advocates can be summed up in a
  # few bullet points:
  #
  # 1. Validations are much simpler and better done using composition rather
  #    than macros.
  # 2. Error messages should be kept separate and possibly in the view or
  #    presenter layer.
  # 3. It should be easy to write your own validation routine.
  #
  # Other validations are simply added on a per-model or per-project basis.
  #
  # If you want other validations you may want to take a peek at Ohm::Contrib
  # and all of the validation modules it provides.
  #
  # @see http://cyx.github.com/ohm-contrib/doc/Ohm/WebValidations.html
  # @see http://cyx.github.com/ohm-contrib/doc/Ohm/NumberValidations.html
  # @see http://cyx.github.com/ohm-contrib/doc/Ohm/ExtraValidations.html
  #
  # @example
  #
  #   class Quote
  #     attr_accessor :title
  #     attr_accessor :price
  #     attr_accessor :date
  #
  #     def validate
  #       assert_present :title
  #       assert_numeric :price
  #       assert_format  :date, /\A[\d]{4}-[\d]{1,2}-[\d]{1,2}\z
  #     end
  #   end
  #
  #   s = Quote.new
  #   s.valid?
  #   # => false
  #
  #   s.errors
  #   # => { :title => [:not_present],
  #          :price => [:not_numeric],
  #          :date  => [:format] }
  #
  module Validations

    # Check if the current model state is valid. Each call to {#valid?} will
    # reset the {#errors} array.
    #
    # All validations should be declared in a `validate` method.
    #
    # @example
    #
    #   class Login
    #     attr_accessor :username
    #     attr_accessor :password
    #
    #     def validate
    #       assert_present :user
    #       assert_present :password
    #     end
    #   end
    #
    def valid?
      errors.clear
      validate
      errors.empty?
    end

    # Base validate implementation. Override this method in subclasses.
    def validate
    end

    # Hash of errors for each attribute in this model.
    def errors
      @errors ||= Hash.new { |hash, key| hash[key] = [] }
    end

  protected

    # Allows you to do a validation check against a regular expression.
    # It's important to note that this internally calls {#assert_present},
    # therefore you need not structure your regular expression to check
    # for a non-empty value.
    #
    # @param [Symbol] att The attribute you want to verify the format of.
    # @param [Regexp] format The regular expression with which to compare
    #                 the value of att with.
    # @param [Array<Symbol, Symbol>] error The error that should be returned
    #                                when the validation fails.
    def assert_format(att, format, error = [att, :format])
      if assert_present(att, error)
        assert(send(att).to_s.match(format), error)
      end
    end

    # The most basic and highly useful assertion. Simply checks if the
    # value of the attribute is empty.
    #
    # @param [Symbol] att The attribute you wish to verify the presence of.
    # @param [Array<Symbol, Symbol>] error The error that should be returned
    #                                when the validation fails.
    def assert_present(att, error = [att, :not_present])
      assert(!send(att).to_s.empty?, error)
    end

    # Checks if all the characters of an attribute is a digit. If you want to
    # verify that a value is a decimal, try looking at Ohm::Contrib's
    # assert_decimal assertion.
    #
    # @param [Symbol] att The attribute you wish to verify the numeric format.
    # @param [Array<Symbol, Symbol>] error The error that should be returned
    #                                when the validation fails.
    # @see http://cyx.github.com/ohm-contrib/doc/Ohm/NumberValidations.html
    def assert_numeric(att, error = [att, :not_numeric])
      if assert_present(att, error)
        assert_format(att, /\A\d+\z/, error)
      end
    end

    URL = /\A(http|https):\/\/([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}|(2
          5[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}
          |localhost)(:[0-9]{1,5})?(\/.*)?\z/ix

    def assert_url(att, error = [att, :not_url])
      if assert_present(att, error)
        assert_format(att, URL, error)
      end
    end

    EMAIL = /\A([\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+\.)*
            [\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+@
            ((((([a-z0-9]{1}[a-z0-9\-]{0,62}[a-z0-9]{1})|[a-z])\.)+
            [a-z]{2,6})|(\d{1,3}\.){3}\d{1,3}(\:\d{1,5})?)\z/ix

    def assert_email(att, error = [att, :not_email])
      if assert_present(att, error)
        assert_format(att, EMAIL, error)
      end
    end

    def assert_member(att, set, err = [att, :not_valid])
      assert(set.include?(send(att)), err)
    end

    def assert_length(att, range, error = [att, :not_in_range])
      if assert_present(att, error)
        val = send(att).to_s
        assert range.include?(val.length), error
      end
    end

    DECIMAL = /\A(\d+)?(\.\d+)?\z/

    def assert_decimal(att, error = [att, :not_decimal])
      assert_format att, DECIMAL, error
    end

    # The grand daddy of all assertions. If you want to build custom
    # assertions, or even quick and dirty ones, you can simply use this method.
    #
    # @example
    #
    #   class CreatePost
    #     attr_accessor :slug
    #     attr_accessor :votes
    #
    #     def validate
    #       assert_slug :slug
    #       assert votes.to_i > 0, [:votes, :not_valid]
    #     end
    #
    #   protected
    #     def assert_slug(att, error = [att, :not_slug])
    #       assert send(att).to_s =~ /\A[a-z\-0-9]+\z/, error
    #     end
    #   end
    def assert(value, error)
      value or errors[error.first].push(error.last) && false
    end
  end
end
