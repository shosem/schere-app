module VenuesHelper
  def safe_url(url)
    return unless url
    begin    
      scheme = URI.parse(url).scheme
    rescue URI::InvalidURIError
      return nil
    end

    if ["http", "https"].include?(scheme)
      return url
    else
      return nil
    end
  end
end
