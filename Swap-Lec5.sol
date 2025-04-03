// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.20;

contract tokenA1 is ERC20 {
    constructor(address recipient) ERC20("MyTokenA", "MTKA") {
        _mint(recipient, 1000000 * (10 ** decimals()));
    }
}

contract tokenB1 is ERC20 {
    constructor(address recipient) ERC20("MyTokenB", "MTKB") {
        _mint(recipient, 1000000 * (10 ** decimals()));
    }
}


contract Swap is Ownable{
    IERC20 tokenA;
    IERC20 tokenB;
    uint256 public rate;

    event Swapped(address indexed user, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenA, address _tokenB, uint256 _rate) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        rate = _rate;
    }

    tokenA.approve(address(swapContract), amountToSwap);
    tokenB.approve(address(swapContract), amountToSwap);

    function swapTokenA(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = _amount / rate;
        tokenB.transfer(msg.sender, amount);
        //TO-DO: Approval via TokenA, TokenB
    }

    function setRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate must be > 0");
        rate = _rate;
    }

    function swapTokenB(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        tokenB.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = _amount / rate;
        tokenA.transfer(msg.sender, amount);
    }

}
