[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=square)](https://github.com/prettier/prettier) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Setup
### Install dependencies

```npm install```

### Please increase RAM limit for Node.js to be able to compile contracts

Set an environmental variable and reboot:

```export NODE_OPTIONS=--max_old_space_size=4096```

### To use the linters, please add these extensions to the VSCode

```ext install JuanBlanco.solidity```

```ext install esbenp.prettier-vscode```

- To lint the file, run **ctrl+shift+i** 

- To lint the whole project, run **npm run lint-fix**

### To verify contracts that are deployed via Truffle, please run:

```truffle run verify <list_of_contracts> --network <network_from_truffle-config>```

### To verify _proxy_ contracts that are deployed via factory, please run:

```npx hardhat verify --network <network_from_truffle-config> <deployed address> "first constructor arg" "second constructor arg" "0x"```