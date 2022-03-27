//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '../interface/RegistryInterface.sol';
import '../interface/PairInterface.sol';
import '../interface/FactoryInterface.sol';
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import '../interface/EventsInterface.sol';


contract Router is ReentrancyGuard, Ownable, EventsInterface {

    RegistryInterface public registry;
    FactoryInterface public factory;
    using Address for address;

    function setRegistry(address _registry) external onlyOwner {
        require(_registry != address(0) && _registry.isContract(), "Invalid address or its not contract");
        registry = RegistryInterface(_registry);
        emit Registry(_registry, address(this));
    }

    function setFactory(address _factory) external onlyOwner {
        require(_factory != address(0) && _factory.isContract(), "Invalid address or its not contract");    
        factory = FactoryInterface(_factory);
        emit Factory(_factory, address(this));
    }

    function addLiquidity(
        address _token0,
        address _token1,
        uint256 _amount0,
        uint256 _amount1
    ) external nonReentrant {
        address pair = registry.getAddressOfPair(_token0,_token1);
        require(pair != address(0), "The pair doesn't exist");
        PairInterface(pair).addLiquidity( _token0, _token1, _amount0, _amount1, msg.sender);
        emit LiquidityRouter(msg.sender, _amount0, _amount1);
    }

    function _createPair(address _token0, address _token1)  private returns (address){
        return factory.createPair(_token0, _token1);
    }

    function removeLiquidity(uint256 _lpAmount, address _token0, address _token1, address recipient) external nonReentrant {
        require(_token0 != address(0) && _token1 != address(0), "Invalid address");
        require(recipient != address(0), "Invalid address");
        require(_token0.isContract() && _token1.isContract(), "its not contracts");
        address pair = registry.getAddressOfPair(_token0,_token1);
        PairInterface(pair).removeLiquidity(_lpAmount, _token0, _token1,  recipient);
        emit LiquidityRouterRemove(msg.sender, _lpAmount, _token0, _token1);
    }

    function swapIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _minAmountOut
    ) external nonReentrant  {
        require(_tokenIn != address(0) && _tokenOut != address(0), "Invalid address");
        require(_tokenIn.isContract() && _tokenOut.isContract(), "its not contracts");
        address pair = RegistryInterface(registry).getAddressOfPair(_tokenIn, _tokenOut);
        PairInterface(pair).swapIn(_tokenIn, _tokenOut, _amountIn, _minAmountOut, msg.sender);
        emit SwapedInRouter(_tokenIn, _tokenOut, _amountIn, _minAmountOut, msg.sender);
    }

    function swapOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        uint256 _maxAmountOut
    ) external nonReentrant  {
        require(_tokenIn != address(0) && _tokenOut != address(0), "Invalid address");
         require(_tokenIn.isContract() && _tokenOut.isContract(), "its not contracts");
        address pair = RegistryInterface(registry).getAddressOfPair(_tokenIn, _tokenOut);
        PairInterface(pair).swapOut(_tokenIn, _tokenOut, _amountOut, _maxAmountOut, msg.sender);
        emit SwapedOutRouter(_tokenIn, _tokenOut, _amountOut, _maxAmountOut, msg.sender);
    }

}