class ApplicationService
  class Error < StandardError; end

  attr_reader :success, :error_message, :error_details

  def self.call(*args, **kwargs)
    new(*args, **kwargs).call
  end

  def initialize(*args, **kwargs)
    @success = false
    @error_message = nil
    @error_details = {}
  end

  def call
    ActiveRecord::Base.transaction do
      begin
        execute

        @success = true
      rescue ActiveRecord::RecordInvalid => e
        @error_message = e.record.errors.full_messages.join(', ')
        @error_details = e.record.errors
        raise ActiveRecord::Rollback
      rescue Error, StandardError => e
        @error_message = e.message
        raise ActiveRecord::Rollback
      end
    end

    self
  end

  def success?
    @success
  end

  private

  def execute
    raise NotImplementedError, "You must implement the #{self.class}##{__method__} method"
  end
end
