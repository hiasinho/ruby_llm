# frozen_string_literal: true

module RubyLLM
  module Providers
    class Nebius
      # Determines capabilities and pricing for Nebius AI models
      module Capabilities
        module_function

        def context_window_for(model_id)
          MODELS.dig(normalize(model_id), :context_window) || 131_072
        end

        def max_tokens_for(model_id)
          MODELS.dig(normalize(model_id), :max_tokens) || 32_768
        end

        def input_price_for(model_id)
          MODELS.dig(normalize(model_id), :input_price) || 0.50
        end

        def output_price_for(model_id)
          MODELS.dig(normalize(model_id), :output_price) || 1.50
        end

        def cache_hit_price_for(model_id)
          MODELS.dig(normalize(model_id), :cache_read_price)
        end

        def supports_vision?(model_id)
          MODELS.dig(normalize(model_id), :vision) || normalize(model_id).match?(/\bVL\b/i)
        end

        def supports_functions?(model_id)
          model_type(model_id) != 'embedding'
        end

        def supports_tool_choice?(model_id)
          model_type(model_id) != 'embedding'
        end

        def supports_tool_parallel_control?(_model_id)
          false
        end

        def supports_json_mode?(_model_id)
          false
        end

        def format_display_name(model_id)
          MODELS.dig(normalize(model_id), :display_name) || normalize(model_id)
        end

        def model_type(model_id)
          MODELS.dig(normalize(model_id), :type) || (embedding_model?(model_id) ? 'embedding' : 'chat')
        end

        def model_family(model_id)
          MODELS.dig(normalize(model_id), :family) || 'nebius'
        end

        def modalities_for(model_id)
          if model_type(model_id) == 'embedding'
            { input: ['text'], output: ['embeddings'] }
          elsif supports_vision?(model_id)
            { input: %w[text image], output: ['text'] }
          else
            { input: ['text'], output: ['text'] }
          end
        end

        def capabilities_for(model_id)
          if model_type(model_id) == 'embedding'
            []
          else
            caps = %w[streaming function_calling]
            caps << 'vision' if supports_vision?(model_id)
            caps
          end
        end

        def pricing_for(model_id)
          standard = {
            input_per_million: input_price_for(model_id),
            output_per_million: output_price_for(model_id)
          }

          cache_price = cache_hit_price_for(model_id)
          standard[:cached_input_per_million] = cache_price if cache_price

          { text_tokens: { standard: standard } }
        end

        def normalize(model_id)
          model_id.split('/').last
        end

        def embedding_model?(model_id)
          normalized = normalize(model_id)
          normalized.match?(/\bbge\b/i) || normalized.match?(/\bembed/i)
        end

        # Known models with capabilities and pricing not available from models.dev
        # Model IDs are normalized (last segment after '/')
        MODELS = {
          'DeepSeek-R1-0528' => {
            display_name: 'DeepSeek R1 0528',
            family: 'deepseek',
            type: 'chat',
            context_window: 65_536,
            max_tokens: 32_768,
            input_price: 0.55,
            output_price: 2.19
          },
          'DeepSeek-R1-0528-fast' => {
            display_name: 'DeepSeek R1 0528 Fast',
            family: 'deepseek',
            type: 'chat',
            context_window: 65_536,
            max_tokens: 32_768,
            input_price: 0.55,
            output_price: 2.19
          },
          'DeepSeek-V3-0324' => {
            display_name: 'DeepSeek V3 0324',
            family: 'deepseek',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 8_192,
            input_price: 0.50,
            output_price: 1.50,
            cache_read_price: 0.05
          },
          'DeepSeek-V3-0324-fast' => {
            display_name: 'DeepSeek V3 0324 Fast',
            family: 'deepseek',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 8_192,
            input_price: 0.50,
            output_price: 1.50
          },
          'DeepSeek-V3.2' => {
            display_name: 'DeepSeek V3.2',
            family: 'deepseek',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 8_192,
            input_price: 0.30,
            output_price: 0.90
          },
          'Meta-Llama-3.1-8B-Instruct' => {
            display_name: 'Llama 3.1 8B Instruct',
            family: 'llama',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 4_096,
            input_price: 0.02,
            output_price: 0.06,
            cache_read_price: 0.002
          },
          'Meta-Llama-3.1-8B-Instruct-fast' => {
            display_name: 'Llama 3.1 8B Instruct Fast',
            family: 'llama',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 4_096,
            input_price: 0.02,
            output_price: 0.06
          },
          'Llama-3.3-70B-Instruct' => {
            display_name: 'Llama 3.3 70B Instruct',
            family: 'llama',
            type: 'chat',
            context_window: 128_000,
            max_tokens: 4_096,
            input_price: 0.18,
            output_price: 0.18
          },
          'Qwen3-235B-A22B-Instruct-2507' => {
            display_name: 'Qwen3 235B A22B Instruct',
            family: 'qwen',
            type: 'chat',
            context_window: 262_144,
            max_tokens: 8_192,
            input_price: 0.20,
            output_price: 0.60
          },
          'Qwen3-32B' => {
            display_name: 'Qwen3 32B',
            family: 'qwen',
            type: 'chat',
            context_window: 131_072,
            max_tokens: 8_192,
            input_price: 0.10,
            output_price: 0.30
          },
          'Qwen2.5-VL-72B-Instruct' => {
            display_name: 'Qwen 2.5 VL 72B Instruct',
            family: 'qwen',
            type: 'chat',
            context_window: 32_768,
            max_tokens: 8_192,
            input_price: 0.35,
            output_price: 0.40
          },
          'Kimi-K2-Instruct' => {
            display_name: 'Kimi K2 Instruct',
            family: 'kimi',
            type: 'chat',
            context_window: 131_072,
            max_tokens: 8_192,
            input_price: 0.60,
            output_price: 2.00
          },
          'Kimi-K2-Thinking' => {
            display_name: 'Kimi K2 Thinking',
            family: 'kimi',
            type: 'chat',
            context_window: 131_072,
            max_tokens: 8_192,
            input_price: 0.60,
            output_price: 2.00
          },
          'Kimi-K2.5' => {
            display_name: 'Kimi K2.5',
            family: 'kimi',
            type: 'chat',
            vision: true,
            context_window: 262_144,
            max_tokens: 8_192,
            input_price: 0.50,
            output_price: 2.50,
            cache_read_price: 0.05
          },
          'bge-en-icl' => {
            display_name: 'BGE EN ICL',
            family: 'bge',
            type: 'embedding',
            context_window: 32_768,
            max_tokens: 0,
            input_price: 0.01,
            output_price: 0.0
          },
          'bge-multilingual-gemma2' => {
            display_name: 'BGE Multilingual Gemma2',
            family: 'bge',
            type: 'embedding',
            context_window: 8_192,
            max_tokens: 0,
            input_price: 0.01,
            output_price: 0.0
          },
          'Qwen3-Embedding-8B' => {
            display_name: 'Qwen3 Embedding 8B',
            family: 'qwen',
            type: 'embedding',
            context_window: 32_768,
            max_tokens: 0,
            input_price: 0.01,
            output_price: 0.0
          },
          'e5-mistral-7b-instruct' => {
            display_name: 'E5 Mistral 7B Instruct',
            family: 'e5',
            type: 'embedding',
            context_window: 32_768,
            max_tokens: 0,
            input_price: 0.01,
            output_price: 0.0
          }
        }.freeze
      end
    end
  end
end
