class Admin::UserRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @user_roles = UserRole.includes(:user, :role).all
  end

  def new
    @user_role = UserRole.new
    @users = User.all
    @roles = Role.all
  end

  def create
    @user_role = UserRole.new(user_role_params)
    if @user_role.save
      redirect_to admin_user_roles_path, notice: 'Роль назначена.'
    else
      @users = User.all
      @roles = Role.all
      render :new
    end
  end

  def destroy
    @user_role = UserRole.find(params[:id])
    @user_role.destroy
    redirect_to admin_user_roles_path, notice: 'Роль удалена у пользователя.'
  end

  private

  def user_role_params
    params.require(:user_role).permit(:user_id, :role_id)
  end

  def authorize_admin!
    authorize :admin, :admin?
  end
end
