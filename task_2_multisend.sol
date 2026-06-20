// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MultiSend
 * @dev Distribute equal Ether to multiple addresses
 * Task 2: Multi-Send Smart Contract
 */
contract MultiSend {
    address public owner;
    
    event Distribution(address indexed sender, uint256 totalAmount, uint256 recipientCount, uint256 amountPerRecipient);
    event FundsReceived(address indexed sender, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
    
    fallback() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
    
    function distributeEqual(address[] calldata recipients) external payable onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        
        uint256 totalAmount = msg.value;
        uint256 amountPerRecipient = totalAmount / recipients.length;
        require(amountPerRecipient > 0, "Amount too small to distribute");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid address in recipients");
            (bool success, ) = recipients[i].call{value: amountPerRecipient}("");
            require(success, "Transfer failed");
        }
        
        uint256 distributed = amountPerRecipient * recipients.length;
        uint256 remaining = totalAmount - distributed;
        if (remaining > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: remaining}("");
            require(refundSuccess, "Refund failed");
        }
        
        emit Distribution(msg.sender, totalAmount, recipients.length, amountPerRecipient);
    }
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawal failed");
        emit Withdrawal(owner, balance);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}
