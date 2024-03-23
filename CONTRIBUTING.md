# Contributing to ExtFit

## Setup

### Local repository

```sh
# use your own fork 
$ git clone git@github.com:arathunku/ext_fit.git
$ cd ext_fit
$ mix deps.get
# ensure everything works
$ mix test 
# do your changes
$ mix check
```

### Updating to new SDK

Requires [`Nix` package manager](https://nixos.org/).

1. Get new SDK from [developer.garmin.com](https://developer.garmin.com/fit/download/)
1. Save `.zip` in "sdks/" directory and unzip it next to it with `fit-sdk-{{version}}`
1. Run `scripts/profile-xlsx-as-csv`. This uses LibreOffice to convert `xlsx` to `csv`
1. Update version in `scripts/gen-profile`
1. Generate new profile files with `scripts/gen-profile`

### Add new test FIT files

Requires [`Nix` package manager](https://nixos.org/).

1. Add new file to `test/support/files`
1. Please use name {{YYYY}}-{{MM}}-{{DD}}-{{company}}-{{device}}-{{context}}.fit where date
  should _mostly_ match date when the activity was recorded
1. Optional:
    - install [fitdecode](https://github.com/polyvertex/fitdecode) for `fitjson` command
    - install [fitdump](https://github.com/dtcooper/python-fitparse) for `fitdump` command

1. Run `scripts/generate-dumps-for-test-files`, this will use official fit2csv tool to dump `.csv` file,
