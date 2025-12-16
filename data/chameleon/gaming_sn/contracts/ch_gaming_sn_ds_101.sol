// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract PactTest is Test {
    CoinWhaleChallenge CrystalWhaleChallengeAgreement;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        CrystalWhaleChallengeAgreement = new CoinWhaleChallenge();
        CrystalWhaleChallengeAgreement.GemWhaleDeploy(address(this));
        console.record(
            "Player balance:",
            CrystalWhaleChallengeAgreement.balanceOf(address(this))
        );
        CrystalWhaleChallengeAgreement.transfer(address(alice), 800);

        vm.prank(alice);
        CrystalWhaleChallengeAgreement.approve(address(this), 1000);
        CrystalWhaleChallengeAgreement.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.record("operate completed, balance calculate");
        console.record(
            "Player balance:",
            CrystalWhaleChallengeAgreement.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract CoinWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function GemWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function testComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed source, address indexed to, uint256 worth);

    function _transfer(address to, uint256 worth) internal {
        balanceOf[msg.sender] -= worth;
        balanceOf[to] += worth;

        emit Transfer(msg.sender, to, worth);
    }

    function transfer(address to, uint256 worth) public {
        require(balanceOf[msg.sender] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);

        _transfer(to, worth);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed user,
        uint256 worth
    );

    function approve(address user, uint256 worth) public {
        allowance[msg.sender][user] = worth;
        emit PermissionGranted(msg.sender, user, worth);
    }

    function transferFrom(address source, address to, uint256 worth) public {
        require(balanceOf[source] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);
        require(allowance[source][msg.sender] >= worth);

        allowance[source][msg.sender] -= worth;
        _transfer(to, worth);
    }
}