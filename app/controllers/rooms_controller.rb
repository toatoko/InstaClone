class RoomsController < ApplicationController
  before_action :authenticate_user!
  def index
    @rooms = Room.public_rooms
    @users = User.includes(:avatar_attachment).all_except(current_user)
  end
  def show
    @room = Room.find(params[:id])
  end
end
