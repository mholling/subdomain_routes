module SubdomainRoutes
  module Routing
    module RouteSet
      include SplitHost
      
      def self.included(base)
        [ :extract_request_environment, :add_route, :raise_named_route_error ].each { |method| base.alias_method_chain method, :subdomains }
      end
      
      def extract_request_environment_with_subdomains(request)
        extract_request_environment_without_subdomains(request).merge(:subdomain => subdomain_for_host(request.host))
      end
      
      def add_route_with_subdomains(*args)
        options = args.extract_options!
        if subdomains = options.delete(:subdomains)
          options[:conditions] ||= {}
          options[:requirements] ||= {}
          options[:conditions][:subdomains] = subdomains
          options[:requirements][:subdomains] = subdomains
        end
        with_options(options) { |routes| routes.add_route_without_subdomains(*args) }
      end

      def raise_named_route_error_with_subdomains(options, named_route, named_route_name)
        unless named_route.conditions[:subdomains].is_a?(Symbol)
          raise_named_route_error_without_subdomains(options, named_route, named_route_name)
        else
          begin
            options.delete(named_route.conditions[:subdomains])
            raise_named_route_error_without_subdomains(options, named_route, named_route_name)
          rescue ActionController::RoutingError => e
            e.message << " You may also need to specify #{named_route.conditions[:subdomains].inspect} for the subdomain."
            raise e
          end
        end
      end
      
      def reserved_subdomains
        routes.map(&:reserved_subdomains).flatten.uniq
      end
    end
  
    module Route
      def self.included(base)
        [ :recognition_conditions, :generation_extraction, :segment_keys, :significant_keys, :recognition_extraction ].each { |method| base.alias_method_chain method, :subdomains }
      end
      
      def recognition_conditions_with_subdomains
        recognition_conditions_without_subdomains.tap do |result|
          case conditions[:subdomains]
          when Array
            result << "conditions[:subdomains].include?(env[:subdomain])"
          when Symbol
            result << "(subdomain = env[:subdomain] unless env[:subdomain].blank?)"
          end
        end
      end
      
      def generation_extraction_with_subdomains
        results = [ generation_extraction_without_subdomains ]
        if conditions[:subdomains].is_a?(Symbol)
          results << "return [nil,nil] unless hash.delete(#{conditions[:subdomains].inspect})"
        end
        results.compact * "\n"
      end
                  
      def segment_keys_with_subdomains
        segment_keys_without_subdomains.tap do |result|
          result.unshift(conditions[:subdomains]) if conditions[:subdomains].is_a? Symbol
        end
      end
      
      def significant_keys_with_subdomains
        significant_keys_without_subdomains.tap do |result|
          if conditions[:subdomains].is_a? Symbol
            result << conditions[:subdomains]
            result.uniq!
          end
        end
      end
      
      def recognition_extraction_with_subdomains
        recognition_extraction_without_subdomains.tap do |result|
          result.unshift "\nparams[#{conditions[:subdomains].inspect}] = subdomain\n" if conditions[:subdomains].is_a? Symbol
        end
      end
      
      def reserved_subdomains
        conditions[:subdomains].is_a?(Array) ? conditions[:subdomains] : []
      end
    end
  end
end

ActionController::Routing::RouteSet.send :include, SubdomainRoutes::Routing::RouteSet
ActionController::Routing::Route.send :include, SubdomainRoutes::Routing::Route
