Scrivener
=========

Validation frontend for models.

Description
-----------

Scrivener removes the validation responsibility from models and
acts as a filter for whitelisted attributes. Read about the
[motivation](#motivation) to understand why this separation of
concerns is important.

Usage
-----

A very basic example would be creating a blog post:

```ruby
class CreateBlogPost < Scrivener
  attr_accessor :title
  attr_accessor :body

  def validate
    assert_present :title
    assert_present :body
  end
end
```

In order to use it, you have to create an instance of `CreateBlogPost`
by passing a hash with the attributes `title` and `body` and their
corresponding values:

```ruby
params = {
  title: "Bartleby",
  body: "I am a rather elderly man..."
}

filter = CreateBlogPost.new(params)
```

Now you can run the validations by calling `filter.valid?`, and you
can retrieve the attributes by calling `filter.attributes`. If the
validation fails, a hash of attributes and error codes will be
available by calling `filter.errors`. For example:

```ruby
if filter.valid?
  puts filter.attributes
else
  puts filter.errors
end
```

For now, we are just printing the attributes and the list of errors,
but often you will use the attributes to create an instance of a
model, and you will display the error messages in a view.

Let's consider the case of creating a new user:

```ruby
class CreateUser < Scrivener
  attr_accessor :email
  attr_accessor :password
  attr_accessor :password_confirmation

  def validate
    assert_email :email

    if assert_present :password
      assert_equal :password, :password_confirmation
    end
  end
end
```

The filter looks very similar, but as you can see the validations
return booleans, thus they can be nested. In this example, we don't
want to bother asserting if the password and the password confirmation
are equal if the password was not provided.

Let's instantiate the filter:

```ruby
params = {
  email: "info@example.com",
  password: "monkey",
  password_confirmation: "monkey"
}

filter = CreateUser.new(params)
```

If the validation succeeds, we only need email and password to
create a new user, and we can discard the password_confirmation.
The `filter.slice` method receives a list of attributes and returns
the attributes hash with any other attributes removed. In this
example, the hash returned by `filter.slice` will contain only the
`email` and `password` fields:

```ruby
if filter.valid?
  User.create(filter.slice(:email, :password))
end
```

Assertions
-----------

Scrivener ships with some basic assertions.

### assert

The `assert` method is used by all the other assertions. It pushes the
second parameter to the list of errors if the first parameter evaluates
to `false` or `nil`.

``` ruby
def assert(value, error)
   value or errors[error.first].push(error.last) && false
end
```

New assertions can be built upon existing ones. For example, let's
define an assertion for possitive numbers:

```ruby
def assert_possitive(att, error = [att, :not_possitive])
  assert(send(att) > 0, error)
end
```

This assertion calls `assert` and passes both the result of evaluating
`send(att) > 0` and the array with the attribute and the error code.
All assertions respect this API.

### assert_present

Checks that the given field is not nil or empty. The error code for
this assertion is `:not_present`.

### assert_equal

Check that the attribute has the expected value. It uses === for
comparison, so type checks are possible too. Note that in order to
make the case equality work, the check inverts the order of the
arguments: `assert_equal :foo, Bar` is translated to the expression
`Bar === send(:foo)`.

### assert_format

Checks that the given field matches the provided regular expression.
The error code for this assertion is `:format`.

### assert_numeric

Checks that the given field holds a number as a Fixnum or as a string
representation. The error code for this assertion is `:not_numeric`.

### assert_url

Provides a pretty general URL regular expression match. An important
point to make is that this assumes that the URL should start with
`http://` or `https://`. The error code for this assertion is
`:not_url`.

### assert_email

In this current day and age, almost all web applications need to
validate an email address. This pretty much matches 99% of the emails
out there. The error code for this assertion is `:not_email`.

### assert_member

Checks that a given field is contained within a set of values (i.e.
like an `ENUM`).

``` ruby
def validate
  assert_member :state, %w{pending paid delivered}
end
```

The error code for this assertion is `:not_valid`

### assert_length

Checks that a given field's length falls under a specified range.

``` ruby
def validate
  assert_length :username, 3..20
end
```

The error code for this assertion is `:not_in_range`.

### assert_decimal

Checks that a given field looks like a number in the human sense
of the word. Valid numbers are: 0.1, .1, 1, 1.1, 3.14159, etc.

The error code for this assertion is `:not_decimal`.

Motivation
----------

A model may expose different APIs to satisfy different purposes.
For example, the set of validations for a User in a sign up process
may not be the same as the one exposed to an Admin when editing a
user profile. While you want the User to provide an email, a password
and a password confirmation, you probably don't want the admin to
mess with those attributes at all.

In a wizard, different model states ask for different validations,
and a single set of validations for the whole process is not the
best solution.

This library exists to satisfy the need for extracting
[Ohm](http://ohm.keyvalue.org)'s validations for reuse in other
scenarios.

Using Scrivener feels very natural no matter what underlying model
you are using. As it provides its own validation and whitelisting
features, you can choose to ignore those that come bundled with
ORMs.

See also
--------

Scrivener is [Bureaucrat](https://github.com/tizoc/bureaucrat)'s
little brother. It draws all the inspiration from it and its features
are a subset of Bureaucrat's.

Installation
------------

    $ gem install scrivener
