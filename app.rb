require "sinatra"
require "sinatra/activerecord"

require "./models"


set :database, "sqlite3:bwitter.sqlite3"
set :sessions, true

get "/" do
	blogs = Blog.all.reverse
	@blogs = []
	if blogs.length > 20
		for i in 0..19
			@blogs.push(blogs[i])
		end

	else
		for i in 0...blogs.length
			@blogs.push(blogs[i])
		end
	end
	erb :index
end

def current_blog
	@blog = Blog.find(params[:id])
end

post "/create_blog" do

	if !session[:user_id]
		redirect "/"
	end

	user = User.find(session[:user_id])
	Blog.create(title: params[:userTitle], content: params[:userContent],user_id: session[:user_id])
	redirect "/users/#{user.id}"
end

get "/account/:id" do 
	if session[:user_id] == nil
		redirect "/"
	else

	@user = User.find(session[:user_id])

	erb :account
	end
end

get "/blog/:id" do

	@blog = Blog.find(params[:id])


	erb :show
end

get "/blog/:id/edit" do
	@blog = Blog.find(params[:id])
	erb :edit
end


post "/update/:id" do
	@blog = Blog.find(params[:id])

	if @blog.update(title: params[:title], content: params[:content])
		redirect "/"
	else
		erb "/blog/<%=@blog.id%>/edit"
	end
end



post "/destroy" do
	blog = Blog.where(id: params[:blogId]).first

	comment = Comment.where(blog_id: params[:blogId])

	for i in comment
		i.destroy
	end

	blog.destroy

	redirect "/"

end

post "/signup" do
	if  params[:username].length == 0 || params[:password].length == 0 || params[:fname].length == 0 || params[:lname].length == 0 || params[:email] == 0
		erb :createUserError
	else
		if User.create(username: params[:username], password: params[:password], fname: params[:fname], lname: params[:lname], email: params[:email])
			redirect "/"
		else
			erb :index
		end	
	end
end

get "/hello" do
 erb :hello
end


post "/login" do
	user = User.where(username: params[:username]).first
	if user != nil
		if user.password == params[:password]
			session[:user_id] = user.id
			@user = User.where(username: params[:username]).first
			redirect "/users/#{user.id}"
			erb :index
		else
			redirect "/failedLogin"
		end
	else 
		redirect "/failedLogin"
	end
end

get "/failedLogin" do

	erb :failedLogin
end

post "/logout" do
	session[:user_id] = nil
	redirect "/"

end


get "/users/:id" do
	@webid = params[:id]
	@user = User.find(params[:id])
	erb :user
end

get "/createUser" do

	erb :createUser
end

post "/addComment" do

	if Comment.create(content: params[:comment], blog_id: params[:blogid], user_id: session[:user_id])
		redirect "/blog/#{params[:blogid]}"
	else
		redirect "/users/#{session[:user_id]}"
	end
end

post "/destroyUser" do

	user = User.find(session[:user_id])
	blog = Blog.where(user_id: session[:user_id])
	comment = Comment.where(user_id: session[:user_id])
	for i in blog
		i.destroy
	end
	for e in comment
		e.destroy
	end
	user.destroy
	session[:user_id] = nil
	redirect "/"
end

post "/updateUser" do
	@user = User.where(id: params[:updateId]).first
	@user.update(username: params[:username], password: params[:password], fname: params[:fname], lname: params[:lname], email: params[:email])

end