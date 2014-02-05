require 'active_record'
require 'action_controller/railtie'

# config
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

app = Class.new(Rails::Application)
app.config.secret_token = "You know I'm born to lose, and gambling's for fools, But that's the way I like it baby, I don't wanna live for ever, And don't forget the joker!"
app.config.session_store :cookie_store, :key => '_myapp_session'
app.config.active_support.deprecation = :log
app.config.eager_load = false
app.initialize!

# routes
app.routes.draw do
  resources :people, :only => [:new, :create, :edit, :show] do
    collection do
      get :new_without_html5_validation
      get :new_with_confirmation
    end
  end
end

# models
class Person < ActiveRecord::Base
end

# controllers
class ApplicationController < ActionController::Base; end
class PeopleController < ApplicationController
  def new
    @person = Person.new
    render :inline => <<-ERB
<%= form_for @person do |f| %>
<%= f.text_field :name %>
<%= f.select :gender, [['male', 1], ['female', 2]] %>
<%= f.text_area :bio %>
<% end %>
ERB
  end

  def edit
    @person = create_person
    render :inline => <<-ERB
<%= form_for @person do |f| %>
<%= f.text_field :name %>
<%= f.select :gender, [['male', 1], ['female', 2]] %>
<%= f.text_area :bio %>
<% end %>
ERB
  end

  def new_without_html5_validation
    @person = Person.new
    render :inline => <<-ERB
<%= form_for @person, :auto_html5_validation => false do |f| %>
<%= f.text_field :name %>
<%= f.select :gender, [['male', 1], ['female', 2]] %>
<%= f.text_field :email %>
<% end %>
ERB
  end

  def new_with_confirmation
    @person = Person.new
    render :inline => <<-ERB
<%= form_for @person do |f| %>
<%= f.text_field :name %>
<%= f.text_field :name_confirmation %>
<%= f.select :gender, [['male', 1], ['female', 2]] %>
<%= f.text_field :email %>
<% end %>
ERB
  end

  private

    def create_person
        Person.create!(:name => 'Name', :bio => 'Bio')
    end
end

# helpers
module ApplicationHelper; end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name
      t.string :email
      t.string :gender
      t.integer :age
      t.text :bio
    end
  end
end
