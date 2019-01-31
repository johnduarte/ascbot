# ascbot

ascbot is a chat bot built on the [Hubot][hubot] framework. It was
initially generated by [generator-hubot][generator-hubot].

This README is intended to help get you started. Definitely update and improve
to talk about your own instance, how to use and deploy, what functionality he
has, etc!

[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot


### Running ascbot Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](#configuration) they rely
upon have been set.

You can start ascbot locally by running:

    % HUBOT_GITHUB_TOKEN=<your-token> ./bin/hubot -a shell


You'll see some start up output and a prompt:

    ascbot>

Then you can interact with ascbot by typing `ascbot help`.

    ascbot> ascbot help
    ascbot 8ball <query> - Consults the magic eight-ball for your question.
    ascbot help - Displays all of the help commands that ascbot knows about.
    ...

### Configuration

A few scripts (including some installed by default) require environment
variables to be set as a simple form of configuration.

How to set environment variables will be specific to your operating system.
Rather than recreate the various methods and best practices in achieving this,
it's suggested that you search for a dedicated guide focused on your OS.


### Scripting

An example script is included at `scripts/example.coffee`, so check it out to
get started, along with the [Scripting Guide](scripting-docs).

For many common tasks, there's a good chance someone has already one to do just
the thing.

[scripting-docs]: https://github.com/github/hubot/blob/master/docs/scripting.md


### external-scripts

There will inevitably be functionality that everyone will want. Instead of
writing it yourself, you can use existing plugins.

Hubot is able to load plugins from third-party `npm` packages. This is the
recommended way to add functionality to your hubot. You can get a list of
available hubot plugins on [npmjs.com](npmjs) or by using `npm search`:

    % npm search hubot-scripts panda
    NAME             DESCRIPTION                        AUTHOR DATE       VERSION KEYWORDS
    hubot-pandapanda a hubot script for panda responses =missu 2014-11-30 0.9.2   hubot hubot-scripts panda
    ...


To use a package, check the package's documentation, but in general it is:

1. Use `npm install --save` to add the package to `package.json` and install it
2. Add the package name to `external-scripts.json` as a double quoted string

You can review `external-scripts.json` to see what is included by default.


##  Persistence

ascbot uses a flat json file for the data storage of the hubot-brain. This
file is expected to be stored in the `/srv` directory in the docker
container. In order to set this path the `HUBOT_BRAIN_DIR` must be set to the
`/srv` path. This path should then be bound to a volume on the docker host in
order to ensure the data survives further deployments of ascbot.


## Adapters

ascbot is expected to be deployed to a slack workspace. You can then run hubot
with the adapter.

    % bin/hubot -a slack

## GitHub

ascbot git and GitHub operations on behalf of the user.  This functionality
requires that the `rpc-automation` GitHub user be added as a collaborator to
any repository that expects ascbot to interact with it.

ascbot uses the GitHub API to perform operations on GitHub repositories as
necessary.  This requires that the `HUBOT_GITHUB_TOKEN` environment variable
be set to a valid token that has access to the GitHub API.

ascbot also performs git commits on behalf of the user.  This functionality
requires that the private SSH key for the `rpc-automation` GitHub user be
added to the ascbot user when the docker container is built.  This is done by
defining `SSH_PRIVATE_KEY` as a `--build-arg` when `docker build` is executed.
The value of this argument will be set as the contents of the ssh key for the
ascbot user on the docker container.  This value needs to be enclosed in
double quotes to ensure that the contents of the key are not misinterpreted as
command line arguments.  An example of the build command is shown in the
[Deployment](#deployment) section of this README.

## Deployment

ascbot includes a `Dockerfile` for building a docker image able to run it.
The Dockerfile requires that a build argument be set for `SSH_PRIVATE_KEY`.
This key is required in order to authenticate the `rpc-automation` user to
GitHub for the purpose of creating git commits.

This image can then be used to run a docker container to complete the
deployment.

* A local volume for the should be bound to the `/srv` path in order
to ensure that the `hubot-brain.json` file has persistent storage.
* A slack "Bot User OAuth Access Token" needs to be passed as an environment
variable in order to enable ascbot to connect to the slack workspace.
* A GitHub token needs to be passed as an environment variable in order to
enable ascbot to perform operations via the GitHub API.

    % sudo docker build --build-arg SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
          -t myuser/ascbot .
    % sudo docker run -d \
          --name ascbot \
          -e HUBOT_BRAIN_DIR=/srv \
          -e HUBOT_SLACK_TOKEN=xoxb-<your-token> \
          -e HUBOT_GITHUB_TOKEN=<your-token> \
          --volume "/local/docker/ascbot/config:/srv" \
          myuser/ascbot
