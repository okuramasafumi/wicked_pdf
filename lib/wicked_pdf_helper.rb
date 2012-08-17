module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(*sources)
    
    if Rails.root.kind_of?(Pathname)
      root_pathname = Rails.root
    elsif Rails.root.kind_of?(String)
      root_obj = Pathname(Rails.root)
    end

    css_dir = root_obj.join('public','stylesheets')
    
    begin
      sources.collect { |source|
        "<style type='text/css'>#{File.read(css_dir.join(source+'.css'))}</style>"
      }.join("\n").html_safe
    rescue NoMethodError
      sources.collect { |source|
        "<style type='text/css'>#{File.read(css_dir.join(source+'.css'))}</style>"
      }.join("\n")
    end
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag "file:///#{root_obj.join('public', 'images', img)}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    javascript_src_tag "file:///#{root_obj.join('public','javascripts',jsfile)}", options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    begin
      sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n").html_safe
    rescue NoMethodError
      sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n")
    end
  end

  module Assets
    def wicked_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source|
        "<style type='text/css'>#{read_asset(source+".css")}</style>"
      }.join("\n").html_safe
    end

    def wicked_pdf_image_tag(img, options={})
      image_tag "file://#{asset_pathname(img).to_s}", options
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      javascript_include_tag "file://#{asset_pathname(jsfile).to_s}", options
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect { |source|
        "<script type='text/javascript'>#{read_asset(source+".js")}</script>"
      }.join("\n").html_safe
    end

    private

    def asset_pathname(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          # asset_path returns an absolute URL using asset_host if asset_host is set
          asset_path(source)
        else
          File.join(Rails.public_path, asset_path(source))
        end
      else
        Rails.application.assets.find_asset(source).pathname
      end
    end

    def read_asset(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          require 'open-uri'
          open(asset_pathname(source)) {|f| f.read }
        else
          IO.read(asset_pathname(source))
        end
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end
  end
end
