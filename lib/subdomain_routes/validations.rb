module SubdomainRoutes
  def self.valid_subdomain?(subdomain)
    subdomain.to_s =~ /^([a-z0-9]|[a-z0-9][-a-z0-9]{0,61}[a-z0-9])*$/
  end

  # # Alternatively, we use URI::parse instead. This gives more lenient subdomains however:
  # def self.valid_subdomain?(subdomain)
  #   URI.parse "http://#{subdomain}.example.com"
  # rescue URI::InvalidURIError
  #   false
  # end
    
  module Validations
    module ClassMethods
      def validates_subdomain_format_of(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)
      
        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless SubdomainRoutes.valid_subdomain?(value)
            record.errors.add(attr_name, :not_a_valid_subdomain, :default => configuration[:message], :value => value) 
          end
        end
      end
      
      def validates_subdomain_not_reserved(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)
      
        validates_each(attr_names, configuration) do |record, attr_name, value|
          if ActionController::Routing::Routes.reserved_subdomains.include? value
            record.errors.add(attr_name, :is_a_reserved_subdomain, :default => configuration[:message], :value => value) 
          end
        end
      end
    end
  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.send :extend, SubdomainRoutes::Validations::ClassMethods
end