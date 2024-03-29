class ImagesController < ApplicationController
  before_action :set_image, only: %i[ show edit destroy download addtofavourite removefromfavourite addcomment addtag removetag ]

  def index
    logged_in_checker
    @tag = params[:tag]
    @favourite = params[:favourite]
    @own = params[:own]
    @images = Image.get_image_page(params[:page], @tag, @favourite, @own, @user.id)

  end

  def new
    logged_in_checker
  end

  def show
    logged_in_checker
    @uploaderUser = User.find_by(id: @image.user_id).name;
    @comments = Comment.where(image_id: @image.id).order(updated_at: :asc)
    @tags = Tag.where(image_id: @image.id)
  end

  def upload
    image = Image.save_file(params[:image], @user.id)
    if image == nil
      flash[:notice] = 'Hibás feltöltés. Csak képet lehet feltölteni!'
      redirect_back fallback_location: new_image_path
    else
      flash[:notice] = 'Sikeres feltöltés!'
      redirect_to image;
    end
  end

  def download
    send_file @image.path, type: @image.mime
  end

  def destroy
    if @image.user_id == @user.id
      @image.destroy
      flash[:notice] = 'A kép törölve!'
      redirect_to images_path
    end
  end

  def addtofavourite
    if Favourite.where(user_id: @user.id, image_id: @image.id).count() > 0
      flash[:notice] = 'A kép már hozzá van adva a kedvencekhez!'
      redirect_back fallback_location: @image
      return
    end
    f = Favourite.new
    f.user_id = @user.id
    f.image_id = @image.id
    f.save
    flash[:notice] = 'A kép sikeresen hozzáadva a kedvencekhez!'
    redirect_back fallback_location: @image
  end

  def removefromfavourite
    f = Favourite.find_by(user_id: @user.id, image_id: @image.id)
    f.destroy
    flash[:notice] = 'A kép sikeresen törölve a kedvencekből!'
    redirect_back fallback_location: @image
  end

  def addcomment
    comment = params[:content].first
    if comment == ''
      flash[:notice] = 'A komment nem lehet üres!'
      redirect_back fallback_location: @image
      return
    end
    c = Comment.new
    c.content = comment
    c.user_id = @user.id
    c.image_id = @image.id
    c.save
    flash[:notice] = 'Komment hozzáadva!'
    redirect_back fallback_location: @image
  end

  def addtag
    tag = params[:tag].first
    if tag == ''
      flash[:notice] = 'A cimke nem lehet üres!'
      redirect_back fallback_location: @image
      return
    end
    if Tag.where(name: tag, image_id: @image.id).count() > 0
      flash[:notice] = 'A cimke már hozzá van adva a képhez!'
      redirect_back fallback_location: @image
      return
    end
    t = Tag.new
    t.name = tag
    t.image_id = @image.id
    t.save
    flash[:notice] = 'Cimke hozzáadva!'
    redirect_back fallback_location: @image
  end

  def removetag
    t = Tag.find_by(id: params[:tag_id])
    t.destroy
    flash[:notice] = 'A cimke sikeresen törölve!'
    redirect_back fallback_location: @image
  end

  private
  def logged_in_checker
    if !session[:user]
      redirect_to loginpage_path
    end
  end

  def set_image
    @image = Image.find(params[:id])
  end
end
