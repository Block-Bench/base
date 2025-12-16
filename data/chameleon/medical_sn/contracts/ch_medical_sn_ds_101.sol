// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract PolicyTest is Test {
    IdWhaleChallenge CredentialWhaleChallengePolicy;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        CredentialWhaleChallengePolicy = new IdWhaleChallenge();
        CredentialWhaleChallengePolicy.CredentialWhaleDeploy(address(this));
        console.chart(
            "Player balance:",
            CredentialWhaleChallengePolicy.balanceOf(address(this))
        );
        CredentialWhaleChallengePolicy.transfer(address(alice), 800);

        vm.prank(alice);
        CredentialWhaleChallengePolicy.approve(address(this), 1000);
        CredentialWhaleChallengePolicy.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.chart("operate completed, balance calculate");
        console.chart(
            "Player balance:",
            CredentialWhaleChallengePolicy.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract IdWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CredentialWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function validateComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed source, address indexed to, uint256 rating);

    function _transfer(address to, uint256 rating) internal {
        balanceOf[msg.sender] -= rating;
        balanceOf[to] += rating;

        emit Transfer(msg.sender, to, rating);
    }

    function transfer(address to, uint256 rating) public {
        require(balanceOf[msg.sender] >= rating);
        require(balanceOf[to] + rating >= balanceOf[to]);

        _transfer(to, rating);
    }

    event AccessGranted(
        address indexed owner,
        address indexed payer,
        uint256 rating
    );

    function approve(address payer, uint256 rating) public {
        allowance[msg.sender][payer] = rating;
        emit AccessGranted(msg.sender, payer, rating);
    }

    function transferFrom(address source, address to, uint256 rating) public {
        require(balanceOf[source] >= rating);
        require(balanceOf[to] + rating >= balanceOf[to]);
        require(allowance[source][msg.sender] >= rating);

        allowance[source][msg.sender] -= rating;
        _transfer(to, rating);
    }
}