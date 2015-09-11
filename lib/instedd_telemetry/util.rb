module InsteddTelemetry::Util
  def self.country_code(number)
    number = number.starts_with?('+') ? number : "+#{number}"
    number = GlobalPhone.parse(number)
    number && number.valid? ? number.country_code : nil
  end
end
