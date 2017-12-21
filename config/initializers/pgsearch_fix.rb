module PgSearchFlexibleOrderMethod
  module FlexibleOrder
    def order(value)
      value.is_a?(String) ? super(Arel.sql(value)) : super(value)
    end
  end

  def apply(scope)
    modified =
      scope.all.spawn.tap do |new_scope|
        new_scope.class_eval { prepend FlexibleOrder }
      end

    super(modified)
  end
end

class PgSearch::ScopeOptions
  prepend PgSearchFlexibleOrderMethod
end
