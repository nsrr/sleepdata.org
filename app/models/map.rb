class Map
  MAP_STATES_AND_CODES = [["Alaska", "us-ak"], ["Alabama", "us-al"], ["Arkansas", "us-ar"], ["Arizona", "us-az"], ["California", "us-ca"], ["Colorado", "us-co"], ["Connecticut", "us-ct"], ["District of Columbia", "us-dc"], ["Delaware", "us-de"], ["Florida", "us-fl"], ["Georgia", "us-ga"], ["Hawaii", "us-hi"], ["Iowa", "us-ia"], ["Idaho", "us-id"], ["Illinois", "us-il"], ["Indiana", "us-in"], ["Kansas", "us-ks"], ["Kentucky", "us-ky"], ["Louisiana", "us-la"], ["Massachusetts", "us-ma"], ["Maryland", "us-md"], ["Maine", "us-me"], ["Michigan", "us-mi"], ["Minnesota", "us-mn"], ["Missouri", "us-mo"], ["Mississippi", "us-ms"], ["Montana", "us-mt"], ["North Carolina", "us-nc"], ["North Dakota", "us-nd"], ["Nebraska", "us-ne"], ["New Hampshire", "us-nh"], ["New Jersey", "us-nj"], ["New Mexico", "us-nm"], ["Nevada", "us-nv"], ["New York", "us-ny"], ["Ohio", "us-oh"], ["Oklahoma", "us-ok"], ["Oregon", "us-or"], ["Pennsylvania", "us-pa"], ["Rhode Island", "us-ri"], ["South Carolina", "us-sc"], ["South Dakota", "us-sd"], ["Tennessee", "us-tn"], ["Texas", "us-tx"], ["Utah", "us-ut"], ["Virginia", "us-va"], ["Vermont", "us-vt"], ["Washington", "us-wa"], ["Wisconsin", "us-wi"], ["West Virginia", "us-wv"], ["Wyoming", "us-wy"]].sort{|a,b| a[0] <=> b[0]}
  MAP_COUNTRIES_AND_CODES = [["Andorra", "ad"], ["United Arab Emirates", "ae"], ["Afghanistan", "af"], ["Antigua and Barbuda", "ag"], ["Albania", "al"], ["Armenia", "am"], ["Angola", "ao"], ["Argentina", "ar"], ["Austria", "at"], ["Australia", "au"], ["Azerbaijan", "az"], ["Bosnia and Herzegovina", "ba"], ["Barbados", "bb"], ["Bangladesh", "bd"], ["Belgium", "be"], ["Burkina Faso", "bf"], ["Bulgaria", "bg"], ["Bahrain", "bh"], ["Burundi", "bi"], ["Benin", "bj"], ["Bajo Nuevo Bank (Petrel Is.)", "bjn"], ["Brunei", "bn"], ["Bolivia", "bo"], ["Brazil", "br"], ["The Bahamas", "bs"], ["Bhutan", "bt"], ["Botswana", "bw"], ["Belarus", "by"], ["Belize", "bz"], ["Canada", "ca"], ["Democratic Republic of the Congo", "cd"], ["Central African Republic", "cf"], ["Republic of Congo", "cg"], ["Switzerland", "ch"], ["Ivory Coast", "ci"], ["Chile", "cl"], ["Cameroon", "cm"], ["China", "cn"], ["Cyprus No Mans Area", "cnm"], ["Colombia", "co"], ["Costa Rica", "cr"], ["Cuba", "cu"], ["Cyprus", "cy"], ["Northern Cyprus", "cyn"], ["Czech Republic", "cz"], ["Germany", "de"], ["Djibouti", "dj"], ["Denmark", "dk"], ["Dominica", "dm"], ["Dominican Republic", "do"], ["Algeria", "dz"], ["Ecuador", "ec"], ["Estonia", "ee"], ["Egypt", "eg"], ["Western Sahara", "eh"], ["Eritrea", "er"], ["Spain", "es"], ["Ethiopia", "et"], ["Finland", "fi"], ["Fiji", "fj"], ["Faroe Islands", "fo"], ["France", "fr"], ["Gabon", "ga"], ["United Kingdom", "gb"], ["Grenada", "gd"], ["Georgia", "ge"], ["Ghana", "gh"], ["Greenland", "gl"], ["Gambia", "gm"], ["Guinea", "gn"], ["Equatorial Guinea", "gq"], ["Greece", "gr"], ["Guatemala", "gt"], ["Guinea Bissau", "gw"], ["Guyana", "gy"], ["Honduras", "hn"], ["Croatia", "hr"], ["Haiti", "ht"], ["Hungary", "hu"], ["Indonesia", "id"], ["Ireland", "ie"], ["Israel", "il"], ["India", "in"], ["Iraq", "iq"], ["Iran", "ir"], ["Iceland", "is"], ["Italy", "it"], ["Jamaica", "jm"], ["Jordan", "jo"], ["Japan", "jp"], ["Siachen Glacier", "kas"], ["Kenya", "ke"], ["Kyrgyzstan", "kg"], ["Cambodia", "kh"], ["Comoros", "km"], ["Saint Kitts and Nevis", "kn"], ["North Korea", "kp"], ["South Korea", "kr"], ["Kosovo", "kv"], ["Kuwait", "kw"], ["Kazakhstan", "kz"], ["Laos", "la"], ["Lebanon", "lb"], ["Saint Lucia", "lc"], ["Liechtenstein", "li"], ["Sri Lanka", "lk"], ["Liberia", "lr"], ["Lesotho", "ls"], ["Lithuania", "lt"], ["Luxembourg", "lu"], ["Latvia", "lv"], ["Libya", "ly"], ["Morocco", "ma"], ["Monaco", "mc"], ["Moldova", "md"], ["Montenegro", "me"], ["Madagascar", "mg"], ["Macedonia", "mk"], ["Mali", "ml"], ["Myanmar", "mm"], ["Mongolia", "mn"], ["Mauritania", "mr"], ["Malta", "mt"], ["Mauritius", "mu"], ["Malawi", "mw"], ["Mexico", "mx"], ["Malaysia", "my"], ["Mozambique", "mz"], ["Namibia", "na"], ["Niger", "ne"], ["Nigeria", "ng"], ["Nicaragua", "ni"], ["Netherlands", "nl"], ["Norway", "no"], ["Nepal", "np"], ["New Zealand", "nz"], ["Oman", "om"], ["Panama", "pa"], ["Peru", "pe"], ["Papua New Guinea", "pg"], ["Spratly Islands", "pga"], ["Philippines", "ph"], ["Pakistan", "pk"], ["Poland", "pl"], ["Puerto Rico", "pr"], ["Portugal", "pt"], ["Palau", "pw"], ["Paraguay", "py"], ["Qatar", "qa"], ["Romania", "ro"], ["Republic of Serbia", "rs"], ["Russia", "ru"], ["Rwanda", "rw"], ["Saudi Arabia", "sa"], ["Solomon Islands", "sb"], ["Scarborough Reef", "scr"], ["Sudan", "sd"], ["Sweden", "se"], ["Serranilla Bank", "ser"], ["Singapore", "sg"], ["Slovenia", "si"], ["Slovakia", "sk"], ["Sierra Leone", "sl"], ["San Marino", "sm"], ["Senegal", "sn"], ["Somalia", "so"], ["Somaliland", "sol"], ["Suriname", "sr"], ["South Sudan", "ss"], ["Sao Tome and Principe", "st"], ["El Salvador", "sv"], ["Syria", "sy"], ["Swaziland", "sz"], ["Chad", "td"], ["Togo", "tg"], ["Thailand", "th"], ["Tajikistan", "tj"], ["East Timor", "tl"], ["Turkmenistan", "tm"], ["Tunisia", "tn"], ["Turkey", "tr"], ["Trinidad and Tobago", "tt"], ["Taiwan", "tw"], ["United Republic of Tanzania", "tz"], ["Ukraine", "ua"], ["Uganda", "ug"], ["United States Minor Outlying Islands", "um"], ["United States of America", "us"], ["Uruguay", "uy"], ["Uzbekistan", "uz"], ["Vatican", "va"], ["Saint Vincent and the Grenadines", "vc"], ["Venezuela", "ve"], ["United States Virgin Islands", "vi"], ["Vietnam", "vn"], ["Vanuatu", "vu"], ["Yemen", "ye"], ["South Africa", "za"], ["Zambia", "zm"], ["Zimbabwe", "zw"]].sort{|a,b| a[0] <=> b[0]}

  # JSON.stringify(Highcharts.maps["countries/us/us-all"]["features"].map(function(object) { return [object['properties']['hc-key'], object['properties']['name']]; }))
  def self.states_for_map
    filter_by_key(:state_code, MAP_STATES_AND_CODES)
  end

  # JSON.stringify(Highcharts.maps["custom/world"]["features"].map(function(object) { return [object['properties']['hc-key'], object['properties']['name']]; }))
  def self.countries_for_map
    filter_by_key(:country_code, MAP_COUNTRIES_AND_CODES)
  end

  def self.update_existing_users!
    User.all.order(:id).each do |u|
      if u.state_code.present? or u.country_code.present?
        Rails.logger.debug "USER ##{u.id} EXISTS: '#{u.state_code}' '#{u.country_code}'"
        next
      end
      results = Geocoder.search(u.current_sign_in_ip)
      result = results.first
      if result
        country = result.country.to_s
        country = "United States of America" if country == "United States"
        state_pair = MAP_STATES_AND_CODES.select{|name, code| name.downcase == result.state.to_s.downcase}.first
        country_pair = MAP_COUNTRIES_AND_CODES.select{|name, code| name.downcase == country.downcase}.first
        if state_pair
          u.update(state_code: state_pair[1], country_code: 'us')
          Rails.logger.debug "USER ##{u.id} UPDATED: '#{u.state_code}' '#{u.country_code}' State: #{result.state}  Country: #{country}"
        elsif country_pair
          u.update(country_code: country_pair[1])
          Rails.logger.debug "USER ##{u.id} UPDATED: '#{u.country_code}' State: #{result.state}  Country: #{country}"
        else
          Rails.logger.debug "User ##{u.id} did not find a match for\n    State: #{result.state}\n  Country: #{country}"
        end
      else
        Rails.logger.debug "User ##{u.id} no result found for #{u.current_sign_in_ip}"
      end
    end
  end

  private

  def self.filter_by_key(key, names_and_codes)
    codes = names_and_codes.collect{|name, code| code}
    max_value = 0
    membership = codes.collect do |c|
      user_count = User.current.where(key => c).count
      max_value = [max_value, user_count].max
      { "hc-key" => c, value: user_count }
    end
    membership + [ value: max_value + 1 ]
  end
end
