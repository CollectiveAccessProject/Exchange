# Exchange
A digital platform for creating, sharing and reusing learning resources – collections of assets sources from a multitude of sources

## Pre-Setup

### ElasticSearch

Before you fire up the app, make sure you have [ElasticSearch](https://www.elastic.co/products/elasticsearch) up+running, because we rely on it for search indexing.
On a Mac with [homebrew](http://brew.sh/) installed, you could simply do this:

    brew install elasticsearch
    elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml
    
This is going to block your Terminal with the ElasticSearch process until you kill it with Ctrl-C.

### Database

The default database setup for the development environment
(see [Configuring Rails](http://guides.rubyonrails.org/configuring.html)) assumes 
there's a local MySQL database `exchange` with username `exchange` and password
`exchange`. See `config/database.yml`.

Next, run `$ rake db:migrate RAILS_ENV=development` to set up the database.

## Startup 

You can either start a server by hand: 

`$ rails server` 

or run it through RubyMine once you have your project set up there.
Go to `Run > Run ...` and select the development environment.
