# Description:
#   Reply with Ron Swanson quote
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot swanson

module.exports = (robot) ->

  robot.respond /swanson/i, (msg) ->
    msg.http("https://ron-swanson-quotes.herokuapp.com/v2/quotes")
      .get() (error, response, body) ->
        data = JSON.parse body
        if data.length > 0
          msg.send data[0]
          return
        msg.send "Mr. Swanson does not want to see anyone right now."
