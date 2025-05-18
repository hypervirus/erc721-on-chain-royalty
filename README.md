# SimpleNFT

A simple ERC721 NFT smart contract with fixed supply, public minting, and royalties support.

## Features

- **Fixed Supply**: Maximum token count is set at deployment and cannot be changed
- **Public Mint Function**: Anyone can mint NFTs by paying the required price
- **Hidden Metadata**: Pre-reveal placeholder metadata for all tokens
- **Metadata Reveal**: Owner can reveal the collection when ready
- **ERC721Enumerable**: Full enumeration support for all tokens
- **Royalties Support**: Implements ERC-2981 for marketplace royalties
- **Owner Controls**: Pricing, royalty settings, and fund withdrawal

## Prerequisites

- [Node.js](https://nodejs.org/) (>= 14.x)
- [npm](https://www.npmjs.com/) (>= 6.x)
- [Hardhat](https://hardhat.org/) or [Truffle](https://trufflesuite.com/)
- [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts)

## Installation

1. Create a new project directory and initialize it:

```bash
mkdir my-nft-project
cd my-nft-project
npm init -y
```

2. Install required dependencies:

```bash
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-waffle @openzeppelin/contracts dotenv
```

3. Initialize Hardhat:

```bash
npx hardhat
```

4. Create a `contracts` directory and add the SimpleNFT contract:

```bash
mkdir contracts
```

5. Create a file named `SimpleNFT.sol` in the contracts directory and copy the contract code into it.

## Deployment

1. Create a deployment script in the `scripts` directory:

```javascript
// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy SimpleNFT contract
  const SimpleNFT = await hre.ethers.getContractFactory("SimpleNFT");
  const simpleNFT = await SimpleNFT.deploy(
    "MyNFTCollection",                // Collection name
    "MNFT",                           // Symbol
    10000,                            // Maximum supply
    "ipfs://QmYourHiddenURI/hidden.json", // Hidden metadata URI
    deployer.address,                 // Royalty receiver address
    500                               // Royalty percentage (5%)
  );

  await simpleNFT.deployed();
  console.log("SimpleNFT deployed to:", simpleNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

2. Configure Hardhat network settings in `hardhat.config.js`

3. Deploy the contract:

```bash
npx hardhat run scripts/deploy.js --network <your-network>
```

## Usage Guide

### Contract Deployment Parameters

When deploying the SimpleNFT contract, you need to provide the following parameters:

1. **_name**: The name of your NFT collection (e.g., "My Awesome NFTs")
2. **_symbol**: A short symbol for your collection (e.g., "MNFT")
3. **_maxSupply**: The maximum number of NFTs that can ever be minted
4. **_hiddenBaseURI**: The URI for hidden metadata before collection reveal (typically points to a single placeholder JSON file)
5. **_royaltyReceiver**: Address that will receive royalties from secondary sales
6. **_royaltyPercentage**: Percentage of sales that go to royalties in basis points (e.g., 500 = 5%)

### Setting Up Metadata

#### Hidden Metadata

Before revealing your collection, all tokens will return the same hidden metadata URI. This should point to a JSON file with placeholder information:

```json
{
  "name": "Hidden NFT",
  "description": "This NFT has not been revealed yet!",
  "image": "ipfs://QmYourHiddenImageCID/hidden.png"
}
```

#### Revealed Metadata

Prepare your revealed metadata with sequential JSON files. For example, if your base URI is `ipfs://QmRevealedCID/`, then token ID 1 would fetch `ipfs://QmRevealedCID/1.json`.

Each JSON file should follow a structure like:

```json
{
  "name": "NFT #1",
  "description": "Description for NFT #1",
  "image": "ipfs://QmYourImagesCID/1.png",
  "attributes": [
    {
      "trait_type": "Background",
      "value": "Blue"
    },
    {
      "trait_type": "Eyes",
      "value": "Green"
    }
  ]
}
```

### Minting NFTs

Users can mint NFTs by calling the `mint` function and sending the required ETH:

```javascript
// Example using ethers.js
const contractAddress = "0xYourContractAddress";
const abi = [...]; // The ABI of your contract
const quantity = 2; // Number of NFTs to mint
const price = ethers.utils.parseEther("0.1"); // 0.05 ETH per NFT * 2

const contract = new ethers.Contract(contractAddress, abi, signer);
const tx = await contract.mint(quantity, { value: price });
await tx.wait();
```

### Owner Functions

#### Revealing the Collection

When you're ready to reveal your collection:

```javascript
const revealedBaseURI = "ipfs://QmYourRevealedMetadataCID/";
const tx = await contract.revealCollection(revealedBaseURI);
await tx.wait();
```

#### Changing Mint Price

```javascript
const newPrice = ethers.utils.parseEther("0.1"); // 0.1 ETH
const tx = await contract.setMintPrice(newPrice);
await tx.wait();
```

#### Updating Royalty Information

```javascript
const newReceiver = "0xNewRoyaltyReceiverAddress";
const newPercentage = 1000; // 10%
const tx = await contract.setRoyaltyInfo(newReceiver, newPercentage);
await tx.wait();
```

#### Withdrawing Funds

```javascript
const tx = await contract.withdraw();
await tx.wait();
```

## Contract Functions Reference

### Public Functions

- **mint(uint256 quantity)**: Mints the specified quantity of NFTs to the caller's address.
  - Requires sending sufficient ETH (mintPrice * quantity)
  - Reverts if quantity would exceed maxSupply

- **tokenURI(uint256 tokenId)**: Returns the metadata URI for a specific token.
  - Returns hiddenBaseURI if the collection is not revealed
  - Returns the token-specific URI if the collection is revealed

- **royaltyInfo(uint256 tokenId, uint256 salePrice)**: Returns royalty information for a token.
  - Implements ERC-2981 standard
  - Returns the royalty receiver address and the royalty amount based on the sale price

### Owner-Only Functions

- **revealCollection(string memory _revealedBaseURI)**: Reveals the collection with the specified base URI.
  - Can only be called by the owner
  - Sets isRevealed to true

- **setMintPrice(uint256 _mintPrice)**: Updates the mint price.
  - Can only be called by the owner

- **setRoyaltyInfo(address _receiver, uint96 _percentage)**: Updates royalty information.
  - Can only be called by the owner
  - Percentage is in basis points (e.g., 500 = 5%)
  - Maximum percentage is 10000 (100%)

- **withdraw()**: Withdraws all funds from the contract to the owner's address.
  - Can only be called by the owner

## Security Considerations

- The contract uses OpenZeppelin's battle-tested libraries for security
- Constructor parameters cannot be changed after deployment (particularly maxSupply)
- Owner functions are protected with the Ownable modifier
- Consider a professional audit before deploying with significant value

## License

This project is licensed under the MIT License
```
