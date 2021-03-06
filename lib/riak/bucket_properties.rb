require 'riak'

module Riak
  # Provides a predictable and useful interface to bucket properties. Allows
  # reading, reloading, and setting new values for bucket properties.
  class BucketProperties
    attr_reader :client
    attr_reader :bucket

    # Create a properties object for a bucket (including bucket-typed buckets).
    # @param [Riak::Bucket, Riak::BucketTyped::Bucket] bucket
    def initialize(bucket)
      @bucket = bucket
      @client = bucket.client
    end

    # Clobber the cached properties, and reload them from Riak.
    def reload
      @cached_props = nil
      cached_props
      true
    end

    # Write bucket properties and invalidate the cache in this object.
    def store
      client.backend do |be|
        be.bucket_properties_operator.put bucket, cached_props
      end
      @cached_props = nil
      return true
    end

    # Take bucket properties from a given {Hash} or {Riak::BucketProperties}
    # object.
    # @param [Hash<String, Object>, Riak::BucketProperties] other
    def merge!(other)
      cached_props.merge! other
    end

    # Convert the cached properties into a hash for merging.
    # @return [Hash<String, Object>] the bucket properties in a {Hash}
    def to_hash
      cached_props
    end

    # Read a bucket property
    # @param [String] property_name
    # @return [Object] the bucket property's value
    def [](property_name)
      cached_props[property_name.to_s]
    end

    # Write a bucket property
    # @param [String] property_name
    # @param [Object] value
    def []=(property_name, value)
      value = unwrap_index(value) if property_name == 'search_index'
      cached_props[property_name.to_s] = value
    end

    private
    def cached_props
      @cached_props ||= client.backend do |be|
        be.bucket_properties_operator.get bucket
      end
    end

    def unwrap_index(value)
      return value.name if value.is_a? Riak::Search::Index

      value
    end
  end
end
