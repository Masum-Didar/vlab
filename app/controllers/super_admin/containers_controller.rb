class SuperAdmin::ContainersController < SuperAdmin::BaseController
  before_action :set_container, only: [:edit, :update, :destroy]

  def index
    @containers = Container.order(:container_type, :name)
  end

  def new
    @container = Container.new
  end

  def create
    @container = Container.new(container_params)
    if @container.save
      redirect_to super_admin_containers_path, notice: "Container created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @container.update(container_params)
      redirect_to super_admin_containers_path, notice: "Container updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @container.destroy
    redirect_to super_admin_containers_path, alert: "Container removed!"
  end

  private

  def set_container
    @container = Container.find(params[:id])
  end

  def container_params
    params.require(:container).permit(:name, :container_type)
  end
end
