## 1.1.1

* Avoid warning when forwarding arguments to #validate.

## 1.1.0

* Allow passing arguments to Scrivener#validate.

## 1.0.0

* Extra attributes are ignored.

    ```ruby
    # Before:

    publish = Publish.new(status: "published", title: "foo")
    publis.attributes # => { :status => "published" }
    # => NoMethodError: undefined method `title=' for #<Publish...>

    # Now:

    # Extra fields are discarded
    publish = Publish.new(status: "published", title: "foo")
    publish.attributes # => { :status => "published" }
    ```

## 0.4.1

* Fix creation of symbols for extra attributes.

## 0.4.0

* Fix `assert_email` and `assert_url` to support longer tld's.

## 0.3.0

* Add support for negative numbers.

## 0.2.0

* Add `assert_equal` validation.
