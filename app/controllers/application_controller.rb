class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_not_found
    render_error(:not_found, 'Not found')
  end

  def render_error(status, message, details = {})
    render json: {
      error: {
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || status,
        message: message,
        details: details.presence || {}
      }
    }, status: status
  end
end
