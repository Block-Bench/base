// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 dosage
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address subscriber, uint256 dosage) external returns (bool);
}

interface IERC721 {
    function transferFrom(address source, address to, uint256 badgeCasenumber) external;

    function ownerOf(uint256 badgeCasenumber) external view returns (address);
}

contract WiseLending {
    struct PoolRecord {
        uint256 pseudoCumulativePool;
        uint256 completeRegisterpaymentPortions;
        uint256 cumulativeRequestadvanceAllocations;
        uint256 depositFactor;
    }

    mapping(address => PoolRecord) public lendingPoolChart;
    mapping(uint256 => mapping(address => uint256)) public enrolleeLendingPortions;
    mapping(uint256 => mapping(address => uint256)) public memberRequestadvanceAllocations;

    IERC721 public positionNFTs;
    uint256 public credentialChartnumberTally;

    function issuecredentialPosition() external returns (uint256) {
        uint256 certificateCasenumber = ++credentialChartnumberTally;
        return certificateCasenumber;
    }

    function providespecimenExactDosage(
        uint256 _credentialCasenumber,
        address _poolBadge,
        uint256 _amount
    ) external returns (uint256 portionQuantity) {
        IERC20(_poolBadge).transferFrom(msg.sender, address(this), _amount);

        PoolRecord storage donorPool = lendingPoolChart[_poolBadge];

        if (donorPool.completeRegisterpaymentPortions == 0) {
            portionQuantity = _amount;
            donorPool.completeRegisterpaymentPortions = _amount;
        } else {
            portionQuantity =
                (_amount * donorPool.completeRegisterpaymentPortions) /
                donorPool.pseudoCumulativePool;
            donorPool.completeRegisterpaymentPortions += portionQuantity;
        }

        donorPool.pseudoCumulativePool += _amount;
        enrolleeLendingPortions[_credentialCasenumber][_poolBadge] += portionQuantity;

        return portionQuantity;
    }

    function claimcoverageExactAllocations(
        uint256 _credentialCasenumber,
        address _poolBadge,
        uint256 _shares
    ) external returns (uint256 retrievesuppliesQuantity) {
        require(
            enrolleeLendingPortions[_credentialCasenumber][_poolBadge] >= _shares,
            "Insufficient shares"
        );

        PoolRecord storage donorPool = lendingPoolChart[_poolBadge];

        retrievesuppliesQuantity =
            (_shares * donorPool.pseudoCumulativePool) /
            donorPool.completeRegisterpaymentPortions;

        enrolleeLendingPortions[_credentialCasenumber][_poolBadge] -= _shares;
        donorPool.completeRegisterpaymentPortions -= _shares;
        donorPool.pseudoCumulativePool -= retrievesuppliesQuantity;

        IERC20(_poolBadge).transfer(msg.sender, retrievesuppliesQuantity);

        return retrievesuppliesQuantity;
    }

    function withdrawbenefitsExactUnits(
        uint256 _credentialCasenumber,
        address _poolBadge,
        uint256 _withdrawbenefitsUnits
    ) external returns (uint256 portionBurned) {
        PoolRecord storage donorPool = lendingPoolChart[_poolBadge];

        portionBurned =
            (_withdrawbenefitsUnits * donorPool.completeRegisterpaymentPortions) /
            donorPool.pseudoCumulativePool;

        require(
            enrolleeLendingPortions[_credentialCasenumber][_poolBadge] >= portionBurned,
            "Insufficient shares"
        );

        enrolleeLendingPortions[_credentialCasenumber][_poolBadge] -= portionBurned;
        donorPool.completeRegisterpaymentPortions -= portionBurned;
        donorPool.pseudoCumulativePool -= _withdrawbenefitsUnits;

        IERC20(_poolBadge).transfer(msg.sender, _withdrawbenefitsUnits);

        return portionBurned;
    }

    function retrievePositionLendingPortions(
        uint256 _credentialCasenumber,
        address _poolBadge
    ) external view returns (uint256) {
        return enrolleeLendingPortions[_credentialCasenumber][_poolBadge];
    }

    function obtainCumulativePool(address _poolBadge) external view returns (uint256) {
        return lendingPoolChart[_poolBadge].pseudoCumulativePool;
    }
}
