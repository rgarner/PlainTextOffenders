class OffendingSitesController < ApplicationController
  def index
    @offending_sites = OffendingSite.all_published_ordered.paginate(:page => params[:page])

    respond_to do |format|
      format.html
      format.xml { render :xml => @offending_sites }
      format.json { render :json => @offending_sites }
    end
  end

  def feed
    @offending_sites = OffendingSite.all_published_ordered

    respond_to do |format|
      format.atom do
        render :layout => false
      end
    end

  end

  def search
     @offending_sites = OffendingSite.search(params[:q]).paginate(:page => params[:page])

    respond_to do |format|
      format.html { render "index"}
      format.xml { render :xml => @offending_sites }
      format.json { render :json => @offending_sites }
    end
  end

  def show
    @offending_site = OffendingSite.where(:id => params[:id]).first

    if @offending_site.nil? or not @offending_site.is_published
      redirect_to root_url and return
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @offending_site }
      format.json { render :json => @offending_site }
    end
  end

  def show_by_url
    url = params[:url]
    url = url.gsub('www.','')
    url = 'http://' + url unless url[0..6] == 'http://'

    @offending_site = OffendingSite.find_by_url(url)

    if @offending_site.nil? or not @offending_site.is_published
      redirect_to root_url and return
    end

    respond_to do |format|
      format.html { render "show" }
      format.xml { render :xml => @offending_site }
      format.json { render :json => @offending_site }
    end
  end

  def create
    @offending_site = OffendingSite.new(params[:offending_site])

    if @offending_site.save
      flash[:notice] = "Thank you! we will go through your submission soon and publish it to the site."
      redirect_to root_url
    else
      render :action => "new"
    end
  end

  def check_url
    url = params[:offending_site][:url]
    url = url.gsub('www.','')
    url = 'http://' + url unless url[0..6] == 'http://'
    @entity = OffendingSite.find_by_url(url)
    respond_to do |format|
      format.json { render :json => !@entity }
    end
  end
end
