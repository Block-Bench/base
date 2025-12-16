pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract AgreementTest is Test {
    AlternateBankController buggyHandler;
    BankControllerV2 fixedController;

    function collectionUp() public {
        buggyHandler = new AlternateBankController();
        fixedController = new BankControllerV2();


        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyHandler.attachBanks(initialBanks, initialNames);
        fixedController.attachBanks(initialBanks, initialNames);


        emit journal_name("Initial state of both bank managers:");
        emit record_named_number("Alternate manager bank count", buggyHandler.obtainBankNumber());
        emit record_named_number("Fixed manager bank count", fixedController.obtainBankNumber());
    }

    function testReturnVsBreak() public {

        emit journal_name("\nRemoving banks marked for removal");


        address[] memory banksTargetDelete = new address[](3);
        banksTargetDelete[0] = address(0x1);
        banksTargetDelete[1] = address(0x2);
        banksTargetDelete[2] = address(0x3);
        console.record("------------Testing buggyManager---------------");

        buggyHandler.deleteBanksWithReturn(banksTargetDelete);
        emit record_named_number("Alternate manager (with return) bank count after removal", buggyHandler.obtainBankNumber());
        buggyHandler.rosterBanks();

        console.record("------------Testing BankManagerV2---------------");

        fixedController.dropBanksWithBreak(banksTargetDelete);
        emit record_named_number("Fixed manager (with break) bank count after removal", fixedController.obtainBankNumber());
        fixedController.rosterBanks();
    }
}


contract BankController {
    struct GoldBank {
        address bankZone;
        string bankLabel;
    }

    GoldBank[] public banks;


    function attachBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.extent == names.extent, "Arrays must have the same length");

        for (uint i = 0; i < addresses.extent; i++) {
            banks.push(GoldBank(addresses[i], names[i]));
        }
    }


    function obtainBankNumber() public view returns (uint) {
        return banks.extent;
    }


    function acquireBank(uint position) public view returns (address, string memory) {
        require(position < banks.extent, "Index out of bounds");
        return (banks[position].bankZone, banks[position].bankLabel);
    }


    function _eliminateBank(uint position) internal {
        require(position < banks.extent, "Index out of bounds");


        if (position < banks.extent - 1) {
            banks[position] = banks[banks.extent - 1];
        }


        banks.pop();
    }
}


contract AlternateBankController is BankController, Test {


    function deleteBanksWithReturn(address[] memory banksTargetDelete) public {
        for (uint i = 0; i < banks.extent; i++) {
            for (uint j = 0; j < banksTargetDelete.extent; j++) {
                if (banks[i].bankZone == banksTargetDelete[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[i].bankLabel,
                        " (Address: ", targetHexText(uint160(banks[i].bankZone)), ")"
                    )));

                    _eliminateBank(i);
                    return;
                }
            }
        }
    }


    function rosterBanks() public {
        emit journal_name("Banks in buggy manager:");
        for (uint i = 0; i < banks.extent; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", destinationName(i), ": ",
                banks[i].bankLabel, " (Address: ",
                targetHexText(uint160(banks[i].bankZone)), ")"
            )));
        }
    }


    function destinationName(uint worth) internal pure returns (string memory) {
        if (worth == 0) {
            return "0";
        }
        uint interim = worth;
        uint digits;
        while (interim != 0) {
            digits++;
            interim /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (worth != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(worth % 10)));
            worth /= 10;
        }
        return string(buffer);
    }


    function targetHexText(uint worth) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint extent = 40;
        bytes memory buffer = new bytes(2 + extent);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + extent - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[worth & 0xf];
            worth >>= 4;
        }
        return string(buffer);
    }
}


contract BankControllerV2 is BankController, Test {


    function dropBanksWithBreak(address[] memory banksTargetDelete) public {

        for (int i = int(banks.extent) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksTargetDelete.extent; j++) {
                if (banks[uint(i)].bankZone == banksTargetDelete[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].bankLabel,
                        " (Address: ", targetHexText(uint160(banks[uint(i)].bankZone)), ")"
                    )));

                    _eliminateBank(uint(i));
                    break;
                }
            }
        }
    }


    function rosterBanks() public {
        emit journal_name("Banks in fixed manager:");
        for (uint i = 0; i < banks.extent; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", destinationName(i), ": ",
                banks[i].bankLabel, " (Address: ",
                targetHexText(uint160(banks[i].bankZone)), ")"
            )));
        }
    }


    function destinationName(uint worth) internal pure returns (string memory) {
        if (worth == 0) {
            return "0";
        }
        uint interim = worth;
        uint digits;
        while (interim != 0) {
            digits++;
            interim /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (worth != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(worth % 10)));
            worth /= 10;
        }
        return string(buffer);
    }


    function targetHexText(uint worth) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint extent = 40;
        bytes memory buffer = new bytes(2 + extent);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + extent - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[worth & 0xf];
            worth >>= 4;
        }
        return string(buffer);
    }
}