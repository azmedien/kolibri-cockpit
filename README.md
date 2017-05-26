# Kolibri Framework

Kolibri is a mobile and web framework for bootstrapping Android and iOS applications in no time.
Using preconfigured web interface `The Kolibri Cockpit`, non technical guys can easy clone existing app and distribute them to Google Play store and iTunes just using a few clicks within a minutes. Other cool feature of the platform is that once cloned and deployed, application can be easily configure
trough the dynamic runtime configuration. There is also support for assets, both `png` and `svg` formats which are scaled and generated for all needed
sizes and densities for the mobile devices. Here also we can include the configurable splash screens, fonts and app icons.

For this case we provide `vanilla`, basic Android and iOS skeleton applications which supports dynamic runtime configuration, navigation and other mandatory useful stuff. This can be used for very simple applications or for starting point, so this way developers can add own custom components.

## Getting started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

Continuous integration server:
* Mac OS X machine
* Android SDK and Platform tools
* Jenkins
* Xcode
* Fastlane
* Maven server (optional)

Cockpit server:
* Ruby
* PostreSQL
* Redis
* imagemagic with librsvg

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

For the Cockpit server we assume you will deploy it on `Heroku` which again is straightforward.

For local development install prerequisites as follow:

```bash
brew install imagemagick --with-librsvg redis postgresql rbenv ruby-build
```

> You can follow this detailed guide for installing ruby rails on your machine:
https://gorails.com/setup/osx/10.12-sierra

Create an `PostreSQL` database using `Postico` for example. Name it `kolibri_development`

Make sure you have exported the `PKEY` env which will grant you `push` rights to the repositories.

```bash
export PKEY=/Users/lekov/Workspace/Kolibri/kolibri-cockpit/cockpit
```

Now you are ready to run the server by executing this command from the project's folder:

```bash
bin/rails server
```

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

> You must create the application in Google play before publish from Kolibri Cockpit

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
