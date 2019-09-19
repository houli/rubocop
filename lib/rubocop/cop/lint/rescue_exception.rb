# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks targeting the Exception class.
      #
      # @example
      #
      #   # bad
      #
      #   begin
      #     do_something
      #   rescue Exception
      #     handle_exception
      #   end
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   rescue ArgumentError
      #     handle_exception
      #   end
      class RescueException < Cop
        MSG = 'Avoid rescuing the `Exception` class. ' \
              'Perhaps you meant to rescue `StandardError`?'

        def on_resbody(node)
          return unless node.children.first

          rescue_args = node.children.first.children
          return unless rescue_args.any? { |a| targets_exception?(a) }

          exception_variable_name = node&.exception_variable&.children&.first
          return if node.body &&
                    calls_raise?(node.body, exception_variable_name)

          add_offense(node)
        end

        def targets_exception?(rescue_arg_node)
          rescue_arg_node.const_name == 'Exception'
        end

        def_node_matcher :kernel_constant?, <<-PATTERN
          (const {nil? cbase} :Kernel)
        PATTERN

        def_node_search :raise_call_with_no_params?, <<-PATTERN
          (send {nil? #kernel_constant?} :raise)
        PATTERN

        def_node_search :raise_call_with_correct_param?, <<-PATTERN
          (send {nil? #kernel_constant?} :raise (lvar %) ...)
        PATTERN

        def calls_raise?(body_node, exception_variable_name)
          raise_call_with_no_params?(body_node) ||
            raise_call_with_correct_param?(body_node, exception_variable_name)
        end
      end
    end
  end
end
