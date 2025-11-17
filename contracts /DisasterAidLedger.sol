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

    // ✨ EVENT LOGS ADDED
    event DonationReceived(address indexed donor, uint amount, uint timestamp);
    event FundsDistributed(address indexed beneficiary, uint amount, string name);

    constructor() {
        admin = msg.sender;
    }

    // Function 1: Accept Donations
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than zero");

        donations[msg.sender].push(
            Donation(msg.sender, msg.value, block.timestamp)
        );

        totalFunds += msg.value;

        emit DonationReceived(msg.sender, msg.value, block.timestamp); // NEW
    }

    // Function 2: Distribute Relief Funds
    function distributeFunds(
        address payable _beneficiary,
        string memory _name,
        uint _amount
    ) external {
        require(msg.sender == admin, "Only admin can distribute funds");
        require(_amount <= totalFunds - totalDistributed, "Insufficient funds");

        beneficiaries[_beneficiary] = Beneficiary(
            _name,
            beneficiaries[_beneficiary].amountReceived + _amount
        );

        totalDistributed += _amount;
        _beneficiary.transfer(_amount);

        emit FundsDistributed(_beneficiary, _amount, _name); // NEW
    }

    // Function 3: Check Donation Summary
    function getDonationSummary(address _donor)
        external
        view
        returns (uint totalDonated, uint numberOfDonations)
    {
        Donation[] memory userDonations = donations[_donor];
        uint total = 0;

        for (uint i = 0; i < userDonations.length; i++) {
            total += userDonations[i].amount;
        }

        return (total, userDonations.length);
    }
        /**
     * @notice Change the admin account.
     * @param newAdmin The new admin address.
     */
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid new admin");

        address old = admin;
        admin = newAdmin;

        emit AdminChanged(old, newAdmin);
    }
}
