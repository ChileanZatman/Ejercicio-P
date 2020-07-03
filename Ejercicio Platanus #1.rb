require 'rest-client'
require 'json'
def apiCall(route=nil)
    return JSON.parse(RestClient.get("https://www.buda.com/api/v2/markets#{route}", :accept => 'application/json'))
end
def getTime()
    cur_tm = (Time.now.to_f * 1000).to_i
end
def addDataAsHtml(current, id, buy, sell)
    return current+"<tr><td>#{id}</td><td>#{buy}</td><td>#{sell}</td></tr>"
end
def htmlWrap(data)
    p "<!DOCTYPE html><html><body><h2>Transacciones mas altas 24h</h2><table><tr><th>Mercado</th><th>Compra</th><th>Venta</th></tr>#{data}</table></body></html>"
end
content = ""
markets = apiCall()["markets"]
markets.each do |market|
    cur_id = market["id"]
    trades = apiCall("/#{cur_id}/trades?timestamp=#{getTime()}")["trades"]["entries"]
    top_b = 0.0
    top_s = 0.0
    trades.each do |trade|
    #trade[]->[0-timestamp(unix-milisecond), 1-amount, 2-price(decimal), 3-direction(buy/sell), 4-not on doc]
        #Tiempo actual menos 24h(86400000 mili)
       if trade[0].to_i>getTime()-86400000
             val = trade[2].to_f
            trade[3] == 'buy' ? top_b = ([top_b,val].max) : top_s = ([top_s,val].max)
       end
    end
    content = addDataAsHtml(content,cur_id,top_b,top_s)
end
htmlWrap(content)