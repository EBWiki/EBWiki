require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application  
  end

  describe "throttle excessive requests by IP address" do
    let(:limit) { 20 }

    context "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do
          get "/", {}, "REMOTE_ADDR" => "1.2.3.4"
          last_response.status.should_not be(429)
        end
      end
    end

    context "number of requests is higher than the limit" do
      it "changes the request status 429" do
        (limit * 2).times do |i|
          get "/", {}, "REMOTE_ADDR" => "1.2.3.5"
          last_response.status.should be(429) if i > limit
        end
      end
    end

  end

  describe "throttle excessive POST requests to sign in by IP address" do
    let(:limit) { 5 }

    context "number of requests is lower than the limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", { email: "rack_attack_example3#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.6"
          last_response.status.should_not be(429)
        end
      end
    end

    context "number of requests is higher than the limit" do
      it "changes the request status to 429" do
        (limit*2).times do |i|
          post "/users/sign_in", { email: "rack_attack_example4#{i}@gmail.com" }, "REMOTE_ADDR" => "1.2.3.7"
          last_response.status.should be(429) if i > limit
        end
      end
    end

  end

  describe "throttle excessive POST requests to sign in by email address" do
    let(:limit) { 5 }

    context "number of requests is lower than limit" do
      it "does not change the request status" do
        limit.times do |i|
          post "/users/sign_in", { email: "rack_attack_example5@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.8"
          last_response.status.should_not be(429)
        end
      end
    end

    context "number of requests is higher than the limit" do
      it "changes the request status to 429" do
        (limit*2).times do |i|
          post "/users/sign_in", { email: "rack_attack_example6@gmail.com" }, "REMOTE_ADDR" => "#{i}.2.3.9"
          last_response.status.should be(429) if i > limit
        end
      end
    end

  end

end

