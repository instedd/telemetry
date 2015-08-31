require 'spec_helper'

RSpec.describe 'shared/_warning.html.erb' do
  context 'not dismissed' do
    before :each do
      allow(InsteddTelemetry::Setting).to receive(:get).with(:dismissed).and_return(false)
    end

    it 'displays a warning if not dismissed' do
      render partial: 'shared/warning'

      expect(rendered).to match /warning/
    end

    it 'contains link to dismiss' do
      render partial: 'shared/warning'

      expect(rendered).to have_link 'Dismiss', href: instedd_telemetry.dismiss_path
    end

    it 'contains link to configure' do
      render partial: 'shared/warning'

      expect(rendered).to have_link 'Configure', href: instedd_telemetry.configure_path
    end
  end

  context 'dismissed' do
    before :each do
      allow(InsteddTelemetry::Setting).to receive(:get).with(:dismissed).and_return(true)
    end

    it 'doesnt display a warning if dismissed' do
      render partial: 'shared/warning'

      expect(rendered).to_not match /warning/
    end
  end
end
