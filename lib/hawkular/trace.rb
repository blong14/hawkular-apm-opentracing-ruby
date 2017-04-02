require 'hawkular/basic_utils'

module Hawkular

  class Node
    include Hawkular::BasicUtils

    attr_reader :span, :nodes, :type, :correlation_ids

    attr_writer :type

    def initialize(span, type, correlation_ids = [])
      @span = span
      @type = type
      @correlation_ids = correlation_ids
      @nodes = []
    end

    def add_correlation_id(correlation_id)
      @correlation_ids << correlation_id
    end

    def operation=(operation)
      @operation = operation
    end

    def operation
      return @operation if @operation.present?

      derive_operation(span)
    end

    def endpoint_type=(endpoint_type)
      @endpoint_type = endpoint_type
    end

    def endpoint_type
      return @endpoint_type if @endpoint_type.nil?

      derive_endpoint_type(span.tags)
    end

    def component_type
      return nil unless span.present?

      derive_component_type(span.tags)
    end

    def uri=(uri)
      @uri = uri
    end

    def uri
      return @uri if @uri.present?
      return nil unless span.present?

      derive_url(span.tags)
    end

    def timestamp=(timestamp)
      @timestamp = timestamp
    end

    def timestamp
      return @timestamp if @timestamp.present?
      return nil unless span.present?

      span.start_time
    end

    def duration
      return 0 unless span.present?

      span.duration
    end

    def properties
      return nil unless span.present?

      tags_to_properties(span.tags)
    end
  end

  class Trace

    attr_reader :nodes

    def initialize
      @nodes = []
    end

    def add_node(type, span, correlation_ids)
      node = find_node(span.parent_id)
      @nodes = node.nodes if node.present?

      @nodes << Node.new(span, type, correlation_ids)
    end

    def add_node_without_span(node, parent_id)
      parent_node = find_node(parent_id, parent_id)
      @nodes = parent_node.nodes if parent_node.present

      @nodes << node
    end

    def set_node_type(type, span, correlation_id)
      node = find_node(span.id)
      if node
        node.type = type
        node.add_correlation_id(correlation_id)
      end
    end

    def is_finished?(span)
      root_span = span
      while root_span.parent_id
        node = find_node(root_span.parent_id)
        if node.present?
          root_span = node.span
        else
          break
        end
      end

      root_node = find_node(root_span.id)

      finished_recur(root_node) ? root_node.span : nil
    end

    def find_node(span_id)
      find_node_dfs(nodes, span_id)
    end

    def node_position_id(span_id)
      find_node_position_dfs(nodes, span_id)
    end

    def trace_decorator=(decorator)
      @decorator = decorator
    end

    def from_span(span)
      trace = {
        trace_id: span.trace_id,
        fragment_id: span.id,
        transaction: span.tags.transaction,
        timestamp: span.start_time * 1000,
        nodes: nodes
      }

      trace_decorator(trace) if trace_decorator.present?

      trace
    end

    private

    def finished_recur(node)
      return nil if node.span.is_finished?

      nodes = node.nodes
      nodes.each do |_node|
        return nil if node.span.is_finished?
        return nil if !finished_recur(node)
      end

      node
    end

    def find_node_dfs(_nodes, span_id)
      return nil if _nodes.empty?

      _nodes.each do |node|
        return node if node.span && span_id == node.span.id

        ret = find_node_dfs(node.nodes)
        return ret if ret.present?
      end

      return nil
    end

    def find_node_position_dfs(_nodes, span_id)
      return nil if _nodes.empty?

      _nodes.each_with_index do |node, i|
        return i if span_id == node.span.id
        ret = find_node_position_dfs(node.nodes)

        return "#{i}:#{ret}" if ret.present?
      end

      nil
    end
  end

end
