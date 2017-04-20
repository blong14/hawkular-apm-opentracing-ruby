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
      return @operation unless @operation.nil?

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
      return nil if span.nil?

      derive_component_type(span.tags)
    end

    def uri=(uri)
      @uri = uri
    end

    def uri
      return @uri unless @uri.nil?
      return nil if span.nil?

      derive_url(span.tags)
    end

    def timestamp=(timestamp)
      @timestamp = timestamp
    end

    def timestamp
      return @timestamp unless @timestamp.nil?
      return nil if span.nil?

      span.start_time
    end

    def duration
      return 0 if span.nil?

      span.duration
    end

    def properties
      return nil if span.nil?

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
      @nodes = node.nodes unless node.nil?

      @nodes << Node.new(span, type, correlation_ids)
    end

    def add_node_without_span(node, parent_id)
      parent_node = find_node(parent_id)
      @nodes = parent_node.nodes unless parent_node.nil?

      @nodes << node
    end

    def set_node_type(type, span, correlation_id)
      node = find_node(span.id)
      if node
        node.type = type
        node.add_correlation_id(correlation_id)
      end
    end

    # TODO: has to be a better name for this method
    # Tried to implement with a ? to signify a boolean
    # return value but instead we return a span?
    def is_finished(span)
      root_span = span
      while root_span.parent_id
        node = find_node(root_span.parent_id)
        if !node.nil?
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

      trace_decorator(trace) unless trace_decorator.nil?

      trace
    end

    private

    def finished_recur(node)
      return nil if !node.span.is_finished?

      nodes = node.nodes
      nodes.each do
        return nil if node.span.is_finished?
        return nil unless finished_recur(node)
      end

      node
    end

    def find_node_dfs(_nodes, span_id)
      return nil if _nodes.empty?

      _nodes.each do |node|
        return node if node.span && span_id == node.span.id

        ret = find_node_dfs(node.nodes, node.span.id)
        return ret unless ret.nil?
      end

      nil
    end

    def find_node_position_dfs(_nodes, span_id)
      return nil if _nodes.empty?

      _nodes.each_with_index do |node, i|
        return i if span_id == node.span.id
        ret = find_node_position_dfs(node.nodes, node.span.id)

        return "#{i}:#{ret}" unless ret.nil?
      end

      nil
    end
  end

end
