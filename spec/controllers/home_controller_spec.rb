require 'spec_helper'
require 'active_support/testing/setup_and_teardown'
include ActiveSupport::Testing::SetupAndTeardown
#include Devise::TestHelpers

describe HomeController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

end
