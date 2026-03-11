# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::Fireworks::Capabilities do
  describe '.context_window_for' do
    it 'returns the correct context window for known models' do
      expect(described_class.context_window_for('accounts/fireworks/models/deepseek-v3p1')).to eq(163_840)
      expect(described_class.context_window_for('accounts/fireworks/models/kimi-k2p5')).to eq(256_000)
      expect(described_class.context_window_for('accounts/fireworks/models/gpt-oss-20b')).to eq(131_072)
    end

    it 'returns a default for unknown models' do
      expect(described_class.context_window_for('accounts/fireworks/models/unknown')).to eq(131_072)
    end
  end

  describe '.max_tokens_for' do
    it 'returns the correct max tokens for known models' do
      expect(described_class.max_tokens_for('accounts/fireworks/models/glm-5')).to eq(131_072)
      expect(described_class.max_tokens_for('accounts/fireworks/models/gpt-oss-120b')).to eq(32_768)
      expect(described_class.max_tokens_for('accounts/fireworks/models/kimi-k2-instruct')).to eq(16_384)
    end
  end

  describe '.input_price_for' do
    it 'returns the correct input price' do
      expect(described_class.input_price_for('accounts/fireworks/models/gpt-oss-20b')).to eq(0.05)
      expect(described_class.input_price_for('accounts/fireworks/models/glm-5')).to eq(1.00)
    end
  end

  describe '.output_price_for' do
    it 'returns the correct output price' do
      expect(described_class.output_price_for('accounts/fireworks/models/gpt-oss-20b')).to eq(0.20)
      expect(described_class.output_price_for('accounts/fireworks/models/glm-5')).to eq(3.20)
    end
  end

  describe '.supports_vision?' do
    it 'returns true only for kimi-k2p5' do
      expect(described_class.supports_vision?('accounts/fireworks/models/kimi-k2p5')).to be true
      expect(described_class.supports_vision?('accounts/fireworks/models/deepseek-v3p1')).to be false
    end
  end

  describe '.supports_functions?' do
    it 'returns true for all models' do
      expect(described_class.supports_functions?('accounts/fireworks/models/deepseek-v3p1')).to be true
      expect(described_class.supports_functions?('accounts/fireworks/models/gpt-oss-20b')).to be true
    end
  end

  describe '.format_display_name' do
    it 'returns friendly display names for known models' do
      expect(described_class.format_display_name('accounts/fireworks/models/deepseek-v3p1')).to eq('DeepSeek V3.1')
      expect(described_class.format_display_name('accounts/fireworks/models/kimi-k2p5')).to eq('Kimi K2.5')
      expect(described_class.format_display_name('accounts/fireworks/models/minimax-m2p5')).to eq('MiniMax M2.5')
    end
  end

  describe '.modalities_for' do
    it 'includes vision for kimi-k2p5' do
      modalities = described_class.modalities_for('accounts/fireworks/models/kimi-k2p5')
      expect(modalities[:input]).to include('image', 'video')
    end

    it 'is text-only for most models' do
      modalities = described_class.modalities_for('accounts/fireworks/models/deepseek-v3p1')
      expect(modalities).to eq(input: ['text'], output: ['text'])
    end
  end

  describe '.pricing_for' do
    it 'includes cache pricing when available' do
      pricing = described_class.pricing_for('accounts/fireworks/models/deepseek-v3p2')
      expect(pricing[:text_tokens][:standard][:cached_input_per_million]).to eq(0.28)
    end

    it 'omits cache pricing when not available' do
      pricing = described_class.pricing_for('accounts/fireworks/models/deepseek-v3p1')
      expect(pricing[:text_tokens][:standard]).not_to have_key(:cached_input_per_million)
    end
  end
end
