RSpec.shared_examples 'hashed key attributes' do
  it 'hashes key attributes on create' do
    record = described_class.create! key_attributes: '{foo: 1}'
    expect(record.key_attributes_hash).to eq(Digest::SHA256.hexdigest('{foo: 1}'))
  end
end
