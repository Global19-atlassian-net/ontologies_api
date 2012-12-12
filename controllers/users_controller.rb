class UsersController
  namespace "/users" do
    # Display all users
    get do
      s(User.all)
    end

    # Display a single user
    get '/:username' do
      s(User.find(params[:username]))
    end

    # Users get created via put because clients can assign an id (POST is only used where servers assign ids)
    put '/:username' do
      user = instance_from_params(User, params)
      if user.valid?
        user.save
      else
        halt 400, {:errors => user.errors}
      end
      s(user, 201)
    end

    # Update an existing submission of an user
    patch '/:username' do
      user = User.find([params[:username]])
      populate_from_params(user, params)
      if user.valid?
        user.save
      else
        halt 400, {:errors => user.errors}
      end
      halt 204
    end

    # Delete a user
    delete '/:username' do
      User.find(params[:username]).delete
      halt 204
    end

  end
end