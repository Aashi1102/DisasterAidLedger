// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisasterAidLedger {
    address public admin;

    struct Donation {
        address donor;
        uint amount;
        uint timestamp;
    }

    struct Beneficiary {
        string name;
        uint amountReceived;
    }

    mapping(address => Donation[]) public donations;
    mapping(address => Beneficiary) public beneficiaries;

    uint public totalFunds;
    uint public totalDistributed;

    constructor() {
        admin = msg.sender;
    }

    // Function 1: Accept Donations
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than zero");
        donations[msg.sender].push(Donation(msg.sender, msg.value, block.timestamp));
        totalFunds += msg.value;
    }

    // Function 2: Distribute Relief Funds
    function distributeFunds(address payable _beneficiary, string memory _name, uint _amount) external {
        require(msg.sender == admin, "Only admin can distribute funds");
        require(_amount <= totalFunds - totalDistributed, "Insufficient funds");

        beneficiaries[_beneficiary] = Beneficiary(_name, beneficiaries[_beneficiary].amountReceived + _amount);
        totalDistributed += _amount;
        _beneficiary.transfer(_amount);
    }

    // Function 3: Check Donation Summary
    function getDonationSummary(address _donor) external view returns (uint totalDonated, uint numberOfDonations) {
        Donation[] memory userDonations = donations[_donor];
        uint total = 0;
        for (uint i = 0; i < userDonations.length; i++) {
            total += userDonations[i].amount;
        }
        return (total, userDonations.length);
    }
}

