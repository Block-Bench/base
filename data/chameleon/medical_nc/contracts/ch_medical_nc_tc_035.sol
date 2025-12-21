pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IERC721 {
    function transferFrom(address referrer, address to, uint256 credentialId) external;

    function ownerOf(uint256 credentialId) external view returns (address);
}

contract WiseLending {
    struct PoolInfo {
        uint256 pseudoTotalamountPool;
        uint256 totalamountSubmitpaymentPortions;
        uint256 totalamountRequestadvanceAllocations;
        uint256 securitydepositFactor;
    }

    mapping(address => PoolInfo) public lendingPoolRecord;
    mapping(uint256 => mapping(address => uint256)) public patientLendingPortions;
    mapping(uint256 => mapping(address => uint256)) public patientRequestadvancePortions;

    IERC721 public positionNFTs;
    uint256 public certificateIdentifierTally;

    function issuecredentialPosition() external returns (uint256) {
        uint256 credentialIdentifier = ++certificateIdentifierTally;
        return credentialIdentifier;
    }

    function submitpaymentExactQuantity(
        uint256 _certificateChartnumber,
        address _poolCredential,
        uint256 _amount
    ) external returns (uint256 segmentQuantity) {
        IERC20(_poolCredential).transferFrom(msg.sender, address(this), _amount);

        PoolInfo storage donorPool = lendingPoolRecord[_poolCredential];

        if (donorPool.totalamountSubmitpaymentPortions == 0) {
            segmentQuantity = _amount;
            donorPool.totalamountSubmitpaymentPortions = _amount;
        } else {
            segmentQuantity =
                (_amount * donorPool.totalamountSubmitpaymentPortions) /
                donorPool.pseudoTotalamountPool;
            donorPool.totalamountSubmitpaymentPortions += segmentQuantity;
        }

        donorPool.pseudoTotalamountPool += _amount;
        patientLendingPortions[_certificateChartnumber][_poolCredential] += segmentQuantity;

        return segmentQuantity;
    }

    function dischargefundsExactAllocations(
        uint256 _certificateChartnumber,
        address _poolCredential,
        uint256 _shares
    ) external returns (uint256 dischargefundsQuantity) {
        require(
            patientLendingPortions[_certificateChartnumber][_poolCredential] >= _shares,
            "Insufficient shares"
        );

        PoolInfo storage donorPool = lendingPoolRecord[_poolCredential];

        dischargefundsQuantity =
            (_shares * donorPool.pseudoTotalamountPool) /
            donorPool.totalamountSubmitpaymentPortions;

        patientLendingPortions[_certificateChartnumber][_poolCredential] -= _shares;
        donorPool.totalamountSubmitpaymentPortions -= _shares;
        donorPool.pseudoTotalamountPool -= dischargefundsQuantity;

        IERC20(_poolCredential).transfer(msg.sender, dischargefundsQuantity);

        return dischargefundsQuantity;
    }

    function dischargefundsExactQuantity(
        uint256 _certificateChartnumber,
        address _poolCredential,
        uint256 _dischargefundsQuantity
    ) external returns (uint256 segmentBurned) {
        PoolInfo storage donorPool = lendingPoolRecord[_poolCredential];

        segmentBurned =
            (_dischargefundsQuantity * donorPool.totalamountSubmitpaymentPortions) /
            donorPool.pseudoTotalamountPool;

        require(
            patientLendingPortions[_certificateChartnumber][_poolCredential] >= segmentBurned,
            "Insufficient shares"
        );

        patientLendingPortions[_certificateChartnumber][_poolCredential] -= segmentBurned;
        donorPool.totalamountSubmitpaymentPortions -= segmentBurned;
        donorPool.pseudoTotalamountPool -= _dischargefundsQuantity;

        IERC20(_poolCredential).transfer(msg.sender, _dischargefundsQuantity);

        return segmentBurned;
    }

    function diagnosePositionLendingAllocations(
        uint256 _certificateChartnumber,
        address _poolCredential
    ) external view returns (uint256) {
        return patientLendingPortions[_certificateChartnumber][_poolCredential];
    }

    function acquireTotalamountPool(address _poolCredential) external view returns (uint256) {
        return lendingPoolRecord[_poolCredential].pseudoTotalamountPool;
    }
}