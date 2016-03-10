# Shaker

Gateway that sits in front of the SaltStack netapi's to make them more RESTful.

Responses are parsed and turned into meaninful status codes.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add shaker to your list of dependencies in `mix.exs`:

        def deps do
          [{:shaker, "~> 0.0.1"}]
        end

  2. Ensure shaker is started before your application:

        def application do
          [applications: [:shaker]]
        end


## Releasing
### Build
- Docker must be installed and running locally. The release script uses a Linux-based Docker image; system libraries get linked in in, so an OSX/Windows based release will not be deployable on Linux.
- Bump the version number in the VERSION file. Then from the root of the project, run `scripts/build_release.sh`

### Publish
- First build the release as instructed above
- [github-releases](https://github.com/aktau/github-release) needs to be installed
- The environmental variables `GITHUB_TOKEN` must be set
- Run `scripts/push_release.sh`
