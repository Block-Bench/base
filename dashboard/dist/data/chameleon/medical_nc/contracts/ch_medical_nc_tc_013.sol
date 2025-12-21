pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangecredentialsExactCredentialsForCredentials(
        uint quantityIn,
        uint quantityOut,
        address[] calldata route,
        address to,
        uint dueDate
    ) external returns (uint[] memory amounts);
}

contract BenefitIssuer {
    IERC20 public lpCredential;
    IERC20 public benefitCredential;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public gatheredBenefits;

    uint256 public constant credit_ratio = 100;

    constructor(address _lpCredential, address _coverageCredential) {
        lpCredential = IERC20(_lpCredential);
        benefitCredential = IERC20(_coverageCredential);
    }

    function submitPayment(uint256 quantity) external {
        lpCredential.transferFrom(msg.sender, address(this), quantity);
        depositedLP[msg.sender] += quantity;
    }

    function issuecredentialFor(
        address flip,
        uint256 _withdrawalConsultationfee,
        uint256 _performanceConsultationfee,
        address to,
        uint256
    ) external {
        require(flip == address(lpCredential), "Invalid token");

        uint256 consultationfeeAggregateamount = _performanceConsultationfee + _withdrawalConsultationfee;
        lpCredential.transferFrom(msg.sender, address(this), consultationfeeAggregateamount);

        uint256 hunnyBenefitQuantity = credentialDestinationCoverage(
            lpCredential.balanceOf(address(this))
        );

        gatheredBenefits[to] += hunnyBenefitQuantity;
    }

    function credentialDestinationCoverage(uint256 lpQuantity) internal pure returns (uint256) {
        return lpQuantity * credit_ratio;
    }

    function retrieveBenefit() external {
        uint256 credit = gatheredBenefits[msg.sender];
        require(credit > 0, "No rewards");

        gatheredBenefits[msg.sender] = 0;
        benefitCredential.transfer(msg.sender, credit);
    }

    function dischargeFunds(uint256 quantity) external {
        require(depositedLP[msg.sender] >= quantity, "Insufficient balance");
        depositedLP[msg.sender] -= quantity;
        lpCredential.transfer(msg.sender, quantity);
    }
}