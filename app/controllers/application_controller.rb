class ApplicationController < ActionController::API
  include Rails.application.routes.url_helpers

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def paginate(scope)
    paginated = scope.page(params[:page]).per(params[:per_page] || 10)

    {
      data: paginated,
      pagination: {
        current_page: paginated.current_page,
        prev_page_url: page_url(paginated.prev_page),
        prev_page: paginated.prev_page,
        next_page_url: page_url(paginated.next_page),
        next_page: paginated.next_page,
        total_pages: paginated.total_pages,
        total_count: paginated.total_count
      }
    }
  end

  private

  def page_url(page)
    return nil unless page

    url_for(
      controller: controller_name,
      action: action_name,
      user_id: params[:user_id],
      page: page,
      per_page: params[:per_page]
    )
  end

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
