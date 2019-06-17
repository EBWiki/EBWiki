class SetCaseDefaults
  include Service

  def call(params)
    if !params[:avatar].present?
      params[:avatar] = '/assets/image.jpg'
    end 
  end
end