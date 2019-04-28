<h1 align="center">Gatsh</h1> 
<p align="center">Recursively inline files required by your scripts</p>

<p align="center">
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/built-with-science.svg"></a>
<a href="https://forthebadge.com"><img src="https://forthebadge.com/images/badges/for-you.svg"></a>
</p>

<br>

## What is this? 

Gatsh parses your script files for references to other scripts and inlines the contents of those. The idea is to allow people to split their shell scripts into multiple files while still giving them the possibility to distribute a single file. 

An example says more than 1000 words. Let's say you have a file that references a bunch of other files: 

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

TODO

## Usage

TODO:

## Development

### Testing

Gatsh uses [bats-core](https://github.com/bats-core/bats-core) for tests. Additionally, a number of extension for bats are in use.

In order to run the tests you must first initialize the extension submodules. 

```
git submodule init
git submodule update
```

Make sure that bats is installed and execute

```bash
bats test/gatsh.bats # System tests, use test files
bats test/unit.bats # Individual function tests
```


## License

[MIT](LICENSE) (c) [@hschne](https://github.com/hschne)
