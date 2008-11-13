module FixtureReplacement
  attributes_for :attachment do |a|
    
	end

  attributes_for :choice do |a|
    
	end

  attributes_for :contest do |a|
    
	end

  attributes_for :comment do |a|
    a.guide_id = 1
    a.body = String.random
    
	end

  attributes_for :guide do |a|
    a.status = Guide::PUBLISHED
    a.user_id = 1
    a.permalink  = String.random
    a.city = String.random
    a.state = 'CA'
    a.date = 1.month.from_now
    a.name = String.random
	end

  attributes_for :link do |a|
    
	end

  attributes_for :pledge do |a|
    
	end

  attributes_for :resource do |a|
    
	end

  attributes_for :role do |a|
    
	end

  attributes_for :style do |a|
    
	end

  attributes_for :theme do |a|
    
	end

  attributes_for :user do |a|
    a.login = login = String.random
    a.email = "#{login}@example.com"
    a.password = 'quire'
    a.password_confirmation = 'quire'
    a.city = 'san francisco'
    a.state = 'CA'
	end

end
