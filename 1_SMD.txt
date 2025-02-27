// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {
    uint a=2;
    /*uint b=4;
    function add() public view returns(uint) {
        return a+b;
    }
    function sub() public view returns(uint) {
        return a-b;
    }
    function div() public view returns(uint) {
        return a/b;
    }*/
    bool flag = true;
    function checker() public view returns(string memory){
        require(a%2==0, "Error");
        return "even";
    }
    
    string str1 = "Hello";
    string str2 = "Sir";

}

