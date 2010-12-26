require "colored"
require "rails"
require "haml"
require "bundler"

@partials = "#{File.dirname(__FILE__)}"

puts "\n========================================================="
puts " FISCHER'S RAILS 3 TEMPLATE".yellow.bold
puts "=========================================================\n"

puts "\nRemoving unnecessary files ... ".magenta
remove_file "README"
remove_file "public/index.html"
remove_file "public/favicon.ico"
remove_file "public/robots.txt"
remove_file "public/index.html"
remove_file "public/images/rails.png"
remove_file "app/views/layouts/application.html.erb"
# remove prototype files
remove_file "public/javascripts/controls.js"
remove_file "public/javascripts/dragdrop.js"
remove_file "public/javascripts/effects.js"
remove_file "public/javascripts/prototype.js"
remove_file "public/javascripts/jrails.js"

#apply "#{@partials}/_gemfile.rb"
# Set up Gemfile

puts "Creating Gemfile ...".magenta

remove_file 'Gemfile'
file 'Gemfile', <<-RUBY.gsub(/^ {2}/, '')
  source 'http://gemcutter.org'

  gem 'rails', '~> 3.0.0'
  #gem 'mysql2'
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'capistrano'

  # HTML and CSS replacement
  gem 'haml', '~> 3.0'
  gem 'haml-rails'

  # HTML/CSS framework and boilerplate
  gem 'compass'
  gem 'html5-boilerplate'

  # Human readable URLs
  gem 'friendly_id', '~> 3.1'

  # Validation of associations
  gem 'validates_existence', '~> 0.5'

  # Better console formatting
  gem 'hirb'

  # User management
  # gem 'devise', '~> 1.1'
  #
  # To convert Markdown to HTML
  # gem 'maruku'
  #
  # Pagination of long lists
  # gem 'will_paginate', '~> 3.0.pre2'
  #
  # For Devise view generation
  # gem 'hpricot'
  # gem 'ruby_parser'
  #
  # File upload management
  # NOTE: requires this fix to be applied: http://github.com/thoughtbot/paperclip/commit/56d6b2402d553a505f29eaeb022d4a6900fda8fa
  # gem 'paperclip', '~> 2.3'
  #
  # To deal with file uploads via Flash uploader
  # gem 'mime-types'
  #
  # To track changes to pages and other objects
  # gem 'vestal_versions'
  #    -or-
  # gem 'paper_trail'

  group :development, :test do
    gem 'factory_girl_rails', '~> 1.0'
    gem 'factory_girl_generator'
    gem 'rspec-rails', '~> 2.1.0'
    gem 'rcov'
    gem 'random_data'
  end
RUBY


#apply "#{@partials}/_rvm.rb"           # Must be after gemfile since it runs bundler
# Set up rvm private gemset

puts "Setting up RVM gemset and installing bundled gems (may take a while) ... ".magenta

current_ruby = `rvm list`.match(/=> ([^ ]+)/)[1]
desired_ruby = ask("Which RVM Ruby would you like to use? [#{current_ruby}]".red)
desired_ruby = current_ruby if desired_ruby.blank?

gemset_name = ask("What name should the custom gemset have? [#{@app_name}]".red)
gemset_name = @app_name if gemset_name.blank?

# Let us run shell commands inside our new gemset. Use this in other template partials.
@rvm = "rvm #{desired_ruby}@#{gemset_name}"

# Create .rvmrc
file '.rvmrc', @rvm
puts "                  #{@rvm}".yellow

# Make the .rvmrc trusted
run "rvm rvmrc trust #{@app_path}"

# Since the gemset is likely empty, manually install bundler so it can install the rest
run "#{@rvm} gem install bundler"

# Install all other gems needed from Gemfile
run "#{@rvm} exec bundle install"




#apply "#{@partials}/_boilerplate.rb"
# Install Paul Irish's HTML5 Boilerplate HTML/CSS via the sporkd gem

puts "Setting up HTML5 Boilerplate with HAML, SASS, and Compass ...".magenta

file 'config/compass.rb', <<-RUBY.gsub(/^ {2}/, '')
  require 'html5-boilerplate'

  project_type = :rails
  project_path = Compass::AppIntegration::Rails.root
  http_path = "/"
  css_dir = "public/stylesheets"
  sass_dir = "app/stylesheets"
  environment = Compass::AppIntegration::Rails.env

  if Compass::AppIntegration::Rails.env == :development
    output_style = :nested
  else
    output_style = :compressed
  end
RUBY

run "#{@rvm} exec compass init rails -r html5-boilerplate -u html5-boilerplate -x sass -c config/compass.rb --force"




#apply "#{@partials}/_grid.rb"          # Must be after boilerplate since it modifies SASS files
# Set up custom 960px CSS grid

puts "Creating CSS grid framework ...".magenta

inject_into_file 'app/stylesheets/style.sass', :after => "@import partials/example\n\n" do
  <<-SASS.gsub(/^ {4}/, '')
    // Import the custom grid layout
    @import partials/grid

  SASS
end

file 'app/stylesheets/partials/_grid.sass', <<-SASS.gsub(/^ {2}/, '')
  /* From http://www.1kbgrid.com/

  $columns: 12
  $col_width: 60px
  $gutter: 20px
  $margin = $gutter / 2
  $width = $columns * ($col_width + $gutter)

  =row
    width: $width
    margin: 0 auto
    overflow: hidden

  =inner_row
    margin: 0 ($margin * -1)
    width: auto
    display: inline-block

  =col($n: 1)
    margin: 0 $margin
    overflow: hidden
    float: left
    display: inline
    width: ($n - 1) * ($col_width + $gutter) + $col_width

  =prepend($n: 1)
    margin-left: $n * ($col_width + $gutter) + $margin

  =append($n: 1)
    margin-right: $n * ($col_width + $gutter) + $margin

  // Add the .row class to a div to start a new row. Can be nested

  .row
    +row

  .row .row
    +inner_row

  // Some sample classes to get started with columns. You should create
  // your own semantic classes (e.g. section.welcome, div.blog, div.post...)

  .non_semantic_12col
    +col(12)

  .non_semantic_8col
    +col(8)

  .non_semantic_4col
    +col(4)

  .non_semantic_4col_tall
    +col(4)
    p
      line-height: 170px

  //
  // Sample HAML to draw a grid
  //
  // .row
  //   .non_semantic_12col
  //     %p 12
  // 
  // .row
  //   .non_semantic_8col
  //     %p 8
  //     .row
  //       .non_semantic_4col
  //         %p 4
  //       .non_semantic_4col
  //         %p 4
  //   .non_semantic_4col_tall
  //     %p 4
  //
  // ---------------------------------------------------
  // |                        12                       |
  // ---------------------------------------------------
  // ---------------------------------- ----------------
  // |                8               | |              |
  // ---------------------------------- |      4       |
  // ----------------- ---------------- |              |
  // |       4       | |       4      | |              |
  // ----------------- ---------------- ----------------
  //
SASS




#apply "#{@partials}/_stylesheets.rb"   # Must be after boilerplate since it modifies SASS files
# Set up custom stylesheet defaults

puts "Creating default stylesheets ...".magenta

remove_file 'app/stylesheets/partials/_example.sass'
gsub_file 'app/stylesheets/style.sass', %r{//@include html5-boilerplate;}, '@include html5-boilerplate'
gsub_file 'app/stylesheets/style.sass', %r{@import partials/example}, '//@import partials/example'

remove_file 'app/stylesheets/partials/_page.sass'
file 'app/stylesheets/partials/_page.sass', <<-SASS.gsub(/^ {2}/, '')
  @import compass/css3

  //-----------------------------------
  // Basic Styles
  //-----------------------------------

  h1, h2, h3, h4, h5, h6
    font-weight: normal

  h1
    +font-size(24px)

  h2
    +font-size(20px)

  h3
    +font-size(18px)

  h4
    +font-size(15px)

  strong, th
    font-weight: bold

  small
    // Use font-size mixin to convert to percentage for YUI
    // http://developer.yahoo.com/yui/3/cssfonts/#fontsize
    // approx 85% when base-font-size eq 13px
    +font-size(11px)

  // Add the 'required' attribute on inputs if you want to use these
  input:valid, textarea:valid

  input:invalid, textarea:invalid
    +border-radius(1px)
    +box-shadow(red, 0, 0, 5px, 0)

  .no-boxshadow input:invalid,
  .no-boxshadow textarea:invalid
    background-color: #f0dddd

  //-----------------------------------
  // HTML5 Boilerplate + http://www.1kbgrid.com/ Grid Layout
  //-----------------------------------

  body
    background-color: white

  div#container

  header#header
    background-color: #cdd9e2
    border-bottom: 1px solid #4f708b
    color: #444
    padding: 15px 0
    .title
      +col(9)
      h1
        +font-size(32px)
    .logo
      +col(3)

  nav#nav
    background-color: #456989
    border-top: 1px solid #87abc8
    border-bottom: 1px solid #e0e8f0
    +linear-gradient(color-stops(#7599b9, #456989))
    color: #fff
    padding: 10px 0
    .menu
      +col(9)
    .search
      +col(3)
      text-align: right

  div#main
    background-color: white
    color: #444
    border-top: 1px solid #c0d0e0
    padding: 15px 0
    div.content
      +col(12)
    div.main
      +col(9)
    div.aside
      +col(3)

  footer#footer
    border-top: 1px solid #b2b9bf
    border-bottom: 1px solid #c2c9cf
    background-color: #d0d9e0
    color: #333
    padding: 20px 0
    .copyright
      +col(2)
      +prepend(10)
      p
        +font-size(10px)
  
  //-----------------------------------
  // Custom Application Styles
  //-----------------------------------

SASS

append_file 'app/stylesheets/style.sass', "@import partials/buttons\n"
file 'app/stylesheets/partials/_buttons.sass', <<-SASS.gsub(/^ {2}/, '')
  // Fancy buttons from http://www.webdesignerwall.com/tutorials/css3-gradient-buttons/

  .buttons
    margin: 1em 0
    button,a.button
      display: inline-block
      vertical-align: baseline
      margin: 0 2px
      outline: none
      cursor: pointer
      text-align: center
      text-decoration: none
      font: 13px/100% Arial, Helvetica, sans-serif
      font-weight: bold
      line-height: 1.45em
      padding: .4em 1.5em .42em
      text-shadow: 0 1px 1px rgba(0,0,0,.3)
      -webkit-border-radius: 1em
      -moz-border-radius: 1em
      border-radius: 1em
      -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.2)
      -moz-box-shadow: 0 1px 2px rgba(0,0,0,.2)
      box-shadow: 0 1px 2px rgba(0,0,0,.2)
      &:hover
        text-decoration: none
      &:active
        position: relative
        top: 1px

    .bigrounded
      -webkit-border-radius: 2em
      -moz-border-radius: 2em
      border-radius: 2em
    .large
      font-size: 14px
      padding: .5em 2em .55em
    .medium
      font-size: 12px
      padding: .4em 1.5em .42em
    .small
      font-size: 11px
      padding: .2em 1em .275em

    /* gray

    .neutral
      color: #e9e9e9
      border: solid 1px #555
      background: #6e6e6e
      background: -webkit-gradient(linear, left top, left bottom, from(#888888), to(#575757))
      background: -moz-linear-gradient(top, #888888, #575757)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#888888', endColorstr='#575757')
      &:hover
        background: #616161
        background: -webkit-gradient(linear, left top, left bottom, from(#757575), to(#4b4b4b))
        background: -moz-linear-gradient(top, #757575, #4b4b4b)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#757575', endColorstr='#4b4b4b')
      &:active
        color: #afafaf
        background: -webkit-gradient(linear, left top, left bottom, from(#575757), to(#888888))
        background: -moz-linear-gradient(top, #575757, #888888)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#575757', endColorstr='#888888')

    /* white

    .white
      color: #606060
      border: solid 1px #b7b7b7
      background: #fff
      background: -webkit-gradient(linear, left top, left bottom, from(white), to(#ededed))
      background: -moz-linear-gradient(top, white, #ededed)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#ededed')
      &:hover
        background: #ededed
        background: -webkit-gradient(linear, left top, left bottom, from(white), to(#dcdcdc))
        background: -moz-linear-gradient(top, white, #dcdcdc)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#dcdcdc')
      &:active
        color: #999
        background: -webkit-gradient(linear, left top, left bottom, from(#ededed), to(white))
        background: -moz-linear-gradient(top, #ededed, white)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#ededed', endColorstr='#ffffff')

    /* blue

    .normal
      color: #d9eef7
      border: solid 1px #0076a3
      background: #0095cd
      background: -webkit-gradient(linear, left top, left bottom, from(#00adee), to(#0078a5))
      background: -moz-linear-gradient(top, #00adee, #0078a5)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#00adee', endColorstr='#0078a5')
      &:hover
        background: #007ead
        background: -webkit-gradient(linear, left top, left bottom, from(#0095cc), to(#00678e))
        background: -moz-linear-gradient(top, #0095cc, #00678e)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#0095cc', endColorstr='#00678e')
      &:active
        color: #80bed6
        background: -webkit-gradient(linear, left top, left bottom, from(#0078a5), to(#00adee))
        background: -moz-linear-gradient(top, #0078a5, #00adee)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#0078a5', endColorstr='#00adee')

    /* rosy

    .warning
      color: #fae7e9
      border: solid 1px #b73948
      background: #da5867
      background: -webkit-gradient(linear, left top, left bottom, from(#f16c7c), to(#bf404f))
      background: -moz-linear-gradient(top, #f16c7c, #bf404f)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#f16c7c', endColorstr='#bf404f')
      &:hover
        background: #ba4b58
        background: -webkit-gradient(linear, left top, left bottom, from(#cf5d6a), to(#a53845))
        background: -moz-linear-gradient(top, #cf5d6a, #a53845)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#cf5d6a', endColorstr='#a53845')
      &:active
        color: #dca4ab
        background: -webkit-gradient(linear, left top, left bottom, from(#bf404f), to(#f16c7c))
        background: -moz-linear-gradient(top, #bf404f, #f16c7c)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#bf404f', endColorstr='#f16c7c')

    /* green

    .positive
      color: #e8f0de
      border: solid 1px #538312
      background: #64991e
      background: -webkit-gradient(linear, left top, left bottom, from(#7db72f), to(#4e7d0e))
      background: -moz-linear-gradient(top, #7db72f, #4e7d0e)
      filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#7db72f', endColorstr='#4e7d0e')
      &:hover
        background: #538018
        background: -webkit-gradient(linear, left top, left bottom, from(#6b9d28), to(#436b0c))
        background: -moz-linear-gradient(top, #6b9d28, #436b0c)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#6b9d28', endColorstr='#436b0c')
      &:active
        color: #a9c08c
        background: -webkit-gradient(linear, left top, left bottom, from(#4e7d0e), to(#7db72f))
        background: -moz-linear-gradient(top, #4e7d0e, #7db72f)
        filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#4e7d0e', endColorstr='#7db72f')
SASS


append_file 'app/stylesheets/style.sass', "@import partials/flashes\n"
file 'app/stylesheets/partials/_flashes.sass', <<-SASS.gsub(/^ {2}/, '')
  //
  // Fancy boxes for Rails flash messages
  //

  !flash_notice_color = #bde5f8
  !flash_alert_color = #ffbaba

  #flash
    +col(8)
    +prepend(2)
    +append(2)

    .notice, .alert
      border: 1px solid
      margin: 0 0 20px 0
      padding: 15px
      +border-radius(8px)

    .notice
      color: $flash_notice_color - #888
      border-color: $flash_notice_color - #333
      background-color: $flash_notice_color
      +linear-gradient(color-stops($flash_notice_color + #111, $flash_notice_color - #111))

    .alert
      color: $flash_alert_color - #888
      border-color: $flash_alert_color - #333
      background-color: $flash_alert_color
      +linear-gradient(color-stops($flash_alert_color + #111, $flash_alert_color - #111))
SASS


append_file 'app/stylesheets/style.sass', "@import partials/forms\n"
file 'app/stylesheets/partials/_forms.sass', <<-SASS.gsub(/^ {2}/, '')
  //
  // FORMS
  //

  #main
    form
      margin-top: 1em
      fieldset
        margin-bottom: 1em
        padding: 1em
        border: 1px solid silver
        +border-radius(10px)
        +linear-gradient(color-stops(#fff, #f2efe9))
      
      legend
        padding: 0 6px
        font-weight: bold

      .form_input
        margin-bottom: 1em
        clear: both

      label
        display: block
        +font-size(12px)
        &.multiline
          width: 35em
        
      span.description
        +font-size(11px)
        &.required
          color: #844

      .cancel
        margin-left: 2em

      .checkbox_group
        input
          height: 1em
          vertical-align: top
        label
          display: inline
          margin-left: 4px

      input
        border: 1px solid #b5ceff
        padding: 3px
        &:focus
          background-color: #F8F8E8
          border: 1px solid #D8D800
          color: black

      textarea
        width: 99%
        height: 16em
        line-height: 1.2em
        padding: 4px
        &.tall
          height: 24em
        &.short
          height: 8em
        &:focus
          background-color: #F8F8E0
          border: 1px solid #D8D800
          color: black
SASS

append_file 'app/stylesheets/style.sass', "@import partials/tables\n"
file 'app/stylesheets/partials/_tables.sass', <<-SASS.gsub(/^ {2}/, '')
  // Tables

  table.horizontal
    margin: 20px
    text-align: left
    padding: 1em
    th
      border-bottom: 2px solid #6678b1
      font-weight: bold
      padding: 6px 8px
    td
      padding: 6px 8px
    tbody
      tr:hover
        background-color: #e8f0ff

  table.vertical
    margin: 20px
    text-align: left
    padding: 1em
    th
      font-weight: bold
      padding: 6px 8px
    td
      padding: 2px 1em
      border-bottom: 1px solid #f1eee8
      vertical-align: middle
    td:first-child
      text-align: right
      white-space: nowrap
      background-color: #f0ede7
      border-bottom: 2px solid white
      border-top: 2px solid white
      +border_radius(8px)
    tr:last-child
      border: none
    pre
      font-family: sans-serif
SASS

append_file 'app/stylesheets/style.sass', "@import partials/hacks\n"
file 'app/stylesheets/partials/_hacks.sass', <<-SASS.gsub(/^ {2}/, '')
  // Hacks
  body
    font-size: 12px
    font-family: arial
    line-height: 1.5
  
  h1
    font-size: 3em
    line-height: 1
    margin-bottom: 0.5em
  
  h2
    font-size: 2em
    margin-bottom: 0.75em
  
  h3
    font-size: 1.5em
    line-height: 1
    margin-bottom: 1em
  
  h4
    font-size: 1.2em
    line-height: 1.25
    margin-bottom: 1.25em
  
  h5
    font-size: 1em
    font-weight: bold
    margin-bottom: 1.5em
  
  p
    margin-bottom: 1.5em
    
  nav
    p
      margin-bottom: 0em
      
  blockquote, q
    color: #666
    font-style: italic
    margin: 1.5em
  
  ul, ol
    margin: 0px 1.5em 1.5em 0px
    padding-left: 1.5em
  
  dl
    margin: 0px 0px 1.5em
    display: block
    dt
      font-weight: bold
      display: block
    dd
      margin-left: 1.5em
      display: block
  
  
  
  #flash
    .notice, .alert
      padding: 10px
      +border-radius(6px)
      p
        margin-bottom: 0em
  
  #main
    form
      margin-bottom: 2em  
      
      fieldset
        +border-radius(4px)
      label
        display: inline
        font-size: 100%
      .checkbox_group
        input
          vertical-align: baseline
  
      input, textarea
        padding: 4px
        margin: 0.5em 0
        border: 1px solid #b5ceff
        
      select, input, textarea, button
        font-size: 99%
        font-family: arial
        vertical-align: baseline
      
      input:invalid, textarea:invalid
        -webkit-box-shadow: none
        +border-radius(0px)
        background-color: #FFE3EE
  
  .buttons
    button,a.button
      -webkit-border-radius: 0.3em
      -moz-border-radius: 0.3em
      border-radius: 0.3em 
  
  
  table
    margin-bottom: 1.4em
    width: 100%
    border-collapse: separate
    display: table
  
  table, td, th
    vertical-align: middle
  
  table.vertical
    td:first-child
      +border_radius(4px)
SASS

#apply "#{@partials}/_layouts.rb"       # Must be after boilerplate since it modifies HAML files
# Set up default haml layout

puts "Creating default layout ...".magenta

remove_file 'app/views/layouts/_footer.html.haml'
file 'app/views/layouts/_footer.html.haml', <<-HAML.gsub(/^ {2}/, '')
  .copyright
    %p Copyright &copy; #{Date.today.year}
HAML

remove_file 'app/views/layouts/_header.html.haml'
file 'app/views/layouts/_header.html.haml', <<-HAML.gsub(/^ {2}/, '')
  .title
    %h1 Header

  .logo
    %h1 Logo goes here
HAML

file 'app/views/layouts/_nav.html.haml', <<-HAML.gsub(/^ {2}/, '')
  .menu
    %p
      This is your navigation bar. Enjoy.

  .search
    %p
      Search box goes here.
HAML

# This needs to be kept up to date as the boilerplate and sporkd gem get updated
remove_file 'app/views/layouts/application.html.haml'
file 'app/views/layouts/application.html.haml', <<-HAML.gsub(/^ {2}/, '')
  !!! 5
  -# http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither
  -ie_html :lang => 'en', :class => 'no-js' do
    = render :partial => 'layouts/head'
    %body{ :class => "\#{controller.controller_name}" }
      #container
        %header#header
          .row
            = render :partial => 'layouts/header'
        %nav#nav
          .row
            = render :partial => 'layouts/nav'
        #main
          .row
            = render :partial => 'layouts/flashes'
          -# You MUST enclose your yielded content in at least one .row
          = yield
        %footer#footer
          .row
            = render :partial => 'layouts/footer'
      -# Javascript at the bottom for fast page loading
      = render :partial => 'layouts/javascripts'
HAML


#apply "#{@partials}/_helpers.rb"
# Set up some view helpers and partials

puts "Creating useful application_helper.rb ...".magenta

remove_file 'app/helpers/application_helper.rb'
file 'app/helpers/application_helper.rb', <<-RUBY.gsub(/^ {2}/, '')
  module ApplicationHelper

    # Help individual pages to set their HTML titles
    def title(text)
      content_for(:title) { text }
    end

    # Help individual pages to set their HTML meta descriptions
    def description(text)
      content_for(:description) { text }
    end

  end
RUBY

# Use inside forms like this:
#
# = form_for @user do |f|
#   = render '/shared/error_messages', :target => @user
file 'app/views/shared/_error_messages.html.haml', <<-HAML.gsub(/^ {2}/, '')
  - if target.errors.any?
    #errorExplanation
      %h2
        = pluralize(target.errors.count, "error")
        prohibited this record from being saved:
      %ul
        - target.errors.full_messages.each do |msg|
          %li= msg
HAML


#apply "#{@partials}/_appconfig.rb"
# Set up an APP_CONFIG[] hash from app_config.yml to allow easy configuration
# of custom settings for each app.

puts "Creating custom app configuration hash ...".magenta

initializer 'app_config.rb' do
<<-RUBY.gsub(/^ {2}/, '')
  # Load application-specific configuration from config/app_config.yml.
  # Access the config params via APP_CONFIG['param']
  APP_CONFIG = YAML.load_file("\#{Rails.root}/config/app_config.yml")
RUBY
end

file 'config/app_config.yml', <<-RUBY.gsub(/^ {2}/, '')
  # Application-specific global configuration settings.
  # These get loaded by config/initializers/app_config.rb and
  # can be accessed via APP_CONFIG[:param]

  # Example:
  #
  # superuser: mfischer
  # per_page: 20
  # array_of_arrays:
  #   - [key, val]
  #   - [key2, val2]
RUBY


#apply "#{@partials}/_rspec.rb"
# Set up rspec

puts "Setting up RSpec ... ".magenta

remove_dir 'test'

# generate 'rspec:install'
run "#{@rvm} exec rails generate rspec:install"

generators = <<-RUBY
  config.generators do |g|
      g.test_framework   :rspec, :fixture => true, :views => false
      g.integration_tool :rspec, :fixture => true, :views => true
    end
RUBY
application generators




#apply "#{@partials}/_capistrano.rb"
# Set up capistrano

puts "Setting up Capistrano ... ".magenta

run "#{@rvm} exec capify ."

# Update deploy.rb !!


#apply "#{@partials}/_application.rb"
# Update things in config/application.rb

puts "Adding password_confirmation to filter_parameters ... ".magenta
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

puts "Adding app/extras/ to autoload_paths ... ".magenta
gsub_file 'config/application.rb', /# config.autoload_paths/, 'config.autoload_paths'

puts "Turning off timestamped_migrations ...".magenta
inject_into_file 'config/application.rb', :before => "  end\nend" do
  <<-RUBY

    # Turn off timestamped migrations
    config.active_record.timestamped_migrations = false
  RUBY
end

puts "Setting up log file rotation ...".magenta
inject_into_file 'config/application.rb', :before => "  end\nend" do
  <<-RUBY

    # Rotate log files (50 files max at 1MB each)
    config.logger = Logger.new(config.paths.log.first, 50, 1048576)
  RUBY
end


#apply "#{@partials}/_friendly_id.rb"   # Must be after application.rb since it runs migrations
# Set up friendly_id

puts "Setting up friendly_id ... ".magenta

run "#{@rvm} exec rails generate friendly_id"



#apply "#{@partials}/_git.rb"           # Must be last in order to commit initial repository
# Create a .gitignore file and a new local repository, commit everything

puts "Initializing new Git repo ...".magenta

remove_file '.gitignore'
file '.gitignore', <<-CODE.gsub(/^ {2}/, '')
  .DS_Store
  .bundle
  mkmf.log
  log/*.log
  tmp/**/*
  db/*.sqlite3
  public/stylesheets/compiled/*
  public/system/*
CODE

git :init
git :add => "."
git :commit => "-am 'Initial commit.'"




#apply "#{@partials}/_demo.rb"

# Add some demo html pages. These can be deleted at any time.

puts "Creating demo pages ...".magenta

inject_into_file 'config/routes.rb', :after => ".routes.draw do\n" do
  <<-RUBY.gsub(/^ {2}/, '')

    match 'demos/grid' => 'demos#grid'
    match 'demos/text' => 'demos#text'
    match 'demos/elements' => 'demos#elements'

  RUBY
end

file 'app/controllers/demos_controller.rb', <<-RUBY.gsub(/^ {2}/, '')
  class DemosController < ApplicationController

    def grid
    end

    def text      
      flash.now[:alert] = "This is an alert"
      flash.now[:notice] = "This is a notice"
    end
    
    def elements
      flash.now[:alert] = "This is an alert"
      flash.now[:notice] = "This is a notice"
    end

  end
RUBY

file 'app/views/demos/grid.html.haml', <<-HAML.gsub(/^ {2}/, '')
  = content_for :stylesheets do
    <style type='text/css'> div#main p { font-size: 60px; text-align: center; margin: 0 0 20px 0; border: 1px solid black } </style>

  .row
    .non_semantic_12col
      %p 12

  .row
    .non_semantic_8col
      %p 8
      .row
        .non_semantic_4col
          %p 4
        .non_semantic_4col
          %p 4
    .non_semantic_4col_tall
      %p 4
HAML

file 'app/views/demos/text.html.haml', <<-HAML.gsub(/^ {2}/, '')
  .row
    .content
      %h1 This is Heading one
      %p
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam egestas sodales metus sit amet varius. Nam euismod
        bibendum ligula. Nam rhoncus, orci ac fermentum viverra, elit diam ornare neque, vel sodales ante lorem nec eros.
        Aenean accumsan volutpat diam ac mattis. Praesent et magna mi, eu ornare enim. Nam mi odio, condimentum non convallis
        eget, vestibulum non lacus. Integer sit amet lorem id ipsum ornare consequat. Integer tortor urna, mollis ullamcorper
        pellentesque vel, sollicitudin at nisi. Aliquam vitae sapien massa, a feugiat dolor. Aliquam varius euismod lorem,
        sed egestas nisi ultrices in. Ut commodo orci in urna malesuada tincidunt pellentesque diam blandit. Curabitur in sem
        a magna consequat porttitor. Morbi elementum egestas turpis sit amet consectetur. Sed velit leo, pretium vel
        tincidunt consectetur, consectetur ac neque. Vestibulum nec orci eu arcu hendrerit malesuada in vel quam. Fusce
        sollicitudin, nisl vel suscipit facilisis, quam arcu adipiscing diam, nec lacinia arcu elit non lorem. Vestibulum
        ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

      %h2 This is Heading two
      %p
        Aenean accumsan volutpat diam ac mattis. Praesent et magna mi, eu ornare enim. Nam mi odio, condimentum non convallis
        eget, vestibulum non lacus. Integer sit amet lorem id ipsum ornare consequat. Integer tortor urna, mollis ullamcorper
        a magna consequat porttitor. Morbi elementum egestas turpis sit amet consectetur. Sed velit leo, pretium vel
        tincidunt consectetur, consectetur ac neque. Vestibulum nec orci eu arcu hendrerit malesuada in vel quam. Fusce
        sollicitudin, nisl vel suscipit facilisis, quam arcu adipiscing diam, nec lacinia arcu elit non lorem. Vestibulum
        ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;
      
      %h3 This is Heading three
      %p
        pellentesque vel, sollicitudin at nisi. Aliquam vitae sapien massa, a feugiat dolor. Aliquam varius euismod lorem,
        sed egestas nisi ultrices in. Ut commodo orci in urna malesuada tincidunt pellentesque diam blandit. Curabitur in sem
        sollicitudin, nisl vel suscipit facilisis, quam arcu adipiscing diam, nec lacinia arcu elit non lorem. Vestibulum
        ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;
      
      %h4 This is Heading four
      %p
        Aenean accumsan volutpat diam ac mattis. Praesent et magna mi, eu ornare enim. Nam mi odio, condimentum non convallis
        eget, vestibulum non lacus. Integer sit amet lorem id ipsum ornare consequat. Integer tortor urna, mollis ullamcorper
        pellentesque vel, sollicitudin at nisi. Aliquam vitae sapien massa, a feugiat dolor. Aliquam varius euismod lorem,
        tincidunt consectetur, consectetur ac neque. Vestibulum nec orci eu arcu hendrerit malesuada in vel quam. Fusce
        sollicitudin, nisl vel suscipit facilisis, quam arcu adipiscing diam, nec lacinia arcu elit non lorem. Vestibulum
        ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;
      
      %h5 This is Heading five
      %p
        eget, vestibulum non lacus. Integer sit amet lorem id ipsum ornare consequat. Integer tortor urna, mollis ullamcorper
        pellentesque vel, sollicitudin at nisi. Aliquam vitae sapien massa, a feugiat dolor. Aliquam varius euismod lorem,
        sed egestas nisi ultrices in. Ut commodo orci in urna malesuada tincidunt pellentesque diam blandit. Curabitur in sem
        tincidunt consectetur, consectetur ac neque. Vestibulum nec orci eu arcu hendrerit malesuada in vel quam. Fusce
        sollicitudin, nisl vel suscipit facilisis, quam arcu adipiscing diam, nec lacinia arcu elit non lorem. Vestibulum
        ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;

      %hr

      .buttons
        %button{:type => :submit, :class => 'positive', :name => :button, :value => :save} Save Changes
        = link_to 'Cancel Changes', '/', :class => 'button neutral large'
        = link_to 'Cancel Changes', '/', :class => 'button normal large'
        = link_to 'Cancel Changes', '/', :class => 'button warning large'

      %hr

      %table.horizontal
        %thead
          %tr
            %th Column 1
            %th Column 2
            %th Column 3
        %tbody
          %tr
            %td Cell 1
            %td Cell 2
            %td Cell 3
          %tr
            %td Cell 1
            %td Cell 2
            %td Cell 3
          %tr
            %td Cell 1
            %td Cell 2
            %td Cell 3

      %hr

      %table.vertical
        %tbody
          %tr
            %td Row 1
            %td Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam egestas sodales metus sit amet varius. Nam euismod bibendum ligula. Nam rhoncus, orci ac fermentum viverra
          %tr
            %td Row 2
            %td Aenean aliquet erat at velit pellentesque posuere.
          %tr
            %td Row 3
            %td Etiam at dui nunc, in iaculis dolor. Maecenas lorem risus, pellentesque eget convallis et, ornare id elit. Donec porta suscipit tincidunt. Nam quis mauris in augue viverra tempus quis non nibh. Cras porttitor lectus cursus lacus       sagittis non volutpat tortor pharetra. Aliquam ultrices ullamcorper molestie. Integer fringilla nisl vitae justo       tempor semper.

      %hr

      = form_tag '/' do
        %fieldset
          %legend Sample form
          .form_input
            = label_tag 'Name:'
            = text_field_tag :name
            %span.description.required
              This is where you enter your name.

          .form_input
            = label_tag "Text:"
            = text_area_tag :content

          .checkbox_group
            = check_box_tag :active
            = label_tag "Check this box for great fun"

      %hr

  .row
    .main
      %p
        Aenean aliquet erat at velit pellentesque posuere. Proin euismod ultrices tellus at placerat. Proin luctus accumsan
        metus, at dignissim elit feugiat ac. Fusce et odio nec orci mollis sollicitudin. Donec diam metus, porttitor sit amet
        suscipit et, bibendum eget velit. Nam at augue felis. In rhoncus, nunc quis pharetra dapibus, nisl diam adipiscing
        sapien, ac laoreet velit neque id mauris. Mauris nisi neque, suscipit nec ornare a, euismod et leo. In varius tellus
        in turpis consequat tincidunt. Nunc tristique, nulla eget semper hendrerit, urna lacus blandit lorem, vitae imperdiet
        lacus dolor et turpis. Nullam convallis tincidunt erat, id imperdiet nibh aliquet in. Vivamus sed ante tellus, at
        lobortis nisl. Integer sed nulla eros. Nulla placerat orci quis nisl hendrerit mollis. Sed lectus justo, pulvinar
        tincidunt lobortis ut, malesuada sed ligula. Proin sed est massa. Nullam venenatis odio ac nunc molestie ullamcorper.

    .aside
      %p
        Etiam at dui nunc, in iaculis dolor. Maecenas lorem risus, pellentesque eget convallis et, ornare id elit. Donec
        porta suscipit tincidunt. Nam quis mauris in augue viverra tempus quis non nibh. Cras porttitor lectus cursus lacus
        sagittis non volutpat tortor pharetra. Aliquam ultrices ullamcorper molestie. Integer fringilla nisl vitae justo
        tempor semper.
HAML

file 'app/views/demos/elements.html.haml', <<-HAML.gsub(/^ {2}/, '')
  .row
    %h1 Title 01 Heading
    %hr/
    %h2 Level 02 Heading
    %p
      Lorem ipsum
      %em emphasised text
      dolor sit amet,
      %strong strong text
      consectetur adipisicing elit,
      %abbr{:title => ""} abbreviated text
      sed do eiusmod tempor
      incididunt ut labore et dolore magna aliqua. Ut
      %q quoted text
      enim ad minim veniam, quis nostrud exercitation
      %a{:href => "/"} link text
      ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
      %ins inserted text
      irure dolor in reprehenderit in voluptate velit esse cillum
      dolore eu fugiat nulla pariatur. Excepteur sint occaecat
      %code code text
      cupidatat
      non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    %p
      Suspendisse rhoncus, est ac sollicitudin viverra, leo orci sagittis massa, sed condimentum
      %acronym{:title => ""} acronym text
      est tortor a lectus. Curabitur porta feugiat ullamcorper. Integer lacinia mi id odio faucibus eget tincidunt nisl iaculis. Nam adipiscing hendrerit turpis, et porttitor felis sollicitudin et. Donec dictum massa ac neque accumsan tempor. Cras aliquam, ipsum sit amet laoreet hendrerit, purus
      %del deleted text
      sapien convallis dui, et porta leo ipsum ac nunc. Nullam ornare porta dui ac semper. Cras aliquam laoreet hendrerit. Quisque vulputate dolor eget mi porta vel porta nisl pretium. Vivamus non leo magna, quis imperdiet risus. Morbi tempor risus placerat tellus imperdiet fringilla.
    %blockquote
      %p I am not one who was born in the possession of knowledge; I am one who is fond of antiquity, and earnest in seeking it there.
    %p
      %cite>
        %a{:href => "/"} Confucius, The Confucian Analects
      ,  (551 BC - 479 BC)
    %h3 Level 03 Heading
    %p
      Extended paragraph.
      %a{:href => ""} Lorem ipsum
      dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
      exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
      reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint
      occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    %ol
      %li Unus
      %li Duo
      %li Tres
      %li Quattuor
    %p
      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
      anim id est laborum.
    %h3 Header 3
    %p
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
      ut labore et dolore magna aliqua.
    %h4 Unordered lists
    %ul
      %li Lorem ipsum dolor sit amet
      %li Consectetur adipisicing elit
      %li Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua
      %li Ut enim ad minim veniam
    %p
      Lorem ipsum dolor sit amet,consectetur adipisicing elit, sed do eiusmod tempor incididunt
      ut labore et dolore magna aliqua.
    %pre
      %code
        :preserve
          body { font:0.8125em/1.618 Arial, sans-serif; 
                background-color:#fff;  
                color:#111;
                }        %p
      Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit
      anim id est laborum.
    %h4 Header 4
    %p
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
      ut labore et dolore magna aliqua.
    %dl
      %dt Definition list
      %dd
        Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna
        aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
        commodo consequat.
      %dt Lorem ipsum dolor sit amet
      %dd
        Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna
        aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
        commodo consequat.
    %p
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
      ut labore et dolore magna aliqua.
    %h4 Ordered list
    %ol
      %li List item
      %li List item
      %li
        List item
        %ol
          %li List item level 2
          %li
            List item level 2
            %ol
              %li List item level 3
              %li List item level 3
    %h4 Unordered list
    %ul
      %li List item 01
      %li List item 02
      %li
        List item 03
        %ul
          %li List item level 2
          %li
            List item level 2
            %ul
              %li List item level 3
              %li List item level 3
    %p
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
      ut labore et dolore magna aliqua.
    %h4 Tables
    %table{:summary => "Jimi Hendrix albums"}
      %caption Jimi Hendrix - albums
      %thead
        %tr
          %th Album
          %th Year
          %th Price
      %tfoot
        %tr
          %td Album
          %td Year
          %td Price
      %tbody
        %tr
          %td Are You Experienced
          %td 1967
          %td $10.00
        %tr
          %td Axis: Bold as Love
          %td 1967
          %td $12.00
        %tr
          %td Electric Ladyland
          %td 1968
          %td $10.00
        %tr
          %td Band of Gypsys
          %td 1970
          %td $12.00
      %tbody
    %p
      I am
      %a{:href => "http://devkick.com/lab/tripoli/sample.php?abc123"} the a tag
      example
      %br/
      I am
      %abbr{:title => "test"} the abbr tag
      example
      %br/
      I am
      %acronym the acronym tag
      example
      %br/
      I am
      %b the b tag
      example
      %br/
      I am
      %big the big tag
      example
      %br/
      I am
      %cite the cite tag
      example
      %br/
      I am
      %code the code tag
      example
      %br/
      I am
      %del the del tag
      example
      %br/
      I am
      %dfn the dfn tag
      example
      %br/
      I am
      %em the em tag
      example
      %br/
      I am
      %font{:face => "verdana"} the font tag
      example
      %br/
      I am
      %i the i tag
      example
      %br/
      I am
      %ins the ins tag
      example
      %br/
      I am
      %kbd the kbd tag
      example
      %br/
      I am
      %q
        the q tag
        %q inside
        a q tag
      example
      %br/
      I am
      %s the s tag
      example
      %br/
      I am
      %samp the samp tag
      example
      %br/
      I am
      %small the small tag
      example
      %br/
      I am
      %span the span tag
      example
      %br/
      I am
      %strike the strike tag
      example
      %br/
      I am
      %strong the strong tag
      example
      %br/
      I am
      %sub the sub tag
      example
      %br/
      I am
      %sup the sup tag
      example
      %br/
      I am
      %tt the tt tag
      example
      %br/
      I am
      %var the var tag
      example
      %br/
      I am
      %u the u tag
      example
    %p
      This is a &lt;p&gt; with some
      %code code
      inside.
    %h3 What is Lorem Ipsum?
    %p
      %b Lorem Ipsum
      is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
    %p
      %strong This
      Lorem Ipsum HTML example is created from the parts of Placeholder Markup with Lorem Ipsum - Jon Tan,
      Emastic CSS Framework,
      Tripoli CSS Framework and
      Baseline CSS Framework .
    %address Address: somewhere, World
    %p
      %a{:href => "#"} Link
      %br/
      %strong &lt;strong&gt;
      %br/
      %del &lt;del&gt; deleted
      %br/
      %dfn &lt;dfn&gt; dfn
      %br/
      %em &lt;em&gt; emphasis
    %pre
      %code &lt;html&gt;
      %code &lt;head&gt;
      %code &lt;/head&gt;
      %code &lt;body&gt;
      %code &lt;div class = "main"&gt; &lt;div&gt;
      %code &lt;/body&gt;
      %code &lt;/html&gt;
    %tt
      \&lt;tt&gt;
      Pellentesque tempor, dui ut ultrices viverra, neque urna blandit nisi, id accumsan dolor est vitae risus.
    %hr/
    / this following markup from http://bluetrip.org/
    %dl
      %dt Description list title 01
      %dd Description list description 01
      %dt Description list title 02
      %dd Description list description 02
      %dd Description list description 03
    %table
      %caption Table Caption
      %thead
        %tr
          %th Table head th
          %td Table head td
      %tfoot
        %tr
          %th Table foot th
          %td Table foot td
      %tbody
        %tr
          %th Table body th
          %td Table body td
        %tr
          %td Table body td
          %td Table body td
    %hr/
    %form{:action => "#"}
      %fieldset
        %legend Form legend
        %div
          %label{:for => "f1"} Optional Text input:
          %input#f1{:type => "text", :value => "input text"}/
        %div
          %label{:for => "rt1"} Required Text input:
          %input#rt1{:required => "", :type => "text"}/
        %div
          %label{:for => "twp1"} Text input with pattern requirement and placeholder:
          %input{:pattern => "\\d{5}(-\\d{4})?", :placeholder => "12345-6789", :title => "a US Zip code, with or without the +4 exension", :type => "text"}/
        %div
          %label{:for => "s1"} Search input:
          %input#s1{:type => "search"}/
        %div
          %label{:for => "e1"} Email input:
          %input#e1{:type => "email"}/
        %div
          %label{:for => "u1"} URL input:
          %input#u1{:type => "url"}/
        %div
          %label{:for => "pw"} Password input:
          %input#pw{:type => "password", :value => "password"}/
        %div
          %label{:for => "f2"} Radio input:
          %input#f2{:type => "radio"}/
        %div
          %label{:for => "f3"} Checkbox input:
          %input#f3{:type => "checkbox"}/
        %div
          %label{:for => "f4"} Select field:
          %select#f4
            %option Option 01
            %option Option 02
        %div
          %label{:for => "f5"} Textarea:
          %textarea#f5{:cols => "30", :rows => "5"} Textarea text
        .buttons
          %div
            %label{:for => "f6"} Input Button:
            %button.positive#f6{:type => "button", :value => "button text"} button text
          %div
            %label{:for => "f7"} Submit Button:
            %button.normal#f7{:type => "submit", :value => "button text"} button text
    / thx peter beverloo: http://peter.sh/examples/?/html/meter-progress.html
    %p#no-support{:style => "color: red; margin-bottom: 12px;"}
      Your browser does not support these elements yet! Consider downloading a
      = succeed "." do
        %a{:href => "http://tools.peter.sh/download-latest-chromium.php"} Chromium Nightly
      %br/
    %h3 &lt;progress&gt;
    %p
      The progress element (spec:
      = succeed ")" do
        %a{:href => "http://www.whatwg.org/specs/web-apps/current-work/multipage/the-button-element.html#the-progress-element"} 4.10.16
      represents the completion progress of a task and can be both indeterminate as determinate.
    %ul.compact
      %li
        %label Indeterminate
        %progress{:max => "100"}
      %li
        %label Progress: 0%
        %progress{:max => "10", :value => "0"}
      %li
        %label Progress: 100%
        %progress{:max => "3254", :value => "3254"}
      %li
        %label Progress: 57%
        %progress{:max => "0.7", :value => "0.4"}
      %li
        %label Javascript
        %progress#progress-javascript-example
    %h3 &lt;meter&gt;
    %p
      Displaying a scalar measurement within a known range, like hard drive usage, can be done using the meter element (spec:
      = succeed ")" do
        %a{:href => "http://www.whatwg.org/specs/web-apps/current-work/multipage/the-button-element.html#the-meter-element"} 4.10.17
    %ul.compact
      %li
        %label Meter: empty
        %meter{:value => "0"}
      %li
        %label Meter: full
        %meter{:value => "1"}
      %li
        %label Meter: "a bit"
        %meter{:max => ".41", :min => ".34", :value => ".36"}
      %li
        %label Preferred usage
        %meter{:high => "200", :low => "100", :max => "250", :min => "50", :value => "120"}
      %li
        %label Too much traffic
        %meter{:high => "8192", :low => "2048", :max => "10240", :min => "1024", :value => "9216"}
      %li
        %label Optimum value
        %meter{:optimum => ".8", :value => ".5"}
      %li
        %label Javascript
        %meter#meter-javascript-example{:value => "0"}
    :javascript
      (function () {
          if (! ('position' in document.createElement ('progress'))) {
              var elements = document.querySelectorAll ('meter, progress');
              for (var i = 0, j = elements.length; i < j; i++) {
                elements [i].style.border = "1px solid red";
                elements [i].style.height = "12px";
                elements [i].style.display = "inline-block";
                elements [i].style.webkitAppearance = "none";
              }
              
              return ;
          }
          
          document.getElementById ('no-support').style.display = 'none';
          
          /** Setup the <progress> JavaScript example **/
          var progressExample = document.getElementById ('progress-javascript-example');
          progressExample.min = 50;
          progressExample.max = 122;
              
          setInterval (function ()
          {
              progressExample.value = progressExample.min + Math.random () * (progressExample.max - progressExample.min);
          
          }, 1000);
          
          /** We'd like some fancy <meter> examples too **/
          var meterExample = document.getElementById ('meter-javascript-example');
          meterExample.min = 0;
          meterExample.max = 100;
          meterExample.value = 50;
          meterExample.low  = 20;
          meterExample.high = 80;
          meterExample.optimum = 65;
              
          setInterval (function ()
          {
              meterExample.value   = meterExample.min + Math.random () * (meterExample.max - meterExample.min);
              meterExample.optimum = 65 + (5 - Math.random () * 10);
          
          }, 1000);
          
      })();
    
    
HAML


puts "\n========================================================="
puts " INSTALLATION COMPLETE!".yellow.bold
puts "=========================================================\n\n\n"
