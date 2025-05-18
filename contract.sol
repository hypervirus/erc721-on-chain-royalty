// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SimpleNFT is ERC721Enumerable, Ownable, IERC2981 {
    using Strings for uint256;
    
    // Maximum supply of tokens
    uint256 public immutable maxSupply;
    
    // Mint price
    uint256 public mintPrice = 0.05 ether;
    
    // Hidden URI for metadata before reveal
    string private hiddenBaseURI;
    
    // Revealed URI for metadata after reveal
    string private revealedBaseURI;
    
    // Flag to check if collection is revealed
    bool public isRevealed = false;
    
    // Royalty information
    address private royaltyReceiver;
    uint96 private royaltyPercentage;
    
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        string memory _hiddenBaseURI,
        address _royaltyReceiver,
        uint96 _royaltyPercentage
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        maxSupply = _maxSupply;
        hiddenBaseURI = _hiddenBaseURI;
        royaltyReceiver = _royaltyReceiver;
        royaltyPercentage = _royaltyPercentage;
    }
    
    // Public mint function
    function mint(uint256 quantity) external payable {
        uint256 supply = totalSupply();
        require(quantity > 0, "Must mint at least 1 NFT");
        require(supply + quantity <= maxSupply, "Exceeds maximum supply");
        require(msg.value >= mintPrice * quantity, "Insufficient payment");
        
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }
    
    // Override tokenURI function to handle hidden/revealed state
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        if (!isRevealed) {
            return hiddenBaseURI;
        }
        
        return string(abi.encodePacked(revealedBaseURI, tokenId.toString(), ".json"));
    }
    
    // Owner function to reveal collection
    function revealCollection(string memory _revealedBaseURI) external onlyOwner {
        revealedBaseURI = _revealedBaseURI;
        isRevealed = true;
    }
    
    // Owner function to set mint price
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }
    
    // Owner function to set royalty info
    function setRoyaltyInfo(address _receiver, uint96 _percentage) external onlyOwner {
        require(_percentage <= 10000, "Percentage cannot exceed 100%");
        royaltyReceiver = _receiver;
        royaltyPercentage = _percentage;
    }
    
    // Owner function to withdraw funds
    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}("");
        require(success, "Withdrawal failed");
    }
    
    // Implementation of IERC2981 royaltyInfo
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(_tokenId), "Token does not exist");
        
        // Calculate royalty amount (percentage is in basis points, e.g. 500 = 5%)
        uint256 amount = (_salePrice * royaltyPercentage) / 10000;
        
        return (royaltyReceiver, amount);
    }
    
    // Override supportsInterface to declare IERC2981 support
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, IERC165) returns (bool) {
        return 
            interfaceId == type(IERC2981).interfaceId || 
            super.supportsInterface(interfaceId);
    }

    // Helper function to check if token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId > 0 && tokenId <= totalSupply();
    }
}
