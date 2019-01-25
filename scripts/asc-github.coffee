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
#   hubot github update sha <repo> <branch>
#   hubot github merge pr <repo> <number>
#   hubot github list prs <repo>

module.exports = (robot) ->

  github = require('githubot')(robot)
  owner = 'rcbops'

  unless (url_api_base = process.env.HUBOT_GITHUB_API)?
    url_api_base = 'https://api.github.com'

  robot.respond /github update sha(s)? (.*)$/i, (msg) ->
    [repo, branch] = msg.match[2].toLowerCase().split(' ')
    repo = "rpc-openstack-system-tests" if repo in ["system-tests","sys-tests"]
    # err if repo or branch not set
    #
    # github.branches "#{repo}", (branches) ->
    #   err if branch not in branches
    #
    # create update-branch (api)
    # clone repo (local)
    # perform submodule update (local)
    # commit update (local)
    # push branch (local)
    # open pr (api)
    msg.send "You supplied repo: #{repo} and branch: #{branch}."
    msg.send "This feature is under development. Please try again later."

  robot.respond /github merge pr (.*)/i, (msg) ->
    [repo, pr_number] = msg.match[1].toLowerCase().split(' ')
    github.put "repos/#{owner}/#{repo}/pulls/#{pr_number}/merge", {}, (merge) ->
      console.log merge.message

  robot.respond /github list prs (.*)/i, (msg) ->
    repo = msg.match[1].toLowerCase()
    github.get "repos/#{owner}/#{repo}/pulls", {}, (pulls) ->
      if pulls.length == 0
        summary = "Achievment unlocked: no open pull requests!"
      else
        summary = "I found #{pulls.length} open pull requests for #{repo}:"
        for pull in pulls
          summary += "\n\t#{pull.title} - #{pull.user.login}: #{pull.html_url}"
      msg.send summary
