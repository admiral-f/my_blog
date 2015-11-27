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
	      "name" TEXT,
	      "created_date" DATE,
	      "content" TEXT
	    )'
	@db.execute 'CREATE TABLE IF NOT EXISTS "Comments"
	    (
	      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
	      "post_id" INTEGER,
	      "name" TEXT,
	      "created_date" DATE,
	      "content" TEXT
	    )'

end

get '/' do
	@results=@db.execute 'select * from Posts order by id desc'
	@NumComments=@db.execute 'select post_id, count(post_id) from Comments group by post_id'	
    erb :index 			
end

get '/new' do
  erb :new
end

post '/new' do
  @content=params[:content]
  @name=params[:name]
  hh={:name=> "Please, enter your name", :content=>"Please, type post text"}
  @error=hh.select {|key,_| params[key]==""}.values.join("; ")
  #if content.length <= 0
  	#@error= 'Please, type post text'
  	#return erb :new
  #end
  if @error==''
  	@db.execute 'insert into Posts (content, name, created_date) values (?,?, datetime())', [@content, @name]
  	redirect to ('/')
  end
  erb :new
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
	@name=params[:name]
	hh={:name=> "Please, enter your name", :content=>"Please, type comment text"}
  	@error=hh.select {|key,_| params[key]==""}.values.join("; ")
  	results=@db.execute 'select * from Posts where id=(?)',[post_id]
	@row=results[0]
    @comments=@db.execute 'select * from Comments where post_id=(?) order by id',[post_id]
    
	if @error==''
  		@db.execute 'insert into Comments (content, name, created_date, post_id) values (?,?, datetime(), ?)', [comment, @name, post_id]
  		redirect to ('/post/' + post_id)
  	end
	return erb :posts

end