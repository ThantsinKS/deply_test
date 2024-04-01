class UserManageController < ApplicationController
  before_action :authenticate_request
  def usermanage
  #  @workspaceid = params[:id]
  #  @userid = params[:user_id]
  @m_user = MUser.find_by(id: @current_user)
    @user_manages_activate = MUser.select("m_users.id,name,email,member_status,admin").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and admin <> 1 and member_status = 1 and t_user_workspaces.workspaceid = ?",@current_workspace)

    @user_manages_deactivate = MUser.select("m_users.id,name,email,member_status,admin").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and admin <> 1 and member_status = 0 and t_user_workspaces.workspaceid = ?",@current_workspace)

    @user_manages_admin = MUser.select("m_users.id,name,email,member_status,admin").joins("join t_user_workspaces on t_user_workspaces.id = m_users.id")
    .where("t_user_workspaces.id = m_users.id and m_users.admin = 1 and t_user_workspaces.workspaceid = ?",@current_workspace)

    #call from ApplicationController for retrieve home data
    # retrievehome
    # data = retrievehome
    # render json: data, status: :ok
  end

  def edit
   MUser.where(id: params[:id]).update_all(member_status: 0)
    # retrievehome
    # render json: @user, status: :ok
    # retrievehome
  end

  def update
    MUser.where(id: params[:id]).update_all(member_status: 1)
    # retrievehome
    # redirect_to action:"usermanage"
  end
end
