class SidekiqConstraint
  def matches?(request)
    # Because this is only for an assignment, we can just let anyone through
    true
  end
end
