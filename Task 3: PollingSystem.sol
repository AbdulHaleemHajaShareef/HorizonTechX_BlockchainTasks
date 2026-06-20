// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title PollingSystem
 * @dev Create and manage polls with voting functionality
 * Task 3: Polling System Smart Contract
 */
contract PollingSystem {
    
    struct Poll {
        string title;
        string[] options;
        uint256 deadline;
        uint256[] votes;
        address creator;
        bool active;
        bool winnerDeclared;
        uint256 winningOption;
    }
    
    mapping(uint256 => Poll) public polls;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    uint256 public pollCount;
    
    event PollCreated(uint256 indexed pollId, string title, address creator, uint256 deadline);
    event VoteCast(uint256 indexed pollId, address indexed voter, uint256 optionIndex);
    event WinnerDeclared(uint256 indexed pollId, uint256 winningOption, uint256 winningVotes);
    
    modifier pollExists(uint256 _pollId) {
        require(_pollId < pollCount, "Poll does not exist");
        _;
    }
    
    modifier pollActive(uint256 _pollId) {
        require(polls[_pollId].active, "Poll is not active");
        require(block.timestamp < polls[_pollId].deadline, "Voting period has ended");
        _;
    }
    
    function createPoll(
        string memory _title, 
        string[] memory _options, 
        uint256 _durationInMinutes
    ) public returns (uint256) {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(_options.length >= 2, "Need at least 2 options");
        require(_durationInMinutes > 0, "Duration must be greater than 0");
        
        uint256 pollId = pollCount;
        uint256[] memory initialVotes = new uint256[](_options.length);
        
        polls[pollId] = Poll({
            title: _title,
            options: _options,
            deadline: block.timestamp + (_durationInMinutes * 1 minutes),
            votes: initialVotes,
            creator: msg.sender,
            active: true,
            winnerDeclared: false,
            winningOption: 0
        });
        
        pollCount++;
        emit PollCreated(pollId, _title, msg.sender, polls[pollId].deadline);
        return pollId;
    }
    
    function vote(uint256 _pollId, uint256 _optionIndex) public pollExists(_pollId) pollActive(_pollId) {
        require(!hasVoted[_pollId][msg.sender], "You have already voted");
        require(_optionIndex < polls[_pollId].options.length, "Invalid option index");
        
        hasVoted[_pollId][msg.sender] = true;
        polls[_pollId].votes[_optionIndex]++;
        emit VoteCast(_pollId, msg.sender, _optionIndex);
    }
    
    function declareWinner(uint256 _pollId) public pollExists(_pollId) returns (uint256 winningOptionIndex, uint256 winningVotes) {
        Poll storage poll = polls[_pollId];
        require(block.timestamp >= poll.deadline, "Voting period has not ended yet");
        require(!poll.winnerDeclared, "Winner already declared");
        
        uint256 maxVotes = 0;
        uint256 winnerIndex = 0;
        
        for (uint256 i = 0; i < poll.votes.length; i++) {
            if (poll.votes[i] > maxVotes) {
                maxVotes = poll.votes[i];
                winnerIndex = i;
            }
        }
        
        poll.winningOption = winnerIndex;
        poll.winnerDeclared = true;
        poll.active = false;
        
        emit WinnerDeclared(_pollId, winnerIndex, maxVotes);
        return (winnerIndex, maxVotes);
    }
    
    function getPoll(uint256 _pollId) public view pollExists(_pollId) returns (
        string memory title,
        string[] memory options,
        uint256 deadline,
        uint256[] memory votes,
        address creator,
        bool active,
        bool winnerDeclared,
        uint256 winningOption
    ) {
        Poll storage poll = polls[_pollId];
        return (poll.title, poll.options, poll.deadline, poll.votes, poll.creator, poll.active, poll.winnerDeclared, poll.winningOption);
    }
    
    function checkIfVoted(uint256 _pollId, address _voter) public view pollExists(_pollId) returns (bool) {
        return hasVoted[_pollId][_voter];
    }
    
    function getTimeRemaining(uint256 _pollId) public view pollExists(_pollId) returns (uint256) {
        if (block.timestamp >= polls[_pollId].deadline) return 0;
        return polls[_pollId].deadline - block.timestamp;
    }
    
    function getTotalPolls() public view returns (uint256) {
        return pollCount;
    }
}
