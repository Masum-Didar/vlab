class Admin::ContainersController < Admin::BaseController
  def index
    @containers = Container.order(:container_type, :name)
  end

  def new
    @container = Container.new
  end

  def create
    @container = Container.new(container_params)

    if @container.save
      redirect_to admin_containers_path, notice: "Container created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def container_params
    params.require(:container).permit(:name, :container_type)
  end
end
