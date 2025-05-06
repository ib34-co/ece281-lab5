----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
signal f_cycle :STD_LOGIC_VECTOR (3 downto 0);
begin
Controller_proc : process(i_adv, i_reset)
begin
if i_reset = '1' then
f_cycle <= "0000";
end if;
if i_adv='1' and f_cycle="0000" then
f_cycle <= "0001";
end if;
if i_adv='1' and f_cycle="0001" then
f_cycle <= "0010";
end if;
if i_adv='1' and f_cycle="0010" then
f_cycle <= "0011";
end if;
if i_adv='1' and f_cycle="0011" then
f_cycle <= "0000";
end if;
o_cycle<=f_cycle;
end process Controller_proc;


end FSM;
