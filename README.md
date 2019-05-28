<h1 align="center">Gatsh</h1> 
<p align="center">Recursively inline files required by your scripts</p>

<p align="center">
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/built-with-science.svg"></a>
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/for-you.svg"></a>
</p>

<br>

## What is this? 

Gatsh parses your script files for references to other scripts and inlines the contents of those. The idea is to allow people to split their shell scripts into multiple files while still giving them the possibility to distribute a single file. 

Let's say you have a file that references a bunch of other files: 

```bash
# root.sh
source lib/logger.sh

log "Hello World!"

# lib/logger.sh
source colors.sh

log()  {
  local message=$1
  echo "${GREEN}[INFO]${DEFAULT} $message"
}

# lib/colors.sh
DEFAULT="\e[39m"
RED="\e[31m"
GREEN="\e[32m"
```

Running `gatsh root.sh` will inline source imports and yield:

```bash
# root.sh
DEFAULT="\e[39m"
RED="\e[31m"
GREEN="\e[32m"

log()  {
  local message=$1
  echo "${GREEN}[INFO]${DEFAULT} $message"
}

log "Hello World!"
```

## Installation

Download the latest version from Gatsh from the releases page or get the latest version. 

```
wget https://raw.githubusercontent.com/hschne/gatsh/master/gatsh && chmod +x gatsh
```

Add Gatsh to your path to make it available from any location.

## Usage

Usage is straight forward - simply run

```
gatsh infile.sh
```

to concatinate `infile.sh` and all its dependencies. Gatsh supports the following options:

```
-o|--outfile  Redirects the output to the specified file
-h|--help     Displays the help dialog
```

## Development

### Testing

Gatsh uses [bats-core](https://github.com/bats-core/bats-core) for tests. Additionally, a number of extension for bats are in use.

In order to run the tests you must first initialize the extension submodules. 

```
git submodule init
git submodule update
```

Bats features both system tests, which verify that the whole script works, and unit tests, which verify specific functions. You can run both using

```bash
bats test/gatsh.bats # System tests, use test files
bats test/unit.bats # Individual function tests
```

System tests rely on a number of files that can be found in `tests/files`.


## License

[MIT](LICENSE) (c) [@hschne](https://github.com/hschne)
