class ConfigsController < ApplicationController
  def index
    @configs = Config.all
  end

  def change
    updated_configs = params[:configurations]
    current_configs = Config.all
    current_configs.zip(updated_configs).each do |c|
      c[0].update!(config_id: c[1].to_i)
    end
    flash[:notice] = "Configuration Settings Updated Successfully!"
    redirect_to configs_path
  end
end
