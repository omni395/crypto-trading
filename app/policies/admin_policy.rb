class AdminPolicy < Struct.new(:user, :admin)
  def admin?
    user.present? && user.has_role?('admin')
  end
end
