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
