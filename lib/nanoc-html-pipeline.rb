# encoding: utf-8

# Load requirements
require 'nanoc3'
require 'html/pipeline'


# puts pipeline_filters.map{|x| [x[0], x[1]] }

class NanocHtmlPipeline < Nanoc::Filter

  def self.filter_key(s) 
    s.to_s.downcase.to_sym
  end

  def self.is_filter(f)
    f < HTML::Pipeline::Filter
  rescue LoadError, ArgumentError
    false
  end

  FILTERS = HTML::Pipeline.constants.reduce({}) do |h, symbol|
    begin
      f = HTML::Pipeline.const_get(symbol)
      if self.is_filter(f)
        h.merge(self.filter_key(symbol) => f)
      else 
        h
      end
    rescue LoadError
      h
    end
    # puts klass
  end

  # Runs the content through [HTML::Pipline](https://github.com/jch/html-pipeline).
  # Takes a `:pipeline` option as well as any additional context options.

  # @param [String] content The content to filter
  #
  # @return [String] The filtered content
  def run(content, params={})
    # Get options
    options = {:pipeline => []}.merge(params)

    filters = options.delete(:pipeline).map do |f|
      if self.class.is_filter(f)
        f
      else
        key = self.class.filter_key(f)
        FILTERS[key]
      end
    end

    HTML::Pipeline.new(filters, options).to_html(content)
  end

end

Nanoc::Filter.register '::NanocHTMLPipeline', :html_pipeline
