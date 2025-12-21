pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);
}

interface ICErc20 {
    function requestAdvance(uint256 quantity) external returns (uint256);

    function requestadvanceAccountcreditsActive(address profile) external returns (uint256);
}

contract LeveragedVault {
    struct CarePosition {
        address owner;
        uint256 securityDeposit;
        uint256 outstandingbalanceAllocation;
    }

    mapping(uint256 => CarePosition) public positions;
    uint256 public followingPositionChartnumber;

    address public cCredential;
    uint256 public totalamountOutstandingbalance;
    uint256 public totalamountOutstandingbalanceAllocation;

    constructor(address _cCredential) {
        cCredential = _cCredential;
        followingPositionChartnumber = 1;
    }

    function openPosition(
        uint256 securitydepositQuantity,
        uint256 requestadvanceQuantity
    ) external returns (uint256 positionCasenumber) {
        positionCasenumber = followingPositionChartnumber++;

        positions[positionCasenumber] = CarePosition({
            owner: msg.sender,
            securityDeposit: securitydepositQuantity,
            outstandingbalanceAllocation: 0
        });

        _borrow(positionCasenumber, requestadvanceQuantity);

        return positionCasenumber;
    }

    function _borrow(uint256 positionCasenumber, uint256 quantity) internal {
        CarePosition storage pos = positions[positionCasenumber];

        uint256 allocation;

        if (totalamountOutstandingbalanceAllocation == 0) {
            allocation = quantity;
        } else {
            allocation = (quantity * totalamountOutstandingbalanceAllocation) / totalamountOutstandingbalance;
        }

        pos.outstandingbalanceAllocation += allocation;
        totalamountOutstandingbalanceAllocation += allocation;
        totalamountOutstandingbalance += quantity;

        ICErc20(cCredential).requestAdvance(quantity);
    }

    function settleBalance(uint256 positionCasenumber, uint256 quantity) external {
        CarePosition storage pos = positions[positionCasenumber];
        require(msg.sender == pos.owner, "Not position owner");

        uint256 portionReceiverDischarge = (quantity * totalamountOutstandingbalanceAllocation) / totalamountOutstandingbalance;

        require(pos.outstandingbalanceAllocation >= portionReceiverDischarge, "Excessive repayment");

        pos.outstandingbalanceAllocation -= portionReceiverDischarge;
        totalamountOutstandingbalanceAllocation -= portionReceiverDischarge;
        totalamountOutstandingbalance -= quantity;
    }

    function obtainPositionOutstandingbalance(
        uint256 positionCasenumber
    ) external view returns (uint256) {
        CarePosition storage pos = positions[positionCasenumber];

        if (totalamountOutstandingbalanceAllocation == 0) return 0;

        return (pos.outstandingbalanceAllocation * totalamountOutstandingbalance) / totalamountOutstandingbalanceAllocation;
    }

    function forceSettlement(uint256 positionCasenumber) external {
        CarePosition storage pos = positions[positionCasenumber];

        uint256 outstandingBalance = (pos.outstandingbalanceAllocation * totalamountOutstandingbalance) / totalamountOutstandingbalanceAllocation;

        require(pos.securityDeposit * 100 < outstandingBalance * 150, "Position is healthy");

        pos.securityDeposit = 0;
        pos.outstandingbalanceAllocation = 0;
    }
}