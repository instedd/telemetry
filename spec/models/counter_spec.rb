require 'spec_helper'
include InsteddTelemetry

describe InsteddTelemetry::Counter do
  include_examples 'hashed key attributes'
end
