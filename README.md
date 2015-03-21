# Werker Step: Selenium

A wercker build step that installs and runs selenium server

## Required Options
* `jar-file-url` - The full URL to the JAR file for selenium-standalone-server.
* `jar-file-version` - A version indicator, that will cause a new JAR to be used (as opposed to the cached version).

## Example
In your wercker.yml
```yaml
deploy:
    steps:
        - rayd/selenium-install:
            jar-file-url: "http://selenium-release.storage.googleapis.com/2.45/selenium-server-standalone-2.45.0.jar"
            jar-file-version: "2.45.0"
```
