// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./Token.sol";

// Learn more about the ERC20 implementation 
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vendor is Ownable {

    using SafeMath for uint256;
    
    address public token; // Address of the ERC20 token being traded
    uint256 public rate; // Exchange rate in tokens per ether
    uint256 public supply; // Amount of tokens available for sale
    
    mapping (address => uint256) public balances; // Track balances of buyers and sellers
    
    event Bought(address indexed buyer, uint256 amount);
    event Sold(address indexed seller, uint256 amount);
    
    constructor(address _token, uint256 _rate, uint256 _supply) {
        token = _token;
        rate = _rate;
        supply = _supply;
    }

    function buy() payable public {
        uint256 amount = msg.value.mul(rate); // Calculate amount of tokens to buy
        require(amount <= supply, "Not enough tokens available for sale");
        
        MyToken(token).transfer(msg.sender, amount); // Transfer tokens to buyer
        supply = supply.sub(amount); // Update available supply
        
        emit Bought(msg.sender, amount);
    }
    
    function sell(uint256 amount) public {
        require(MyToken(token).balanceOf(msg.sender) >= amount, "Not enough tokens to sell");
        
        uint256 value = amount.div(rate); // Calculate ether value to receive
        supply = supply.add(amount); // Update available supply
        
        MyToken(token).transferFrom(msg.sender, address(this), amount); // Transfer tokens to contract
        payable(msg.sender).transfer(value); // Transfer ether to seller
        
        emit Sold(msg.sender, amount);
    }

    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has not balance to withdraw");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }

}