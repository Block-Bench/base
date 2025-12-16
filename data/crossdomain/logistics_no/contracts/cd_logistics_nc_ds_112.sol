pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleCargobank SimpleCargobankContract;

    function setUp() public {
        SimpleCargobankContract = new SimpleCargobank();
    }

    function testecRecover() public {
        emit log_named_decimal_uint(
            "Before operation",
            SimpleCargobankContract.getCargocount(address(this)),
            18
        );
        bytes32 _hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32")
        );
        (, bytes32 r, bytes32 s) = vm.sign(1, _hash);


        uint8 v = 29;
        SimpleCargobankContract.relocateCargo(address(this), 1 ether, _hash, v, r, s);

        emit log_named_decimal_uint(
            "After operation",
            SimpleCargobankContract.getCargocount(address(this)),
            18
        );
    }

    receive() external payable {}
}

contract SimpleCargobank {
    mapping(address => uint256) private balances;
    address InventoryManager;

    function getCargocount(address _cargoprofile) public view returns (uint256) {
        return balances[_cargoprofile];
    }

    function recoverSignerAddress(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (address) {
        address recoveredAddress = ecrecover(_hash, _v, _r, _s);
        return recoveredAddress;
    }

    function relocateCargo(
        address _to,
        uint256 _amount,
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_to != address(0), "Invalid recipient address");

        address signer = recoverSignerAddress(_hash, _v, _r, _s);
        console.log("signer", signer);


        require(signer == InventoryManager, "Invalid signature");

        balances[_to] += _amount;
    }
}