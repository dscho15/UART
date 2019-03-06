----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/06/2019 08:29:32 AM
-- Design Name:
-- Module Name: SPI_checksum - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity SPI_checksum is
generic(

    data_l  :   integer := 16

    );
port(

    clk     :   in  std_logic;

    data    :   in  std_logic_vector(data_l-1 downto 0);

    ready   :   in  std_logic;

    busy    :   out std_logic;

    correct :   out std_logic

);
end SPI_checksum;

architecture Behavioral of SPI_checksum is

    begin

    process(clk)

    variable b_index : integer range 0 to data_l-1;

    begin

    


    end process

end Behavioral;
