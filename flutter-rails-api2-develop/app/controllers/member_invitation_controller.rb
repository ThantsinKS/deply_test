class MemberInvitationController < ApplicationController
  def new
    #check unlogin user
    # checkuser
    # session.delete(:s_user_id)
    # session.delete(:s_channel_id)
    # session.delete(:s_direct_message_id)
    # session.delete(:s_group_message_id)
    # session.delete(:r_direct_size)
    # session.delete(:r_group_size)
    #call from ApplicationController for retrieve home data
    # retrievehome
  end
  def invite
    #check unlogin user
    # checkuser
    # puts params[:email].nil?
    # puts params[:channel_id].nil?
    # puts params[:workspace_id]
    @user = MUser.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.userid = m_users.id").where("t_user_workspaces.workspaceid = ? and m_users.email = ?", invite_params[:workspace_id], invite_params[:email])
    
    if @user.size > 0
      render json: { message: "Email Is Already Member." }, status: :unprocessable_entity
    else
      if invite_params[:channelid].nil? || invite_params[:channelid] == ""
        render json: { message: "Please Select Channel." }, status: :unprocessable_entity 
      elsif invite_params[:email].nil? || invite_params[:email] == ""
        render json: { message: "Please Enter Email." }, status: :unprocessable_entity
      else
        @i_user = MUser.new
        @i_user.email =invite_params[:email]
        @i_channel = MChannel.find_by(id: invite_params[:channelid])
        @i_workspace = MWorkspace.find_by(id: invite_params[:workspace_id])

        UserMailer.member_invite(@i_user, @i_workspace, @i_channel).deliver_now
        render json: { message: "Invitation Is Success." }, status: :ok
      end
    end
  end
  private
  def invite_params
    params.require(:m_invite).permit(:email,:channelid,:workspace_id);
  end
end