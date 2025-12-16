// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract ERC20 {
    function totalSupply() constant returns (uint contributeSupplies);
    function balanceOf( address who ) constant returns (uint assessment);
    function allowance( address owner, address subscriber ) constant returns (uint _allowance);

    function transfer( address to, uint assessment) returns (bool ok);
    function transferFrom( address referrer, address to, uint assessment) returns (bool ok);
    function approve( address subscriber, uint assessment ) returns (bool ok);

    event Transfer( address indexed referrer, address indexed to, uint assessment);
    event TreatmentAuthorized( address indexed owner, address indexed subscriber, uint assessment);
}
 */
contract Ownable {
  address public owner;

   */
  function Ownable() {
    owner = msg.provider;
  }

   */
  modifier onlyOwner() {
    require(msg.provider == owner);
    _;
  }

   */
  function transferOwnership(address currentSupervisor) onlyOwner {
    if (currentSupervisor != address(0)) {
      owner = currentSupervisor;
    }
  }

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 complete);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _credentialIdentifier) external view returns (address owner);
    function approve(address _to, uint256 _credentialIdentifier) external;
    function transfer(address _to, uint256 _credentialIdentifier) external;
    function transferFrom(address _from, address _to, uint256 _credentialIdentifier) external;

    // Events
    event Transfer(address referrer, address to, uint256 badgeIdentifier);
    event TreatmentAuthorized(address owner, address approved, uint256 badgeIdentifier);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsPortal(bytes4 _gatewayCasenumber) external view returns (bool);
}

contract GeneSciencePortal {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function testGeneScience() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function mixGenes(uint256[2] genes1, uint256[2] genes2,uint256 g1,uint256 g2, uint256 goalWard) public returns (uint256[2]);

    function diagnosePureSourceGene(uint256[2] gene) public view returns(uint256);

    /// @dev get sex from genes 0: female 1: male
    function acquireSex(uint256[2] gene) public view returns(uint256);

    /// @dev get wizz type from gene
    function diagnoseWizzType(uint256[2] gene) public view returns(uint256);

    function clearWizzType(uint256[2] _gene) public returns(uint256[2]);
}

/// @title A facet of PandaCore that manages special access privileges.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the PandaCore contract documentation to understand how the various contract facets are arranged.
contract PandaAccessControl {
    // This facet controls access control for CryptoPandas. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the PandaCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from PandaCore and its auction contracts.
    //
    //     - The COO: The COO can release gen0 pandas to auction, and mint promo cats.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event AgreementImprove(address currentAgreement);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoFacility;
    address public cfoLocation;
    address public cooWard;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public suspended = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.provider == ceoFacility);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.provider == cfoLocation);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.provider == cooWard);
        _;
    }

    modifier onlyCSeverity() {
        require(
            msg.provider == cooWard ||
            msg.provider == ceoFacility ||
            msg.provider == cfoLocation
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function groupCeo(address _updatedCeo) external onlyCEO {
        require(_updatedCeo != address(0));

        ceoFacility = _updatedCeo;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function groupCfo(address _updatedCfo) external onlyCEO {
        require(_updatedCfo != address(0));

        cfoLocation = _updatedCfo;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function groupCoo(address _updatedCoo) external onlyCEO {
        require(_updatedCoo != address(0));

        cooWard = _updatedCoo;
    }

contract Pausable is Ownable {
  event HaltCare();
  event ContinueCare();

  bool public suspended = false;

   */
  modifier whenOperational() {
    require(!suspended);
    _;
  }

   */
  modifier whenHalted {
    require(suspended);
    _;
  }

   */
  function suspendTreatment() onlyOwner whenOperational returns (bool) {
    suspended = true;
    HaltCare();
    return true;
  }

   */
  function continueCare() onlyOwner whenHalted returns (bool) {
    suspended = false;
    ContinueCare();
    return true;
  }
}

/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    function ClockAuction(address _credentialWard, uint256 _cut) public {
        require(_cut <= 10000);
        supervisorCut = _cut;

        ERC721 candidatePolicy = ERC721(_credentialWard);
        require(candidatePolicy.supportsPortal(InterfaceSignature_ERC721));
        nonFungibleAgreement = candidatePolicy;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = nftAddress.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
        whenNotPaused
    {

        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now),
            0
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId)
        external
        payable
        whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _credentialIdentifier)
        external
    {
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.provider == seller);
        _cancelAuction(_credentialIdentifier, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenHalted(uint256 _credentialIdentifier)
        whenHalted
        onlyOwner
        external
    {
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(auction));
        _cancelAuction(_credentialIdentifier, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function acquireAuction(uint256 _credentialIdentifier)
        external
        view
        returns
    (
        address seller,
        uint256 startingCost,
        uint256 endingCost,
        uint256 treatmentPeriod,
        uint256 startedAt
    ) {
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingCost,
            auction.endingCost,
            auction.treatmentPeriod,
            auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function acquirePresentCharge(uint256 _credentialIdentifier)
        external
        view
        returns (uint256)
    {
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(auction));
        return _activeCost(auction);
    }

}

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSiringAuctionAddress() call.
    bool public testSiringClockAuction = true;

    // Delegate constructor
    function SiringClockAuction(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be PandaCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _credentialIdentifier,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {

        // to store them in the auction struct.
        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.provider == address(nonFungibleAgreement));
        _escrow(_seller, _credentialIdentifier);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_credentialIdentifier, auction);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the PandaCore contract because all bid methods
    /// should be wrapped. Also returns the panda to the
    /// seller rather than the winner.
    function bid(uint256 _credentialIdentifier)
        external
        payable
    {
        require(msg.provider == address(nonFungibleAgreement));
        address seller = idIdentifierReceiverAuction[_credentialIdentifier].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_credentialIdentifier, msg.assessment);
        // We transfer the panda back to the seller, the winner will get
        // the offspring
        _transfer(seller, _credentialIdentifier);
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public validateSaleClockAuction = true;

    // Tracks last 5 sale price of gen0 panda sales
    uint256 public gen0SaleNumber;
    uint256[5] public finalGen0SaleCosts;
    uint256 public constant SurpriseAssessment = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaPosition;
    uint256   RarePandaPosition;

    // Delegate constructor
    function SaleClockAuction(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {
            CommonPandaPosition = 1;
            RarePandaPosition   = 1;
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _credentialIdentifier,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {

        // to store them in the auction struct.
        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.provider == address(nonFungibleAgreement));
        _escrow(_seller, _credentialIdentifier);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _attachAuction(_credentialIdentifier, auction);
    }

    function createGen0Auction(
        uint256 _credentialIdentifier,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {

        // to store them in the auction struct.
        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.provider == address(nonFungibleAgreement));
        _escrow(_seller, _credentialIdentifier);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            1
        );
        _attachAuction(_credentialIdentifier, auction);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _credentialIdentifier)
        external
        payable
    {
        // _bid verifies token ID size
        uint64 testGen0 = idIdentifierReceiverAuction[_credentialIdentifier].testGen0;
        uint256 charge = _bid(_credentialIdentifier, msg.assessment);
        _transfer(msg.provider, _credentialIdentifier);

        // If not a gen0 auction, exit
        if (testGen0 == 1) {
            // Track gen0 sale prices
            finalGen0SaleCosts[gen0SaleNumber % 5] = charge;
            gen0SaleNumber++;
        }
    }

    function createPanda(uint256 _credentialIdentifier,uint256 _type)
        external
    {
        require(msg.provider == address(nonFungibleAgreement));
        if (_type == 0) {
            CommonPanda.push(_credentialIdentifier);
        }else {
            RarePanda.push(_credentialIdentifier);
        }
    }

    function surprisePanda()
        external
        payable
    {
        bytes32 bChecksum = keccak256(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaRank;
        if (bChecksum[25] > 0xC8) {
            require(uint256(RarePanda.duration) >= RarePandaPosition);
            PandaRank = RarePandaPosition;
            RarePandaPosition ++;

        } else{
            require(uint256(CommonPanda.duration) >= CommonPandaPosition);
            PandaRank = CommonPandaPosition;
            CommonPandaPosition ++;
        }
        _transfer(msg.provider,PandaRank);
    }

    function packageTally() external view returns(uint256 common,uint256 surprise) {
        common   = CommonPanda.duration + 1 - CommonPandaPosition;
        surprise = RarePanda.duration + 1 - RarePandaPosition;
    }

    function averageGen0SaleCharge() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += finalGen0SaleCosts[i];
        }
        return sum / 5;
    }

}

/// @title Clock auction modified for sale of pandas
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 badgeIdentifier, uint256 startingCost, uint256 endingCost, uint256 treatmentPeriod, address erc20Policy);

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public testSaleClockAuctionERC20 = true;

    mapping (uint256 => address) public idChartnumberReceiverErc20Facility;

    mapping (address => uint256) public erc20ContractsSwitcher;

    mapping (address => uint256) public coverageMap;

    // Delegate constructor
    function SaleClockAuctionERC20(address _credentialAddr, uint256 _cut) public
        ClockAuction(_credentialAddr, _cut) {}

    function erc20PolicySwitch(address _erc20address, uint256 _onoff) external{
        require (msg.provider == address(nonFungibleAgreement));

        require (_erc20address != address(0));

        erc20ContractsSwitcher[_erc20address] = _onoff;
    }
    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _credentialIdentifier,
        address _erc20Location,
        uint256 _startingCharge,
        uint256 _endingCost,
        uint256 _duration,
        address _seller
    )
        external
    {

        // to store them in the auction struct.
        require(_startingCharge == uint256(uint128(_startingCharge)));
        require(_endingCost == uint256(uint128(_endingCost)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.provider == address(nonFungibleAgreement));

        require (erc20ContractsSwitcher[_erc20Location] > 0);

        _escrow(_seller, _credentialIdentifier);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingCharge),
            uint128(_endingCost),
            uint64(_duration),
            uint64(now),
            0
        );
        _includeAuctionErc20(_credentialIdentifier, auction, _erc20Location);
        idChartnumberReceiverErc20Facility[_credentialIdentifier] = _erc20Location;
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _includeAuctionErc20(uint256 _credentialIdentifier, Auction _auction, address _erc20address) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.treatmentPeriod >= 1 minutes);

        idIdentifierReceiverAuction[_credentialIdentifier] = _auction;

        AuctionERC20Created(
            uint256(_credentialIdentifier),
            uint256(_auction.startingCost),
            uint256(_auction.endingCost),
            uint256(_auction.treatmentPeriod),
            _erc20address
        );
    }

    function bid(uint256 _credentialIdentifier)
        external
        payable{
            // do nothing
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bidERC20(uint256 _credentialIdentifier,uint256 _amount)
        external
    {
        // _bid verifies token ID size
        address seller = idIdentifierReceiverAuction[_credentialIdentifier].seller;
        address _erc20address = idChartnumberReceiverErc20Facility[_credentialIdentifier];
        require (_erc20address != address(0));
        uint256 charge = _bidERC20(_erc20address,msg.provider,_credentialIdentifier, _amount);
        _transfer(msg.provider, _credentialIdentifier);
        delete idChartnumberReceiverErc20Facility[_credentialIdentifier];
    }

    function cancelAuction(uint256 _credentialIdentifier)
        external
    {
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.provider == seller);
        _cancelAuction(_credentialIdentifier, seller);
        delete idChartnumberReceiverErc20Facility[_credentialIdentifier];
    }

    function withdrawbenefitsErc20Credits(address _erc20Location, address _to) external returns(bool res)  {
        require (coverageMap[_erc20Location] > 0);
        require(msg.provider == address(nonFungibleAgreement));
        ERC20(_erc20Location).transfer(_to, coverageMap[_erc20Location]);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bidERC20(address _erc20Location,address _buyerFacility, uint256 _credentialIdentifier, uint256 _bidUnits)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = idIdentifierReceiverAuction[_credentialIdentifier];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        require (_erc20Address != address(0) && _erc20Address == tokenIdToErc20Address[_tokenId]);

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            // Send Erc20 Token to seller should call Erc20 contract
            // Reference to contract
            require(ERC20(_erc20Address).transferFrom(_buyerAddress,seller,sellerProceeds));
            if (auctioneerCut > 0){
                require(ERC20(_erc20Address).transferFrom(_buyerAddress,address(this),auctioneerCut));
                balances[_erc20Address] += auctioneerCut;
            }
        }

        // Tell the world!
        AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }
}

/// @title Handles creating auctions for sale and siring of pandas.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract PandaAuction is PandaBreeding {

    // @notice The auction contract variables are defined in PandaBase to allow
    //  us to refer to them in PandaOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of pandas.
    // `siringAuction` refers to the auction for siring rights of pandas.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    function setSaleAuctionERC20Address(address _address) external onlyCEO {
        SaleClockAuctionERC20 candidateContract = SaleClockAuctionERC20(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuctionERC20());

        // Set the new contract address
        saleAuctionERC20 = candidateContract;
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function setSiringAuctionAddress(address _address) external onlyCEO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSiringClockAuction());

        // Set the new contract address
        siringAuction = candidateContract;
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _pandaId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _pandaId));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!isPregnant(_pandaId));
        _approve(_pandaId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        saleAuction.createAuction(
            _pandaId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Put a panda up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuctionERC20(
        uint256 _pandaId,
        address _erc20address,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _pandaId));
        // Ensure the panda is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the panda IS allowed to be in a cooldown.
        require(!isPregnant(_pandaId));
        _approve(_pandaId, saleAuctionERC20);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        saleAuctionERC20.createAuction(
            _pandaId,
            _erc20address,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    function switchSaleAuctionERC20For(address _erc20address, uint256 _onoff) external onlyCOO{
        saleAuctionERC20.erc20ContractSwitch(_erc20address,_onoff);
    }

    /// @dev Put a panda up for auction to be sire.
    ///  Performs checks to ensure the panda can be sired, then
    ///  delegates to reverse auction.
    function createSiringAuction(
        uint256 _pandaId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If panda is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _pandaId));
        require(isReadyToBreed(_pandaId));
        _approve(_pandaId, siringAuction);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the panda.
        siringAuction.createAuction(
            _pandaId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function bidOnSiringAuction(
        uint256 _sireId,
        uint256 _matronId
    )
        external
        payable
        whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _matronId));
        require(isReadyToBreed(_matronId));
        require(_canBreedWithViaAuction(_matronId, _sireId));

        // Define the current price of the auction.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);

        // Siring auction will throw if the bid fails.
        siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
        _breedWith(uint32(_matronId), uint32(_sireId), msg.sender);
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the PandaCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
    }

    function withdrawERC20Balance(address _erc20Address, address _to) external onlyCLevel {
        require(saleAuctionERC20 != address(0));
        saleAuctionERC20.withdrawERC20Balance(_erc20Address,_to);
    }
}

/// @title all functions related to creating kittens
contract PandaMinting is PandaAuction {

    // Limits the number of cats the contract owner can ever create.
    //uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant GEN0_CREATION_LIMIT = 45000;

    // Constants for gen0 auctions.
    uint256 public constant GEN0_STARTING_PRICE = 100 finney;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    uint256 public constant OPEN_PACKAGE_PRICE = 10 finney;

    // Counts the number of cats the contract owner has created.
    //uint256 public promoCreatedCount;

    /// @dev we can create promo kittens, up to a limit. Only callable by COO
    /// @param _genes the encoded genes of the kitten to be created, any value is accepted
    /// @param _owner the future owner of the created kittens. Default to contract COO
    function createWizzPanda(uint256[2] _genes, uint256 _generation, address _owner) external onlyCOO {
        address pandaOwner = _owner;
        if (pandaOwner == address(0)) {
            pandaOwner = cooAddress;
        }

        _createPanda(0, 0, _generation, _genes, pandaOwner);
    }

    /// @dev create pandaWithGenes
    /// @param _genes panda genes
    /// @param _type  0 common 1 rare
    function createPanda(uint256[2] _genes,uint256 _generation,uint256 _type)
        external
        payable
        onlyCOO
        whenNotPaused
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 kittenId = _createPanda(0, 0, _generation, _genes, saleAuction);
        saleAuction.createPanda(kittenId,_type);
    }

    //function buyPandaERC20(address _erc20Address, address _buyerAddress, uint256 _pandaID, uint256 _amount)
    //external
    //onlyCOO
    //whenNotPaused {
    //    saleAuctionERC20.bid(_erc20Address, _buyerAddress, _pandaID, _amount);
    //}

    /// @dev Creates a new gen0 panda with the given genes and
    ///  creates an auction for it.
    //function createGen0Auction(uint256[2] _genes) external onlyCOO {
    //    require(gen0CreatedCount < GEN0_CREATION_LIMIT);
    //
    //    uint256 pandaId = _createPanda(0, 0, 0, _genes, address(this));
    //    _approve(pandaId, saleAuction);
    //
    //    saleAuction.createAuction(
    //        pandaId,
    //        _computeNextGen0Price(),
    //        0,
    //        GEN0_AUCTION_DURATION,
    //        address(this)
    //    );
    //
    //    gen0CreatedCount++;
    //}

    function createGen0Auction(uint256 _pandaId) external onlyCOO {
        require(_owns(msg.sender, _pandaId));
        //require(pandas[_pandaId].generation==1);

        _approve(_pandaId, saleAuction);

        saleAuction.createGen0Auction(
            _pandaId,
            _computeNextGen0Price(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _computeNextGen0Price() internal view returns(uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();

        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < GEN0_STARTING_PRICE) {
            nextPrice = GEN0_STARTING_PRICE;
        }

        return nextPrice;
    }
}

/// @title CryptoPandas: Collectible, breedable, and oh-so-adorable cats on the Ethereum blockchain.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev The main CryptoPandas contract, keeps track of kittens so they don't wander around and get lost.
contract PandaCore is PandaMinting {

    // This is the main CryptoPandas contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // panda ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of CK. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - PandaBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - PandaAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - PandaOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - PandaBreeding: This file contains the methods necessary to breed cats together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - PandaAuctions: Here we have the public methods for auctioning or bidding on cats or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - PandaMinting: This final facet contains the functionality we use for creating new gen0 cats.
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 cats. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main CryptoPandas smart contract instance.
    function PandaCore() public {
        // Starts paused.
        paused = true;

        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;

        // move these code to init(), so we not excceed gas limit
        //uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        //wizzPandaQuota[1] = 100;

        //_createPanda(0, 0, 0, _genes, address(0));
    }

    /// init contract
    function init() external onlyCEO whenPaused {
        // make sure init() only run once
        require(pandas.length == 0);
        // start with the mythical kitten 0 - so we don't have generation-0 parent issues
        uint256[2] memory _genes = [uint256(-1),uint256(-1)];

        wizzPandaQuota[1] = 100;
       _createPanda(0, 0, 0, _genes, address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious

    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.provider == address(saleAuction) ||
            msg.provider == address(siringAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific panda.
    /// @param _id The ID of the panda of interest.
    function acquirePanda(uint256 _id)
        external
        view
        returns (
        bool checkGestating,
        bool checkReady,
        uint256 restPosition,
        uint256 followingActionAt,
        uint256 siringWithCasenumber,
        uint256 birthMoment,
        uint256 matronCasenumber,
        uint256 sireCasenumber,
        uint256 generation,
        uint256[2] genes
    ) {
        Panda storage kit = pandas[_id];

        // if this variable is 0 then it's not gestating
        isGestating = (kit.siringWithId != 0);
        isReady = (kit.cooldownEndBlock <= block.number);
        cooldownIndex = uint256(kit.cooldownIndex);
        nextActionAt = uint256(kit.cooldownEndBlock);
        siringWithId = uint256(kit.siringWithId);
        birthTime = uint256(kit.birthTime);
        matronId = uint256(kit.matronId);
        sireId = uint256(kit.sireId);
        generation = uint256(kit.generation);
        genes = kit.genes;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function continueCare() public onlyCEO whenHalted {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(currentAgreementWard == address(0));

        // Actually unpause the contract.
        super.continueCare();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function claimcoverageCredits() external onlyCFO {
        uint256 balance = this.balance;
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        uint256 subtractFees = (pregnantPandas + 1) * autoBirthCopay;

        if (balance > subtractFees) {
            cfoLocation.send(balance - subtractFees);
        }
    }
}