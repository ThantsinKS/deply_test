# class TDirectMessagesController < ApplicationController
#   def show
#     # Assuming retrieve_direct_thread is a method
#     @direct_thread = retrieve_direct_thread
#     render json: @direct_thread
#   end
#   private
#   def retrieve_direct_thread
#     # Your implementation to retrieve the direct thread
#     # For example, you might fetch it from the database
#     DirectThread.find(params[:id])
#   end
# end
class TDirectMessagesController < ApplicationController
  def show
    #check unlogin user
    # checkuser
    @direct_message_id = params[:direct_message_id]
    # @receiverUserID = params[:s_user_id]
    # @senderID = params [:user_id]
    # session[:s_direct_message_id] =  params[:id]
    #call from ApplicationController for retrieve direct thread data
    retrieve_direct_thread(@direct_message_id)
    #call from ApplicationController for retrieve home data
    # retrievehome
  end
end