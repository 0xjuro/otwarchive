# note, if you modify this file you have to restart the server or console
# grabbed from http://code.google.com/p/sanitizeparams/ and tweaked
module SanitizeParams

  def get_white_list_sanitizer
    @white_list_sanitizer ||= HTML::WhiteListSanitizer.new
  end

  def get_full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end

  # strip comment and <!whatever> tags like DOCTYPE
  def strip_comments(text)
    return if text.nil?
    text.gsub!(/<!--(.*?)-->[\n]?/m, "")
    text.gsub!(/<!(.*?)>[\n]?/m, "")
    return text
  end
  
  # replace evil msword curly quotes
  def fix_quotes(text)
    return "" if text.nil?
    text.gsub! "<3", "&#60;3"
    text.gsub! "\342\200\230", "'"
    text.gsub! "\342\200\231", "'"
#    text.gsub! "\221", "'"
#    text.gsub! "\222", "'"
    text.gsub! "\342\200\234", '"'
    text.gsub! "\342\200\235", '"'
#    text.gsub! "\223", '"'
#    text.gsub! "\224", '"'
    return text
  end
  
  # strip all html 
  def sanitize_fully(text)
    return "" if text.nil?
    text.gsub!(/\xc2\x92/um, "")
    get_full_sanitizer
    @full_sanitizer.sanitize(text)
  end  
  
  # strip dangerous html
  # if :tags => %w(list of tags) and :attributes => %w(list of attributes)
  # are passed as options, only those tags/attributes will be allowed. 
  def sanitize_whitelist(text, options = {})
    return "" if text.nil?
    text.gsub!(/\xc2\x92/um, "")
    get_white_list_sanitizer
    @white_list_sanitizer.sanitize(text, options)
  end

  def sanitize_params(params = params)
    get_white_list_sanitizer
    get_full_sanitizer
    params = walk_hash(params) if params
  end

  def walk_hash(hash)
    hash.keys.each do |key|
      if hash[key].is_a? String
        hash[key].strip!
        if ArchiveConfig.FIELDS_ALLOWING_HTML.include?(key.to_s)
          hash[key] = @white_list_sanitizer.sanitize(fix_quotes(hash[key]))
        # prevent invisible titles
        elsif key.to_s == 'title'
          hash[key].gsub!("<", "&lt;")
          hash[key].gsub!(">", "&gt;")
        else
          hash[key] = @full_sanitizer.sanitize(hash[key])
        end
      elsif hash[key].is_a? Hash
        hash[key] = walk_hash(hash[key])
      elsif hash[key].is_a? Array
        hash[key] = walk_array(hash[key])
      end
    end
    hash
  end

  def walk_array(array)
    array.each_with_index do |el,i|
      if el.is_a? String
        array[i] = @full_sanitizer.sanitize(el)
      elsif el.is_a? Hash
        array[i] = walk_hash(el)
      elsif el.is_a? Array
        array[i] = walk_array(el)
      end
    end
    array
  end

end
