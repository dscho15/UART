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

    type enable_spi is (ENB, DIS, WAITING);

    signal state        :   enable_spi := ENB;
    signal index        :   integer := (data_l-1);

    begin

    process(sck, ss)

    variable b_index    : integer;
    variable data_shift : std_logic_vector(data_l-1 downto 0);

    begin

        case( state ) is

            when ENB =>
            if (ss = '0') then
                data_shift := data;
                miso <= data_shift(index);
                index <= index - 1;
                busy <= '1';
                state <= DIS;
            else
                index <= data_l-1;
                state <= ENB;
            end if;

            when DIS =>
            if (ss = '0') then
                if(falling_edge(sck)) then
                    b_index := index;
                    if (b_index >= 1) then
                        miso <= data_shift(index);
                        index <= index - 1;
                        state <= DIS;
                    elsif (b_index = 0) then
                        miso <= data_shift(index);
                        index <= data_l-1;
                        state <= WAITING;
                    else
                        miso <= '0';
                        state <= WAITING;
                    end if;
                end if;
            else
                miso <= '0';
                state <= WAITING;
            end if;

            when WAITING =>
            if(ss = '1') then
                busy <= '0';
                state <= ENB;
            end if;

        end case;

        end process;
    end Behavioral;
