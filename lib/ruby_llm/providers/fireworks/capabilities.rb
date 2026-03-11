# frozen_string_literal: true

module RubyLLM
  module Providers
    class Fireworks
      # Determines capabilities and pricing for Fireworks AI models
      module Capabilities
        module_function

        def context_window_for(model_id)
          MODELS.dig(normalize(model_id), :context_window) || 131_072
        end

        def max_tokens_for(model_id)
          MODELS.dig(normalize(model_id), :max_tokens) || 32_768
        end

        def input_price_for(model_id)
          MODELS.dig(normalize(model_id), :input_price) || 0.56
        end

        def output_price_for(model_id)
          MODELS.dig(normalize(model_id), :output_price) || 1.68
        end

        def cache_hit_price_for(model_id)
          MODELS.dig(normalize(model_id), :cache_read_price)
        end

        def supports_vision?(model_id)
          normalize(model_id) == 'kimi-k2p5'
        end

        def supports_functions?(_model_id)
          true
        end

        def supports_tool_choice?(_model_id)
          true
        end

        def supports_tool_parallel_control?(_model_id)
          false
        end

        def supports_json_mode?(_model_id)
          false
        end

        def format_display_name(model_id)
          MODELS.dig(normalize(model_id), :display_name) || model_id.split('/').last
                                                                     .split('-')
                                                                     .map(&:capitalize)
                                                                     .join(' ')
        end

        def model_type(_model_id)
          'chat'
        end

        def model_family(model_id)
          MODELS.dig(normalize(model_id), :family) || 'fireworks'
        end

        def modalities_for(model_id)
          if supports_vision?(model_id)
            { input: %w[text image video], output: ['text'] }
          else
            { input: ['text'], output: ['text'] }
          end
        end

        def capabilities_for(model_id)
          caps = %w[streaming function_calling]
          caps << 'vision' if supports_vision?(model_id)
          caps
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

        MODELS = {
          'deepseek-v3p1' => {
            display_name: 'DeepSeek V3.1',
            family: 'deepseek',
            context_window: 163_840,
            max_tokens: 163_840,
            input_price: 0.56,
            output_price: 1.68
          },
          'deepseek-v3p2' => {
            display_name: 'DeepSeek V3.2',
            family: 'deepseek',
            context_window: 160_000,
            max_tokens: 160_000,
            input_price: 0.56,
            output_price: 1.68,
            cache_read_price: 0.28
          },
          'glm-4p5-air' => {
            display_name: 'GLM 4.5 Air',
            family: 'glm',
            context_window: 131_072,
            max_tokens: 131_072,
            input_price: 0.22,
            output_price: 0.88
          },
          'glm-4p5' => {
            display_name: 'GLM 4.5',
            family: 'glm',
            context_window: 131_072,
            max_tokens: 131_072,
            input_price: 0.55,
            output_price: 2.19
          },
          'glm-4p7' => {
            display_name: 'GLM 4.7',
            family: 'glm',
            context_window: 198_000,
            max_tokens: 198_000,
            input_price: 0.60,
            output_price: 2.20,
            cache_read_price: 0.30
          },
          'glm-5' => {
            display_name: 'GLM 5',
            family: 'glm',
            context_window: 202_752,
            max_tokens: 131_072,
            input_price: 1.00,
            output_price: 3.20,
            cache_read_price: 0.50
          },
          'gpt-oss-120b' => {
            display_name: 'GPT OSS 120B',
            family: 'gpt-oss',
            context_window: 131_072,
            max_tokens: 32_768,
            input_price: 0.15,
            output_price: 0.60
          },
          'gpt-oss-20b' => {
            display_name: 'GPT OSS 20B',
            family: 'gpt-oss',
            context_window: 131_072,
            max_tokens: 32_768,
            input_price: 0.05,
            output_price: 0.20
          },
          'kimi-k2-instruct' => {
            display_name: 'Kimi K2 Instruct',
            family: 'kimi',
            context_window: 128_000,
            max_tokens: 16_384,
            input_price: 1.00,
            output_price: 3.00
          },
          'kimi-k2-thinking' => {
            display_name: 'Kimi K2 Thinking',
            family: 'kimi',
            context_window: 256_000,
            max_tokens: 256_000,
            input_price: 0.60,
            output_price: 2.50,
            cache_read_price: 0.30
          },
          'kimi-k2p5' => {
            display_name: 'Kimi K2.5',
            family: 'kimi',
            context_window: 256_000,
            max_tokens: 256_000,
            input_price: 0.60,
            output_price: 3.00,
            cache_read_price: 0.10
          },
          'minimax-m2p1' => {
            display_name: 'MiniMax M2.1',
            family: 'minimax',
            context_window: 200_000,
            max_tokens: 200_000,
            input_price: 0.30,
            output_price: 1.20,
            cache_read_price: 0.03
          },
          'minimax-m2p5' => {
            display_name: 'MiniMax M2.5',
            family: 'minimax',
            context_window: 196_608,
            max_tokens: 196_608,
            input_price: 0.30,
            output_price: 1.20,
            cache_read_price: 0.03
          }
        }.freeze
      end
    end
  end
end
