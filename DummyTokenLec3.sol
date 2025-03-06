// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2;

contract DummyTokenLec3 {
    mapping(address => uint) public balanceOf;
    uint cap = 200000;
    uint totalSupply = 500;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit(uint amount) public {
        balanceOf[msg.sender] = amount;
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Balance too low!");
        require(recipient != address(0), "Zero address detected");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        
        return true;
    }

    function mint(address recipient, uint amount) public returns (bool) {
        require(recipient != address(0), "Zero address detected");
        require(amount > 0, "Amount must be greater than 0");
        require(totalSupply <= cap, "Cap reached!");
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        return true;
    }
    
}
