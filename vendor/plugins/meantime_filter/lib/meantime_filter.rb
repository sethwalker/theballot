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

module ActionController
  module Filters
    
    # See the README file for usage informations.
    module MeantimeFilter
      def self.included(base) #:nodoc:
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        
        # The passed <tt>filters</tt> will be appended to the array of filters
        # that's run _wrapping_ actions performed on this controller.
        def append_meantime_filter(*filters)
          conditions = extract_conditions!(filters)
          add_action_conditions(filters, conditions)
          append_filter_to_chain('meantime', filters)
        end
        
        # The passed <tt>filters</tt> will be prepended to the array of
        # filters that's run _wrapping_ actions performed on this controller.
        def prepend_meantime_filter(*filters)
          conditions = extract_conditions!(filters)
          add_action_conditions(filters, conditions)
          prepend_filter_to_chain('meantime', filters)
        end
        
        # Short-hand for append_meantime_filter since that's the most common of the
        # two.
        alias :meantime_filter :append_meantime_filter
        
        # Returns all the wrap filters for this class and all its ancestors.
        def meantime_filters #:nodoc:
          @meantime_filters ||= read_inheritable_attribute('meantime_filters') || []
        end
        
        # Aliases for +meantime_filter+
        for name in [:wrap_filter, :wrap_actions]
          eval <<-EOA
            alias prepend_#{name} prepend_meantime_filter
            alias append_#{name}  append_meantime_filter
            alias #{name}         append_meantime_filter
          EOA
        end
      end
      
      module InstanceMethods
        def self.included(base) #:nodoc:
          base.module_eval do
            alias_method :perform_action_without_meantime, :perform_action_without_filters
            alias_method :perform_action_without_filters, :perform_action_with_meantime
          end
        end

        def perform_action_with_meantime
          during_action { perform_action_without_meantime }
        end 

        private
        
        def during_action(&action)
          filters_and_action = self.class.meantime_filters.reject {|filter| action_exempted?(filter) } << action
          call_meantime_filters_or_action(filters_and_action)
        end
        
        def call_meantime_filters_or_action(filters_and_action)
          filter = filters_and_action.shift
          
          # Case 1: it is the action
          if filters_and_action.empty?
            filter.call
          
          # Case 2: it is a filter
          else
            todo = lambda { call_meantime_filters_or_action(filters_and_action) }
            case
              when filter.is_a?(Symbol) then  send(filter, &todo)
              when filter.is_a?(Method) then  filter.call(self, &todo)
              when filter_class?(filter) then filter.filter(self, &todo)
              else
                raise(
                  ActionControllerError, 
                  'Meantime filter needs to be either a Symbol, a Method, or any object implementing a "filter" method which receives the controller as only parameter'
                )
            end
          end
        end
      end # InstanceMethods
    end # MeantimeFilter
  end # Filters
end # ActionController
