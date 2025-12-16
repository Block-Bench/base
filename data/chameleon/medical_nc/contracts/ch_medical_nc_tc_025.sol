pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);
    function transferFrom(address referrer, address to, uint256 measure) external returns (bool);
}

interface ICompoundId {
    function seekCoverage(uint256 measure) external;
    function returnequipmentRequestadvance(uint256 measure) external;
    function cashOutCoverage(uint256 credentials) external;
    function createPrescription(uint256 measure) external;
}

contract LendingMarket {
    mapping(address => uint256) public profileBorrows;
    mapping(address => uint256) public profileIds;

    address public underlying;
    uint256 public cumulativeBorrows;

    constructor(address _underlying) {
        underlying = _underlying;
    }

    function seekCoverage(uint256 measure) external {
        profileBorrows[msg.sender] += measure;
        cumulativeBorrows += measure;

        IERC20(underlying).transfer(msg.sender, measure);
    }

    function returnequipmentRequestadvance(uint256 measure) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), measure);

        profileBorrows[msg.sender] -= measure;
        cumulativeBorrows -= measure;
    }
}