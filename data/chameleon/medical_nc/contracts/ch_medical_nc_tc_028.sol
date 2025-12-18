pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);
    function transfer(address to, uint256 quantity) external returns (bool);
    function transferFrom(address source, address to, uint256 quantity) external returns (bool);
}

contract PatientRecordsVault {
    address public credential;
    mapping(address => uint256) public payments;

    constructor(address _token) {
        credential = _token;
    }

    function submitPayment(uint256 quantity) external {
        IERC20(credential).transferFrom(msg.sender, address(this), quantity);

        payments[msg.sender] += quantity;
    }

    function dischargeFunds(uint256 quantity) external {
        require(payments[msg.sender] >= quantity, "Insufficient");

        payments[msg.sender] -= quantity;

        IERC20(credential).transfer(msg.sender, quantity);
    }
}