class MWorkspacesController < ApplicationController
    def new
        #check login user
        # checkloginuser
        
        @m_user = MUser.new
    end
end
