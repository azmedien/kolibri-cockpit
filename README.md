# Kolibri Framework

Kolibri is a mobile and web framework for bootstrapping Android and iOS applications in no time.
Using preconfigured web interface `The Kolibri Cockpit`, non technical guys can easy clone existing app and distribute them to Google Play store and iTunes just using a few clicks within a minutes. Other cool feature of the platform is that once cloned and deployed, application can be easily configure
trough the dynamic runtime configuration. There is also support for assets, both `png` and `svg` formats which are scaled and generated for all needed
sizes and densities for the mobile devices. Also we support fonts and custom `json` files in the assets, configurable splash screens, and app icons.

There is `vanilla`, basic Android and iOS skeleton applications which supports dynamic runtime configuration, navigation and other mandatory useful stuff. This can be used for very simple applications or for starting point, so this way developers can add own custom components.

## Architecture

This framework has multiple parts and links several services.
First there is a continuous integration server which build, test and publish the applications.
The process is configured using `Fastlane`. Other hand there is the mentioned above `Cockpit` which controls the creation, clone, configure and publish process.
Imagine it as middleware between developers, testers, publishes and managers on one side and `Google Play`, `Fabric`, `TestFlgiht`, `AppStore` in other. For application management the framework lies on version control management and branching mechanism. This will be explained later.

The big picture looks like this:

```
                                                                          +--------------------+
                    +----------------------+       +------------+         |                    |
             (5)    |                      |  (3)  |            |   (4)   |    TestFlight      |
        +----------->   Cockpit Web App    <-------+ Jenkins CI +--------->    Fabric          |
        |           |                      |       |            |         |    AppStore        |
        |           +----+----------+------+       +-----^------+         |    GooglePlay      |
+-------+-------+        |          |                    |                |    Slack           |
|               |        |          |                    |                |                    |
|  User or Dev  |     (1)|          |(6)                 |                +--------------------+
|               |        |          |                    | (2)
+-------+-------+        |          |                    |
        |                |          |                    |
        |           +----v----------v----+               |
        |           |                    |               |
        +-----------> Repository/Vanilla +---------------+
            (7)     |                    |
                    +--------------------+


```

0. When we create new application, cockpit clone the repository (or the vanilla) and branch from its master.
New branch is created with the name and the id of the app containing fully configured and functional basic app.

  _Updating an app will update the current branch if needed. Because the app is under VCS only changes will trigger the process._

0. Repository `push` hook will notify Jenkins and build of this branch will be started.

0. Jenkins will execute `Fastlane` build script and will notify the `cockpit` of the current stage and process status.

0. `Fastlane` will try to upload to Fabric, AppStore and/or Google Play. Also will post notification on Slack.

0. When user clone an app all configuration and assets will be copied.

0. Cockpit also will branch the app from the origin application's branch. This means that all custom functionality will be available in the cloned app. And then the process continue from **point (2)**

0. Developer can clone the app branch and can add custom functionality as writing a code or something else. Once published the process continue from **point (2)**

## Getting started

These instructions will get you a configured copy of the platform, both Jenkins for CI and the Cockpit up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

> Note that it's better that the Cockpit and Jenkins CI instances to be separated, on different machines.

Continuous integration
---

### Prerequisites

Things you need to install and how to install and configure them:

* Mac OS X machine
* Android SDK and Platform tools
* Jenkins
* Xcode
* Fastlane
* Blade (https://github.com/jondot/blade)
* Maven server (optional, we used Artifactory)

### Installing

We assume you have already configured Mac OS X machine with installed prerequisites for the continuous integration server. Installation of each needed component is straightforward.

**Required Jenkins plugins are:**

* Android Emulator Plugin
* Android Lint Plugin
* Android Signing Plugin
* Artifactory Plugin (optional if you deploy your custom libraries)
* Bitbucket Plugin (optional if you use Bitbucket as VCS)
* Blue Ocean
* CocoaPods Jenkins Integration
* Xcode integration

### Setup Apple Developer

Login to the apple developer portal and generate development and production certificates for the continuous integration server, which will build the iOS applications.

Now you must setup system environment `FL_APPLE_USER` with the email associated with configured profile.
Next you must add the account credentials to the Fastlane credentials manager.

```bash
$ fastlane fastlane-credentials add --username john@doe.me
Password: ***********
Credential john@doe.me:*********** added to keychain.
```

### Configure it

**TODO**

Kolibri cockpit
---

### Prerequisites

Things you need to install and how to install and configure them:

* Ruby
* PostreSQL
* Redis
* imagemagic with librsvg

### Installing

We assume you have already installed prerequisites. Installation of each needed component is straightforward.
Currently you can deploy the Cockpit on `Heroku` without any doubts.

For local development install prerequisites as follow:

```bash
$ brew install imagemagick --with-librsvg redis postgresql rbenv ruby-build
$ brew tap jondot/tap
$ brew install blade
```

> You can follow this detailed guide for installing ruby rails on your machine:
https://gorails.com/setup/osx/10.12-sierra

Then create an `PostreSQL` database using `Postico` for example. Name it `kolibri_development`.
Make sure you have exported the `PKEY` env which will grant you `push` rights to the repositories.

```bash
$ export PKEY=/Users/lekov/Workspace/Kolibri/kolibri-cockpit/cockpit
```

Now you are ready to run the server by executing this command from the project's folder:

```bash
$ bin/rails server
```

## Run the testers

**TODO**

## Deployment

Add additional notes about how to deploy this on a live system

### Setup env variables

**Jenkins:**

* `JENKINS_USER`
* `JENKINS_SECRET`

**Amazon S3:**

* `S3_BUCKET_NAME`
* `S3_KEY`
* `S3_REGION`
* `S3_SECRET`

**Access to repos:**

* `PKEY=/app/cockpit` - pointing to the private key which must be used to access repositories. Make sure the public key is added to the repository with read and write access.

> Note that currently Kolibri Cockpit uses only one key for accessing all repositories.

## Getting started with Cockpit

> You must create the application in Google play and make an initial upload before publish from Kolibri Cockpit

### Create an app

**TODO**

### Clone an app

**TODO**

### Configure the app

**TODO**

### Runtime configuration

**TODO**

#### Styling guide

Currently Kolibri Cockpit supports overrides for styling element as follow:

* `toolbarBackground` - which tints the toolbar and the navigation header in case there's no background image.
* `toolbarText` - which tints the toolbar title text
* `menuItemSelectedColor` - which tints the menu item icons and text

> Example styling object into the runtime configuration

```json
...

"styling": {
  "color-palette": {
    ...
  },
  "overrides": {
    "menuItemSelectedColor": "#00457A",
    "toolbarBackground": "#00457A"
  }
},

...
```

### Adding some assets

**TODO**

### Publishing

**TODO**

### Send push notifications

When open the `Notifications` tab on the cockpit you will see there is a `Firebase Server key`. This key can be obtain from the firebase console and once you have set it in the field cannot be changed and will be used in future.


## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Asen Lekov** - *Initial work* - [L3K0V](https://github.com/L3K0V)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc
