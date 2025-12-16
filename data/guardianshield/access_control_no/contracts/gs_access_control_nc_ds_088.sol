pragma solidity ^0.8.15;

import "forge-std/Test.sol";

contract ContractTest is Test {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    HashCollision HashCollisionContract;

    function setUp() public onlyOwner {
        HashCollisionContract = new HashCollision();
    }

    function testHash_collisions() public {
        emit log_named_bytes32(
            "(AAA,BBB) Hash",
            HashCollisionContract.createHash("AAA", "BBB")
        );
        HashCollisionContract.deposit{value: 1 ether}("AAA", "BBB");

        emit log_named_bytes32(
            "(AA,ABBB) Hash",
            HashCollisionContract.createHash("AA", "ABBB")
        );
        vm.expectRevert("Hash collision detected");
        HashCollisionContract.deposit{value: 1 ether}("AA", "ABBB");
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}

contract HashCollision {
    mapping(bytes32 => uint256) public balances;

    function createHash(
        string memory _string1,
        string memory _string2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string1, _string2));
    }

    function deposit(
        string memory _string1,
        string memory _string2
    ) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");

        bytes32 hash = createHash(_string1, _string2);


        require(balances[hash] == 0, "Hash collision detected");

        balances[hash] = msg.value;
    }
}