// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function transferbenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function coverageOf(address coverageProfile) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferbenefitFrom(address from, address to, uint256 healthtokenId) external;

    function supervisorOf(uint256 healthtokenId) external view returns (address);
}

contract WiseMedicalloan {
    struct BenefitpoolData {
        uint256 pseudoTotalCoveragepool;
        uint256 totalContributepremiumShares;
        uint256 totalTakehealthloanShares;
        uint256 copayFactor;
    }

    mapping(address => BenefitpoolData) public benefitadvanceBenefitpoolData;
    mapping(uint256 => mapping(address => uint256)) public subscriberBenefitadvanceShares;
    mapping(uint256 => mapping(address => uint256)) public patientBorrowcreditShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function issuecoveragePosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function addcoverageExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).transferbenefitFrom(msg.sender, address(this), _amount);

        BenefitpoolData storage insurancePool = benefitadvanceBenefitpoolData[_poolToken];

        if (insurancePool.totalContributepremiumShares == 0) {
            shareAmount = _amount;
            insurancePool.totalContributepremiumShares = _amount;
        } else {
            shareAmount =
                (_amount * insurancePool.totalContributepremiumShares) /
                insurancePool.pseudoTotalCoveragepool;
            insurancePool.totalContributepremiumShares += shareAmount;
        }

        insurancePool.pseudoTotalCoveragepool += _amount;
        subscriberBenefitadvanceShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function claimbenefitExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 claimbenefitAmount) {
        require(
            subscriberBenefitadvanceShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        BenefitpoolData storage insurancePool = benefitadvanceBenefitpoolData[_poolToken];

        claimbenefitAmount =
            (_shares * insurancePool.pseudoTotalCoveragepool) /
            insurancePool.totalContributepremiumShares;

        subscriberBenefitadvanceShares[_nftId][_poolToken] -= _shares;
        insurancePool.totalContributepremiumShares -= _shares;
        insurancePool.pseudoTotalCoveragepool -= claimbenefitAmount;

        IERC20(_poolToken).assignCredit(msg.sender, claimbenefitAmount);

        return claimbenefitAmount;
    }

    function collectcoverageExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        BenefitpoolData storage insurancePool = benefitadvanceBenefitpoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * insurancePool.totalContributepremiumShares) /
            insurancePool.pseudoTotalCoveragepool;

        require(
            subscriberBenefitadvanceShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        subscriberBenefitadvanceShares[_nftId][_poolToken] -= shareBurned;
        insurancePool.totalContributepremiumShares -= shareBurned;
        insurancePool.pseudoTotalCoveragepool -= _withdrawAmount;

        IERC20(_poolToken).assignCredit(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionHealthcreditShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return subscriberBenefitadvanceShares[_nftId][_poolToken];
    }

    function getTotalInsurancepool(address _poolToken) external view returns (uint256) {
        return benefitadvanceBenefitpoolData[_poolToken].pseudoTotalCoveragepool;
    }
}
