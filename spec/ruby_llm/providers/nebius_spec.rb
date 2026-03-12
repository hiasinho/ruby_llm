# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::Nebius do
  subject(:provider) { described_class.new(config) }

  let(:config) do
    instance_double(
      RubyLLM::Configuration,
      request_timeout: 300,
      max_retries: 3,
      retry_interval: 0.1,
      retry_interval_randomness: 0.5,
      retry_backoff_factor: 2,
      http_proxy: nil,
      nebius_api_key: 'test-key',
      nebius_api_base: nebius_api_base
    )
  end

  describe '#api_base' do
    context 'when nebius_api_base is not set' do
      let(:nebius_api_base) { nil }

      it 'returns the default Nebius AI API URL' do
        expect(provider.api_base).to eq('https://api.tokenfactory.nebius.com/v1')
      end
    end

    context 'when nebius_api_base is set' do
      let(:nebius_api_base) { 'https://custom-nebius-endpoint.example.com' }

      it 'returns the custom API URL' do
        expect(provider.api_base).to eq('https://custom-nebius-endpoint.example.com')
      end
    end
  end

  describe '#headers' do
    let(:nebius_api_base) { nil }

    it 'includes the authorization header' do
      expect(provider.headers).to eq('Authorization' => 'Bearer test-key')
    end
  end

  describe '.capabilities' do
    it 'returns the Nebius capabilities module' do
      expect(described_class.capabilities).to eq(RubyLLM::Providers::Nebius::Capabilities)
    end
  end

  describe '.configuration_options' do
    it 'returns nebius config keys' do
      expect(described_class.configuration_options).to eq(%i[nebius_api_key nebius_api_base])
    end
  end

  describe '.configuration_requirements' do
    it 'requires the API key' do
      expect(described_class.configuration_requirements).to eq(%i[nebius_api_key])
    end
  end
end
