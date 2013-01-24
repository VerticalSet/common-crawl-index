# CommonCrawlIndex

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'common-crawl-index'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install common-crawl-index

## Usage

When using with Rails in `config/initializers/common_crawl_index.rb`

```ruby
CommonCrawlIndex::Client.config({
  :access_key_id =>  "amazon aws access_key",
  :secret_access_key => "amazon aws secret_key",
  :cc_index_path => "s3://aws-publicdatasets/common-crawl/projects/url-index/url-index.1356128792" # optional
})
```

And to find URLs matching certain prefix use following syntax

```ruby
client = CommonCrawlIndex::Client.new(AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY)

# or

client = CommonCrawlIndex::Client.new() # already configured

url = "http://www.amazon.com/"

client.find_by_prefix(url) do |url_data|
  # get all URLs starting with http://www.amazon.com/
end
```

See `spec/basic_spec.rb` for more examples on usage.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
