require 'spec_helper'

describe WidgetsController do

  describe "GET 'main-bar'" do
    it "should be successful" do
      get 'main-bar'
      response.should be_success
    end
  end

end
