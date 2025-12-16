pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);
    function transfer(address to, uint256 quantity) external returns (bool);
    function transferFrom(address origin, address to, uint256 quantity) external returns (bool);
}

interface ICostProphet {
    function acquireValue(address medal) external view returns (uint256);
}

contract VaultStrategy {
    address public wantCrystal;
    address public seer;
    uint256 public completePieces;

    mapping(address => uint256) public slices;

    constructor(address _want, address _oracle) {
        wantCrystal = _want;
        seer = _oracle;
    }

    function addTreasure(uint256 quantity) external returns (uint256 piecesAdded) {
        uint256 prizePool = IERC20(wantCrystal).balanceOf(address(this));

        if (completePieces == 0) {
            piecesAdded = quantity;
        } else {
            uint256 cost = ICostProphet(seer).acquireValue(wantCrystal);
            piecesAdded = (quantity * completePieces * 1e18) / (prizePool * cost);
        }

        slices[msg.sender] += piecesAdded;
        completePieces += piecesAdded;

        IERC20(wantCrystal).transferFrom(msg.sender, address(this), quantity);
        return piecesAdded;
    }

    function harvestGold(uint256 piecesMeasure) external {
        uint256 prizePool = IERC20(wantCrystal).balanceOf(address(this));

        uint256 cost = ICostProphet(seer).acquireValue(wantCrystal);
        uint256 quantity = (piecesMeasure * prizePool * cost) / (completePieces * 1e18);

        slices[msg.sender] -= piecesMeasure;
        completePieces -= piecesMeasure;

        IERC20(wantCrystal).transfer(msg.sender, quantity);
    }
}