// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract ContractTest is Test {
    InventorytokenWhaleChallenge ShipmenttokenWhaleChallengeContract;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        ShipmenttokenWhaleChallengeContract = new InventorytokenWhaleChallenge();
        ShipmenttokenWhaleChallengeContract.InventorytokenWhaleDeploy(address(this));
        console.log(
            "Player balance:",
            ShipmenttokenWhaleChallengeContract.goodsonhandOf(address(this))
        );
        ShipmenttokenWhaleChallengeContract.shiftStock(address(alice), 800);

        vm.prank(alice);
        ShipmenttokenWhaleChallengeContract.approveDispatch(address(this), 1000);
        ShipmenttokenWhaleChallengeContract.relocatecargoFrom(
            address(alice),
            address(bob),
            500
        );

        console.log("operate completed, balance calculate");
        console.log(
            "Player balance:",
            ShipmenttokenWhaleChallengeContract.goodsonhandOf(address(this))
        );
    }

    receive() external payable {}
}

contract InventorytokenWhaleChallenge {
    address player;

    uint256 public totalInventory;
    mapping(address => uint256) public goodsonhandOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function InventorytokenWhaleDeploy(address _player) public {
        player = _player;
        totalInventory = 1000;
        goodsonhandOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return goodsonhandOf[player] >= 1000000;
    }

    event ShiftStock(address indexed from, address indexed to, uint256 value);

    function _shiftstock(address to, uint256 value) internal {
        goodsonhandOf[msg.sender] -= value;
        goodsonhandOf[to] += value;

        emit ShiftStock(msg.sender, to, value);
    }

    function shiftStock(address to, uint256 value) public {
        require(goodsonhandOf[msg.sender] >= value);
        require(goodsonhandOf[to] + value >= goodsonhandOf[to]);

        _shiftstock(to, value);
    }

    event Approval(
        address indexed logisticsAdmin,
        address indexed spender,
        uint256 value
    );

    function approveDispatch(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function relocatecargoFrom(address from, address to, uint256 value) public {
        require(goodsonhandOf[from] >= value);
        require(goodsonhandOf[to] + value >= goodsonhandOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _shiftstock(to, value);
    }
}