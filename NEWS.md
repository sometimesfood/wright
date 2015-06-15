# wright NEWS
## 0.4.2 (2015-06-15)
- Don't colorize log messages if Config[:log][:colorize] is nil (#13)

## 0.4.1 (2015-06-14)
- Use GNU passwd group and user providers on Fedora

## 0.4.0 (2015-06-11)
- Add --dry-run option
- Add -r option
- Add support for virtual packages to apt provider
- Add yum support to package provider
- Use GNU passwd group and user providers on CentOS/RHEL
- Add options attribute to package resource

## 0.3.2 (2015-06-01)
- Expand script file path (#11)

## 0.3.1 (2015-05-26)
- Fix quoting issue in GNU passwd group provider (#10)

## 0.3.0 (2015-04-23)
- Add bin/wright
- Add wright(1) manpage
- Add OS X user provider
- Improve performance of the apt provider
- Improve error message for resources without names (#5)
- Improve error message for symlinks without target (#6)

## 0.2.0 (2015-03-13)
- Add Homebrew package provider for OS X
- Add group resource
  - Add group provider for GNU systems
  - Add group provider for OS X
- Add user resource (provider)
  - Add user provider for GNU systems
- Fix name error in symlink provider
- Add `Provider#exec_or_fail`
- Pass arguments to `Open3::capture3` properly

## 0.1.2 (2015-01-31)
- Convert docs to YARD
- Fix color code for warnings

## 0.1.1 (2015-01-20)
- Remove hardcoded package provider config
- Specify Ruby version in gemspec

## 0.1.0 (2015-01-16)
- First public release
