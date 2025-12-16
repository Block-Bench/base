pragma solidity ^0.8.0;


interface ICurvePool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minimum_dy
    ) external returns (uint256);

    function retrieve_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract YieldVault {
    address public underlyingMedal;
    ICurvePool public curvePool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;


    uint256 public investedGoldholding;

    event DepositGold(address indexed adventurer, uint256 count, uint256 pieces);
    event TreasureWithdrawn(address indexed adventurer, uint256 pieces, uint256 count);

    constructor(address _token, address _curvePool) {
        underlyingMedal = _token;
        curvePool = ICurvePool(_curvePool);
    }


    function stashRewards(uint256 count) external returns (uint256 pieces) {
        require(count > 0, "Zero amount");


        if (totalSupply == 0) {
            pieces = count;
        } else {
            uint256 fullAssets = retrieveCombinedAssets();
            pieces = (count * totalSupply) / fullAssets;
        }

        balanceOf[msg.sender] += pieces;
        totalSupply += pieces;


        _investInCurve(count);

        emit DepositGold(msg.sender, count, pieces);
        return pieces;
    }


    function extractWinnings(uint256 pieces) external returns (uint256 count) {
        require(pieces > 0, "Zero shares");
        require(balanceOf[msg.sender] >= pieces, "Insufficient balance");


        uint256 fullAssets = retrieveCombinedAssets();
        count = (pieces * fullAssets) / totalSupply;

        balanceOf[msg.sender] -= pieces;
        totalSupply -= pieces;


        _collectbountyOriginCurve(count);

        emit TreasureWithdrawn(msg.sender, pieces, count);
        return count;
    }


    function retrieveCombinedAssets() public view returns (uint256) {
        uint256 vaultGoldholding = 0;
        uint256 curvePrizecount = investedGoldholding;

        return vaultGoldholding + curvePrizecount;
    }


    function fetchValuePerFullPiece() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (retrieveCombinedAssets() * 1e18) / totalSupply;
    }


    function _investInCurve(uint256 count) internal {
        investedGoldholding += count;
    }


    function _collectbountyOriginCurve(uint256 count) internal {
        require(investedGoldholding >= count, "Insufficient invested");
        investedGoldholding -= count;
    }
}