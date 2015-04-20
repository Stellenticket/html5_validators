require 'spec_helper'

feature 'person#new' do
  context 'without validation' do
    scenario 'new form' do
      visit '/people/new'
      page.should have_css('input#person_name')
      page.should_not have_css('input#person_name[required=required]')
    end

    scenario 'new_without_html5_validation form' do
      visit '/people/new_without_html5_validation'
      page.should have_css('input#person_email')
      page.should_not have_css('input#person_email[required=required]')
    end
  end

  context 'with required validation' do
    background do
      Person.validates_presence_of :name, :bio, :gender
    end
    after do
      clear_validators
    end
    scenario 'new form' do
      visit '/people/new'

      find('input#person_name')[:required].should == 'required'
      find('select#person_gender')[:required].should == 'required'
      find('textarea#person_bio')[:required].should == 'required'
    end
    scenario 'new_without_html5_validation form' do
      visit '/people/new_without_html5_validation'

      find('input#person_name')[:required].should be_nil
    end

    context 'disabling html5_validation in class level' do
      background do
        Person.class_eval do |kls|
          kls.auto_html5_validation = false
        end
      end
      after do
        Person.class_eval do |kls|
          kls.auto_html5_validation = nil
        end
      end
      scenario 'new form' do
        visit '/people/new'

        find('input#person_name')[:required].should be_nil
      end
    end
  end

  context 'with required validation and :on option' do
    background do
      Person.validates_presence_of :name, :on => :create
      Person.validates_presence_of :bio, :on => :update
    end
    after do
      clear_validators
    end

    scenario 'new form' do
      visit '/people/new'

      find('input#person_name')[:required].should == 'required'
      find('textarea#person_bio')[:required].should be_nil
    end

    scenario 'edit form' do
      visit '/people/1/edit'

      find('input#person_name')[:required].should be_nil
      find('textarea#person_bio')[:required].should == 'required'
    end
  end

  context 'with required validation and :confirmation option' do
    background do
      Person.validates :name, presence: true, confirmation: true
    end
    after do
      clear_validators
    end

    scenario 'new form' do
      visit '/people/new_with_confirmation'

      find('input#person_name')[:required].should == 'required'
      find('input#person_name_confirmation')[:required].should == 'required'

      find('input#person_name_confirmation')['data-dependent-validation'].should == 'person_name'
    end
  end

  context 'without required validation and with :confirmation option' do
    background do
      Person.validates :name, confirmation: true
    end
    after do
      clear_validators
    end

    scenario 'new form' do
      visit '/people/new_with_confirmation'

      find('input#person_name')[:required].should be_nil
      find('input#person_name_confirmation')[:required].should be_nil

      find('input#person_name_confirmation')['data-dependent-validation'].should == 'person_name'
    end
  end

  context 'with maxlength validation' do
    background do
      Person.validates_length_of :name, {:maximum => 20}
      Person.validates_length_of :bio, {:maximum => 100}
    end
    after do
      clear_validators
    end

    scenario 'new form' do
      visit '/people/new'

      find('input#person_name')[:maxlength].should == '20'
      find('textarea#person_bio')[:maxlength].should == '100'
    end
  end

  context 'with minlength validation' do
    background do
      Person.validates :name, :length => {:minimum => 20}
      Person.validates :bio, :length => {:minimum => 100}
    end
    after do
      clear_validators
    end

    scenario 'new form' do
      visit '/people/new'

      find('input#person_name')['pattern'].should == '.{20,}'
      find('textarea#person_bio')['pattern'].should == '.{100,}'
    end
  end

  context 'with readonly' do
    background do
      Person.attr_readonly :bio
    end
    after do
      clear_readonly
    end

    scenario 'new form' do
      visit '/people/new'

      find('textarea#person_bio')[:readonly].should be_nil
    end

    scenario 'edit form' do
      visit '/people/1/edit'

      find('textarea#person_bio')[:readonly].should == 'readonly'
    end
  end

  context 'with required set in form' do
    background do
      Person.validates_presence_of :name, :email
    end
    after do
      clear_validators
    end

    scenario 'it should not overwrite attributes' do
      visit '/people/new_with_explicit_required'
      page.should_not have_css('input#person_name[required=required]')
      page.should_not have_css('input#person_email[required=required]')
    end
  end
end
