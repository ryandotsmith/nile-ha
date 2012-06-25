require 'bundler/setup'
require 'sinatra'

get "/" do
end

# Idempotently create a new zone
put "/zones" do
end

get "/zones/:id" do
end

delete "/zones/:id" do
end

put "/zones/:id/endpoints" do
end

delete "/endpoints/:id" do
end
