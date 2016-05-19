require 'sinatra'
require 'sinatra/json'
require "sinatra/reloader"

module Nero
  class Web < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    get '/workflows/:workflow_id/user_states/:user_id' do
      storage = Nero::Storage.new(DB)
      user_state = storage.find_user_state(params[:user_id], params[:workflow_id])
      json user_state
    end

    get '/workflows/:workflow_id/subject_states/:subject_id' do
      storage = Nero::Storage.new(DB)
      subject_state = storage.find_subject_state(params[:subject_id], params[:workflow_id])
      json subject_state
    end
  end
end
