# Introduction

Errata is a combination of plugin and software client to manage Rails application errors.

The Errata plugin logs all errors from your application (along with their context of the error) into JSON files that are served from your applications public directory. You specify how many errors to keep and the plugin automatically manages deleting old error files.

The Errata plugin goes hand-in-hand with the Errata client that reads the errors and presents them in a friendly fashion.

# Using Errata

## Install the plugin

## Create the errata folder

The plugin will, automatically, create the `errata` folder under `public` if it does not exist. However it is recommended that you create a folder that will be shared across releases and symlink it into your applications `public` folder during deployment.

Further it is recommended that you protect the `errata` folder with a username & password which can be used by the client.  

## Install the client

Download the Errata client.
Create a new Application and point it at the URL to your server. Give it the username & password required. Specify the polling interval.

