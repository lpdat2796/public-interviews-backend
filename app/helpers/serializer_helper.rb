module SerializerHelper
  def render_response_success(status_code, data = [], options = {})
    if (options[:serializer] || options[:each_serializer])
      data = ActiveModelSerializers::SerializableResource.new(data, options)
    end

    render json: { status: 'success', data: data }, status: status_code
  end
end
