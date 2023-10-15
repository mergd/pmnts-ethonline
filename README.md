## pmnts contracts

base goerli, scroll sepolia, mantle sepolia, zkEVM goerli: 0x5c90c2f1022F8C67Ed5B162c2754Ce8dA9A66e3a

Goerli – verified:
new wrapper addr 0xcc9B102ba9D606C18BeD431C2e2deC998a85716B
new cxrc20 addr 0x54d9a3B5232486fdb5E8c27380B9cbab3ed90Ba3
new apexrc20 addr 0xF83D2FdF52450970127B17e2390b6e06e480F75A
new xerc20 factory addr 0x2d34A48bCc05CBd7566bBA967A450a35Ce69F97c

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
