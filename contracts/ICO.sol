pragma solidity 0.4.24;



import "./SellableToken.sol";

import "./PrivateSale.sol";





contract ICO is SellableToken {



    PrivateSale public privateSale;
    uint256 public etherPriceInUSD;

    uint256 public minInvest;

    event Contribution(address indexed _form, uint256 value, uint256 amount);

    constructor(

        address _multivestAddress,

        address _autobay,

        address _etherHolder,

        uint256 _etherPriceInUSD, // if price 709.38000 the  value has to be 70938000

        uint256 _minInvest, //if price 250.28000 the  value has to be 25028000

        uint256 _maxTokenSupply

    ) SellableToken(

        _multivestAddress,

        _autobay,

        _etherHolder,

        _etherPriceInUSD,

        _maxTokenSupply

    ) public {

        minInvest = _minInvest;


        tiers.push(

            Tier(

                uint256(330000000).mul(uint256(10) ** DECIMALS),

                uint256(7300),

                1538380800,

                0

            )

        );//@ 0,0365 USD

        tiers.push(

            Tier(

                uint256(300000001).mul(uint256(10) ** DECIMALS.sub(1)),

                uint256(10000),

                0,

                1541059200

            )

        );//@ 0,05 USD



        startTime = 1538380800;

        endTime = 1544860800;

    }



    /* public methods */

    function setPrivateSale(address _privateSale) public onlyOwner {

        if (_privateSale != address(0)) {

            privateSale = PrivateSale(_privateSale);

        }

    }



    function changeMinInvest(uint256 _minInvest) public onlyOwner {

        minInvest = _minInvest;

    }



    function changePreICODates(uint256 _start, uint256 _end) public onlyOwner {

        if (_start != 0 && _start < _end) {

            Tier storage preICOTier = tiers[PRE_ICO_ID];

            preICOTier.startTime = _start;

            preICOTier.endTime = _end;

            startTime = _start;

        }

    }



    function changeICODates(uint256 _start, uint256 _end) public onlyOwner {

        if (_start != 0 && _start < _end) {

            Tier storage icoFirsTier = tiers[PRE_ICO_ID.add(1)];

            icoFirsTier.startTime = _start;

            Tier storage icoLastTier = tiers[tiers.length.sub(1)];

            icoLastTier.endTime = _end;

            endTime = _end;

        }

 
    }



    function calculateTokensAmount(uint256 _value) public constant returns (uint256) {
       

        if (_value == 0 || _value < (uint256(1 ether).mul(minInvest).div(etherPriceInUSD))) {

            return 0;

        }



        uint256 amount;

        if (isPreICOActive() || tiers[PRE_ICO_ID].startTime > now) {
    

            amount = _value.mul(etherPriceInUSD).div(tiers[i].price);

            return soldTokens.add(amount) <= tiers[PRE_ICO_ID].maxAmount ? amount : 0;

        }



        if (isICOFinished()) {

            return 0;

        }

        uint256 newSoldTokens = soldTokens;

        uint256 remainingValue = _value;



        for (uint i = PRE_ICO_ID.add(1); i < tiers.length; i++) {

            amount = remainingValue.mul(etherPriceInUSD).div(tiers[i].price);



            if (newSoldTokens.add(amount) > tiers[i].maxAmount) {

                uint256 diff = tiers[i].maxAmount.sub(newSoldTokens);

                remainingValue = remainingValue.sub(diff.mul(tiers[i].price).div(etherPriceInUSD));

                newSoldTokens = newSoldTokens.add(diff);

            } else {

                remainingValue = 0;

                newSoldTokens = newSoldTokens.add(amount);

            }



            if (remainingValue == 0) {

                break;

            }

        }



        if (remainingValue > 0) {

            return 0;

        }



        return newSoldTokens.sub(soldTokens);

    }



    function calculateEthersAmount(uint256 _amount) public constant returns (uint256) {

        if (_amount == 0) {

            return 0;

        }

        uint256 ethersAmount;

        if (isPreICOActive() || tiers[PRE_ICO_ID].startTime > now) {

            ethersAmount = _amount.mul(tiers[i].price).div(etherPriceInUSD);

            if (

                ethersAmount < (uint256(1 ether).mul(minInvest).div(etherPriceInUSD)) ||

                soldTokens.add(_amount) >= tiers[PRE_ICO_ID].maxAmount

            ) {

                return 0;

            }

            return ethersAmount;

        }



        if (isICOFinished()) {

            return 0;

        }

        uint256 remainingValue = _amount;



        for (uint i = PRE_ICO_ID.add(1); i < tiers.length; i++) {



            if (soldTokens.add(_amount) > tiers[i].maxAmount) {

                uint256 diff = tiers[i].maxAmount.sub(soldTokens);

                remainingValue = remainingValue.sub(diff);

                ethersAmount = ethersAmount.add(diff.mul(tiers[i].price).div(etherPriceInUSD));

            } else {

                ethersAmount = ethersAmount.add(remainingValue.mul(tiers[i].price).div(etherPriceInUSD));

                remainingValue = 0;

            }



            if (remainingValue == 0) {

                break;

            }

        }



        if (remainingValue > 0 || ethersAmount < (uint256(1 ether).mul(minInvest).div(etherPriceInUSD))) {

            return 0;

        }



        return ethersAmount;

    }



    function updateStateWithPrivateSale(uint256 _amount, address[] _investors) public {

        if (_amount > 0 && msg.sender == address(privateSale)) {

            Tier storage preICOTier = tiers[PRE_ICO_ID];

            preICOTier.maxAmount = preICOTier.maxAmount.add(_amount);

            maxTokenSupply = maxTokenSupply.add(_amount);



            if (_investors.length > 0) {

                for (uint256 i = 0; i < _investors.length; i++) {

                    investors.push(_investors[i]);

                }

            }

        }

    }



    function getMinEthersInvestment() public view returns (uint256) {

        return uint256(1 ether).mul(minInvest).div(etherPriceInUSD);

    }



    function getStats(uint256 _ethPerBtc) public view returns (

        uint256 start,

        uint256 end,

        uint256 sold,

        uint256 totalSoldTokens,

        uint256 maxSupply,

        uint256 tokensPerEth,

        uint256 tokensPerBtc,

        uint256[12] tiersData

    ) {

        start = tiers[PRE_ICO_ID].startTime;

        end = tiers[tiers.length.sub(1)].endTime;

        sold = soldTokens;

        totalSoldTokens = soldTokens;

        if (address(privateSale) != address(0)) {

            totalSoldTokens = totalSoldTokens.add(privateSale.soldTokens());

        }

        maxSupply = maxTokenSupply;

        tokensPerEth = calculateTokensAmount(1 ether);

        tokensPerBtc = calculateTokensAmount(_ethPerBtc);

        uint256 j = 0;

        for (uint256 i = 0; i < tiers.length; i++) {

            tiersData[j++] = uint256(tiers[i].maxAmount);

            tiersData[j++] = uint256(tiers[i].price);

            tiersData[j++] = uint256(tiers[i].startTime);

            tiersData[j++] = uint256(tiers[i].endTime);

        }

    }



    function buy(address _address, uint256 _value) internal returns (bool) {

        if (_value == 0) {

            return false;

        }

        require(_address != address(0) && (isPreICOActive() || !isICOFinished()));



        if (priceUpdateAt.add(1 hours) < block.timestamp) {

            update();

            priceUpdateAt = block.timestamp;

        }



        uint256 amount = calculateTokensAmount(_value);



        require(amount > 0 && amount == mintInternal(_address, amount));



        collectedEthers = collectedEthers.add(_value);

        emit Contribution(_address, _value, amount);



        transferEthers();

        return true;

    }



}