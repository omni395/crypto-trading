class Admin::RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      redirect_to admin_roles_path, notice: 'Роль создана.'
    else
      render :new
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    @role = Role.find(params[:id])
    if @role.update(role_params)
      redirect_to admin_roles_path, notice: 'Роль обновлена.'
    else
      render :edit
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    redirect_to admin_roles_path, notice: 'Роль удалена.'
  end

  private

  def role_params
    params.require(:role).permit(:name)
  end

  def authorize_admin!
    authorize :admin, :admin? # Теперь используем универсальную проверку админских прав
  end
end
