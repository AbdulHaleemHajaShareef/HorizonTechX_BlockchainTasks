// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title CryptoLock
 * @dev Lock Ether for a specified period with time-based withdrawal
 * Task 4: Crypto Locking Smart Contract
 */
contract CryptoLock {
    
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }
    
    mapping(address => Lock) public locks;
    address[] public lockHolders;
    mapping(address => bool) public isLockHolder;
    uint256 public totalLocked;
    
    event FundsLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event LockExtended(address indexed user, uint256 newUnlockTime);
    
    function deposit(uint256 _lockDurationInMinutes) external payable {
        require(msg.value > 0, "Must send some Ether");
        require(_lockDurationInMinutes > 0, "Lock duration must be greater than 0");
        require(locks[msg.sender].amount == 0 || locks[msg.sender].withdrawn, "Active lock exists");
        
        uint256 unlockTime = block.timestamp + (_lockDurationInMinutes * 1 minutes);
        
        locks[msg.sender] = Lock({
            amount: msg.value,
            unlockTime: unlockTime,
            withdrawn: false
        });
        
        if (!isLockHolder[msg.sender]) {
            lockHolders.push(msg.sender);
            isLockHolder[msg.sender] = true;
        }
        
        totalLocked += msg.value;
        emit FundsLocked(msg.sender, msg.value, unlockTime);
    }
    
    function withdraw() external {
        Lock storage userLock = locks[msg.sender];
        require(userLock.amount > 0, "No funds locked");
        require(!userLock.withdrawn, "Funds already withdrawn");
        require(block.timestamp >= userLock.unlockTime, "Lock period has not ended yet");
        
        uint256 amount = userLock.amount;
        userLock.withdrawn = true;
        totalLocked -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
        emit FundsWithdrawn(msg.sender, amount);
    }
    
    function extendLock(uint256 _additionalMinutes) external {
        Lock storage userLock = locks[msg.sender];
        require(userLock.amount > 0, "No funds locked");
        require(!userLock.withdrawn, "Funds already withdrawn");
        require(_additionalMinutes > 0, "Additional time must be greater than 0");
        
        userLock.unlockTime += (_additionalMinutes * 1 minutes);
        emit LockExtended(msg.sender, userLock.unlockTime);
    }
    
    function getMyLock() external view returns (uint256 amount, uint256 unlockTime, uint256 timeRemaining, bool withdrawn) {
        Lock storage userLock = locks[msg.sender];
        uint256 remaining = 0;
        if (block.timestamp < userLock.unlockTime) {
            remaining = userLock.unlockTime - block.timestamp;
        }
        return (userLock.amount, userLock.unlockTime, remaining, userLock.withdrawn);
    }
    
    function getLockDetails(address _user) external view returns (uint256 amount, uint256 unlockTime, uint256 timeRemaining, bool withdrawn) {
        Lock storage userLock = locks[_user];
        uint256 remaining = 0;
        if (block.timestamp < userLock.unlockTime) {
            remaining = userLock.unlockTime - block.timestamp;
        }
        return (userLock.amount, userLock.unlockTime, remaining, userLock.withdrawn);
    }
    
    function canWithdraw() external view returns (bool) {
        Lock storage userLock = locks[msg.sender];
        return (userLock.amount > 0 && !userLock.withdrawn && block.timestamp >= userLock.unlockTime);
    }
    
    function getLockHolderCount() external view returns (uint256) {
        return lockHolders.length;
    }
    
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
