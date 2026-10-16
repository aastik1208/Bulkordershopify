class CountriesController < ApplicationController

  def index
  end

  def search
    @countries = Country.lookup_name(search_params[:name]).or(Country.lookup_code(search_params[:code])).includes(:states)
    unless @countries.present?
      flash[:notice] = "No countries found."
      redirect_to countries_path
    end
  end

  private def search_params
    params.permit(:name, :code)
  end

end
