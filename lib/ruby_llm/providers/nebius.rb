# frozen_string_literal: true

module RubyLLM
  module Providers
    # Nebius AI API integration.
    class Nebius < OpenAI
      include Nebius::Chat

      def api_base
        @config.nebius_api_base || 'https://api.tokenfactory.nebius.com/v1'
      end

      def headers
        {
          'Authorization' => "Bearer #{@config.nebius_api_key}"
        }
      end

      class << self
        def capabilities
          Nebius::Capabilities
        end

        def configuration_options
          %i[nebius_api_key nebius_api_base]
        end

        def configuration_requirements
          %i[nebius_api_key]
        end
      end
    end
  end
end
