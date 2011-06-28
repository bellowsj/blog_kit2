class UrlValidator < ActiveModel::EachValidator
  def initialize(options)
    super

    @domain = options[:domain]
    @permissible_schemes = options[:schemes] || %w(http https)
    @error_message = options[:message] || 'is not a valid url'
  end

  def validate_each(record, attribute, value)
    if URI::regexp(@permissible_schemes).match(value)
      begin
        uri = URI.parse(value)
        if @domain
          record.errors.add(attribute, 'does not belong to domain', :value => value) unless uri.host == @domain || uri.host.ends_with?(".#{@domain}")
        end
      rescue URI::InvalidURIError
        record.errors.add(attribute, @error_message, :value => value)
      end
    else
      record.errors.add(attribute, @error_message, :value => value)
    end
  end
end
