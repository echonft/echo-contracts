### Setup

Follow instructions at: https://book.getfoundry.sh/getting-started/installation.html

### Deploy

#### Sepolia
```sh
source .env
forge script script/DeployEcho.s.sol:DeployEcho --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```
To deploy mock ERC721 (currently deploys BAYC, MAYC and CyberKongz) on Sepolia:
```sh
source .env
forge script script/DeployERC721.s.sol:DeployNFT --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```

### Tests

```bash
# All tests
forge test

# With more logs (adjust from -v to -vvvv)
forge test -vvvv
```

Fuzzing is set to `1000`, from `250` by default.
