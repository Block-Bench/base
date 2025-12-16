pragma solidity 0.8.0;


import "forge-std/Test.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract ContractTest is Test  is ReentrancyGuard {
    Dirtybytes Dirtybytesontract;

    function testDirtybytes() public {
        Dirtybytesontract = new Dirtybytes();
        emit log_named_bytes(
            "Array element in h() not being zero::",
            Dirtybytesontract.h()
        );
        console.log(
            "Such that the byte after the 63 bytes allocated below will be 0x02."
        );
    }
}

contract Dirtybytes {
    event ev(uint[], uint);
    bytes s;

    constructor() {


        emit ev(new uint[](2), 0);
        bytes memory m = new bytes(63);
        s = m;
    }

    function h() external returns (bytes memory) {
        s.push();
        return s;
    }
}