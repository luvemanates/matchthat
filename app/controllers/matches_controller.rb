require 'mongoid'
require_relative '../../lib/tasks/digital_wallet'
require_relative '../../lib/tasks/mint'

class MatchesController < ApplicationController
  before_action :set_match, only: %i[ show edit update destroy user_tally ]

  # GET /matches or /matches.json
  def index
    dw = DigitalWallet.where(:wallet_name => 'Bank Wallet').first
    puts dw.inspect
    if params[:page]
      @page = params[:page]
    else
      @page = 1 
    end
    @matches = Match.all.includes(:creator, :users).order(:created_at => :desc).paginate(:page => @page, :per_page => 5 )
  end

  def popular
    if params[:page]
      @page = params[:page]
    else
      @page = 1 
    end
    @matches = Match.all.includes(:creator, :users).order(:total_amount => :desc).paginate(:page => @page, :per_page => 5 )
  end

  def user_tally
    @matches_for_sum = Match.where(:creator => @match.creator)
    @matches = Match.where(:creator => @match.creator).includes(:creator, :users).paginate(:page => @page, :per_page => 5)
    @tally = 0
    for match in @matches_for_sum
      if match.total_amount < 1
        @tally = match.total_amount
        return
      end
      @tally = @tally + match.total_amount.to_f
    end
  end

  # GET /matches/1 or /matches/1.json
  def show
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  def matchthat
    unless user_signed_in?
      redirect_to new_user_session_path, notice: 'You must sign in to do that.' 
      return 
    end
    @match = Match.find(params[:id])
    if @match.users.include?(current_user)
      flash[:notice] = "You're already matching that."
      redirect_to match_path(@match) and return
    else
      @match.users << current_user
      flash[:notice] = "You're now matching that."
      redirect_to match_path(@match) and return
    end
  end

  # POST /matches or /matches.json
  def create
    if user_signed_in?
      @match = Match.new(match_params.merge(:creator => current_user))
    else
      flash[:notice] = "You must login first."
      redirect_to user_session_path and return
    end

    respond_to do |format|
      if @match.save
        @match.users << current_user
        update_wallet_and_mint_coin
        format.html { redirect_to match_url(@match), notice: "Match was successfully created." }
        format.json { render :show, status: :created, location: @match }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1 or /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to match_url(@match), notice: "Match was successfully updated." }
        format.json { render :show, status: :ok, location: @match }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1 or /matches/1.json
  def destroy
    @match.destroy!

    respond_to do |format|
      format.html { redirect_to matches_url, notice: "Match was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def update_wallet_and_mint_coin
      puts "in create update_wallet_and_mint_coin"
      if current_user
        dw = DigitalWallet.where(:wallet_name => current_user.email + " wallet").first
        unless dw
          dw = DigitalWallet.new(:wallet_name => current_user.email + " wallet")
          dw.save
        end
        puts "inspecting digital wallet"
        puts dw.inspect
        mint = MatchMintingBank.new
        coin = mint.mint(:face_value => @match.total_amount, :digital_wallet => dw)
        coin.save
        puts "inspecting minted coin"
        puts coin.inspect
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def match_params
      params.require(:match).permit(:title, :total_amount, :description, :base_amount, :creator_id)
    end
end
