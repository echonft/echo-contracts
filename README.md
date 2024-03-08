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
source .env; forge script script/DeployERC721.s.sol:DeployNFT --rpc-url $SEPOLIA_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```

### Tests

```bash
# All tests
forge test

# With more logs (adjust from -v to -vvvv)
forge test -vvvv
```

Fuzzing is set to `1000`, from `250` by default.

### Scripting
To run commands on the contracts, we use `cast`. You need to have the `.env` file setup correctly before running commands.
The ERC721 methods are based on our MockERC721 implementation.
#### Mint NFT
```bash
source .env; cast send CONTRACT_ADDRESS "publicMint(uint256)" NUMBER_OF_NFTS_TO_MINT --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```
#### Transfer NFT
```bash
source .env; cast send CONTRACT ADDRESS "transferFrom(address, address, uint256)" FROM_ADDRESS TO_ADDRESSS NFT_ID --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

### Mocked NFTs contracts (Sepolia):
**Sora's dreamworld**
0x3512BbCAD47275F8e11e7B843FA4BDf7b526f5b8

**Bored Ape Yacht Club**
0x65426F3C04e85936b0F875510d045b413134186A

**Mutant Ape Yacht Club**
0xd91303F46C3f4883D9D74c703C15948e5E04E110

**Cyberkongz**
0x43bE93945E168A205D708F1A41A124fA302e1f76

**Creepz**
0xB9FBf3cDf5B344a9e09528FEe853e376d57eE7cA