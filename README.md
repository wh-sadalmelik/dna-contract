# Periodic NFT

## Install Dependencies

```
$ pnpm install
```

## Test

The `build` folder show be empty when every test run.

```
$ rm -rf build/* && truffle test
```

## Compilers config

In `truffle-config.js`

```javascript
{
	compilers: {
    solc: {
			// version 要和合约一样
      version: "0.8.2",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
				// 因为有个Base64的库要用到shr/shl, 所以要选择这个伊斯坦布尔分叉里面的虚拟机
        evmVersion: "istanbul",
      },
    },
  },
}
```

## Deploy

add `.ethereumscan` and `.secret` file at root path of project. These files will be ignored by `.gitignore`

put `API-KEY` of etherscan into the `.ethereumsacn`. https://etherscan.io/myapikey

put 助记词 into the `.secret`

```
$ truffle deploy --network rinkeby
```

## Verify

copy the content of flattner.sol to verify on etherscan

```
$ truffle-flattener contracts/DNA.sol > flattner.sol
```
