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

    client.should_not == nil
  end

  it "should find by prefix" do
    client = CommonCrawlIndex::Client.new(AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY)

    total_urls_to_test = 100

    url = "http://www.amazon.com/"
    normalized_url = CommonCrawlIndex::Client.normalize_url(url, false)
    normalized_url_length = normalized_url.length

    client.find_by_prefix(url) do |url_data|
      total_urls_to_test -= 1
      prefix = url_data[:normalized_url][0..normalized_url_length-1]
      normalized_url.should eql prefix
      false if total_urls_to_test == 0
    end
  end

  it "should match an exact url" do
    client = CommonCrawlIndex::Client.new(AMAZON_ACCESS_KEY_ID, AMAZON_SECRET_ACCESS_KEY)

    client.find_by_prefix("http://www.google.com/", true) do |url_data|
      expected_url_data = {:normalized_url=>"com.google.www/:http", :url=>"http://www.google.com/", :arcSourceSegmentId=>1346823846039, :arcFileDate=>1346870285062, :arcFilePartition=>14, :arcFileOffset=>38347629, :compressedSize=>6198}
      url_data.should eql expected_url_data
    end
  end

  it "should normalize the urls correctly" do
    normalized_url =  CommonCrawlIndex::Client.normalize_url("http://www.google.com/test/path")
    normalized_url.should == "com.google.www/test/path:http"
  end

  it "should normalize the urls correctly without scheme" do
    normalized_url =  CommonCrawlIndex::Client.normalize_url("http://www.google.com/test/path", false)
    normalized_url.should == "com.google.www/test/path"
  end

  it "should denormalize the urls correctly" do
    url =  CommonCrawlIndex::Client.denormalize_url("com.google.www/test/path:http")
    url.should == "http://www.google.com/test/path"
  end

  it "should denormalize the urls correctly without scheme" do
    url =  CommonCrawlIndex::Client.denormalize_url("com.google.www/test/path", false)
    url.should == "http://www.google.com/test/path"
  end
end