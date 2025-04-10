// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//TODO:
/*
ListTokens
SellTokens - Seller -> Contract
BuyTokens - Payable
Prevent Frontrunning
GetList - Total Tokens
*/


contract ERC20Auction is ERC20, Ownable {
    struct Listing {
        address seller;
        IERC20 token;
        uint pricePerToken;
        uint remainingAmount;
    }
    mapping (uint => uint) public purchaseTimestamp;
    mapping (address => Listing) public ListedTokens;
    event Sold(address indexed user, IERC20 token, uint256 amount);
    event Bought(address indexed user, IERC20 token, uint256 amount);

    constructor(address recipient, address _token, uint pricePerToken, uint256 initialSupply) ERC20 ("Rey", "RTK") Ownable(recipient) {
        uint256 supplyFormat = initialSupply * 10 ** decimals();
        _mint(recipient, supplyFormat);
        IERC20 token = IERC20(_token);
        ListedTokens[recipient] = Listing (msg.sender, token, pricePerToken, initialSupply); 
    }

    function sellTokens(address _token, uint256 amount) external {
        IERC20 token = IERC20(_token);
        if(ListedTokens[msg.sender].token == token) {
            require(amount > 0, "Amount must be greater than 0");
            if(balanceOf(msg.sender) > amount) {
                token.transferFrom(msg.sender, address(this), amount);
            }
        }
        emit Sold(msg.sender, token, amount);
    }

    function buyTokens(address buyer, uint256 tokenAmount, address _token) external payable {
        //prevent front running
        uint purchaseTimeLimit = 5 seconds;
        uint256 purchaseTime = block.timestamp - purchaseTimestamp[msg.sender]; 
        if(purchaseTime > purchaseTimeLimit) {
            require (balanceOf(buyer) > tokenAmount * ListedTokens[msg.sender].pricePerToken, "Insufficient Fund");
            IERC20 token = IERC20(_token);
            if (_token == address(0)) {  //checking for zero address
                require (balanceOf(buyer) >= tokenAmount);
                payable(msg.sender).transfer(tokenAmount * ListedTokens[msg.sender].pricePerToken);
            }
            emit Bought(buyer, token, tokenAmount);
        }
        purchaseTimestamp[0] += block.timestamp;
    }

    function getListingCount() external view returns(uint) {
        uint256 count = 0;
        for (uint256 i; i > Listing; i+1) 
        {
            count += 1;
        }
        return count;
    }

}
