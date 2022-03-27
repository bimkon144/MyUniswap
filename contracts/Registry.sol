//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import '../interface/RegistryInterface.sol';
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '../interface/EventsInterface.sol';

contract Registry is Ownable, RegistryInterface, EventsInterface {
    address public factory;
    using Address for address;
    
    mapping(address => mapping(address => address)) public getPair;

    address[] public allPairs;


    modifier onlyFactory() {
        require(factory == _msgSender(), "caller is not the Factory");
        _;
    }

    function setFactory(address _factory) external override onlyOwner {
        require(_factory != address(0), "Invalid address or its not contract");
        factory = _factory;
        emit Factory(_factory, address(this));
    }

    function setPair(
        address token0,
        address token1,
        address pairAddress
    ) external override onlyFactory {
        require(token0 != address(0) && token1 != address(0) && pairAddress != address(0), "Invalid address");
        require(token0.isContract() && token1.isContract(), "its not contracts");
        getPair[token0][token1] = pairAddress;
        getPair[token1][token0] = pairAddress; 
        allPairs.push(pairAddress);
        emit NewPair(token0, token1, pairAddress);
    }


    function getAddressOfPair(address token0, address token1) external view override returns (address)
    {
        return getPair[token0][token1];
    }
}