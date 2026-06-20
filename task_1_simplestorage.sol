// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SimpleStorage
 * @dev A basic contract to store and modify an integer value
 * Task 1: Simple Storage Smart Contract
 */
contract SimpleStorage {
    uint256 private storedValue;
    
    event ValueChanged(uint256 oldValue, uint256 newValue, string operation);
    
    function getValue() public view returns (uint256) {
        return storedValue;
    }
    
    function increment() public {
        uint256 oldValue = storedValue;
        storedValue += 1;
        emit ValueChanged(oldValue, storedValue, "increment");
    }
    
    function decrement() public {
        require(storedValue > 0, "Cannot decrement below zero");
        uint256 oldValue = storedValue;
        storedValue -= 1;
        emit ValueChanged(oldValue, storedValue, "decrement");
    }
    
    function setValue(uint256 _value) public {
        uint256 oldValue = storedValue;
        storedValue = _value;
        emit ValueChanged(oldValue, storedValue, "set");
    }
}
