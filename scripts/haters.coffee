# Description:
#   Display a random "haters gonna hate" image
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot haters - Returns a random haters gonna hate url
#
# Author:
#   atmos

haters = [
  "http://twjmag.com/images/Haters.JPG"
, "http://i.imgflip.com/1ze53w.jpg"
, "http://thelibertarianrepublic.com/wp-content/uploads/2015/07/58264158.jpg"
, "http://tenor.com/view/haters-gonna-hate-haters-gif-3949059"
, "http://cdn.someecards.com/someecards/usercards/players-gonna-play-haters-gonna-hate-creepers-gonna-creep-fakers-gonna-fake-but-im-gonna-shake-shake-it-off--9211d.png"
, "http://tenor.com/view/tinabelcher-combing-haters-gonna-hate-gif-6043574"
, "http://24.media.tumblr.com/tumblr_lltwmdVpoL1qekprfo1_500.gif"
, "http://s3.amazonaws.com/kym-assets/photos/images/newsfeed/000/087/536/1292102239519.gif"
, "http://media.tumblr.com/tumblr_m2yv2hqw9l1rnvwt1.gif"
, "http://static.fjcdn.com/pictures/Haters+Gonna+Hate_0dd058_3113024.jpg"
]

hatin = (msg) ->
  msg.send msg.random haters

module.exports = (robot) ->
  robot.respond /haters/i, (msg) ->
    hatin msg
  robot.hear /haters gonna hate/i, (msg) ->
    hatin msg
