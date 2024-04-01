class TGroupMessagesController < ApplicationController
  def show
    #check unlogin user
    # checkuser

    
    if params[:s_channel_id].nil?
      redirect_to home_url
    elsif MChannel.find_by(id: params[:s_channel_id]).nil?
      redirect_to home_url
    else
      params[:s_group_message_id] =  params[:id]

      #call from ApplicationController for retrieve group thread data
      retrieve_group_thread

      #call from ApplicationController for retrieve home data
      # retrievehome
    end
  end
end