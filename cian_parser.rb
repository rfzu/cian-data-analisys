class CianParser
  require 'csv'

  def self.parse 
    puts 'start!'
    url = 'http://www.cian.ru/cat.php'
    params = {
      'foot_min'         => 15,  
      'sost_type'        => 1, 
      'metro'            => 154,  
      'only_foot'        => 2, 
      'engine_version'   => 2,  
      'p'                => 1, 
      'room2'            => 1, 
      'minfloor'         => 2,  
      'room1'            => 1, 
      'deal_type'        => 'sale',  
      'offer_type'       => 'flat', 
      'room9'            => 1,
    }

    # data = []

    (1..159).each do |metro|
      puts "try to parse metro № #{metro}"
      data = []
      params['metro'] = metro
      n = get_data(url, params)
      flat_pack = []
      flat_pack << n.css('div.serp-list')[0].css('div.serp-item')
      page_count = n.css('div.pager_pages').css('a').count
      puts "page_count: #{page_count}"      
      (2..page_count+1).each do |page_num|
        params_page = params
        params_page['p'] = page_num
        n = get_data(url, params)
        flat_pack << n.css('div.serp-list')[0].css('div.serp-item')
      end

      puts "grab all data and start analysis"
      # sleep(1)

      flat_pack.each do |flats|
        flats.each do |flat|
          begin
            next if flat.css('div.serp-item__alert').any?
            price   = flat.css('div.serp-item__price-col/div.serp-item__solid').to_s.gsub(',','.').match(/\d+\.\d+/).try(:[], 0)
            price ||= flat.css('div.serp-item__price-col/div.serp-item__solid').to_s.gsub(',','.').match(/\d+/).try(:[], 0)
            price = price.to_f
            result = {
              :metro         => flat.css('div.serp-item__solid/a').children.to_s,
              :type          => flat.css('div.serp-item__type-col/div.serp-item__solid').text.gsub("\n",'').strip,
              :flat_url      => flat.attributes['href'].value,
              :address       => flat.css('div.serp-item__address-precise').text.gsub("\n",'').gsub("\t",''),
              :minutes       => flat.css('div.serp-item__distance').children.to_s.match(/\d+/).try(:[],0).to_i,
              :price         => price
            }
          rescue Exception => e
            # file.close
            puts "exception: #{e}"
          end

          data << result
          # file.puts CSV.generate_line(result.values, col_sep: ';')
        end
      end
      file    = File.open(Rails.root.join("tmp/cian_2", "cian_#{metro}.csv"), 'w')
      file.write(CSV.generate_line([
        'метро',
        'комнат',
        'ссылка',
        'адрес',
        'минут до метро',
        'цена',
      ], col_sep: ';'))     
      data.each do |flat|
        file.write(CSV.generate_line([
        flat[:metro],
        flat[:type],
        flat[:flat_url],
        flat[:address],
        flat[:minutes],
        flat[:price],
        ], col_sep: ';'))
      end
      file.close            
    end
  end

  def self.get_data(url, params)
    request = Typhoeus::Request.new(url, params: params)
    resp = request.run
    if [301,302].include? resp.code
      puts "got #{resp.code}"
      new_url = resp.options[:response_headers].match(/http.+\r/)[0].gsub("\r",'')
      resp = Typhoeus::Request.new(new_url).run
    elsif resp.code != 200
      sleep(5)
      resp = request.run
    end
    result = Nokogiri resp.body
    result
  end

end
