require "redis"
require "redis_ext"
require "connection_pool"
require "active_support"
require "active_support/core_ext"
require "active_support/concern"
require "active_support/inflector"
require "ssdb-attr/version"
require "ssdb/objects/sorted_set"
require "ssdb/attr"

module SSDBAttr
  class << self
    attr_accessor :pool

    def setup(options={})
      pool_size = (options[:pool]     || 1).to_i
      timeout   = (options[:timeout]  || 2).to_i

      SSDBAttr.pool = ConnectionPool.new(size: pool_size, timeout: timeout) do
        if options[:url].present?
          Redis.new(url: options[:url])
        else
          Redis.new(host: options[:host], port: options[:port])
        end
      end
    end

    def disconnect!
      SSDBAttr.pool.shutdown do |conn|
        conn.disconnect!
      end
    end
  end
end
