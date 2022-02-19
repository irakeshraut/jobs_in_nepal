class CategoriesController < ApplicationController
  skip_before_action :require_login

  def index
    categories_keys = Category::LIST.keys.sort
    @categories =  categories_keys.each_slice((categories_keys.size/2.0).round).to_a
  end
end
