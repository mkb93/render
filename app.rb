# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'
require_relative 'lib/album'
require_relative 'lib/artist'



DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end
  get '/' do
    return erb(:index)
  end
  get '/album/new' do
    return erb(:new_album_form)
  end
  get '/albums' do
    repo = AlbumRepository.new
    @artists = ArtistRepository.new
    @albums = repo.all
    
    return erb(:index)
  end
  post '/albums' do
    repo = AlbumRepository.new
    al = Album.new
    al.title=params[:title]
    al.release_year=params[:release_year]
    al.artist_id=params[:artist_id]
    repo.create(al)
    return ''
  end
  post '/newalbum' do
    repo = AlbumRepository.new
    @al = Album.new
    @al.title=params[:title]
    @al.release_year=params[:release_year]
    @al.artist_id=params[:artist_id]
    repo.create(@al)
    return erb(:new_album_submit)
  end
  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end
  post '/artists' do
    if invalid_artist_parameters?
      status 400
      return ''
    end
    repo = ArtistRepository.new
    new_artist = Artist.new
    new_artist.name = params[:name]
    new_artist.genre = params[:genre]
    repo.create(new_artist)
    return erb(:artist_created)
  end
  get '/albums/:id' do
    repo = AlbumRepository.new
    artists = ArtistRepository.new
    
    @al = repo.find(params[:id])
    @artist = artists.find(@al.artist_id)
    return erb(:album)
  end
  get '/artists/new' do
    return erb(:new_artist_form)
  end
  get '/artists/:id' do
    artists = ArtistRepository.new
    
    @artist = artists.find(params[:id])
    return erb(:artist)
  end

  private

  def invalid_artist_parameters?
    return true if params[:name] == nil || params[:genre] == nil
    return true if params[:name] == '' || params[:genre] == ''
    return false
  end
end