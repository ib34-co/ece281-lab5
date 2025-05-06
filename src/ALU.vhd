----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
--any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port (
           i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
signal f_result : STD_LOGIC_VECTOR (7 downto 0);
signal f_flags : STD_LOGIC_VECTOR (3 downto 0);
signal r_c: unsigned (8 downto 0);
begin
ALU_result : process(i_A,i_B, i_op)
begin
if i_op="000" then
f_result <= std_logic_vector(signed(i_A) + signed(i_B));
r_c <= resize(unsigned(i_A), 9) + resize(unsigned(i_B), 9);
f_flags(2)<=r_c(8);
end if;
if i_op="001" then
f_result <= std_logic_vector(signed(i_A) - signed(i_B));
r_c <= resize(unsigned(i_A), 9) + resize(unsigned(i_B), 9);
f_flags(2)<=r_c(8);
end if;
if i_op="010" then
f_result <= std_logic_vector(signed(i_A) and signed(i_B));
end if;
if i_op="011" then
f_result <= std_logic_vector(signed(i_A) or signed(i_B));
end if;
if f_result(7)='1' then
f_flags(0)<='1';
end if;
if f_result="000000000" then
f_flags(1)<='1';
end if;
if i_op(1)='0' and ((f_result(7)='1' and i_A(7)='0' and i_B(7)='0') or (f_result(7)='0' and i_A(7)='1' and i_B(7)='1')) then
f_flags(3)<='1';
end if;
end process ALU_result;
o_result<=f_result;
o_flags<=f_flags;
end Behavioral;
