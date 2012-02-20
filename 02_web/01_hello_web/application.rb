
require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'json'
require 'roxml'
require 'yaml'
require 'lingua/stemmer'  # ruby-stemmer, a stemming lib


class ExampleServer < Sinatra::Base
  CONTENT_TYPES = {
    'txt'  => 'text/plain',
    'yaml'  => 'text/plain',
    'xml'  => 'text/xml',
    'json' => 'application/json'
  }

  #
  # helper method that takes a ruby object and returns a string
  # representation in the specified format
  #
  def reformat(data, format=params[:format])
    content_type CONTENT_TYPES[format], :charset => 'utf-8'
    case format
    when 'txt'
      data.to_s
    when 'yaml'
      YAML::dump(data)
    when 'xml'
      data.to_xml
    when 'json'
      data.to_json
    else
      raise 'Unknown format: ' + format
    end
  end

  #
  # piglatin generator (for the most part)
  # returns a string of piglatin given a string of english.
  # multiple words are separated by a '+' sign
  #
  def piglatin(data)
    if data
      # + means space
      words = data.split("+")
      piglatin_words = []

      words.each do |word|
        # vowel?
        if word[0].match(/[a,e,i,o,u]/)
          word = word + "way"
        # 'qu' at front?
        elsif word[0,2] == "qu"
          word = word[2..-1] + "quay"
        # consonant?
        elsif word[0].match(/[^a,e,i,o,u,0-9]/)
          word = word[1..-1] + word[0] + "ay"
        end

        piglatin_words.push(word)
      end

      piglatin_words.join(" ")
    else
      "Error: need input"
    end
  end

  #
  # stemming algorithm returns list of tokens from the
  # snowball stemming lib a la ruby-stemmer
  #
  def stem(data)
    if data
      words = data.split(/[+,_]|%20/)  # split on '+', '_', or '%20'
      tokens = []

      words.each do |word|
        tokens.push(Lingua.stemmer(word, :language => "en"))
      end

      tokens.join(",")
    else
      "Error: need input"
    end
  end

  #
  # a basic time service, a la:
  # http://localhost:4567/time.txt (or .xml or .json or .yaml)
  #
  get '/time.?:format?' do 
    reformat({ :time => Time.now })
  end

  #
  # outputs a message from the url,
  # a la : http://localhost:4567/echo.format/foo
  #
  get '/echo.?:format?/:message' do
    reformat({ :echo => params[:message] })
  end

  #
  # outputs a message from the url,
  # a la : http://localhost:4567/echo.format?message=foo
  #
  get '/echo.?:format?' do
    reformat({ :echo => params[:message] })
  end

  #
  # outputs the reverse of the message,
  # a la : http://localhost:4567/reverse.format/foo
  #
  get '/reverse.?:format?/:message' do
    reformat({ :message => params[:message], :reverse => params[:message].reverse })
  end

  #
  # outputs the reverse of the message,
  # a la : http://localhost:4567/reverse.format?message=foo
  #
  get '/reverse.?:format?' do
    reformat({ :message => params[:message], :reverse => params[:message].reverse })
  end

  #
  # outputs a pig latin string from given english,
  # a la : http://localhost:4567/piglatin.format/foo
  #
  get '/piglatin.?:format?/:message' do
    reformat({ :message => params[:message], :piglatin => piglatin(params[:message]) })
  end

  #
  # outputs a pig latin string from given english,
  # a la : http://localhost:4567/piglatin.format?message=foo
  #
  get '/piglatin.?:format?' do
    reformat({ :message => params[:message], :piglatin => piglatin(params[:message]) })
  end

  #
  # outputs a comma separated list of stemmed tokens,
  # a la : http://localhost:4567/stem.format/foo
  #
  get '/snowball.?:format?/:message' do
    reformat({ :snowball => stem(params[:message]) })
  end

  #
  # outputs a comma separated list of stemmed tokens,
  # a la : http://localhost:4567/stem.format?message=foo
  #
  get '/snowball.?:format?' do
    reformat({ :snowball => stem(params[:message]) })
  end

  run! if app_file == $0
end
