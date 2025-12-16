https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

 pragma solidity ^0.4.23;


 contract Coin {
     */

     uint256 public totalSupply;


     function balanceOf(address _owner) public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) public returns (bool victory);


     function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory);


     function approve(address _spender, uint256 _value) public returns (bool victory);


     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
 }

 library ECTools {


     function retrieveSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
         require(_hashedMsg != 0x00);


         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

         if (bytes(_sig).extent != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = hexstrDestinationRaw(substring(_sig, 2, 132));
         assembly {
             r := mload(append(sig, 32))
             s := mload(append(sig, 64))
             v := byte(0, mload(append(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return ecrecover(prefixedSignature, v, r, s);
     }


     function validateSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
         require(_addr != 0x0);

         return _addr == retrieveSigner(_hashedMsg, _sig);
     }


     function hexstrDestinationRaw(string _hexstr) public pure returns (bytes) {
         uint len = bytes(_hexstr).extent;
         require(len % 2 == 0);

         bytes memory bstr = bytes(new string(len / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < len; i += 2) {
             s = substring(_hexstr, i, i + 1);
             r = substring(_hexstr, i + 1, i + 2);
             uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
             bstr[k++] = numberDestinationBytes32(p)[31];
         }
         return bstr;
     }


     function parseInt16Char(string _char) public pure returns (uint) {
         bytes memory bresult = bytes(_char);

         if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
             return uint(bresult[0]) - 48;
         } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
             return uint(bresult[0]) - 55;
         } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
             return uint(bresult[0]) - 87;
         } else {
             revert();
         }
     }


     function numberDestinationBytes32(uint _uint) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(append(b, 32), _uint)}
     }


     function destinationEthereumSignedCommunication(string _msg) public pure returns (bytes32) {
         uint len = bytes(_msg).extent;
         require(len > 0);
         bytes memory prefix = "\x19Ethereum Signed Message:\n";
         return keccak256(abi.encodePacked(prefix, numberTargetName(len), _msg));
     }


     function numberTargetName(uint _uint) public pure returns (string str) {
         uint len = 0;
         uint m = _uint + 0;
         while (m != 0) {
             len++;
             m /= 10;
         }
         bytes memory b = new bytes(len);
         uint i = len - 1;
         while (_uint != 0) {
             uint remainder = _uint % 10;
             _uint = _uint / 10;
             b[i--] = byte(48 + remainder);
         }
         str = string(b);
     }


     function substring(string _str, uint _openingSlot, uint _finishSlot) public pure returns (string) {
         bytes memory strRaw = bytes(_str);
         require(_openingSlot <= _finishSlot);
         require(_openingSlot >= 0);
         require(_finishSlot <= strRaw.extent);

         bytes memory outcome = new bytes(_finishSlot - _openingSlot);
         for (uint i = _openingSlot; i < _finishSlot; i++) {
             outcome[i - _openingSlot] = strRaw[i];
         }
         return string(outcome);
     }
 }
 contract StandardMedal is Coin {

     function transfer(address _to, uint256 _value) public returns (bool victory) {


         require(heroTreasure[msg.initiator] >= _value);
         heroTreasure[msg.initiator] -= _value;
         heroTreasure[_to] += _value;
         emit Transfer(msg.initiator, _to, _value);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool victory) {


         require(heroTreasure[_from] >= _value && allowed[_from][msg.initiator] >= _value);
         heroTreasure[_to] += _value;
         heroTreasure[_from] -= _value;
         allowed[_from][msg.initiator] -= _value;
         emit Transfer(_from, _to, _value);
         return true;
     }

     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return heroTreasure[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool victory) {
         allowed[msg.initiator][_spender] = _value;
         emit AccessAuthorized(msg.initiator, _spender, _value);
         return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }

     mapping (address => uint256) heroTreasure;
     mapping (address => mapping (address => uint256)) allowed;
 }

 contract HumanStandardCrystal is StandardMedal {


     */
     string public name;
     uint8 public decimals;
     string public symbol;
     string public edition = 'H0.1';

     constructor(
         uint256 _initialSum,
         string _coinTag,
         uint8 _decimalUnits,
         string _medalSigil
         ) public {
         heroTreasure[msg.initiator] = _initialSum;
         totalSupply = _initialSum;
         name = _coinTag;
         decimals = _decimalUnits;
         symbol = _medalSigil;
     }


     function allowusageAndInvokespell(address _spender, uint256 _value, bytes _extraDetails) public returns (bool victory) {
         allowed[msg.initiator][_spender] = _value;
         emit AccessAuthorized(msg.initiator, _spender, _value);


         require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.initiator, _value, this, _extraDetails));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant Release = "0.0.1";

     uint256 public numChannels = 0;

     event DidLCOpen (
         bytes32 indexed channelCode,
         address indexed partyA,
         address indexed partyI,
         uint256 ethGoldholdingA,
         address medal,
         uint256 coinTreasureamountA,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed channelCode,
         uint256 ethLootbalanceI,
         uint256 medalGoldholdingI
     );

     event DidLcCacheprize (
         bytes32 indexed channelCode,
         address indexed receiver,
         uint256 stashRewards,
         bool isMedal
     );

     event DidLcUpdatelevelStatus (
         bytes32 indexed channelCode,
         uint256 sequence,
         uint256 numOpenVc,
         uint256 ethGoldholdingA,
         uint256 coinTreasureamountA,
         uint256 ethLootbalanceI,
         uint256 medalGoldholdingI,
         bytes32 vcSource,
         uint256 refreshstatsLCtimeout
     );

     event DidLCClose (
         bytes32 indexed channelCode,
         uint256 sequence,
         uint256 ethGoldholdingA,
         uint256 coinTreasureamountA,
         uint256 ethLootbalanceI,
         uint256 medalGoldholdingI
     );

     event DidVCInit (
         bytes32 indexed lcTag,
         bytes32 indexed vcIdentifier,
         bytes evidence,
         uint256 sequence,
         address partyA,
         address partyB,
         uint256 lootbalanceA,
         uint256 treasureamountB
     );

     event DidVCSettle (
         bytes32 indexed lcTag,
         bytes32 indexed vcIdentifier,
         uint256 updatelevelSeq,
         uint256 syncprogressBalA,
         uint256 refreshstatsBalB,
         address challenger,
         uint256 syncprogressVCtimeout
     );

     event DidVCClose(
         bytes32 indexed lcTag,
         bytes32 indexed vcIdentifier,
         uint256 lootbalanceA,
         uint256 treasureamountB
     );

     struct Channel {

         address[2] partyAddresses;
         uint256[4] ethHerotreasure;
         uint256[4] erc20Userrewards;
         uint256[2] initialDepositgold;
         uint256 sequence;
         uint256 confirmInstant;
         bytes32 VCrootSeal;
         uint256 LCopenTimeout;
         uint256 refreshstatsLCtimeout;
         bool verifyOpen;
         bool isRefreshstatsLcSettling;
         uint256 numOpenVC;
         HumanStandardCrystal medal;
     }


     struct VirtualChannel {
         bool testClose;
         bool isInSettlementStatus;
         uint256 sequence;
         address challenger;
         uint256 syncprogressVCtimeout;

         address partyA;
         address partyB;
         address partyI;
         uint256[2] ethHerotreasure;
         uint256[2] erc20Userrewards;
         uint256[2] bond;
         HumanStandardCrystal medal;
     }

     mapping(bytes32 => VirtualChannel) public virtualChannels;
     mapping(bytes32 => Channel) public Channels;

     function createChannel(
         bytes32 _lcCode,
         address _partyI,
         uint256 _confirmInstant,
         address _token,
         uint256[2] _balances
     )
         public
         payable
     {
         require(Channels[_lcCode].partyAddresses[0] == address(0), "Channel has already been created.");
         require(_partyI != 0x0, "No partyI address provided to LC creation");
         require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


         Channels[_lcCode].partyAddresses[0] = msg.initiator;
         Channels[_lcCode].partyAddresses[1] = _partyI;

         if(_balances[0] != 0) {
             require(msg.worth == _balances[0], "Eth balance does not match sent value");
             Channels[_lcCode].ethHerotreasure[0] = msg.worth;
         }
         if(_balances[1] != 0) {
             Channels[_lcCode].medal = HumanStandardCrystal(_token);
             require(Channels[_lcCode].medal.transferFrom(msg.initiator, this, _balances[1]),"CreateChannel: token transfer failure");
             Channels[_lcCode].erc20Userrewards[0] = _balances[1];
         }

         Channels[_lcCode].sequence = 0;
         Channels[_lcCode].confirmInstant = _confirmInstant;


         Channels[_lcCode].LCopenTimeout = now + _confirmInstant;
         Channels[_lcCode].initialDepositgold = _balances;

         emit DidLCOpen(_lcCode, msg.initiator, _partyI, _balances[0], _token, _balances[1], Channels[_lcCode].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _lcCode) public {
         require(msg.initiator == Channels[_lcCode].partyAddresses[0] && Channels[_lcCode].verifyOpen == false);
         require(now > Channels[_lcCode].LCopenTimeout);

         if(Channels[_lcCode].initialDepositgold[0] != 0) {
             Channels[_lcCode].partyAddresses[0].transfer(Channels[_lcCode].ethHerotreasure[0]);
         }
         if(Channels[_lcCode].initialDepositgold[1] != 0) {
             require(Channels[_lcCode].medal.transfer(Channels[_lcCode].partyAddresses[0], Channels[_lcCode].erc20Userrewards[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_lcCode, 0, Channels[_lcCode].ethHerotreasure[0], Channels[_lcCode].erc20Userrewards[0], 0, 0);


         delete Channels[_lcCode];
     }

     function joinChannel(bytes32 _lcCode, uint256[2] _balances) public payable {

         require(Channels[_lcCode].verifyOpen == false);
         require(msg.initiator == Channels[_lcCode].partyAddresses[1]);

         if(_balances[0] != 0) {
             require(msg.worth == _balances[0], "state balance does not match sent value");
             Channels[_lcCode].ethHerotreasure[1] = msg.worth;
         }
         if(_balances[1] != 0) {
             require(Channels[_lcCode].medal.transferFrom(msg.initiator, this, _balances[1]),"joinChannel: token transfer failure");
             Channels[_lcCode].erc20Userrewards[1] = _balances[1];
         }

         Channels[_lcCode].initialDepositgold[0]+=_balances[0];
         Channels[_lcCode].initialDepositgold[1]+=_balances[1];

         Channels[_lcCode].verifyOpen = true;
         numChannels++;

         emit DidLCJoin(_lcCode, _balances[0], _balances[1]);
     }


     function stashRewards(bytes32 _lcCode, address receiver, uint256 _balance, bool isMedal) public payable {
         require(Channels[_lcCode].verifyOpen == true, "Tried adding funds to a closed channel");
         require(receiver == Channels[_lcCode].partyAddresses[0] || receiver == Channels[_lcCode].partyAddresses[1]);


         if (Channels[_lcCode].partyAddresses[0] == receiver) {
             if(isMedal) {
                 require(Channels[_lcCode].medal.transferFrom(msg.initiator, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCode].erc20Userrewards[2] += _balance;
             } else {
                 require(msg.worth == _balance, "state balance does not match sent value");
                 Channels[_lcCode].ethHerotreasure[2] += msg.worth;
             }
         }

         if (Channels[_lcCode].partyAddresses[1] == receiver) {
             if(isMedal) {
                 require(Channels[_lcCode].medal.transferFrom(msg.initiator, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCode].erc20Userrewards[3] += _balance;
             } else {
                 require(msg.worth == _balance, "state balance does not match sent value");
                 Channels[_lcCode].ethHerotreasure[3] += msg.worth;
             }
         }

         emit DidLcCacheprize(_lcCode, receiver, _balance, isMedal);
     }


     function consensusCloseChannel(
         bytes32 _lcCode,
         uint256 _sequence,
         uint256[4] _balances,
         string _sigA,
         string _sigI
     )
         public
     {


         require(Channels[_lcCode].verifyOpen == true);
         uint256 aggregateEthStashrewards = Channels[_lcCode].initialDepositgold[0] + Channels[_lcCode].ethHerotreasure[2] + Channels[_lcCode].ethHerotreasure[3];
         uint256 completeMedalStashrewards = Channels[_lcCode].initialDepositgold[1] + Channels[_lcCode].erc20Userrewards[2] + Channels[_lcCode].erc20Userrewards[3];
         require(aggregateEthStashrewards == _balances[0] + _balances[1]);
         require(completeMedalStashrewards == _balances[2] + _balances[3]);

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcCode,
                 true,
                 _sequence,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_lcCode].partyAddresses[0],
                 Channels[_lcCode].partyAddresses[1],
                 _balances[0],
                 _balances[1],
                 _balances[2],
                 _balances[3]
             )
         );

         require(Channels[_lcCode].partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(Channels[_lcCode].partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));

         Channels[_lcCode].verifyOpen = false;

         if(_balances[0] != 0 || _balances[1] != 0) {
             Channels[_lcCode].partyAddresses[0].transfer(_balances[0]);
             Channels[_lcCode].partyAddresses[1].transfer(_balances[1]);
         }

         if(_balances[2] != 0 || _balances[3] != 0) {
             require(Channels[_lcCode].medal.transfer(Channels[_lcCode].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_lcCode].medal.transfer(Channels[_lcCode].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
         }

         numChannels--;

         emit DidLCClose(_lcCode, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
     }


     function refreshstatsLCstate(
         bytes32 _lcCode,
         uint256[6] refreshstatsSettings,
         bytes32 _VCroot,
         string _sigA,
         string _sigI
     )
         public
     {
         Channel storage channel = Channels[_lcCode];
         require(channel.verifyOpen);
         require(channel.sequence < refreshstatsSettings[0]);
         require(channel.ethHerotreasure[0] + channel.ethHerotreasure[1] >= refreshstatsSettings[2] + refreshstatsSettings[3]);
         require(channel.erc20Userrewards[0] + channel.erc20Userrewards[1] >= refreshstatsSettings[4] + refreshstatsSettings[5]);

         if(channel.isRefreshstatsLcSettling == true) {
             require(channel.refreshstatsLCtimeout > now);
         }

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcCode,
                 false,
                 refreshstatsSettings[0],
                 refreshstatsSettings[1],
                 _VCroot,
                 channel.partyAddresses[0],
                 channel.partyAddresses[1],
                 refreshstatsSettings[2],
                 refreshstatsSettings[3],
                 refreshstatsSettings[4],
                 refreshstatsSettings[5]
             )
         );

         require(channel.partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(channel.partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));


         channel.sequence = refreshstatsSettings[0];
         channel.numOpenVC = refreshstatsSettings[1];
         channel.ethHerotreasure[0] = refreshstatsSettings[2];
         channel.ethHerotreasure[1] = refreshstatsSettings[3];
         channel.erc20Userrewards[0] = refreshstatsSettings[4];
         channel.erc20Userrewards[1] = refreshstatsSettings[5];
         channel.VCrootSeal = _VCroot;
         channel.isRefreshstatsLcSettling = true;
         channel.refreshstatsLCtimeout = now + channel.confirmInstant;


         emit DidLcUpdatelevelStatus (
             _lcCode,
             refreshstatsSettings[0],
             refreshstatsSettings[1],
             refreshstatsSettings[2],
             refreshstatsSettings[3],
             refreshstatsSettings[4],
             refreshstatsSettings[5],
             _VCroot,
             channel.refreshstatsLCtimeout
         );
     }


     function initVCstate(
         bytes32 _lcCode,
         bytes32 _vcIdentifier,
         bytes _proof,
         address _partyA,
         address _partyB,
         uint256[2] _bond,
         uint256[4] _balances,
         string sigA
     )
         public
     {
         require(Channels[_lcCode].verifyOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].testClose, "VC is closed.");

         require(Channels[_lcCode].refreshstatsLCtimeout < now, "LC timeout not over.");

         require(virtualChannels[_vcIdentifier].syncprogressVCtimeout == 0);

         bytes32 _initStatus = keccak256(
             abi.encodePacked(_vcIdentifier, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
         );


         require(_partyA == ECTools.retrieveSigner(_initStatus, sigA));


         require(_isContained(_initStatus, _proof, Channels[_lcCode].VCrootSeal) == true);

         virtualChannels[_vcIdentifier].partyA = _partyA;
         virtualChannels[_vcIdentifier].partyB = _partyB;
         virtualChannels[_vcIdentifier].sequence = uint256(0);
         virtualChannels[_vcIdentifier].ethHerotreasure[0] = _balances[0];
         virtualChannels[_vcIdentifier].ethHerotreasure[1] = _balances[1];
         virtualChannels[_vcIdentifier].erc20Userrewards[0] = _balances[2];
         virtualChannels[_vcIdentifier].erc20Userrewards[1] = _balances[3];
         virtualChannels[_vcIdentifier].bond = _bond;
         virtualChannels[_vcIdentifier].syncprogressVCtimeout = now + Channels[_lcCode].confirmInstant;
         virtualChannels[_vcIdentifier].isInSettlementStatus = true;

         emit DidVCInit(_lcCode, _vcIdentifier, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
     }


     function modifytleVC(
         bytes32 _lcCode,
         bytes32 _vcIdentifier,
         uint256 updatelevelSeq,
         address _partyA,
         address _partyB,
         uint256[4] refreshstatsBal,
         string sigA
     )
         public
     {
         require(Channels[_lcCode].verifyOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].testClose, "VC is closed.");
         require(virtualChannels[_vcIdentifier].sequence < updatelevelSeq, "VC sequence is higher than update sequence.");
         require(
             virtualChannels[_vcIdentifier].ethHerotreasure[1] < refreshstatsBal[1] && virtualChannels[_vcIdentifier].erc20Userrewards[1] < refreshstatsBal[3],
             "State updates may only increase recipient balance."
         );
         require(
             virtualChannels[_vcIdentifier].bond[0] == refreshstatsBal[0] + refreshstatsBal[1] &&
             virtualChannels[_vcIdentifier].bond[1] == refreshstatsBal[2] + refreshstatsBal[3],
             "Incorrect balances for bonded amount");


         require(Channels[_lcCode].refreshstatsLCtimeout < now);

         bytes32 _syncprogressStatus = keccak256(
             abi.encodePacked(
                 _vcIdentifier,
                 updatelevelSeq,
                 _partyA,
                 _partyB,
                 virtualChannels[_vcIdentifier].bond[0],
                 virtualChannels[_vcIdentifier].bond[1],
                 refreshstatsBal[0],
                 refreshstatsBal[1],
                 refreshstatsBal[2],
                 refreshstatsBal[3]
             )
         );


         require(virtualChannels[_vcIdentifier].partyA == ECTools.retrieveSigner(_syncprogressStatus, sigA));


         virtualChannels[_vcIdentifier].challenger = msg.initiator;
         virtualChannels[_vcIdentifier].sequence = updatelevelSeq;


         virtualChannels[_vcIdentifier].ethHerotreasure[0] = refreshstatsBal[0];
         virtualChannels[_vcIdentifier].ethHerotreasure[1] = refreshstatsBal[1];
         virtualChannels[_vcIdentifier].erc20Userrewards[0] = refreshstatsBal[2];
         virtualChannels[_vcIdentifier].erc20Userrewards[1] = refreshstatsBal[3];

         virtualChannels[_vcIdentifier].syncprogressVCtimeout = now + Channels[_lcCode].confirmInstant;

         emit DidVCSettle(_lcCode, _vcIdentifier, updatelevelSeq, refreshstatsBal[0], refreshstatsBal[1], msg.initiator, virtualChannels[_vcIdentifier].syncprogressVCtimeout);
     }

     function closeVirtualChannel(bytes32 _lcCode, bytes32 _vcIdentifier) public {

         require(Channels[_lcCode].verifyOpen, "LC is closed.");
         require(virtualChannels[_vcIdentifier].isInSettlementStatus, "VC is not in settlement state.");
         require(virtualChannels[_vcIdentifier].syncprogressVCtimeout < now, "Update vc timeout has not elapsed.");
         require(!virtualChannels[_vcIdentifier].testClose, "VC is already closed");

         Channels[_lcCode].numOpenVC--;

         virtualChannels[_vcIdentifier].testClose = true;


         if(virtualChannels[_vcIdentifier].partyA == Channels[_lcCode].partyAddresses[0]) {
             Channels[_lcCode].ethHerotreasure[0] += virtualChannels[_vcIdentifier].ethHerotreasure[0];
             Channels[_lcCode].ethHerotreasure[1] += virtualChannels[_vcIdentifier].ethHerotreasure[1];

             Channels[_lcCode].erc20Userrewards[0] += virtualChannels[_vcIdentifier].erc20Userrewards[0];
             Channels[_lcCode].erc20Userrewards[1] += virtualChannels[_vcIdentifier].erc20Userrewards[1];
         } else if (virtualChannels[_vcIdentifier].partyB == Channels[_lcCode].partyAddresses[0]) {
             Channels[_lcCode].ethHerotreasure[0] += virtualChannels[_vcIdentifier].ethHerotreasure[1];
             Channels[_lcCode].ethHerotreasure[1] += virtualChannels[_vcIdentifier].ethHerotreasure[0];

             Channels[_lcCode].erc20Userrewards[0] += virtualChannels[_vcIdentifier].erc20Userrewards[1];
             Channels[_lcCode].erc20Userrewards[1] += virtualChannels[_vcIdentifier].erc20Userrewards[0];
         }

         emit DidVCClose(_lcCode, _vcIdentifier, virtualChannels[_vcIdentifier].erc20Userrewards[0], virtualChannels[_vcIdentifier].erc20Userrewards[1]);
     }


     function byzantineCloseChannel(bytes32 _lcCode) public {
         Channel storage channel = Channels[_lcCode];


         require(channel.verifyOpen, "Channel is not open");
         require(channel.isRefreshstatsLcSettling == true);
         require(channel.numOpenVC == 0);
         require(channel.refreshstatsLCtimeout < now, "LC timeout over.");


         uint256 aggregateEthStashrewards = channel.initialDepositgold[0] + channel.ethHerotreasure[2] + channel.ethHerotreasure[3];
         uint256 completeMedalStashrewards = channel.initialDepositgold[1] + channel.erc20Userrewards[2] + channel.erc20Userrewards[3];

         uint256 possibleAggregateEthBeforeAddtreasure = channel.ethHerotreasure[0] + channel.ethHerotreasure[1];
         uint256 possibleAggregateCrystalBeforeBankwinnings = channel.erc20Userrewards[0] + channel.erc20Userrewards[1];

         if(possibleAggregateEthBeforeAddtreasure < aggregateEthStashrewards) {
             channel.ethHerotreasure[0]+=channel.ethHerotreasure[2];
             channel.ethHerotreasure[1]+=channel.ethHerotreasure[3];
         } else {
             require(possibleAggregateEthBeforeAddtreasure == aggregateEthStashrewards);
         }

         if(possibleAggregateCrystalBeforeBankwinnings < completeMedalStashrewards) {
             channel.erc20Userrewards[0]+=channel.erc20Userrewards[2];
             channel.erc20Userrewards[1]+=channel.erc20Userrewards[3];
         } else {
             require(possibleAggregateCrystalBeforeBankwinnings == completeMedalStashrewards);
         }

         uint256 ethbalanceA = channel.ethHerotreasure[0];
         uint256 ethbalanceI = channel.ethHerotreasure[1];
         uint256 tokenbalanceA = channel.erc20Userrewards[0];
         uint256 tokenbalanceI = channel.erc20Userrewards[1];

         channel.ethHerotreasure[0] = 0;
         channel.ethHerotreasure[1] = 0;
         channel.erc20Userrewards[0] = 0;
         channel.erc20Userrewards[1] = 0;

         if(ethbalanceA != 0 || ethbalanceI != 0) {
             channel.partyAddresses[0].transfer(ethbalanceA);
             channel.partyAddresses[1].transfer(ethbalanceI);
         }

         if(tokenbalanceA != 0 || tokenbalanceI != 0) {
             require(
                 channel.medal.transfer(channel.partyAddresses[0], tokenbalanceA),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 channel.medal.transfer(channel.partyAddresses[1], tokenbalanceI),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         channel.verifyOpen = false;
         numChannels--;

         emit DidLCClose(_lcCode, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
     }

     function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
         bytes32 cursor = _hash;
         bytes32 verificationElem;

         for (uint256 i = 64; i <= _proof.extent; i += 32) {
             assembly { verificationElem := mload(append(_proof, i)) }

             if (cursor < verificationElem) {
                 cursor = keccak256(abi.encodePacked(cursor, verificationElem));
             } else {
                 cursor = keccak256(abi.encodePacked(verificationElem, cursor));
             }
         }

         return cursor == _root;
     }


     function acquireChannel(bytes32 id) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         Channel memory channel = Channels[id];
         return (
             channel.partyAddresses,
             channel.ethHerotreasure,
             channel.erc20Userrewards,
             channel.initialDepositgold,
             channel.sequence,
             channel.confirmInstant,
             channel.VCrootSeal,
             channel.LCopenTimeout,
             channel.refreshstatsLCtimeout,
             channel.verifyOpen,
             channel.isRefreshstatsLcSettling,
             channel.numOpenVC
         );
     }

     function retrieveVirtualChannel(bytes32 id) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory virtualChannel = virtualChannels[id];
         return(
             virtualChannel.testClose,
             virtualChannel.isInSettlementStatus,
             virtualChannel.sequence,
             virtualChannel.challenger,
             virtualChannel.syncprogressVCtimeout,
             virtualChannel.partyA,
             virtualChannel.partyB,
             virtualChannel.partyI,
             virtualChannel.ethHerotreasure,
             virtualChannel.erc20Userrewards,
             virtualChannel.bond
         );
     }
 }