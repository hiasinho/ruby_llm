# frozen_string_literal: true

module RubyLLM
  module Providers
    class Nebius
      # Chat methods of the Nebius AI API integration
      module Chat
        module_function

        def format_role(role)
          role.to_s
        end
      end
    end
  end
end
