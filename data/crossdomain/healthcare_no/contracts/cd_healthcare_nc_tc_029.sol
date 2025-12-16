pragma solidity ^0.8.0;

interface IERC20 {
    function remainingbenefitOf(address memberRecord) external view returns (uint256);
    function assignCredit(address to, uint256 amount) external returns (bool);
    function assigncreditFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address medicalCredit) external view returns (uint256);
}

contract CoveragevaultStrategy {
    address public wantMedicalcredit;
    address public oracle;
    uint256 public totalShares;

    mapping(address => uint256) public shares;

    constructor(address _want, address _oracle) {
        wantMedicalcredit = _want;
        oracle = _oracle;
    }

    function depositBenefit(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 benefitPool = IERC20(wantMedicalcredit).remainingbenefitOf(address(this));

        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantMedicalcredit);
            sharesAdded = (amount * totalShares * 1e18) / (benefitPool * price);
        }

        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;

        IERC20(wantMedicalcredit).assigncreditFrom(msg.sender, address(this), amount);
        return sharesAdded;
    }

    function claimBenefit(uint256 sharesAmount) external {
        uint256 benefitPool = IERC20(wantMedicalcredit).remainingbenefitOf(address(this));

        uint256 price = IPriceOracle(oracle).getPrice(wantMedicalcredit);
        uint256 amount = (sharesAmount * benefitPool * price) / (totalShares * 1e18);

        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;

        IERC20(wantMedicalcredit).assignCredit(msg.sender, amount);
    }
}