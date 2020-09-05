require File.expand_path("../lib/scrivener", File.dirname(__FILE__))

class A < Scrivener
  attr_accessor :a
  attr_accessor :b
end

scope do
  test "ignore extra fields" do
    atts = { :a => 1, :b => 2, :c => 3 }

    filter = A.new(atts)

    atts.delete(:c)

    assert_equal atts, filter.attributes
  end

  test "not raise when there are less fields" do
    atts = { :a => 1 }

    assert filter = A.new(atts)
    assert_equal filter.attributes, { :a => 1 }
  end

  test "return attributes" do
    atts = { :a => 1, :b => 2 }

    filter = A.new(atts)

    assert_equal atts, filter.attributes
  end

  test "return only the required attributes" do
    atts = { :a => 1, :b => 2 }

    filter = A.new(atts)

    assert_equal filter.slice(:a), { :a => 1 }
  end
end

class B < Scrivener
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

    filter = B.new(atts)

    assert filter.valid?
  end

  test "validation errors" do
    atts = { :a => 1 }

    filter = B.new(atts)

    assert_equal false, filter.valid?
    assert_equal [], filter.errors[:a]
    assert_equal [:not_present], filter.errors[:b]
  end

  test "attributes without @errors" do
    atts = { :a => 1, :b => 2 }

    filter = B.new(atts)

    filter.valid?
    assert_equal atts, filter.attributes
  end
end

class C
  include Scrivener::Validations

  attr_accessor :a

  def validate
    assert_present :a
  end
end

scope do
  test "validations without Scrivener" do
    filter = C.new
    filter.a = 1
    assert filter.valid?

    filter = C.new
    assert_equal false, filter.valid?
    assert_equal [:not_present], filter.errors[:a]
  end
end

class D < Scrivener
  attr_accessor :url, :email

  def validate
    assert_url :url
    assert_email :email
  end
end

scope do
  test "email & url" do
    filter = D.new({})

    assert ! filter.valid?
    assert_equal [:not_url],  filter.errors[:url]
    assert_equal [:not_email],  filter.errors[:email]

    filter = D.new(url: "google.com", email: "egoogle.com")

    assert ! filter.valid?
    assert_equal [:not_url],  filter.errors[:url]
    assert_equal [:not_email],  filter.errors[:email]

    filter = D.new(url: "http://google.com", email: "me@google.com")
    assert filter.valid?

    filter = D.new(url: "http://example.versicherung", email: "me@example.versicherung")
    assert filter.valid?
  end
end

class E < Scrivener
  attr_accessor :a

  def validate
    assert_length :a, 3..10
  end
end

scope do
  test "length validation" do
    filter = E.new({})

    assert ! filter.valid?
    assert filter.errors[:a].include?(:not_in_range)

    filter = E.new(a: "fo")
    assert ! filter.valid?
    assert filter.errors[:a].include?(:not_in_range)

    filter = E.new(a: "foofoofoofo")
    assert ! filter.valid?
    assert filter.errors[:a].include?(:not_in_range)

    filter = E.new(a: "foo")
    assert filter.valid?
  end
end

class F < Scrivener
  attr_accessor :status

  def validate
    assert_member :status, %w{pending paid delivered}
  end
end

scope do
  test "member validation" do
    filter = F.new({})
    assert ! filter.valid?
    assert_equal [:not_valid], filter.errors[:status]

    filter = F.new(status: "foo")
    assert ! filter.valid?
    assert_equal [:not_valid], filter.errors[:status]

    %w{pending paid delivered}.each do |status|
      filter = F.new(status: status)
      assert filter.valid?
    end
  end
end

class G < Scrivener
  attr_accessor :a

  def validate
    assert_decimal :a
  end
end

scope do
  test "decimal validation" do
    filter = G.new({})
    assert ! filter.valid?
    assert_equal [:not_decimal], filter.errors[:a]

    %w{10 10.1 10.100000 0.100000 .1000 -10}.each do |a|
      filter = G.new(a: a)
      assert filter.valid?
    end
  end
end

class H < Scrivener
  attr_accessor :a
  attr_accessor :b

  def validate
    assert_equal :a, "foo"
    assert_equal :b, Integer
  end
end

scope do
  test "equality validation" do
    filter = H.new({})

    assert ! filter.valid?
    assert filter.errors[:a].include?(:not_equal)
    assert filter.errors[:b].include?(:not_equal)

    filter = H.new(a: "foo", b: "bar")
    assert ! filter.valid?

    filter = H.new(a: "foo")
    assert ! filter.valid?
    assert filter.errors[:a].empty?
    assert filter.errors[:b].include?(:not_equal)

    filter = H.new(a: "foo", b: 42)
    filter.valid?
    assert filter.valid?
  end
end

class Scrivener
  def assert_filter(att, filter, error = nil)
    filter = filter.new(send(att))
    
    unless filter.valid?
      assert(false, error || [att, filter.errors])
    end
  end
end

class I < Scrivener
  attr_accessor :name
  
  def validate
    assert_equal :name, "I"
  end
end

class J < Scrivener
  attr_accessor :name
  attr_accessor :i

  def validate
    assert_equal :name, "J"
    assert_filter :i, I
  end
end

scope do
  test "nested filters" do
    j1 = J.new(name: "J", i: { name: "I" })
    j2 = J.new(name: "J", i: { name: "H" })

    assert_equal true, j1.valid?
    assert_equal false, j2.valid?

    errors = {
      i: [{ name: [:not_equal] }]
    }

    assert_equal errors, j2.errors
  end
end

class K < Scrivener
  def validate(argument)
    assert argument == "K", [:k, :not_valid]
  end
end

scope do
  test "passing arguments" do
    k = K.new({})

    assert_equal true,  k.valid?("K")
    assert_equal false, k.valid?("L")

    errors = {
      k: [:not_valid]
    }

    assert_equal errors, k.errors
  end
end

class L < Scrivener
  def validate(argument, key:)
    assert argument == "L" && key == "L", [:l, :not_valid]
  end
end

scope do
  test "passing keyword arguments" do
    l = L.new({})

    assert_equal true,  l.valid?("L", key: "L")
    assert_equal false, l.valid?("M", key: "M")

    errors = {
      l: [:not_valid]
    }

    assert_equal errors, l.errors
  end
end
