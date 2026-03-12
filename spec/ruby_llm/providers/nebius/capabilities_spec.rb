# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::Nebius::Capabilities do
  describe '.context_window_for' do
    it 'returns the correct context window for known models' do
      expect(described_class.context_window_for('deepseek-ai/DeepSeek-R1-0528')).to eq(65_536)
      expect(described_class.context_window_for('deepseek-ai/DeepSeek-V3-0324')).to eq(128_000)
      expect(described_class.context_window_for('Qwen/Qwen3-235B-A22B-Instruct-2507')).to eq(262_144)
    end

    it 'returns a default for unknown models' do
      expect(described_class.context_window_for('unknown-model')).to eq(131_072)
    end
  end

  describe '.max_tokens_for' do
    it 'returns the correct max tokens for known models' do
      expect(described_class.max_tokens_for('deepseek-ai/DeepSeek-R1-0528')).to eq(32_768)
      expect(described_class.max_tokens_for('BAAI/bge-en-icl')).to eq(0)
      expect(described_class.max_tokens_for('meta-llama/Meta-Llama-3.1-8B-Instruct')).to eq(4_096)
    end
  end

  describe '.input_price_for' do
    it 'returns the correct input price' do
      expect(described_class.input_price_for('meta-llama/Meta-Llama-3.1-8B-Instruct')).to eq(0.02)
      expect(described_class.input_price_for('deepseek-ai/DeepSeek-R1-0528')).to eq(0.55)
    end
  end

  describe '.output_price_for' do
    it 'returns the correct output price' do
      expect(described_class.output_price_for('meta-llama/Meta-Llama-3.1-8B-Instruct')).to eq(0.06)
      expect(described_class.output_price_for('deepseek-ai/DeepSeek-R1-0528')).to eq(2.19)
    end
  end

  describe '.supports_functions?' do
    it 'returns true for chat models' do
      expect(described_class.supports_functions?('deepseek-ai/DeepSeek-V3-0324')).to be true
    end

    it 'returns false for embedding models' do
      expect(described_class.supports_functions?('BAAI/bge-en-icl')).to be false
    end
  end

  describe '.supports_vision?' do
    it 'returns true for VL models' do
      expect(described_class.supports_vision?('Qwen/Qwen2.5-VL-72B-Instruct')).to be true
    end

    it 'returns false for non-VL models' do
      expect(described_class.supports_vision?('deepseek-ai/DeepSeek-V3-0324')).to be false
    end
  end

  describe '.model_type' do
    it 'returns chat for chat models' do
      expect(described_class.model_type('deepseek-ai/DeepSeek-V3-0324')).to eq('chat')
    end

    it 'returns embedding for embedding models' do
      expect(described_class.model_type('BAAI/bge-en-icl')).to eq('embedding')
      expect(described_class.model_type('BAAI/bge-multilingual-gemma2')).to eq('embedding')
    end

    it 'detects unknown bge models as embedding' do
      expect(described_class.model_type('some-bge-model')).to eq('embedding')
    end
  end

  describe '.format_display_name' do
    it 'returns friendly display names for known models' do
      expect(described_class.format_display_name('deepseek-ai/DeepSeek-R1-0528')).to eq('DeepSeek R1 0528')
      expect(described_class.format_display_name('BAAI/bge-en-icl')).to eq('BGE EN ICL')
      model_id = 'meta-llama/Meta-Llama-3.1-8B-Instruct'
      expect(described_class.format_display_name(model_id)).to eq('Llama 3.1 8B Instruct')
    end
  end

  describe '.modalities_for' do
    it 'returns text modalities for chat models' do
      modalities = described_class.modalities_for('deepseek-ai/DeepSeek-V3-0324')
      expect(modalities).to eq(input: ['text'], output: ['text'])
    end

    it 'returns embedding modalities for embedding models' do
      modalities = described_class.modalities_for('BAAI/bge-en-icl')
      expect(modalities).to eq(input: ['text'], output: ['embeddings'])
    end

    it 'includes image input for VL models' do
      modalities = described_class.modalities_for('Qwen/Qwen2.5-VL-72B-Instruct')
      expect(modalities[:input]).to include('image')
    end
  end

  describe '.pricing_for' do
    it 'returns pricing structure' do
      pricing = described_class.pricing_for('deepseek-ai/DeepSeek-V3-0324')
      expect(pricing[:text_tokens][:standard][:input_per_million]).to eq(0.50)
      expect(pricing[:text_tokens][:standard][:output_per_million]).to eq(1.50)
    end

    it 'includes cache pricing when available' do
      pricing = described_class.pricing_for('deepseek-ai/DeepSeek-V3-0324')
      expect(pricing[:text_tokens][:standard][:cached_input_per_million]).to eq(0.05)
    end

    it 'omits cache pricing when not available' do
      pricing = described_class.pricing_for('deepseek-ai/DeepSeek-R1-0528')
      expect(pricing[:text_tokens][:standard]).not_to have_key(:cached_input_per_million)
    end
  end
end
