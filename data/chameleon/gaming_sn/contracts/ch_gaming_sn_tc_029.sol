// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);
    function transfer(address to, uint256 measure) external returns (bool);
    function transferFrom(address origin, address to, uint256 measure) external returns (bool);
}

interface ICostSeer {
    function fetchCost(address gem) external view returns (uint256);
}

contract VaultStrategy {
    address public wantCrystal;
    address public seer;
    uint256 public combinedPortions;

    mapping(address => uint256) public pieces;

    constructor(address _want, address _oracle) {
        wantCrystal = _want;
        seer = _oracle;
    }

    function storeLoot(uint256 measure) external returns (uint256 piecesAdded) {
        uint256 lootPool = IERC20(wantCrystal).balanceOf(address(this));

        if (combinedPortions == 0) {
            piecesAdded = measure;
        } else {
            uint256 cost = ICostSeer(seer).fetchCost(wantCrystal);
            piecesAdded = (measure * combinedPortions * 1e18) / (lootPool * cost);
        }

        pieces[msg.sender] += piecesAdded;
        combinedPortions += piecesAdded;

        IERC20(wantCrystal).transferFrom(msg.sender, address(this), measure);
        return piecesAdded;
    }

    function redeemTokens(uint256 piecesSum) external {
        uint256 lootPool = IERC20(wantCrystal).balanceOf(address(this));

        uint256 cost = ICostSeer(seer).fetchCost(wantCrystal);
        uint256 measure = (piecesSum * lootPool * cost) / (combinedPortions * 1e18);

        pieces[msg.sender] -= piecesSum;
        combinedPortions -= piecesSum;

        IERC20(wantCrystal).transfer(msg.sender, measure);
    }
}
