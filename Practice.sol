// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rey2 is ERC20, Ownable {
    uint256 public feePercentage;
    address public beneficiary;

    event FeeUpdated(uint256 newFee);
    event BeneficiaryUpdated(address newBeneficiary);

    constructor(address recipient, uint256 initialSupply) ERC20 ("Rey", "RTK") Ownable(recipient) {
        //create n amount of tokens and send them to me
        uint256 supplyFormat = initialSupply * 10 ** decimals();
        _mint(recipient, supplyFormat);
    } 

    function setFeePercentage(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee cannot exceed 100%");
        feePercentage = newFee;
        emit FeeUpdated(newFee);
    }

    function setBeneficiary(address newBeneficiary) external onlyOwner {
        require(newBeneficiary != address(0), "Invalid address");
        beneficiary = newBeneficiary;
        emit BeneficiaryUpdated(newBeneficiary);
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0) && to != address(0)) {
            // Apply fee and burn logic for transfers
            uint256 feeAmount = (amount * feePercentage) / 100;
            uint256 recipientAmount = amount - feeAmount;
            uint256 burnAmount = (recipientAmount * 5) / 100;
            
            require(balanceOf(from) >= amount + burnAmount, "Insufficient balance");
            
            if (beneficiary != address(0) && feeAmount > 0) {
                super._update(from, beneficiary, feeAmount);
            }
            
            super._update(from, to, recipientAmount);
            
            if (burnAmount > 0) {
                super._update(from, address(0), burnAmount);
            }
        } else {
            super._update(from, to, amount);
        }
    }
}

contract Staking {
    Rey2 public token;
    uint256 public rewardPercentage = 5;

    constructor(address _token) {
        token = Rey2(_token);
    }

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTimestamp;
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function stake(uint256 amount) external {
        require(amount > 0, "make amount greater than 0");
        require(token.balanceOf(msg.sender) >= amount, "no balance to stake");

        //transfer tokens from user to contract (user must approve first)
        token.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        stakingTimestamp[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function withdraw() external {
        uint256 stakedAmount = stakedBalance[msg.sender];
        require(stakedAmount > 0, "No tokens staked");
        require(block.timestamp >= (stakingTimestamp[msg.sender]) + 1 seconds, "time constaint");

        uint256 claimTime = block.timestamp - stakingTimestamp[msg.sender];
        uint256 reward = 0;
        uint256 totalRewardPercentage = 0;
        totalRewardPercentage = rewardPercentage * claimTime;

        reward = (stakedAmount * totalRewardPercentage * claimTime) / 100;

        stakedBalance[msg.sender] = 0;
        stakingTimestamp[msg.sender] = 0;

        uint256 totalAmount = stakedAmount + reward;
        token.transfer(msg.sender, totalAmount);
        emit Withdrawn(msg.sender, totalAmount);
    }
}

contract TokenA is ERC20 {
    constructor(address recipient) ERC20("MyTokenA", "MTKA") {
        _mint(recipient, 1000000 * (10 ** decimals()));
    }
}

contract TokenB is ERC20 {
    constructor(address recipient) ERC20("MyTokenB", "MTKB") {
        _mint(recipient, 1000000 * (10 ** decimals()));
    }
}

contract Swap is Ownable{
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public rate;

    event Swapped(address indexed user, uint256 amountIn, uint256 amountOut);

    constructor(address _tokenA, address _tokenB, uint256 _rate) Ownable(msg.sender) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        require(_rate > 0, "Rate must be > 0");
        rate = _rate;
    }

    function fundContract(uint256 amountA, uint256 amountB) external {
        if (amountA > 0) {
            require(tokenA.transferFrom(msg.sender, address(this), amountA), "TokenA transfer failed");
        }
        if (amountB > 0) {
            require(tokenB.transferFrom(msg.sender, address(this), amountB), "TokenB transfer failed");
        }
    }

    function approveTokens(uint256 _amountToSwap) external onlyOwner {
        uint256 amountA = _amountToSwap * (10 ** IERC20Metadata(address(tokenA)).decimals());
        uint256 amountB = _amountToSwap * (10 ** IERC20Metadata(address(tokenB)).decimals());
        tokenA.approve(address(this), amountA);
        tokenB.approve(address(this), amountB);
    }

    function swapTokenA(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        //we use transferFrom to transfer tokens that belong to someone else, that you have been
        //..approved to do

        //msg.sender: represents the user's address, the person calling swapTokenA()
        //address(this) represents the contracts address
        tokenA.transferFrom(msg.sender, address(this), _amount);
        uint256 amountOut = _amount / rate;
        //we use transfer when we are transferring our own tokens

        //msg.sender is once again the user we are sending 'amountOut' to
        tokenB.transfer(msg.sender, amountOut);
        emit Swapped(msg.sender, _amount, amountOut);
    }

    function swapTokenB(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        tokenB.transferFrom(msg.sender, address(this), _amount);
        uint256 amountOut = _amount / rate;
        tokenA.transfer(msg.sender, amountOut);
        emit Swapped(msg.sender, _amount, amountOut);
    }

    function setRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate must be > 0");
        rate = _rate;
    }
}
