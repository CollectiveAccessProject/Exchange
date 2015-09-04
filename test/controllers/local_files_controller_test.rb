require 'test_helper'

class LocalFilesControllerTest < ActionController::TestCase
  setup do
    @local_file = local_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:local_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create local_file" do
    assert_difference('LocalFile.count') do
      post :create, local_file: { media: @local_file.media, media_fingerprint: @local_file.media_fingerprint }
    end

    assert_redirected_to local_file_path(assigns(:local_file))
  end

  test "should show local_file" do
    get :show, id: @local_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @local_file
    assert_response :success
  end

  test "should update local_file" do
    patch :update, id: @local_file, local_file: { media: @local_file.media, media_fingerprint: @local_file.media_fingerprint }
    assert_redirected_to local_file_path(assigns(:local_file))
  end

  test "should destroy local_file" do
    assert_difference('LocalFile.count', -1) do
      delete :destroy, id: @local_file
    end

    assert_redirected_to local_files_path
  end
end
