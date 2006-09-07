require 'meantime_filter'

ActionController::Base.send(:include, ActionController::Filters::MeantimeFilter)
