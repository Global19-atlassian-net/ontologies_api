class AnnotatorController < ApplicationController
  namespace "/annotator" do

    post do
      process_annotation
    end

    get do
      process_annotation
    end

    # execute an annotator query
    def process_annotation(params=nil)
      params ||= @params
      text = params["text"]
      raise error 400, "A text to be annotated must be supplied using the argument text=<text to be annotated>" if text.nil? || text.strip.empty?
      ontologies = restricted_ontologies(params)
      acronyms = ontologies.map {|o| o.acronym}
      semantic_types = semantic_types_param
      max_level = params["max_level"].to_i || 0
      mapping_types = params["mappings"]

      if mapping_types
        mapping_types = mapping_types.is_a?(Array) ? mapping_types : []
      end
      exclude_nums = params["exclude_numbers"].eql?("true")
      stop_words = params["stopWords"]
      min_term_size = params["minTermSize"]

      if min_term_size
        min_term_size = min_term_size.to_i
      end
      annotator = Annotator::Models::NcboAnnotator.new

      unless stop_words.nil?
        annotator.stop_words = stop_words
      end
      annotations = annotator.annotate(text, 
                                       acronyms,
                                       semantic_types, 
                                       exclude_nums, 
                                       max_level,
                                       expand_with_mappings=mapping_types,
                                       min_term_size)
      reply 200, annotations
    end

    get '/dictionary' do
      annotator = Annotator::Models::NcboAnnotator.new
      annotator.generate_dictionary_file
    end

    get '/cache' do
      annotator = Annotator::Models::NcboAnnotator.new
      annotator.create_term_cache
    end

    private

    def get_page_params(text, args={})
      return args
    end
  end
end

