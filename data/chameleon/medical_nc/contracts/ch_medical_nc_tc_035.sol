pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address subscriber, uint256 units) external returns (bool);
}

interface IERC721 {
    function transferFrom(address referrer, address to, uint256 credentialChartnumber) external;

    function ownerOf(uint256 credentialChartnumber) external view returns (address);
}

contract WiseLending {
    struct PoolChart {
        uint256 pseudoCompletePool;
        uint256 completeProvidespecimenPortions;
        uint256 completeRequestadvanceAllocations;
        uint256 depositFactor;
    }

    mapping(address => PoolChart) public lendingPoolRecord;
    mapping(uint256 => mapping(address => uint256)) public beneficiaryLendingPortions;
    mapping(uint256 => mapping(address => uint256)) public enrolleeRequestadvancePortions;

    IERC721 public positionNFTs;
    uint256 public certificateIdentifierTally;

    function issuecredentialPosition() external returns (uint256) {
        uint256 certificateCasenumber = ++certificateIdentifierTally;
        return certificateCasenumber;
    }

    function registerpaymentExactUnits(
        uint256 _certificateCasenumber,
        address _poolCredential,
        uint256 _amount
    ) external returns (uint256 portionDosage) {
        IERC20(_poolCredential).transferFrom(msg.sender, address(this), _amount);

        PoolChart storage therapyPool = lendingPoolRecord[_poolCredential];

        if (therapyPool.completeProvidespecimenPortions == 0) {
            portionDosage = _amount;
            therapyPool.completeProvidespecimenPortions = _amount;
        } else {
            portionDosage =
                (_amount * therapyPool.completeProvidespecimenPortions) /
                therapyPool.pseudoCompletePool;
            therapyPool.completeProvidespecimenPortions += portionDosage;
        }

        therapyPool.pseudoCompletePool += _amount;
        beneficiaryLendingPortions[_certificateCasenumber][_poolCredential] += portionDosage;

        return portionDosage;
    }

    function obtaincareExactAllocations(
        uint256 _certificateCasenumber,
        address _poolCredential,
        uint256 _shares
    ) external returns (uint256 dispensemedicationDosage) {
        require(
            beneficiaryLendingPortions[_certificateCasenumber][_poolCredential] >= _shares,
            "Insufficient shares"
        );

        PoolChart storage therapyPool = lendingPoolRecord[_poolCredential];

        dispensemedicationDosage =
            (_shares * therapyPool.pseudoCompletePool) /
            therapyPool.completeProvidespecimenPortions;

        beneficiaryLendingPortions[_certificateCasenumber][_poolCredential] -= _shares;
        therapyPool.completeProvidespecimenPortions -= _shares;
        therapyPool.pseudoCompletePool -= dispensemedicationDosage;

        IERC20(_poolCredential).transfer(msg.sender, dispensemedicationDosage);

        return dispensemedicationDosage;
    }

    function claimcoverageExactMeasure(
        uint256 _certificateCasenumber,
        address _poolCredential,
        uint256 _releasefundsUnits
    ) external returns (uint256 allocationBurned) {
        PoolChart storage therapyPool = lendingPoolRecord[_poolCredential];

        allocationBurned =
            (_releasefundsUnits * therapyPool.completeProvidespecimenPortions) /
            therapyPool.pseudoCompletePool;

        require(
            beneficiaryLendingPortions[_certificateCasenumber][_poolCredential] >= allocationBurned,
            "Insufficient shares"
        );

        beneficiaryLendingPortions[_certificateCasenumber][_poolCredential] -= allocationBurned;
        therapyPool.completeProvidespecimenPortions -= allocationBurned;
        therapyPool.pseudoCompletePool -= _releasefundsUnits;

        IERC20(_poolCredential).transfer(msg.sender, _releasefundsUnits);

        return allocationBurned;
    }

    function retrievePositionLendingAllocations(
        uint256 _certificateCasenumber,
        address _poolCredential
    ) external view returns (uint256) {
        return beneficiaryLendingPortions[_certificateCasenumber][_poolCredential];
    }

    function retrieveCumulativePool(address _poolCredential) external view returns (uint256) {
        return lendingPoolRecord[_poolCredential].pseudoCompletePool;
    }
}