require 'spec'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
gem 'activesupport', '>= 2.3.9'
gem 'actionpack', '>= 2.3.9'
gem 'activerecord', '>= 2.3.9'
gem 'actionmailer', '>= 2.3.9'

require 'active_support'
require 'action_controller'
require 'active_record' # only required for testing optional features, not required by the gem
require 'action_mailer' # only required for testing optional features, not required by the gem

require 'subdomain_routes'

require 'action_controller/test_process'
require 'action_view/test_case'
require 'test_unit_matcher'

ActiveSupport::OptionMerger.send(:define_method, :options) { @options }


Spec::Runner.configure do |config|
  config.before(:each) do
    ActionController::Routing::Routes.clear!
    SubdomainRoutes::Config.stub!(:domain_length).and_return(2)
  end
  config.include(SubdomainRoutes::TestUnitMatcher)
end

def map_subdomain(*subdomains, &block)
  ActionController::Routing::Routes.draw do |map|
    map.subdomain(*subdomains, &block)
  end
end

def recognize_path(request)
  ActionController::Routing::Routes.recognize_path(request.path, ActionController::Routing::Routes.extract_request_environment(request))
end

def in_controller_with_host(host, options = {}, &block)
  spec = self
  Class.new(ActionView::TestCase::TestController) do
    include Spec::Matchers
  end.new.instance_eval do
    request.host = host
    request.instance_eval do
      @env.merge! 'HTTPS' => 'on','SERVER_PORT' => 443 if options[:protocol] =~ /^https(:\/\/)?$/
      @env.merge! 'SERVER_PORT'=> options[:port] if options[:port]
    end
    copy_instance_variables_from(spec)
    instance_eval(&block)
  end
end

def in_object_with_host(host, options = {}, &block)
  spec = self
  Class.new do
    include Spec::Matchers
    include ActionController::UrlWriter
  end.new.instance_eval do
    self.class.default_url_options = { :host => host }
    self.class.default_url_options.merge! options.slice(:port, :protocol)
    copy_instance_variables_from(spec)
    instance_eval(&block)
  end
end

def with_host(host, options = {}, &block)
  in_controller_with_host(host, options.dup, &block)
  in_object_with_host(host, options.dup, &block)
end

ActiveRecord::Base.class_eval do
  alias_method :save, :valid?
  def self.columns() @columns ||= []; end
  
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type, null)
  end
end
