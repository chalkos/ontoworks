require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  setup do
    @ontology = ontologies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ontologies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ontology" do
    assert_difference('Ontology.count') do
      post :create, ontology: { directory: @ontology.directory, name: @ontology.name }
    end

    assert_redirected_to ontology_path(assigns(:ontology))
  end

  test "should show ontology" do
    get :show, id: @ontology
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ontology
    assert_response :success
  end

  test "should update ontology" do
    patch :update, id: @ontology, ontology: { directory: @ontology.directory, name: @ontology.name }
    assert_redirected_to ontology_path(assigns(:ontology))
  end

  test "should destroy ontology" do
    assert_difference('Ontology.count', -1) do
      delete :destroy, id: @ontology
    end

    assert_redirected_to ontologies_path
  end
end
