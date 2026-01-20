# Jupyterlab with uv


This repo contains a customized Containerfile for Jupyterlab that uses uv for
package management. It's a work in progress at the moment but it works for me
(YMMV).

This isn't quite an unopinionated, blank-slate Jupyterlab setup. I've included
what I like in terms of default configuration and plugins, such as language
server support with pylsp. The official docker images are perfectly serviceable,
if you don't like my setup.

The example notebook uses polars. Its just better than pandas, I stand by that
and I want others to know.


### Features:
- Uses uv for package management for speed improvements and because uv is awesome
- Jupyter server defaults to using a unix socket, because I run my Jupyter on a
  /shared/ server that I SSH into (so only listening on localhost still exposes
  Jupyter to other users, a security issue).
- Scripts that add workarounds for podman rootless environments.
- Some default plugins and associated config:
  - Jupyter-lsp with pylsp
  - pympl and pywidgets for matplotlib widgets
- A shared folder (~/notebooks in the container) for saving notebooks to the
  host (I needed a shared folder for the socket too, might as well add this one)
  
  
### To-Do:
- Rewrite the Containerfile from scratch, pulling what needs to be pulled in
  from the Jupyter docker-stacks repo. I don't want to call it bloated, it just
  has more than I need and isn't fully OCI compliant (uses "SHELL" instruction).
- Switch entirely over to uv. Currently there is still conda reliance and it
  loads a conda venv by default (I'd rather it use uv)
- change the username
- ARG variables to control build and run
- Manage install of jupyter/dependencies with uv

#### plugins to look into
- https://github.com/leotaku/jupyter-ruff
- 
