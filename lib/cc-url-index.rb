require "cc-url-index/version"
#require 'rubygems'
require 'aws-sdk'
require 'open3'


module CommonCrawlIndex
  class Client
    @@settings = {
      :access_key_id => nil,
      :secret_access_key => nil,
      :cc_index_path => "s3://aws-publicdatasets/common-crawl/projects/url-index/url-index.1356128792"
    }

    def self.init(settings = {})
      @@settings = @@settings.merge(settings)
    end

    HEADER_OFFSET = 8

    def initialize(access_key_id=nil, secret_access_key=nil, cc_index_path = nil)
      @s3=AWS::S3.new(
        :access_key_id => access_key_id || @@settings[:access_key_id],
        :secret_access_key => secret_access_key || @@settings[:secret_access_key]
      )

      @cc_index_path = cc_index_path || @@settings[:cc_index_path]

      proto,unused,@bucket_name,*rest=@cc_index_path.chomp.split File::SEPARATOR
      raise ArgumentError, "#{__FILE__}: Unknown S3 Protocol #{proto}" unless proto=~/^s3/
      @object_name=File.join rest

      @block_size, @index_block_count = read( (0..7) ).unpack("LL")
    end

    def find_by_prefix(url, exact_match = false, &proc_block)
      next_block = 0
      while next_block < @index_block_count
        next_block = get_next_block_id(url, next_block)
      end
      get_matching_urls_from_data_blocks(next_block, url, exact_match, &proc_block)
    end

    def self.normalize_url(url, append_schema = true)
      url_to_find = url
      norm_url_to_find = URI(url_to_find)
      norm_url_to_find.host = norm_url_to_find.host.split(".").reverse.join(".")
      norm_url = norm_url_to_find.to_s
      norm_url = norm_url[norm_url.index("\/\/")+2..-1]
      norm_url = ":" + norm_url_to_find.scheme if append_schema
      norm_url
    end

    private

    def s3_object
      @s3_object ||= @s3.buckets[@bucket_name].objects[@object_name]
    end

    def get_matching_urls_from_data_blocks(start_block, url_to_find, exact_match, &proc_block)

      norm_url = Client.normalize_url(url_to_find, false)
      norm_url_length = norm_url.length

      first_match_found = false

      cur_block_index = start_block
      cur_block = read_block(start_block)
      cur_loc = 0

      end_found = false
      while(!end_found)
        if cur_block[cur_loc..cur_loc] == "\x00" || cur_loc >= @block_size
          cur_block_index += 1
          cur_block = read_block(cur_block_index)
          cur_loc = 0
        end
        nil_loc = cur_block.index("\x00", cur_loc)
        url = cur_block[cur_loc..nil_loc-1]
        if url[0..norm_url_length-1] == norm_url
          url_data = {}
          url_data[:url] = url
          if first_match_found
            if exact_match
              if url == Client.normalize_url(url_to_find, true)
                proc_block.call(url_data)
              else
                proc_block.call(nil)
              end
              break
            end
          else
            first_match_found = true
          end
          break if proc_block.call(url_data) == false
        else
          if first_match_found
            break
          end
        end
        cur_loc = nil_loc + 32 + 1
      end
    end

    def read(target_range)
      s3_object.read( :range => target_range )
    end

    def read_block(block_id)
      puts "Reading block No: #{block_id}"
      start = HEADER_OFFSET + @block_size * block_id
      target_range = (start..start+@block_size-1)
      cur_block = read(target_range)
    end

    # search within
    def get_next_block_id(url_to_find, block_id)
      norm_url = Client.normalize_url(url_to_find, false)
      cur_block = read_block(block_id)
      #puts cur_block[0..1000].inspect

      not_found = true
      cur_loc = 4
      last_block_num = nil

      counter = 0

      while not_found # && counter < 3

        counter += 1

        # read from cur_loc
        next_nil_loc = cur_block.index("\x00", cur_loc)

        break if next_nil_loc == cur_loc + 1

        cur_prefix = cur_block[cur_loc..next_nil_loc-1]
        cur_block_num = cur_block[next_nil_loc+1..next_nil_loc+1+4].unpack("L")[0]

        if cur_prefix >= norm_url
          next_block = last_block_num || cur_block_num
          return next_block
        else
          #puts "Less"
        end

        break if cur_loc >= @block_size

        last_block_num = cur_block_num
        cur_loc = next_nil_loc + 1 + 4
      end

    end
  end
end