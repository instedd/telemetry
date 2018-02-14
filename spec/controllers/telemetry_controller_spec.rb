require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::TelemetryController do

  routes { InsteddTelemetry::Engine.routes }

  describe "settings update" do
    before(:each) do
      allow(InsteddTelemetry.api).to receive(:update_installation)
    end

    it "stores settings in database" do
      post :configuration_update, params: {opt_in: "true", admin_email: "foo@bar.com"}

      expect(Setting.get_bool(:disable_upload)).to eq(false)
      expect(Setting.get(:admin_email)).to eq("foo@bar.com")
    end

    it "redirects to root by defeault" do
      post :configuration_update, params: {opt_in: "true", admin_email: "foo@bar.com"}
      expect(response).to redirect_to("/")
    end

    it "redirects to specified url if present" do
      post :configuration_update, params: {
        opt_in: "true",
        redirect_url: "/previously_visited_page"
      }
      expect(response).to redirect_to("/previously_visited_page")
    end

    it "stores opt-out if user doesn't check input" do
      post :configuration_update, params: {admin_email: "foo@bar.com"}
      expect(Setting.get_bool(:disable_upload)).to eq(true)
    end

    it "allows the user not to send email" do
      post :configuration_update, params: {}
      expect(response).not_to be_error
      expect(Setting.get(:admin_email)).to be_nil
    end

    it "trims user email if present" do
      post :configuration_update, params: {admin_email: " foo@bar.com\t"}
      expect(Setting.get(:admin_email)).to eq("foo@bar.com")
    end

    it "doesn't allow to post settings more than once" do
      post :configuration_update, params: { opt_in: "true" }
      expect {
        post :configuration_update, params: { opt_in: "false" }
      }.to raise_error(ActionController::RoutingError)

      expect(Setting.get_bool(:disable_upload)).to eq(false)
    end

  end

  describe "access to settings page" do

    it "allows to access settings the first time" do
      get :configuration
      expect(response).to be_successful
    end


    it "doesn't allow to access settings if user has already set them" do
      allow(InsteddTelemetry.api).to receive(:update_installation)

      post :configuration_update, params: {}

      expect {
        get :configuration
      }.to raise_error(ActionController::RoutingError)
    end

  end

  describe "dismissing banner" do

    before :each do
      allow(InsteddTelemetry.api).to receive(:update_installation)
    end

    it "stores setting" do
      get :dismiss
      expect(Setting.get_bool(:dismissed)).to be_truthy
    end

    it "redirects to root by defeault" do
      get :dismiss
      expect(response).to redirect_to("/")
    end

    it "redirects to specified url if present" do
      get :dismiss, params: { redirect_url: "/foo" }
      expect(response).to redirect_to("/foo")
    end

    it "updates the installation" do
      expect(InsteddTelemetry.api).to receive(:update_installation).with(application: InsteddTelemetry.application)

      get :dismiss
    end

  end

  describe "update installation" do
    let(:api) { double('api')}

    before :each do
      allow(InsteddTelemetry).to receive(:api).and_return(api)
    end

    it "updates installation with opt-out if checkbox disabled" do
      expect(api).to receive(:update_installation).with(application: InsteddTelemetry.application, opt_out: "true")

      post :configuration_update
    end

    it "updates installation with admin email if set" do
      expect(api).to receive(:update_installation).with(application: InsteddTelemetry.application, admin_email: 'foo@bar.com', opt_out: "true")

      post :configuration_update, params: { admin_email: 'foo@bar.com' }
    end

    it "updates installation without admin email if not set" do
      expect(api).to receive(:update_installation).with(application: InsteddTelemetry.application, opt_out: "false")

      post :configuration_update, params: { opt_in: "true" }
    end
  end

end
