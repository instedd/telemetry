require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::TelemetryController do

  routes { InsteddTelemetry::Engine.routes }

  describe "settings update" do

    it "stores settings in database" do
      post :configuration_update, {telemetry_enabled: "true", admin_email: "foo@bar.com"}

      expect(Setting.get_bool(:disable_upload)).to eq(false)
      expect(Setting.get(:admin_email)).to eq("foo@bar.com")
    end

    it "redirects to root by defeault" do
      post :configuration_update, {telemetry_enabled: "true", admin_email: "foo@bar.com"}
      expect(response).to redirect_to("/")
    end

    it "redirects to specified url if present" do
      post :configuration_update, {
        telemetry_enabled: "true",
        redirect_url: "/previously_visited_page"
      }
      expect(response).to redirect_to("/previously_visited_page")
    end

    it "stores opt-out if user doesn't check input" do
      post :configuration_update, {admin_email: "foo@bar.com"}
      expect(Setting.get_bool(:disable_upload)).to eq(true)
    end

    it "allows the user not to send email" do
      post :configuration_update, {}
      expect(response).not_to be_error
      expect(Setting.get(:admin_email)).to be_nil
    end

    it "trims user email if present" do
      post :configuration_update, {admin_email: " foo@bar.com\t"}
      expect(Setting.get(:admin_email)).to eq("foo@bar.com")
    end

    it "doesn't allow to post settings more than once" do
      post :configuration_update, { telemetry_enabled: "true" }
      expect {
        post :configuration_update, { telemetry_enabled: "false" }
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
      post :configuration_update, {}

      expect {
        get :configuration
      }.to raise_error(ActionController::RoutingError)
    end

  end


end