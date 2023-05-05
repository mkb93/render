require "spec_helper"
require "rack/test"
require_relative '../../app'
require "album"
require "album_repository"


def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end
describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }
  
  before(:each) do 
    reset_albums_table
  end
  context "GET /albums" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = get('/albums')
     

      expect(response.status).to eq(200)
      expect(response.body).to include ('ABBA')
    end
  end
  context "POST /albums" do
    it 'returns 200 OK' do
      # Assuming the post with id 1 exists.
      response = post('/albums', title: 'Voyage', release_year: '1997', artist_id: 1)
      
      expect(response.status).to eq(200)
      expect(response.body).to eq('')
      
      response = get('/albums')

      expect(response.status).to eq(200)
      expect(response.body).to include 'Voyage'
    end
  end
  context "GET /artists" do
    it 'returns 200 OK' do
      response = get('/artists')      
      expect(response.status).to eq(200)
      expect(response.body).to include('Pixies')
      
    end
  end
  context "POST /artists" do
    it 'returns 200 OK' do
      response = post('/artists', name: 'Wild Nothing', genre: 'Indie')      
      expect(response.status).to eq(200)

    end
  end
  context "GET /albums/:id" do
    it 'returns 200 OK' do
      response = get('/albums/1')
      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Doolittle</h1>'

    end
  end
  context "GET /artists/:id" do
    it 'returns 200 OK' do
      response = get('/artists/1')
      expect(response.status).to eq 200
      expect(response.body).to include '<h1>Pixies</h1>'

    end
  end
  context "GET /artists" do
    it 'returns 200 OK' do
      response = get('/artists')
      expect(response.status).to eq 200
      expect(response.body).to include 'Pixies'
      expect(response.body).to include '<div>Name<a href="artists/1"> Pixies</a></div>'

    end
  end
  context "GET /album/new" do
    it 'returns 200 OK' do
      response = get('/album/new')
      expect(response.status).to eq 200
      expect(response.body).to include '<form'

    end
  end
  context "POST /newalbum" do
    it 'returns 200 OK' do
      response = post('/newalbum', title: 'fish', release_year: 23, artist_id: 2)
      expect(response.status).to eq 200
      expect(response.body).to include 'fish'

    end
  end
  context "GET /artists/new" do
    it 'returns 200 OK and a new artist form' do
      response = get('/artists/new')

      expect(response.status).to eq 200
      expect(response.body).to include '<form action="/artists" method="POST">'
      expect(response.body).to include '<h1>add an artist</h1>'
      expect(response.body).to include '<input type="text" id="name" name="name">'
      expect(response.body).to include '<input type="text" id="genre" name="genre">'

    end
  end
  context "POST /artists" do
    it 'returns 200 OK and a new artist form' do
      response = post(
        '/artists',
        name: 'fish',
        genre: 'fish_rock')

      expect(response.status).to eq 200
      expect(response.body).to include '<p>Artist Added!</p>'

    end
    it 'returns 400' do
      response = post(
        '/artists',
        name: '',
        genre: ''
      )
      expect(response.status).to eq 400
    end
  end
end
