require File.expand_path("../lib/scrivener", File.dirname(__FILE__))

class S < Scrivener
  attr_accessor :a
  attr_accessor :b
end

scope do
  test "raise when there are extra fields" do
    atts = { :a => 1, :b => 2, :c => 3 }

    assert_raise NoMethodError do
      s = S.new(atts)
    end
  end

  test "not raise when there are less fields" do
    atts = { :a => 1 }

    assert s = S.new(atts)
  end

  test "return attributes" do
    atts = { :a => 1, :b => 2 }

    s = S.new(atts)

    assert_equal atts, s.attributes
  end
end

class T < Scrivener
  attr_accessor :a
  attr_accessor :b

  def validate
    assert_present :a
    assert_present :b
  end
end

scope do
  test "validations" do
    atts = { :a => 1, :b => 2 }

    t = T.new(atts)

    assert t.valid?
  end

  test "validation errors" do
    atts = { :a => 1 }

    t = T.new(atts)

    assert_equal false, t.valid?
    assert_equal [], t.errors[:a]
    assert_equal [:not_present], t.errors[:b]
  end

  test "attributes without @errors" do
    atts = { :a => 1, :b => 2 }

    t = T.new(atts)

    t.valid?
    assert_equal atts, t.attributes
  end
end

class Quote
  include Scrivener::Validations

  attr_accessor :foo

  def validate
    assert_present :foo
  end
end

scope do
  test "validations without Scrivener" do
    q = Quote.new
    q.foo = 1
    assert q.valid?

    q = Quote.new
    assert_equal false, q.valid?
    assert_equal [:not_present], q.errors[:foo]
  end
end

class Post < Scrivener
  attr_accessor :url, :email

  def validate
    assert_url :url
    assert_email :email
  end
end

scope do
  test "email & url" do
    p = Post.new({})

    assert ! p.valid?
    assert_equal [:not_url],  p.errors[:url]
    assert_equal [:not_email],  p.errors[:email]

    p = Post.new(url: "google.com", email: "egoogle.com")

    assert ! p.valid?
    assert_equal [:not_url],  p.errors[:url]
    assert_equal [:not_email],  p.errors[:email]

    p = Post.new(url: "http://google.com", email: "me@google.com")
    assert p.valid?
  end
end

class Person < Scrivener
  attr_accessor :username

  def validate
    assert_length :username, 3..10
  end
end

scope do
  test "length validation" do
    p = Person.new({})

    assert ! p.valid?
    assert p.errors[:username].include?(:not_in_range)

    p = Person.new(username: "fo")
    assert ! p.valid?
    assert p.errors[:username].include?(:not_in_range)

    p = Person.new(username: "foofoofoofo")
    assert ! p.valid?
    assert p.errors[:username].include?(:not_in_range)

    p = Person.new(username: "foo")
    assert p.valid?
  end
end

class Order < Scrivener
  attr_accessor :status

  def validate
    assert_member :status, %w{pending paid delivered}
  end
end

scope do
  test "member validation" do
    o = Order.new({})
    assert ! o.valid?
    assert_equal [:not_valid], o.errors[:status]

    o = Order.new(status: "foo")
    assert ! o.valid?
    assert_equal [:not_valid], o.errors[:status]

    %w{pending paid delivered}.each do |status|
      o = Order.new(status: status)
      assert o.valid?
    end
  end
end

class Product < Scrivener
  attr_accessor :price

  def validate
    assert_decimal :price
  end
end

scope do
  test "decimal validation" do
    p = Product.new({})
    assert ! p.valid?
    assert_equal [:not_decimal], p.errors[:price]

    %w{10 10.1 10.100000 0.100000 .1000}.each do |price|
      p = Product.new(price: price)
      assert p.valid?
    end
  end
end