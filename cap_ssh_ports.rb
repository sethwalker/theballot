module Capistrano
# A helper class for dealing with SSH connections.
    class SSH
      def self.connect(server, config, port=22, &block)
        methods = [ %w(publickey hostbased), %w(password keyboard-interactive) ]
        password_value = nil
    
        begin
          ssh_options = { :username => config.user,
                          :password => password_value,
                          :port => port,
                          :auth_methods => methods.shift }.merge(config.ssh_options)
                      
          # This regex is used for its byproducts, the $1-9 match vars.
          # This regex will always match the ssh hostname and if there 
          # is a username or port they will be matched as well. This 
          # allows us to set the username and ssh port right in the 
          # role string:  "ez@123.12.123.12:8088"
          # This remains fully backwards compatible and can still be
          # intermixed with the old way of doing things. usernames
          # and ports will be used from the role string if present
          # but they will fall back to the regular defaults when not
          # present.
          server =~ /^(?:(\w+)@|)(.*?)(?::(\d+)|)$/                
          ssh_options[:username] = $1 if $1    
          ssh_options[:port] = $3 if $3
            
          Net::SSH.start($2,ssh_options,&block)
        rescue Net::SSH::AuthenticationFailed
          raise if methods.empty?
          password_value = config.password
          retry
        end
      end
    end
    
end

