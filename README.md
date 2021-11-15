[gitea-tutorial-go2prepaid-video]: https://www.youtube.com/watch?v=Tj8a7TSG4sU

[gitea-tutorial-go2prepaid-thumbnail]: https://i.ytimg.com/vi/Tj8a7TSG4sU/hqdefault.jpg?sqp=-oaymwEZCNACELwBSFXyq4qpAwsIARUAAIhCGAFwAQ==&rs=AOn4CLBrjPPYZu5KLIZ5Qx_Z0W60i44ojQ

# Gitea-installer
[![.github/workflows/CI_Relese.yml](https://github.com/uvulpos/gitea-installer/actions/workflows/CI_Relese.yml/badge.svg?branch=master)](https://github.com/uvulpos/gitea-installer/actions/workflows/CI_Relese.yml)

Simple bash-script installer to install Gitea on Ubuntu server. It's an alternative for server who can't run docker
properly (e.x. LXC)

## Tutorials

[![Mainhoster (ehemals Go2Prepaid) Gitea Video (Installation)][gitea-tutorial-go2prepaid-thumbnail]][gitea-tutorial-go2prepaid-video]

## Supported Operating Systems:

| Name | Status |
|------|--------|
|Ubuntu| original supported |
|Debian| not supported ([but confirmed on debian 11](https://github.com/uvulpos/gitea-installer/issues/8)) |

## How to use it:

1. Download this repo
    1. Cone via GitHub SSH `git clone git@github.com:uvulpos/gitea-installer.git`
    1. Cone via GitHub HTTPS `git clone https://github.com/uvulpos/gitea-installer.git`
    1. Cone via GitHub CLI `gh repo clone uvulpos/gitea-installer`
    1. Download zip release [here](https://github.com/uvulpos/gitea-installer/releases) and extract it
2. Execute installer (this may take some time because I also update the server)
    1. Execute english version `bash ./gitea-installer-en.sh`
    1. Execute german version `bash ./gitea-installer-de.sh`
3. At the end of my script, there is an url and login data for mysql database. Go to the website and enter the details
   to install it via gitea installer! Safe the credentials also at your desktop pc for backup!
4. Execute finish script to remove write privileges to certain files `bash after-install.sh`

## Important:

This software has absolutely no warranty. Use it on your own risk!

