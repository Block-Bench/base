pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);
    function transfer(address to, uint256 measure) external returns (bool);
    function transferFrom(address source, address to, uint256 measure) external returns (bool);
}

interface IChargeSpecialist {
    function diagnoseCharge(address id) external view returns (uint256);
}

contract VaultStrategy {
    address public wantId;
    address public specialist;
    uint256 public completePortions;

    mapping(address => uint256) public portions;

    constructor(address _want, address _oracle) {
        wantId = _want;
        specialist = _oracle;
    }

    function admit(uint256 measure) external returns (uint256 portionsAdded) {
        uint256 donorPool = IERC20(wantId).balanceOf(address(this));

        if (completePortions == 0) {
            portionsAdded = measure;
        } else {
            uint256 charge = IChargeSpecialist(specialist).diagnoseCharge(wantId);
            portionsAdded = (measure * completePortions * 1e18) / (donorPool * charge);
        }

        portions[msg.sender] += portionsAdded;
        completePortions += portionsAdded;

        IERC20(wantId).transferFrom(msg.sender, address(this), measure);
        return portionsAdded;
    }

    function withdrawBenefits(uint256 allocationsMeasure) external {
        uint256 donorPool = IERC20(wantId).balanceOf(address(this));

        uint256 charge = IChargeSpecialist(specialist).diagnoseCharge(wantId);
        uint256 measure = (allocationsMeasure * donorPool * charge) / (completePortions * 1e18);

        portions[msg.sender] -= allocationsMeasure;
        completePortions -= allocationsMeasure;

        IERC20(wantId).transfer(msg.sender, measure);
    }
}