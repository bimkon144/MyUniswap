//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface PairInterface {
    function setRouter(address _router) external;
    // function addLiquidity(address token0, address token1, uint256 amount0, uint256 amount1) external;
    function swapIn(address tokenIn,address tokenOut, uint256 amountIn, uint256 minAmountOut, address recipient) external returns (uint256 amountOut);
    function swapOut(address tokenIn,address tokenOut, uint256 amountOut,uint256 maxAmountIn, address recipient) external returns (uint256 amountIn);
    function initialize(address _token0, address _token1) external;
    function addLiquidity (address _token0, address _token1, uint _count0, uint _count1, address recipient) external returns (uint256 liquidity);
    function removeLiquidity(uint256 _amount, address _token0, address _token1,address recipient)  external  returns (uint256, uint256);
    function getReserveToken0() external view returns (uint256);
    function getReserveToken1() external view returns (uint256);
    // function getToken1Amount(uint256 _token0Sold) external view returns (uint256);
    // function getToken0Amount(uint256 _token1Sold) external view returns (uint256);
    // function token0ToToken1Swap(uint256 _token0Sold) external;
    // function token1ToToken0Swap(uint256 _token1Sold) external;
}