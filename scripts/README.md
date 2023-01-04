# Klippa Scanner SDK Version Incrementor

A script to update the fallback versions of the Klippa Scanner SDK for both Android and iOS. It also updates the version number in `package.json` and adds a new entry to `CHANGELOG.md` with the updated versions.

## Prerequisites
- `jq` command line JSON processor


### How to install prerequisites (MacOS)

1. Install Homebrew by running the following command in a terminal:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install jq by running the following command:
```
brew install jq
```

## How to use

1. Give execution permissions to the script: `chmod +x increment.sh`
2. Run the script: `./increment.sh`
3. Enter the new fallback version for Android when prompted
4. Enter the new fallback version for iOS when prompted
5. Enter the new version number for package.json when prompted

## Output

The script will update the fallback versions in the `build.gradle` file for Android and the `.sdk_version` file for iOS, update the version number in `package.json`, and add a new entry to the top of `CHANGELOG.md` with the updated versions. If either of the fallback versions is not provided, it will not be included in the `CHANGELOG.md` entry. If no version numbers are provided, the script will exit with an error message.