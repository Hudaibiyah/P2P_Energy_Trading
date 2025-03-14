pragma solidity >=0.4.22 <0.6.0;

import "./registerMeter.sol";

contract orderBook is registerMeter {

    struct SellOrder {
    address producer;
    uint32 price;
    uint64 energy;
    uint64 timestamp;
  }

  struct BuyOrder {
    address producer;
    uint32 price;
    uint64 energy;
    address meterAddress;
    uint64 timestamp;
  }

  //add address of the universal producer
  address public univeralProducer = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;

  SellOrder[] public sellOrders;
  BuyOrder[] public buyOrders;

  //stores the amount of energy supplied by the producer
  BuyOrder[] public producerEnergy;

  mapping(address => uint) public sellIndex;
  mapping(address => uint) public buyIndex;
  
  event sellEvent(address indexed producer, uint32 indexed price, uint64 energy);
  event buyEvent(address indexed producer, uint32 price, uint64 energy, address meterAddress);

  function sellEnergy(uint32 aprice, uint64 aenergy, uint64 atimestamp) onlyRegisteredMeters public {
    // require a minimum offer of 1 kWh
    require(aenergy >= 1);

    // record the sell order
    uint idx = sellIndex[msg.sender];

    sellOrders.push(SellOrder({
      producer: msg.sender,
      price: aprice,
      energy: aenergy,
      timestamp: atimestamp
      }));
    emit sellEvent(sellOrders[idx].producer, sellOrders[idx].price, sellOrders[idx].energy);
  }

  function buyEnergy(address aproducer, uint32 aprice, uint64 aenergy, address mAddress, uint64 atimestamp) onlyRegisteredMeters public {
    // find offer by producer (aproducer)
    uint idx = sellIndex[aproducer];

    require(0x0 != idx);

    // check if the offer exists...
    if ((sellOrders.length > idx) && (sellOrders[idx].producer == aproducer)) {
      // check if it matches the price
      require(sellOrders[idx].price == aprice);

      buyIndex[msg.sender] = buyOrders.length;
      // record the user's choice
      buyOrders.push(BuyOrder({
        producer: aproducer,
        price: aprice,
        energy: aenergy,
        meterAddress: mAddress,
        timestamp: atimestamp
        }));
      emit buyEvent(aproducer, aprice, aenergy, mAddress);

      //checks if the consumer bought from the producer and stores it
      require(buyOrders[idx].producer == univeralProducer);
      producerEnergy.push(BuyOrder({
        producer: aproducer,
        price: aprice,
        energy: aenergy,
        meterAddress: mAddress,
        timestamp: atimestamp
        }));

     } else {
      revert();
    }
  }
}