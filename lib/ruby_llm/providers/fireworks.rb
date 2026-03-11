# frozen_string_literal: true

module RubyLLM
  module Providers
    # Fireworks AI API integration.
    class Fireworks < OpenAI
      include Fireworks::Chat

      def api_base
        @config.fireworks_api_base || 'https://api.fireworks.ai/inference/v1'
      end

      def headers
        {
          'Authorization' => "Bearer #{@config.fireworks_api_key}"
        }
      end

      class << self
        def capabilities
          Fireworks::Capabilities
        end

        def configuration_options
          %i[fireworks_api_key fireworks_api_base]
        end

        def configuration_requirements
          %i[fireworks_api_key]
        end
      end
    end
  end
end
