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


entity SPI_slave_trns is
    generic(

    data_l  :   integer := 16

    );
    port(

    sck     :   in  std_logic := '0';

    ss      :   in  std_logic := '1';

    data    :   in  std_logic_vector(data_l-1 downto 0) := x"0000";

    miso    :   out std_logic := '0';

    busy    :   out std_logic := '0'
    );
end SPI_slave_trns;

architecture Behavioral of SPI_slave_trns is

    signal index        :   integer := (data_l-1);

    begin

        process(sck)

        variable b_index : integer;

        variable data_shift : std_logic_vector(data_l-1 downto 0);

        begin

            if (rising_edge(sck)) then

                b_index := index;

                if (b_index = data_l-1) then

                    data_shift := data; -- buffer!!

                end if;

                    if (ss = '0') and (b_index >= 1) then

                        miso <= data_shift(index);

                        busy <= '1';

                        index <= index - 1;

                    elsif (b_index = 0) then

                        miso <= data_shift(index);

                        busy <= '0';

                        index <= data_l-1;


                    else

                        index <= data_l-1;

                        busy <= '0';

                    end if;

            end if;

        end process;

    end Behavioral;
