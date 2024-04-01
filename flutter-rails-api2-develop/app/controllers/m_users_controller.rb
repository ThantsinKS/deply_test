class MUsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:signin_user,:create,:show,:invite_member_create,:confirm]
  def new
    #check login user
    # checkloginuser

    @m_user = MUser.new
  end
   def create
    #check login user
    # checkloginuser

    @m_user = MUser.new(user_params)

    @m_workspace = MWorkspace.new
    @m_workspace.workspace_name = @m_user.remember_digest

    @m_channel = MChannel.new
    @m_channel.channel_name = @m_user.profile_image
    @m_channel.channel_status = 1

    @m_user.member_status = 1

    status = true

    # @t_workspace = MWorkspace.find_by(id: session[:invite_workspaceid])
    @t_workspace = MWorkspace.find_by(id: params[:invite_workspaceid])
    if status &&  @m_user.save
      MUser.where(id: @m_user.id).update_all(remember_digest: nil, profile_image: nil)
    else 
      status = false
    end

    if(@t_workspace.nil?)
      if status && @m_workspace.save
      
      else 
        status = false
      end
    else
      @m_workspace = @t_workspace
    end

    @t_user_workspace = TUserWorkspace.new
    @t_user_workspace.userid = @m_user.id
    @t_user_workspace.workspaceid = @m_workspace.id

    if status && @t_user_workspace.save

    else 
      status = false
    end

    @t_user_channel = TUserChannel.new
    
    @t_channel = MChannel.find_by(channel_name: @m_channel.channel_name, m_workspace_id: @m_workspace.id)
    
    if(@t_channel.nil?)
      @t_user_channel.created_admin = 1
      @m_channel.m_workspace_id = @m_workspace.id

      if status && @m_channel.save
      else 
        status = false
      end
    else
      @t_user_channel.created_admin = 0
      @m_channel = @t_channel
    end

    @t_user_channel.message_count = 0
    @t_user_channel.unread_channel_message = 0
    @t_user_channel.userid = @m_user.id
    @t_user_channel.channelid = @m_channel.id

    if status && @t_user_channel.save
    else 
      status = false
    end

    if(status)
      render json: { message: "Signup Complete." }, status: :ok
    else
      render json: { error: "Signup Failed." }, status: :unprocessable_entity
    end
  end

  def invite_member_create
    @m_user = MUser.new(user_params)
    @m_workspace = MWorkspace.new
    @m_workspace.workspace_name = @m_user.remember_digest
    @m_channel = MChannel.new
    @m_channel.channel_name = @m_user.profile_image
    @m_channel.channel_status = 1
    @m_user.member_status = 1
    status = true
    @t_workspace = MWorkspace.find_by(id: invite_workspace_id_param[:invite_workspaceid])
    if status &&  @m_user.save
      MUser.where(id: @m_user.id).update_all(remember_digest: nil, profile_image: nil)
    else
      status = false
    end
    if(@t_workspace.nil?)
      if status && @m_workspace.save
      else
        status = false
      end
    else
      @m_workspace = @t_workspace
    end
    @t_user_workspace = TUserWorkspace.new
    @t_user_workspace.userid = @m_user.id
    @t_user_workspace.workspaceid = @m_workspace.id
    if status && @t_user_workspace.save
    else
      status = false
    end
    @t_user_channel = TUserChannel.new
    @t_channel = MChannel.find_by(channel_name: @m_channel.channel_name, m_workspace_id: @m_workspace.id)
    if(@t_channel.nil?)
      @t_user_channel.created_admin = 1
      @m_channel.m_workspace_id = @m_workspace.id
      if status && @m_channel.save
      else
        status = false
      end
    else
      @t_user_channel.created_admin = 0
      @m_channel = @t_channel
    end
    @t_user_channel.message_count = 0
    @t_user_channel.unread_channel_message = 0
    @t_user_channel.userid = @m_user.id
    @t_user_channel.channelid = @m_channel.id
    if status && @t_user_channel.save
    else
      status = false
    end
    if(status)
      render json: { message: "Signup Complete."}, status: :ok
    else
      render json: { error: "Signup Failed."}, status: :unprocessable_entity
    end
  end
  def index
  end
  def show
    # @s_user_id =  params[:id]
    @m_user = MUser.find_by(id: @current_user)
    @user_id =  MUser.find_by(id: params[:id])
    @r_direct_size =  10
    # retrieve_direct_message(@user_id)
    # retrievehome
    # @m_user = MUser.find_by(id: params[:id])
    
    if @m_user
      render json: @m_user, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end
  def showMessage
    @second_user = params[:second_user]
    retrieve_direct_message(@second_user)
  end
  def update
    
    # checkuser
    @user = @current_user.id
    @m_user = MUser.new(user_params)
    password = params[:m_user][:password]
    password_confirmation = params[:m_user][:password_confirmation]
    if password == "" || password.nil?
      render json: { error: "Password can't be blank." }, status: :unprocessable_entity
    elsif password_confirmation == "" || password_confirmation.nil?
      render json: { error: "Confirm Password can't be blank." }, status: :unprocessable_entity
    elsif password != password_confirmation
      render json: { error: "Password and Confirmation Password does not match." }, status: :unprocessable_entity
    else
      MUser.where(id: @user).update_all(password_digest: @m_user.password_digest)
      render json: { message: "Change Password Successful." }, status: :ok
    end
  end 
  def update_password
    @user = MUser.find_by(email: update_params[:email])

    if @user
      if @user.update(password: update_params[:password], password_confirmation: update_params[:password_confirmation])
        render json: { message: "Password updated successfully!" }, status: :ok
      else
        render json: { error: "Password update failed"}, status: :unprocessable_entity
      end
    else
      render json: { error: "Provided email does not match the user's email" }, status: :unauthorized
    end
  end

  def confirm
    @m_workspace = MWorkspace.find_by(id: params[:workspaceid])
    @m_channel = MChannel.find_by(id: params[:channelid])
  
    @m_user = MUser.new
    @m_user.email = params[:email]
    @m_user.remember_digest = @m_workspace.workspace_name
    @m_user.profile_image = @m_channel.channel_name
    # render json: { message: "Successful." }, status: :ok
  end

  def refresh_direct
  
    r_direct_size = params[:r_direct_size].to_i || 0
  
    if r_direct_size.zero?
      r_direct_size = 10
    else
      r_direct_size += 10
    end
    render json: { r_direct_size: r_direct_size, direct_messages: direct_messages, home_data: home_data }, status: :ok
  end
  def show_user
    @m_workspace = MWorkspace.find_by(id: @current_workspace)
    @m_user = MUser.find_by(id: @current_user)
    retrievehome
    if @m_user
      # render json:{@m_user,@m_workspace}, status: :ok
    end
  end

  def signin_user
    m_user = MUser.find_by(name: signin_params[:name])
    m_workspace = MWorkspace.joins("INNER JOIN t_user_workspaces ON t_user_workspaces.workspaceid = m_workspaces.id
                                    INNER JOIN m_users ON m_users.id = t_user_workspaces.userid")
                            .where("m_workspaces.workspace_name = ? and m_users.name = ? ", signin_params[:workspace_name],  signin_params[:name]).take(1)
    if m_user && m_user.authenticate(signin_params[:password]) && m_workspace.size > 0
      t_user_workspace = TUserWorkspace.find_by(userid: m_user.id, workspaceid: m_workspace[0].id)
      if t_user_workspace
        if m_user.member_status == true
          token = jwt_encode(user_id: m_user.id,workspace_id: m_workspace[0].id)
          render json: { token: token}, status: :ok
        else
          render json: { error: 'Account Deactivate. Please contact admin.' }, status: :unauthorized
        end
      else
        render json: { error: 'Invalid name combination' }, status: :unauthorized
      end
    else
      render json: { error: 'Invalid name/password combination' }, status: :unauthorized
    end
  end

  private

def user_params
  params.require(:m_user).permit(:name, :email, :password, :password_confirmation, :admin, :profile_image, :remember_digest)
end
def signin_params
  params.require(:user).permit(:name,:password,:workspace_name)
end
def update_params
params.require(:user).permit(
  :email,
  :password,
  :password_confirmation
)
end
def invite_workspace_id_param
  params.require(:workspace_id).permit(:invite_workspaceid)
end

end
