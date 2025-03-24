class LikesController < ApplicationController
  before_action :set_like, only: %i[ destroy ]

  # POST /likes or /likes.json
  def create
    @like = Like.new(like_params)

    respond_to do |format|
      if @like.save
        format.html { redirect_back fallback_location: @like.photo, notice: "Like was successfully created." }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1 or /likes/1.json
  def destroy
    @like.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: @like.photo, notice: "Like was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      @like = Like.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def like_params
      params.require(:like).permit(:fan_id, :photo_id)
    end
end
