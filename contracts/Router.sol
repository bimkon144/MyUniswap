//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '../interface/RegistryInterface.sol';
import '../interface/PairInterface.sol';
import '../interface/FactoryInterface.sol';
import "hardhat/console.sol";


contract Router is ReentrancyGuard, Ownable {
    // uint256 public swapFee;
    // uint256 public protocolPerformanceFee;
    // address public protocolPerformanceFeeRecipient;
    // uint256 public feeDecimals;
    address public registry;
    address public factory;

    function setRegistry(address _registry) external onlyOwner {
        registry = _registry;
    }

    function setFactory(address _factory) external onlyOwner {
        factory = _factory;
    }

    function addLiquidity(
        address _token0,
        address _token1,
        uint256 _amount0,
        uint256 _amount1
    ) external nonReentrant {
        if ( RegistryInterface(registry).getAddressOfPair(_token0,_token1) == address(0)) {
            FactoryInterface(factory).createPair(_token0, _token1);
        }
        address pair = RegistryInterface(registry).getAddressOfPair(_token0,_token1);
        PairInterface(pair).addLiquidity( _token0, _token1, _amount0, _amount1, msg.sender);
    }

    function removeLiquidity(uint256 _lpAmount, address _token0, address _token1, address recipient) external nonReentrant {
        address pair = RegistryInterface(registry).getAddressOfPair(_token0,_token1);
        PairInterface(pair).removeLiquidity(_lpAmount, _token0, _token1,  recipient);
    }

    function swapIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _minAmountOut
    ) external nonReentrant  {
        address pair = RegistryInterface(registry).getAddressOfPair(_tokenIn, _tokenOut);
        PairInterface(pair).swapIn(_tokenIn, _tokenOut, _amountIn, _minAmountOut, msg.sender);
    }

    function swapOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountOut,
        uint256 _maxAmountOut
    ) external nonReentrant  {
        address pair = RegistryInterface(registry).getAddressOfPair(_tokenIn, _tokenOut);
        PairInterface(pair).swapOut(_tokenIn, _tokenOut, _amountOut, _maxAmountOut, msg.sender);
    }

}