pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract PactTest is Test {
    AlternateBankController buggyHandler;
    BankHandlerV2 fixedController;

    function collectionUp() public {
        buggyHandler = new AlternateBankController();
        fixedController = new BankHandlerV2();


        address[] memory initialBanks = new address[](3);
        string[] memory initialNames = new string[](3);

        initialBanks[0] = address(0x1);
        initialNames[0] = "ABC Bank";

        initialBanks[1] = address(0x2);
        initialNames[1] = "XYZ Bank";

        initialBanks[2] = address(0x3);
        initialNames[2] = "Global Bank";

        buggyHandler.includeBanks(initialBanks, initialNames);
        fixedController.includeBanks(initialBanks, initialNames);


        emit journal_name("Initial state of both bank managers:");
        emit journal_named_number("Alternate manager bank count", buggyHandler.obtainBankTally());
        emit journal_named_number("Fixed manager bank count", fixedController.obtainBankTally());
    }

    function testReturnVsBreak() public {

        emit journal_name("\nRemoving banks marked for removal");


        address[] memory banksDestinationDelete = new address[](3);
        banksDestinationDelete[0] = address(0x1);
        banksDestinationDelete[1] = address(0x2);
        banksDestinationDelete[2] = address(0x3);
        console.record("------------Testing buggyManager---------------");

        buggyHandler.eliminateBanksWithReturn(banksDestinationDelete);
        emit journal_named_number("Alternate manager (with return) bank count after removal", buggyHandler.obtainBankTally());
        buggyHandler.rosterBanks();

        console.record("------------Testing BankManagerV2---------------");

        fixedController.deleteBanksWithBreak(banksDestinationDelete);
        emit journal_named_number("Fixed manager (with break) bank count after removal", fixedController.obtainBankTally());
        fixedController.rosterBanks();
    }
}


contract BankHandler {
    struct FortuneVault {
        address bankRealm;
        string bankLabel;
    }

    FortuneVault[] public banks;


    function includeBanks(address[] memory addresses, string[] memory names) public {
        require(addresses.size == names.size, "Arrays must have the same length");

        for (uint i = 0; i < addresses.size; i++) {
            banks.push(FortuneVault(addresses[i], names[i]));
        }
    }


    function obtainBankTally() public view returns (uint) {
        return banks.size;
    }


    function fetchBank(uint position) public view returns (address, string memory) {
        require(position < banks.size, "Index out of bounds");
        return (banks[position].bankRealm, banks[position].bankLabel);
    }


    function _dropBank(uint position) internal {
        require(position < banks.size, "Index out of bounds");


        if (position < banks.size - 1) {
            banks[position] = banks[banks.size - 1];
        }


        banks.pop();
    }
}


contract AlternateBankController is BankHandler, Test {


    function eliminateBanksWithReturn(address[] memory banksDestinationDelete) public {
        for (uint i = 0; i < banks.size; i++) {
            for (uint j = 0; j < banksDestinationDelete.size; j++) {
                if (banks[i].bankRealm == banksDestinationDelete[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[i].bankLabel,
                        " (Address: ", targetHexText(uint160(banks[i].bankRealm)), ")"
                    )));

                    _dropBank(i);
                    return;
                }
            }
        }
    }


    function rosterBanks() public {
        emit journal_name("Banks in buggy manager:");
        for (uint i = 0; i < banks.size; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", targetText(i), ": ",
                banks[i].bankLabel, " (Address: ",
                targetHexText(uint160(banks[i].bankRealm)), ")"
            )));
        }
    }


    function targetText(uint cost) internal pure returns (string memory) {
        if (cost == 0) {
            return "0";
        }
        uint interim = cost;
        uint digits;
        while (interim != 0) {
            digits++;
            interim /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (cost != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(cost % 10)));
            cost /= 10;
        }
        return string(buffer);
    }


    function targetHexText(uint cost) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint size = 40;
        bytes memory buffer = new bytes(2 + size);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + size - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[cost & 0xf];
            cost >>= 4;
        }
        return string(buffer);
    }
}


contract BankHandlerV2 is BankHandler, Test {


    function deleteBanksWithBreak(address[] memory banksDestinationDelete) public {

        for (int i = int(banks.size) - 1; i >= 0; i--) {
            for (uint j = 0; j < banksDestinationDelete.size; j++) {
                if (banks[uint(i)].bankRealm == banksDestinationDelete[j]) {
                    emit journal_name(string(abi.encodePacked(
                        "Removing bank: ", banks[uint(i)].bankLabel,
                        " (Address: ", targetHexText(uint160(banks[uint(i)].bankRealm)), ")"
                    )));

                    _dropBank(uint(i));
                    break;
                }
            }
        }
    }


    function rosterBanks() public {
        emit journal_name("Banks in fixed manager:");
        for (uint i = 0; i < banks.size; i++) {
            emit journal_name(string(abi.encodePacked(
                "Bank ", targetText(i), ": ",
                banks[i].bankLabel, " (Address: ",
                targetHexText(uint160(banks[i].bankRealm)), ")"
            )));
        }
    }


    function targetText(uint cost) internal pure returns (string memory) {
        if (cost == 0) {
            return "0";
        }
        uint interim = cost;
        uint digits;
        while (interim != 0) {
            digits++;
            interim /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (cost != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint(cost % 10)));
            cost /= 10;
        }
        return string(buffer);
    }


    function targetHexText(uint cost) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        uint size = 40;
        bytes memory buffer = new bytes(2 + size);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint i = 2 + size - 1; i >= 2; i--) {
            buffer[i] = hexSymbols[cost & 0xf];
            cost >>= 4;
        }
        return string(buffer);
    }
}