class ApplicationService
  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def call
    perform
  end

  private

  def execute
    raise NotImplementedError, "You must implement the #{self.class}##{__method__} method"
  end
end
