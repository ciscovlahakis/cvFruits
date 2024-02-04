require "sinatra"
require "sinatra/reloader" if development?
require "httparty"
require "algoliasearch"
require "json"
require "dotenv/load"

# Configure Algolia
ALGOLIA_APP_ID = ENV["ALGOLIA_APP_ID"]
ALGOLIA_ADMIN_API_KEY = ENV["ALGOLIA_ADMIN_API_KEY"]
Algolia.init(application_id: ALGOLIA_APP_ID, api_key: ALGOLIA_ADMIN_API_KEY)

before do
  @index = Algolia::Index.new("fruits")
end

# Route to fetch and upload fruits data to Algolia
post "/update_algolia" do
  response = HTTParty.get("https://www.fruityvice.com/api/fruit/all")
  fruits = JSON.parse(response.body)

  # Convert fruits data to a format acceptable by Algolia
  fruits.each_with_index do |fruit, index|
    fruit[:objectID] = index
  end

  @index.clear_index
  @index.add_objects(fruits)

  "Algolia index updated."
  redirect to('/')
end

get '/fruits' do
  response = HTTParty.get('https://www.fruityvice.com/api/fruit/all')
  content_type :json
  response.body
end

get "/" do
  erb :index
end
