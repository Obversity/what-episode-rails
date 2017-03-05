# Include in an ActiveRecord model (or any class that implements a
# cache_key method that uniquely identifies the object)
# to allow rails-caching of method results
#
# Example:
#
# def get_the_thing(arg1, arg2)
#   // do time consuming or computation heavy thing here and return results
# end
#
# cache_method :get_the_thing, expires_in: 10.minutes
#
# # # # # # #
#
# Internally, this will:
#   - move the get_the_thing method to get_the_thing_alias
#   - create a new method called get_the_thing, which calls and caches the
#     results of get_the_thing with the given arguments
#
module CacheMethod
  extend ActiveSupport::Concern

  class_methods do
    def cache_method(method_name, expires_in:, class_method: false)
      # Determine if aliasing class or instance method
      object = class_method ? singleton_class : self

      # Make a copy of original method
      # E.g. .age -> .uncached_age
      uncached_method_name = "uncached_#{method_name}"
      object.send(:alias_method, uncached_method_name, method_name)

      # Redefine original method to use Rails cache
      object.send :define_method, method_name do |*args|
        key = generate_cache_method_key(method_name, args)
        Rails.cache.fetch(key, expires_in: expires_in) do
          if args.present?
            send(uncached_method_name, *args)
          else
            send(uncached_method_name)
          end
        end
      end

      #define a method reset cache method for this
      object.send :define_method, "cache_reset_#{method_name}" do |*args|
        key = generate_cache_method_key(method_name, args)
        Rails.cache.delete(key)
      end

      #define method to generate key based on method name and args
      object.send :define_method, :generate_cache_method_key do |method_name, args|
        args_key = Digest::MD5.hexdigest(args.join)
        key = "#{cache_key}:#{method_name}:#{args_key}"
      end
    end

    # Setup cache methods in batch with
    #
    # cache_methods :start_time, :end_time, expires_in: 10.minutes
    #
    def cache_methods(*method_names, expires_in:)
      method_names.each do |method_name|
        cache_method(method_name, expires_in: expires_in)
      end
    end

    def cache_class_methods(*method_names, expires_in:)
      method_names.each do |method_name|
        cache_method(method_name, expires_in: expires_in, class_method: true)
      end
    end

    alias_method :cache_class_method, :cache_class_methods

  end

end
