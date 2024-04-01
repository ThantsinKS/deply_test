if @user_manages_activate
  json.user_manages_activate @user_manages_activate
end
if @user_manages_deactivate
  json.user_manages_deactivate @user_manages_deactivate
end
if @user_manages_admin
  json.user_manages_admin @user_manages_admin
end
