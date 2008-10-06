require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Guide do
  fixtures :guides, :contests

  it "should create" do
    count = Guide.count
    g = Guide.new(:name => 'can create', :date => Time.now.to_date, :city => 'sf', :state => 'CA')
    lambda { g.save }.should change(Guide, :count).by(1)
  end

   it "should validate correctly" do
    g = Guide.new
    # name and date must be present
    g.save.should be_false
    g.errors[:name].should_not be_nil
    g.errors[:date].should_not be_nil
    g.errors[:city].should_not be_nil
    g.errors[:state].should_not be_nil

    g.name = 'has name'
    g.save.should be_false
    g.errors[:name].should be_nil

    #date must be today or greater
    g.date = Time.now - 1.day
    g.save.should be_false
    g.errors[:date].should_not be_nil
    g.date = Time.now
    g.save.should be_false
    g.errors[:date].should be_nil

    g.city = 'sf'
    g.state = 'CA'
    g.save.should be_true
  end

  it "should validate permalink" do
    pending
    date = Time.now
    first = Guide.new(:name => 'original', :date => date, :city => 'sf', :state => 'CA')
    assert first.save

    dup = Guide.new(:name => 'original', :date => date, :city => 'sf', :state => 'CA')
    assert !dup.save
    assert_not_nil dup.errors[:permalink]

    dup.date += 1.day
    assert dup.save
  end

  it "should add contests" do
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

  it "should publish" do
    g = Guide.new(:name => 'publish test', :date => Time.now, :city => 'sf', :state => 'CA')
    assert g.save

    assert !g.is_published?
    g.publish
    assert g.is_published?
    g.unpublish
    assert !g.is_published?
  end
end
