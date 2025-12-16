pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address coverageProfile) external view returns (uint256);

    function permitPayout(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function assigncreditFrom(address from, address to, uint256 healthtokenId) external;

    function supervisorOf(uint256 healthtokenId) external view returns (address);
}

contract WiseHealthcredit {
    struct InsurancepoolData {
        uint256 pseudoTotalBenefitpool;
        uint256 totalContributepremiumShares;
        uint256 totalAccesscreditShares;
        uint256 deductibleFactor;
    }

    mapping(address => InsurancepoolData) public benefitadvanceInsurancepoolData;
    mapping(uint256 => mapping(address => uint256)) public beneficiaryMedicalloanShares;
    mapping(uint256 => mapping(address => uint256)) public memberBorrowcreditShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function assigncoveragePosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function contributepremiumExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).assigncreditFrom(msg.sender, address(this), _amount);

        InsurancepoolData storage claimPool = benefitadvanceInsurancepoolData[_poolToken];

        if (claimPool.totalContributepremiumShares == 0) {
            shareAmount = _amount;
            claimPool.totalContributepremiumShares = _amount;
        } else {
            shareAmount =
                (_amount * claimPool.totalContributepremiumShares) /
                claimPool.pseudoTotalBenefitpool;
            claimPool.totalContributepremiumShares += shareAmount;
        }

        claimPool.pseudoTotalBenefitpool += _amount;
        beneficiaryMedicalloanShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function accessbenefitExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 accessbenefitAmount) {
        require(
            beneficiaryMedicalloanShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        InsurancepoolData storage claimPool = benefitadvanceInsurancepoolData[_poolToken];

        accessbenefitAmount =
            (_shares * claimPool.pseudoTotalBenefitpool) /
            claimPool.totalContributepremiumShares;

        beneficiaryMedicalloanShares[_nftId][_poolToken] -= _shares;
        claimPool.totalContributepremiumShares -= _shares;
        claimPool.pseudoTotalBenefitpool -= accessbenefitAmount;

        IERC20(_poolToken).assignCredit(msg.sender, accessbenefitAmount);

        return accessbenefitAmount;
    }

    function withdrawfundsExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        InsurancepoolData storage claimPool = benefitadvanceInsurancepoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * claimPool.totalContributepremiumShares) /
            claimPool.pseudoTotalBenefitpool;

        require(
            beneficiaryMedicalloanShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        beneficiaryMedicalloanShares[_nftId][_poolToken] -= shareBurned;
        claimPool.totalContributepremiumShares -= shareBurned;
        claimPool.pseudoTotalBenefitpool -= _withdrawAmount;

        IERC20(_poolToken).assignCredit(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionHealthcreditShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return beneficiaryMedicalloanShares[_nftId][_poolToken];
    }

    function getTotalClaimpool(address _poolToken) external view returns (uint256) {
        return benefitadvanceInsurancepoolData[_poolToken].pseudoTotalBenefitpool;
    }
}