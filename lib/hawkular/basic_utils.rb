require 'uri'


module Hawkular
  module BasicUtils

    def generate_span_id
      raise 'not yet implemented'
    end

    def derive_type_from_url(tags)
      url_types = []
      tags.keys.each do |tag|
        if tag.include?('.url') || tag.include?('.uri')
          url_types << tag[0..tag.length - 4].upcase
        end
      end

      return nil if url_types.empty?

      #TODO(help): figure out what to actually return here
      url_types[0]
    end

    def derive_operation(span)
      return span.tags['http.method'] if span.operation_name.nil?

      span.operation_name
    end

    def derive_endpoint_type(tags)
      endpoint_type = derive_type_from_url(tags)
      return 'HTTP' if endpoint_type.nil?

      endpoint_type
    end

    def derive_component_type(tags)
      component_type = tags.component
      return component_type unless component_type.nil?

      derive_type_from_url(tags)
    end

    def derive_url(tags)
      url = tags['http.url']
      return URI.parse(url).path unless url.nil?

      url = tags['http.uri']
      return URI.parse(url).path unless url.nil?

      url = tags['http.path']
      return url unless url.nil?

      nil
    end

    def tags_to_properties(tags)
      return nil if tags.nil?

      properties = []
      tags.keys.each do |tag|
        value = tags[tag]
        type = value.class.name

        properties << {name: tag, type: type, value: value}
      end
      properties
    end

  end

end

