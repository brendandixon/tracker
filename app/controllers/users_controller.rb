class UsersController < ApplicationController
  include FilterHandler
  include SortHandler

  DEFAULT_SORT = ['email']
  INDEX_ACTIONS = [:create, :destroy, :index, :update]

  before_filter :ensure_initial_state
  before_filter :build_index_query, only: INDEX_ACTIONS

  # GET /users
  # GET /users.json
  def index
    respond_to do |format|
      format.html { render 'shared/index'}
      format.js { render @filter.errors.empty? ? 'shared/index' : 'filter' }
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @expanded << @user.id if params.has_key?(:expanded)

    respond_to do |format|
      format.html { render template: 'shared/show' }
      format.js { render 'user' }
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @edited << 'new'
    @expanded << 'new'

    respond_to do |format|
      format.html { render template: 'shared/new' }
      format.js { render 'user' }
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @edited << @user.id
    @expanded << @user.id

    respond_to do |format|
      format.html { render template: 'shared/edit' }
      format.js { render 'user' }
      format.json { render json: @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        @changed << @user.id
        
        format.html { redirect_to users_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { render json: @user, status: :created, location: @user }
      else
        @edited << @user.id
        @expanded << @user.id

        format.html { render action: "new" }
        format.js { render 'user' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        @changed << @user.id

        format.html { redirect_to users_path }
        format.js { render 'shared/index'; flash.discard }
        format.json { head :no_content }
      else
        @edited << @user.id
        @expanded << @user.id

        format.html { render action: "edit" }
        format.js { render 'user' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    flash[:notice] = 'User was successfully deleted.'

    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render 'shared/index'; flash.discard }
      format.json { head :no_content }
    end
  end


  def is_index_action
    INDEX_ACTIONS.include?(action_name.to_sym)
  end

  private

  def build_index_query
    query = User
    
    @sort.each do |sort|
      case sort
      when '-email' then query = query.in_email_order('ASC')
      when 'email' then query = query.in_email_order('DESC')
      end
    end

    @users = query
  end

  def ensure_initial_state
    @edited = []
    @expanded = []
    @changed = []
  end

end
