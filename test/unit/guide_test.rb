require File.dirname(__FILE__) + '/../test_helper'

class GuideTest < Test::Unit::TestCase
  fixtures :guides, :contests

  def test_create
    count = Guide.count
    g = Guide.new(:name => 'can create', :date => Time.now.to_date, :city => 'sf', :state => 'CA')
    assert g.save
    assert Guide.count == count+1
  end

  def test_validations
    g = Guide.new
    # name and date must be present
    assert !g.save
    assert_not_nil g.errors[:name]
    assert_not_nil g.errors[:date]
    assert_not_nil g.errors[:city]
    assert_not_nil g.errors[:state]

    g.name = 'has name'
    assert !g.save
    assert_nil g.errors[:name]

    #date must be today or greater
    g.date = Time.now - 1.day
    assert !g.save
    assert_not_nil g.errors[:date]
    g.date = Time.now
    assert !g.save
    assert_nil g.errors[:date]

    g.city = 'sf'
    g.state = 'CA'
    assert g.save
  end

  def test_validates_permalink
    first = Guide.new(:name => 'original', :date => Time.now, :city => 'sf', :state => 'CA')
    assert first.save

    dup = Guide.new(:name => 'original', :date => Time.now, :city => 'sf', :state => 'CA')
    assert !dup.save
    assert_not_nil dup.errors[:permalink]

    dup.date += 1.day
    assert dup.save
  end

  def test_add_contests
    g = Guide.new(:name => 'namey', :date => Time.now, :city => 'sf', :state => 'CA')
    g.contests.build(:name => contests(:order_1).name)
    g.contests.build(:name => contests(:order_2).name)
    g.contests.build(:name => contests(:order_3).name)
    assert g.save

    first = g.contests.find(:first, :conditions => "contests.position = 1")
    second = g.contests.find(:first, :conditions => "contests.position = 2")
    third = g.contests.find(:first, :conditions => "contests.position = 3")
    assert_equal first.name, contests(:order_1).name
    assert_equal second.name, contests(:order_2).name
    assert_equal third.name, contests(:order_3).name
    assert first.first?
    assert third.last?
  end

  def test_publish
    g = Guide.new(:name => 'publish test', :date => Time.now, :city => 'sf', :state => 'CA')
    assert g.save

    assert !g.is_published?
    g.publish
    assert g.is_published?
    g.unpublish
    assert !g.is_published?
  end
end
