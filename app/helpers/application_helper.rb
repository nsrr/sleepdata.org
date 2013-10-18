module ApplicationHelper

    def mac?
      !!(ua =~ /Mac OS X/)
    end

    def windows?
      !!(ua =~ /Windows/)
    end

    def linux?
      !!(ua =~ /Linux/)
    end

    def ua
      request.env['HTTP_USER_AGENT']
    end

    def site_prefix
      "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
    end
end
