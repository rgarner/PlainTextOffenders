class Admin::OffendingSitesController < Admin::AdminController
  def index
    @offending_sites = OffendingSite.all_ordered
  end

  def new
    @offending_site = OffendingSite.new
  end

  def create
    @offending_site = OffendingSite.new(params[:offending_site])

    if @offending_site.save
      redirect_to admin_offending_sites_url
    else
      render :action => "new"
    end
  end

   def edit
     @offending_site = get_offending_site
   end

  def update
    @offending_site = get_offending_site

    # Don't continue if @offending_site is null
    return if @offending_site.nil?

    # Update entity and then save to DB
    @offending_site.attributes = params[:offending_site]
    if @offending_site.save
      flash[:notice] = "Update finished successfully"
      redirect_to admin_offending_sites_url
    else
      render :action => "edit"
    end
  end

  def destroy
    offending_site = get_offending_site

    # Don't continue if @offending_site is null
    return if offending_site.nil?

    offending_site.destroy

    flash[:notice] = "Offending site was deleted successfully"
    redirect_to admin_offending_sites_url
  end

  def publish
    offending_site = get_offending_site

    # Don't continue if @offending_site is null
    return if offending_site.nil?

    offending_site.is_published = true
    offending_site.save!

    flash[:notice] = "The site #{offending_site.url} is now published"
    redirect_to admin_offending_sites_url
  end

  def unpublish
    offending_site = get_offending_site

    # Don't continue if @offending_site is null
    return if offending_site.nil?

    offending_site.is_published = false
    offending_site.save!

    flash[:notice] = "The site #{offending_site.url} is now UNpublished"
    redirect_to admin_offending_sites_url
  end

  private
  def get_offending_site
    offending_site = OffendingSite.where(:id => params[:id]).first

    # If ID is not found, return to list with a warning
    if offending_site.nil?
      flash[:error] = "Given ID could not be found"
      redirect_to admin_offending_sites_url
    end

    offending_site
  end
end
