require 'spec_helper'

describe InsteddTelemetry::Util do

  describe 'country code' do
    it 'returns country code' do
      expect(InsteddTelemetry::Util.country_code('54 11 4444 5555')).to eq('54')
      expect(InsteddTelemetry::Util.country_code('855 23 686 0360')).to eq('855')
    end

    it 'fails if number is invalid' do
      expect(InsteddTelemetry::Util.country_code('123')).to be_nil
    end

    it 'fails if number does not include country code' do
      expect(InsteddTelemetry::Util.country_code('11 4444 5555')).to be_nil
      expect(InsteddTelemetry::Util.country_code('23 686 0360')).to be_nil
    end
  end

end
