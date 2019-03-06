----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/04/2019 07:28:51 PM
-- Design Name:
-- Module Name: SPL_slave - Behavioral
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

entity SPI_slave_reciever is
generic(

    data_l : integer := 16

    );
port(

    sck     :   in  std_logic := '0';

    ss      :   in  std_logic := '1';

    mosi    :   in  std_logic;

    data    :   out std_logic_vector(data_l-1 downto 0) := x"0000";

    busy    :   out std_logic := '0';

    ready   :   out std_logic := '1'

    );
end SPI_slave_reciever;

architecture Behavioral of SPI_slave_reciever is

    signal data_temp    :   std_logic_vector (data_l-1 downto 0) := x"0000";

    signal index        :   integer := data_l-1;

    begin

        process(sck)

        variable b_index : integer;

        begin
        
            if (falling_edge(sck)) then

                b_index := index;

                if (ss = '0') and (b_index >= 1) then

                    data_temp(index) <= mosi;

                    index <= index - 1;

                    busy <= '1';

                    ready <= '0';


                elsif (b_index = 0) then

                    data <= data_temp(15 downto 1) & mosi;

                    data_temp <= (others => '0');

                    index <= data_l - 1;

                    busy <= '0';

                    ready <= '1';

                else

                end if;

            end if;

        end process;

    end Behavioral;
