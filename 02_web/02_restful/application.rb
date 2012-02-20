
require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'supermodel'
require 'json'

#
# For documentation, see:
#   https://github.com/maccman/supermodel/blob/master/lib/supermodel/base.rb
#
class Idea < SuperModel::Base
  include SuperModel::RandomID
  belongs_to :inventor
end

class Inventor < SuperModel::Base
  include SuperModel::RandomID
  attributes :name
  validates_uniqueness_of :name
end

class RestfulServer < Sinatra::Base
  ANONYMOUS = Inventor.create!(:name => "anonymous")

  # helper method that returns json
  def json_out(data)
    content_type 'application/json', :charset => 'utf-8'
    data.to_json + "\n"
  end

  # displays a not found error
  def not_found
    status 404
    body "not found\n"
  end

  # obtain a list of all ideas
  def list_ideas
    json_out(Idea.all)
  end

  # obtain a list of all ideas
  def list_inventors
    json_out(Inventor.all)
  end

  # display the list of ideas
  get '/' do
    list_ideas
  end

  # display the list of ideas
  get '/ideas' do
    list_ideas
  end

  # display the list of inventors
  get '/inventors' do
    list_inventors
  end

  # delete an inventor
  delete '/inventors/:id' do
    unless Inventor.exists?(params[:id])
      not_found
      return
    end

    Inventor.find(params[:id]).destroy
    status 204
    "inventor #{params[:id]} deleted\n"
  end

  # create a new idea
  post '/ideas' do
    req = JSON.parse(request.body.read)

    if req["inventor"]
      # were we given an inventor?
      inventor = nil

      # check if the inventor exists by name or id
      if req["inventor"]["id"] and Inventor.exists?(req["inventor"]["id"])
        inventor = Inventor.find(req["inventor"]["id"])
      elsif req["inventor"]["name"] and Inventor.exists?(req["inventor"]["name"])
        inventor = Inventor.find_by_name(req["inventor"]["name"])
      else
        # else create an inventor
        inventor = Inventor.new(req["inventor"])
        inventor.save
      end

      req["inventor"] = inventor
    else
      # an inventor was not given, use the anonymous one instead
      req["inventor"] = ANONYMOUS
    end

    # return the idea
    json_out(Idea.create!(req))
  end

  # get an idea by id
  get '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    json_out(Idea.find(params[:id]))
  end

  # update an idea
  put '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    idea = Idea.find(params[:id])
    idea.update_attributes!(JSON.parse(request.body.read))
    json_out(idea)
  end

  # delete an idea
  delete '/ideas/:id' do
    unless Idea.exists?(params[:id])
      not_found
      return
    end

    Idea.find(params[:id]).destroy
    status 204
    "idea #{params[:id]} deleted\n"
  end


  # delete all data if password is correct
  post '/nuke' do
    req = JSON.parse(request.body.read)
    pass = req["pass"]

    unless pass and pass == "ilikenukes"
      status 404
      body "password parameter is incorrect or nil\n"
    end

    Idea.destroy_all
    Inventor.destroy_all

    "all data has been destroyed!"
  end

  run! if app_file == $0
end
