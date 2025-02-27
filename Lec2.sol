// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Lec2 {
    //Payment Module:


    //by adding the below line it enables the contract to receive external payables i.e ether.
    //triggered when contract receives ether
    //external keyword specifies function can only be called from outside the contract
    //payable keyword allows it to accept ether
    receive() external payable { }

    //owner is a state variable that holds the address of the contracts deployer
    //msg.sender refers to the address that interacts with the contract (in this case addr of contract deployer
    //payable ensures address is capable of receiving ether in the future
    address payable owner = payable(msg.sender); //saves address of the one that deploys contract.
    
    //state variable storing balance of the contract (how much ether contract holds)
    //address(this).balance gets value of contract itself
    //this variable will be updated later when eth is transferred
    uint public contractBalance = address(this).balance;

    //a payable function is highlighted in red under the deploy section
    //function to send ether with the function call  
    function sendEther() public payable{
        //msg.value amount of ether sent with the function call
        //require statement ensures atleast one ether is sent 
        require(msg.value >=1 ether, "Not enough Ether");

        //address(this.balance) : current contracts balance
        //updates the contractBalance state variable to reflect the current balance of the contract after receiving the Ether.
        contractBalance = address(this).balance;

        //this line sends all the Ether in the contract to the owner address 
        //..(the address that deployed the contract). The transfer() function is used to send 
        //Ether to the owner. It sends the entire balance of the contract.
        payable(owner).transfer(contractBalance);
    }

    //Flow:
    /*
    Assume a user sends 3 ether, it is received at address(this).balance 
    , the line 'payable(owner).transfer(address(this).balance);' transfers ether received to 
    the 'owner' (represented by an address of the person who is the deployer of the contract.)

    1. Deploy Contract:
        When the contract is deployed, the contract's owner is set to the address that deployed the contract (the msg.sender).
    2. Sending Ether to the Contract:
        When someone sends Ether (let's say 3 Ether) to the contract, the receive() function is triggered, and the Ether is stored in the contract's balance.
    3. Calling sendEther:
        After sending Ether to the contract, a user can call the sendEther() function.
        If they send at least 1 Ether (this is checked by the require statement), the contract's balance
        Then, all the Ether in the contract (the contract balance) is sent to the owner's address.
    4. Outcome:
        After calling sendEther(), the contract's balance is zero, and the owner has received all the Ether stored in the contract.
        
    */
}

