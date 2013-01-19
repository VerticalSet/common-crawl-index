require 'spec_helper'
describe CommonCrawlIndex do

  AMAZON_ACCESS_KEY_ID = ENV['AMAZON_ACCESS_KEY_ID']
  AMAZON_SECRET_ACCESS_KEY = ENV['AMAZON_SECRET_ACCESS_KEY']

  it "should init successfully" do
    settings = {
      :access_key_id => "access_key",
      :secret_access_key => "secret_key",
      :cc_index_path => "s3://aws-publicdatasets/common-crawl/projects/url-index/url-index.1356128792" # optional
    }

    CommonCrawlIndex::Client.init(settings)

    final_settings = CommonCrawlIndex::Client.class_variable_get(:@@settings)

    final_settings.should == settings
  end

  it "should initialize client" do
    client = CommonCrawlIndex::Client.new(AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY)

    client.find_by_prefix("http://www.google.com/") do |url_data|
      puts url_data
    end
  end
end