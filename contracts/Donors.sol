//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Donors {
    mapping (address => uint256) public paymentsOf;
    mapping (address => uint256) public donationsBy;

    address payable public owner;
    uint256 public balance;
    uint256 public withdrawn;
    uint256 public totalDonations = 0;
    uint256 public totalWithdrawal = 0;

    event Donation(
        uint256 id,
        address indexed to,
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    event Withdrawal(
        uint256 id,
        address indexed to,
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    constructor() {
        owner = payable(msg.sender);
    }

    function donate() payable public {
        require(msg.value > 0, "Donation cannot be zero!");

        paymentsOf[msg.sender] += msg.value;
        donationsBy[msg.sender] += 1;
        balance += msg.value;
        totalDonations++;

        emit Donation(
            totalDonations, 
            address(this), 
            msg.sender, 
            msg.value, 
            block.timestamp
        );
    }

    function withdraw(uint256 amount) external returns (bool) {
        require(msg.sender == owner, "Unauthorized!");
        require(balance >= amount, "Insufficient balance");

        balance -= amount;
        withdrawn += amount;
        owner.transfer(amount);
        totalWithdrawal++;

        emit Withdrawal(
            totalWithdrawal,
            msg.sender, 
            address(this),
            amount, 
            block.timestamp
        );
        return true;
    }
}