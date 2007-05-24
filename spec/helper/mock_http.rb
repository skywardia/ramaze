require 'ramaze'
require 'rack/mock'

module Ramaze
  module Adapter
    class Fake < Base
    end
  end
end

module MockHTTP
  DEFAULTS = {
    'REMOTE_ADDR' => '127.0.0.1'
  }

  MOCK_URI = URI::HTTP.build(
    :host => 'localhost',
    :port => 80
  )

  FISHING = {
    :input => :input,
    :referrer => 'HTTP_REFERER',
    :referer => 'HTTP_REFERER',
    :cookie => 'HTTP_COOKIE',
  }

  MOCK_REQUEST = ::Rack::MockRequest.new(Ramaze::Adapter::Fake)

  def get(*args)    mock_request(:get,    *args) end
  def put(*args)    mock_request(:put,    *args) end
  def post(*args)   mock_request(:post,   *args) end
  def delete(*args) mock_request(:delete, *args) end

  def mock_request(meth, path, query = {})
    uri, options = process_request(path, query)
    MOCK_REQUEST.send(meth, uri, DEFAULTS.merge(options))
  end

  def process_request(path, query)
    options = {}
    FISHING.each{|key, value|
      options[value] = query.delete(key)}
    [create_url(path, query), options]
  end

  def create_url(path, query)
    uri = MOCK_URI.dup
    uri.path = path
    uri.query = make_query(query)
    uri.to_s
  end

	def make_query query
		return query unless query && query.class == Hash
    query.inject([]) do |s, (key, value)|
			s + [CGI::escape(key) + "=" + CGI::escape(value)]
    end.join('&')
	end
end
