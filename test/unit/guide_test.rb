require File.dirname(__FILE__) + '/../test_helper'

class GuideTest < Test::Unit::TestCase
  fixtures :guides, :endorsements

  def test_create
    count = Guide.count
    g = Guide.new(:name => 'can create', :date => Time.now.to_date)
    assert g.save
    assert Guide.count == count+1
  end

  def test_validations
    g = Guide.new
    # name and date must be present
    assert !g.save
    assert_not_nil g.errors[:name]
    assert_not_nil g.errors[:date]

    g.name = 'has name'
    assert !g.save
    assert_nil g.errors[:name]

    #date must be today or greater
    g.date = Time.now - 1.day
    assert !g.save
    assert_not_nil g.errors[:date]
    g.date = Time.now
    assert g.save
  end

  def test_validates_permalink
    first = Guide.new(:name => 'original', :date => Time.now)
    assert first.save

    dup = Guide.new(:name => 'original', :date => Time.now)
    assert !dup.save
    assert_not_nil dup.errors[:permalink]

    dup.date += 1.day
    assert dup.save
  end

  def test_add_endrosements
    g = Guide.new(:name => 'namey', :date => Time.now)
    g.endorsements.build(:contest => endorsements(:order_1).contest)
    g.endorsements.build(:contest => endorsements(:order_2).contest)
    g.endorsements.build(:contest => endorsements(:order_3).contest)
    assert g.save

    first = g.endorsements.find(:first, :conditions => "position = 1")
    second = g.endorsements.find(:first, :conditions => "position = 2")
    third = g.endorsements.find(:first, :conditions => "position = 3")
    assert_equal first.contest, endorsements(:order_1).contest
    assert_equal second.contest, endorsements(:order_2).contest
    assert_equal third.contest, endorsements(:order_3).contest
    assert first.first?
    assert third.last?
  end
end
