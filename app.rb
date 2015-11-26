#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db=SQLite3::Database.new 'my_blog.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS "Posts"
	    (
	      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	      "created_date" DATE,
	      "content" TEXT
	    )'
	@db.execute 'CREATE TABLE IF NOT EXISTS "Comments"
	    (
	      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	      "post_id" INTEGER,
	      "created_date" DATE,
	      "content" TEXT
	    )'

end

get '/' do
	@results=@db.execute 'select * from Posts order by id desc'	
    erb :index 			
end

get '/new' do
  erb :new
end

post '/new' do
  content=params[:content]
  if content.length <= 0
  	@error= 'Please, type post text'
  	return erb :new
  end
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
  redirect to ('/')
end

get '/post/:id' do
	post_id=params[:id]
	results=@db.execute 'select * from Posts where id=(?)',[post_id]
	@row=results[0]
	@comments=@db.execute 'select * from Comments where post_id=(?) order by id',[post_id]
	erb :posts
end

post '/post/:id' do
	comment=params[:content]
	post_id=params[:id]
	if comment.length <= 0
  		@error= "Please, type comment text"
  		results=@db.execute 'select * from Posts where id=(?)',[post_id]
		@row=results[0]
		@comments=@db.execute 'select * from Comments where post_id=(?) order by id',[post_id]
		return erb :posts
  	else  	
		@db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [comment, post_id]
	end
	redirect to ('/post/' + post_id)

end