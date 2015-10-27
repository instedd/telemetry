require 'spec_helper'

describe InsteddTelemetry::StatCollectors::Utils do

  let(:subject) do
    o = Object.new
    o.extend(InsteddTelemetry::StatCollectors::Utils)
    o
  end

  it 'buils a simple counter' do
    expect(subject.simple_counter('a metric', {foo: 'bar'}, 17)).to eq({
      counters: [
        {
          metric: 'a metric',
          key: {foo: 'bar'},
          value: 17
        }
      ]
    })
  end

end
