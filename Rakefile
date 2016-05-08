require 'rubygems'
require 'rake'
require 'yaml'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "subdomain_routes"
    gem.summary = %Q{A Rails library for incorporating subdomains into route generation and recognition.}
    gem.description = <<-EOF
      SubdomainRoutes add subdomain conditions to the Rails routing system. Routes may be restricted to
      one or many specified subdomains. An URL will be recognised only if the host subdomain matches the
      subdomain specified in the route. Route generation is also enhanced, so that the subdomain of a
      generated URL (or path) will be changed if the requested route has a different subdomain to that of
      the current request. Model-based subdomain routes can also be defined.
    EOF
    gem.email = "mdholling@gmail.com"
    gem.homepage = "http://github.com/mholling/subdomain_routes"
    gem.authors = ["Matthew Hollingworth"]
    gem.add_dependency 'actionpack', ">= 2.3.9"
    gem.has_rdoc = false

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "subdomain_routes #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

