describe "ActiveRecord::Base" do
  before(:each) do
    class User < ActiveRecord::Base
      attr_accessor :subdomain
    end
  end

  it "should have validates_subdomain_format_of which runs SubdomainRoutes.valid_subdomain? against the attributes" do
    User.validates_subdomain_format_of :subdomain
    SubdomainRoutes.should_receive(:valid_subdomain?).with("mholling").and_return(true)
    User.new(:subdomain => "mholling").should be_valid
    SubdomainRoutes.should_receive(:valid_subdomain?).with("mholling").and_return(nil)
    User.new(:subdomain => "mholling").should_not be_valid
  end
  
  it "should have validates_subdomain_not_reserved which checks the attributes against the fixed-subdomain routes" do
    User.validates_subdomain_not_reserved :subdomain
    reserved = [ "", "www", "support", "admin" ]
    map_subdomain(*reserved) { |map| map.resource :home }
    reserved.each do |subdomain|
      User.new(:subdomain => subdomain).should_not be_valid
    end
    [ "mholling", "edmondst", "2girls1cup" ].each do |subdomain|
      User.new(:subdomain => subdomain).should be_valid
    end
  end
end
