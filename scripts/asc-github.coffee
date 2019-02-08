# Description:
#   Perform operations on github repos
#
# Dependencies:
#   githubot
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#
# Commands:
#   hubot github update submodule <repo> <branch>
#   hubot github merge branch <repo> <source-branch> <target-branch>
#   hubot github merge pr <repo> <number>
#   hubot github list prs <repo>

module.exports = (robot) ->

  authorized_rooms = [ 'G8C8VJAHM' ]

  github = require('githubot')(robot)
  owner = 'rcbops'

  unless (url_api_base = process.env.HUBOT_GITHUB_API)?
    url_api_base = 'https://api.github.com'

  robot.respond /github update submodule(s)? (.*)$/i, (msg) ->
    if msg.message.room in authorized_rooms
      [repo, branch] = msg.match[2].toLowerCase().split(' ')
      @exec = require('child_process').exec
      cmd =  "/home/ascbot/scripts/update-submodule.sh -o #{owner} -r #{repo} -b #{branch}"
      msg.send "Creating topic branch with update..."
      @exec cmd, (error, stdout, stderr) ->
        if error
          msg.send "Error: #{error} - #{stderr}"
        else
          msg.send "Creating PR for update..."
          github.handleErrors (response) ->
            msg.send "Error: #{response.statusCode} #{response.error} #{response.body}"
          topic = stdout.trim()
          index = topic.lastIndexOf '\n'
          topic = topic.substr index+1
          data = { title: "MAINT - Update submodule SHAs", head: "#{topic}", base: "#{branch}" }
          github.post "repos/#{owner}/#{repo}/pulls", data, (pr) ->
            msg.send pr.html_url
    else
      msg.send "Sorry, this action is not permitted in this room."


  robot.respond /github merge pr (.*)/i, (msg) ->
    [repo, pr_number] = msg.match[1].toLowerCase().split(' ')
    github.put "repos/#{owner}/#{repo}/pulls/#{pr_number}/merge", {}, (merge) ->
      msg.send merge.message
      github.get "repos/#{owner}/#{repo}/pulls/#{pr_number}", {}, (pull) ->
        if pull.merged
          github.branches( "#{owner}/#{repo}" ).delete "#{pull.head.ref}", ->
            msg.send "Deleted #{pull.head.ref} branch."

  robot.respond /github list pr(s)? (.*)/i, (msg) ->
    repo = msg.match[2].toLowerCase()
    github.get "repos/#{owner}/#{repo}/pulls", {}, (pulls) ->
      if pulls.length == 0
        summary = "Achievment unlocked: no open pull requests!"
      else
        summary = "I found #{pulls.length} open pull requests for #{repo}:"
        for pull in pulls
          summary += "\n\t#{pull.title} - #{pull.user.login}: #{pull.html_url}"
      msg.send summary

  robot.respond /github merge branch (.*)$/i, (msg) ->
    if msg.message.room in authorized_rooms
      github.handleErrors (response) ->
        msg.send "Error: #{response.statusCode} #{response.error} #{response.body}"
      [repo, source, target] = msg.match[1].toLowerCase().split(' ')
      github.branches( "#{owner}/#{repo}" ).merge "#{source}", into: "#{target}", (mergeCommit) ->
        msg.send mergeCommit.message
    else
      msg.send "Sorry, this action is not permitted in this room."
