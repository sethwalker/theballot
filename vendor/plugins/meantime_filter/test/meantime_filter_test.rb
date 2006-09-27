#--
# Copyright (c) 2006 Roman LE NEGRATE
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_controller/test_process'
require File.join(File.dirname(__FILE__), '..', 'init')

ActionController::Routing::Routes.reload

class PostsController < ActionController::Base
  module AroundExceptions
    class Error < StandardError ; end
    class Before < Error ; end
    class After < Error ; end
  end
  include AroundExceptions
  
  class Filter
    include AroundExceptions
  end
  
  module_eval %w( raises_before raises_after raises_both no_raise no_filter ).map {|action| "def #{action} ; default_action ; end" }.join("\n")
  
  def redirect_to_default
    # Do things...
    redirect_to :action => :default_action
  end
  
  private
    def default_action
      render :nothing => true
    end
end

class ControllerWithSymbolAsFilter < PostsController
  meantime_filter :raise_before, :only => :raises_before
  meantime_filter :raise_after, :only => :raises_after
  meantime_filter :without_exception, :only => [:no_raise, :redirect_to_default]
  
  private
    def raise_before
      raise Before
      yield
    end
  
    def raise_after
      yield
      raise After
    end
  
    def without_exception
      # Do stuff...
      1 + 1
    
      yield
    
      # Do stuff...
      1 + 1
    end
end

class ControllerWithFilterClass < PostsController
  class YieldingFilter < Filter
    def self.filter(controller)
      yield
      raise After
    end
  end
  
  meantime_filter YieldingFilter, :only => :raises_after
end

class ControllerWithFilterInstance < PostsController
  class YieldingFilter < Filter
    def filter(controller)
      yield
      raise After
    end
  end
  
  meantime_filter YieldingFilter.new, :only => :raises_after
end

class ControllerWithFilterMethod < PostsController
  class YieldingFilter < Filter
    def filter(controller)
      yield
      raise After
    end
  end
  
  meantime_filter YieldingFilter.new.method(:filter), :only => :raises_after
end

class ControllerWithWrongFilterType < PostsController
  meantime_filter lambda {|anything| yield }, :only => :no_raise
end

class ControllerWithNestedFilters < ControllerWithSymbolAsFilter
  meantime_filter :raise_before, :raise_after, :without_exception, :only => :raises_both
end

REGISTER_FILTERS_WITH_ALIASES = lambda do
  class AliasesTestsController < ControllerWithFilterClass
    wrap_actions YieldingFilter
    wrap_filter YieldingFilter
    prepend_wrap_actions YieldingFilter
    meantime_filter YieldingFilter
  end
end

class MeantimeFilterTest < Test::Unit::TestCase
  include PostsController::AroundExceptions
  
  def setup
    @with_symbol      = ControllerWithSymbolAsFilter.new
    @with_method      = ControllerWithFilterMethod.new
    @with_class       = ControllerWithFilterClass.new
    @with_instance    = ControllerWithFilterInstance.new
    @with_wrong_type  = ControllerWithWrongFilterType.new
    @with_nested      = ControllerWithNestedFilters.new
    @base             = PostsController.new
    
    @request          = ActionController::TestRequest.new
    @response         = ActionController::TestResponse.new
  end
  
  def test_filters_registering
    assert_equal 1, ControllerWithFilterMethod.meantime_filters.size
    assert_equal 1, ControllerWithFilterClass.meantime_filters.size
    assert_equal 1, ControllerWithFilterInstance.meantime_filters.size
    assert_equal 3, ControllerWithSymbolAsFilter.meantime_filters.size
    assert_equal 1, ControllerWithWrongFilterType.meantime_filters.size
    assert_equal 6, ControllerWithNestedFilters.meantime_filters.size
  end
  
  def test_wrong_filter_type
    @controller = @with_wrong_type
    assert_raise(ActionController::ActionControllerError) { get :no_raise }
  end
  
  def test_base
    @controller = @base
    assert_nothing_raised { get :no_raise }
    assert_nothing_raised { get :raises_before }
    assert_nothing_raised { get :raises_after }
    assert_nothing_raised { get :no_filter }
  end
  
  def test_with_symbol
    @controller = @with_symbol
    assert_nothing_raised { get :no_raise }
    assert_raise(Before) { get :raises_before }
    assert_raise(After) { get :raises_after }
    assert_nothing_raised { get :no_raise }
  end
  
  def test_with_class
    @controller = @with_class
    assert_nothing_raised { get :no_raise }
    assert_raise(After) { get :raises_after }
  end
  
  def test_with_instance
    @controller = @with_instance
    assert_nothing_raised { get :no_raise }
    assert_raise(After) { get :raises_after }
  end
  
  def test_with_method
    @controller = @with_method
    assert_nothing_raised { get :no_raise }
    assert_raise(After) { get :raises_after }
  end
  
  def test_nested_filters
    @controller = @with_nested
    assert_nothing_raised do
      begin
        get :raises_both
      rescue Before, After
      end
    end
    assert_raise Before do
      begin
        get :raises_both
      rescue After
      end
    end
  end
  
  def test_aliases
    assert_nothing_raised { REGISTER_FILTERS_WITH_ALIASES.call }
  end
  
  def test_redirect
    @controller = @with_symbol
    assert_nothing_raised { get :redirect_to_default }
  end
end
