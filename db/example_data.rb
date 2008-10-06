module FixtureReplacement
  attributes_for :attachment do |a|
    
	end

  attributes_for :choice do |a|
    
	end

  attributes_for :contest do |a|
    
	end

  attributes_for :guide do |a|
    
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
    a.login = 'quire'
    a.email = 'quire@example.com'
    a.password = 'quire'
    a.password_confirmation = 'quire'
    a.city = 'san francisco'
    a.state = 'CA'
	end

end
