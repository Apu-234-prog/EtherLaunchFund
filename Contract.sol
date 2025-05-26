
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFundX {
    address public creator;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    bool public withdrawn;

    mapping(address => uint) public contributions;

    event Funded(address indexed backer, uint amount);
    event Withdrawn(uint amount);
    event Refunded(address indexed backer, uint amount);

    constructor(uint _goalInWei, uint _durationInMinutes) {
        require(_goalInWei > 0, "Goal must be greater than 0");
        creator = msg.sender;
        goal = _goalInWei;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    /// @notice Fund the project
    function fund() external payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Must send some ether");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit Funded(msg.sender, msg.value);
    }

    /// @notice Creator withdraws funds if goal is met
    function withdraw() external {
        require(msg.sender == creator, "Only creator can withdraw");
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalRaised >= goal, "Funding goal not reached");
        require(!withdrawn, "Funds already withdrawn");

        withdrawn = true;
        payable(creator).transfer(totalRaised);

        emit Withdrawn(totalRaised);
    }

    /// @notice Contributors can get refunds if goal not met
    function refund() external {
        require(block.timestamp >= deadline, "Campaign still active");
        require(totalRaised < goal, "Funding goal was met");
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution found");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit Refunded(msg.sender, amount);
    }

    /// @notice View remaining time in seconds
    function timeLeft() external view returns (uint) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}
