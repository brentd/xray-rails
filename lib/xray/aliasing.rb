module Xray
  # This module implements the old ActiveSupport alias_method_chain feature
  # with a new name, and without the deprecation warnings. In ActiveSupport 5+,
  # this style of patching was deprecated in favor of Module.prepend. But
  # Module.prepend is not present in Ruby 1.9, which we would still like to
  # support. So we continue to use of alias_method_chain, albeit with a
  # different name to avoid collisions.
  #
  # TODO: remove this and drop support for Ruby 1.9.
  #
  module Aliasing
    # This code is copied and pasted from ActiveSupport, but with :xray
    # hardcoded as the feature name, and with the deprecation warning removed.
    def xray_method_alias(target)
      feature = :xray

      # Strip out punctuation on predicates, bang or writer methods since
      # e.g. target?_without_feature is not a valid method name.
      aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
      yield(aliased_target, punctuation) if block_given?

      with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
      without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

      alias_method without_method, target
      alias_method target, with_method

      case
      when public_method_defined?(without_method)
        public target
      when protected_method_defined?(without_method)
        protected target
      when private_method_defined?(without_method)
        private target
      end
    end
  end
end
