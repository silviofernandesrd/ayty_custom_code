##### AYTYCRM - Silvio Fernandes #####

PrincipalMembershipsController.class_eval do

  before_filter :fill_ayty_selectable_users, :only => [:create, :update, :destroy, :ayty_replicate_memberships]

  def fill_ayty_selectable_users
    # ARM - Ayty Replicate Membership
    @ayty_selectable_users = User.ayty_users
  end

  # ARM - Ayty Replicate Memberships
  def ayty_replicate_memberships
    # usuario que sera atualizado
    @user = User.find(params[:id])

    @user.ayty_replicate_memberships_by_user_id(params[:ayty_user_stunt_id])

    @principal = Principal.find(@user.id)

    respond_to do |format|
      format.html { redirect_to edit_polymorphic_path(principal, :tab => 'memberships') }
      format.js
    end
  end

end